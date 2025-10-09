#!/bin/sh
set -eu

script_name=${0##*/}; script_name=${script_name%%.*}; script_name=${script_name%%_*}
argv0="/usr/bin/$script_name"

WITH_SUDO="install remove purge update upgrade full-upgrade dist-upgrade autoremove clean autoclean download hold unhold edit-sources"
CMDS="/usr/bin/aptitude /usr/bin/apt-cache"

needs_sudo=0
search_cmd=""
use_search_cmd=0

if [ $# -gt 0 ]; then
    for arg in "$@"; do
        if [ "$arg" = "search" ]; then
            use_search_cmd=1
            for cmd in $CMDS "$argv0"; do
                if [ -x "$cmd" ]; then
                    search_cmd="$cmd"
                    break
                fi
            done
            break
        fi

        if [ "$(id -u)" -gt 0 ]; then
            case " $WITH_SUDO " in
                *" $arg "*) needs_sudo=1; break ;;
            esac
        fi

        case "$arg" in
            -*) ;;  # continuar
            *) break ;;
        esac
    done
else
    set -- --help
fi

if [ "$use_search_cmd" -eq 1 ]; then
    exec "$search_cmd" "$@"
elif [ "$needs_sudo" -eq 1 ]; then
    exec /usr/bin/sudo "$argv0" "$@"
else
    exec "$argv0" "$@"
fi
