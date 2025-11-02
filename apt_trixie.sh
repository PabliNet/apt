#!/bin/sh
PATH=/usr/bin/
cmd=$(basename "$0")
cmd=${cmd%%.*}
cmd=${cmd%%_*}

case "$cmd" in
    apt)
        WITH_SUDO="install remove purge update upgrade full-upgrade dist-upgrade autoremove clean autoclean edit-sources"
        search="APT_SEARCH"
    ;;
    apt-get)
        WITH_SUDO="install remove purge update upgrade full-upgrade dist-upgrade autoremove clean autoclean dselect-upgrade"
    ;;
    aptitude)
        WITH_SUDO="install remove purge update upgrade full-upgrade dist-upgrade autoremove clean autoclean safe-upgrade hold unhold"
        search="APTITUDE_SEARCH"
    ;;
esac

new_argv0="$PATH$cmd"

if [ -n "$search" ]; then
    eval "search_value=\$$search"
    if [ -z "$search_value" ]; then
        apt_search="$PATH$cmd"
    else
        apt_search_base=$(basename "$search_value")
        apt_search_base=${apt_search_base%%.*}
        apt_search_base=${apt_search_base%%_*}
        case "$search_value" in
            /usr/bin/*) apt_search="$search_value" ;;
            *) apt_search="$PATH$apt_search_base" ;;
        esac
    fi
else
    apt_search="$new_argv0"
fi

needs_sudo=0
use_search=0

if [ $# -gt 0 ]; then
    for arg in "$@"; do
        case "$arg" in
            search)
                [ -x "$apt_search" ] && use_search=1
                break
            ;;
            -*) continue ;;
            *)
                for sudo_cmd in $WITH_SUDO; do
                    if [ "$arg" = "$sudo_cmd" ] && [ "$(id -u)" -gt 0 ]; then
                        needs_sudo=1
                        break 2
                    fi
                done
                break
            ;;
        esac
    done
else
    set -- --help
fi

if [ "$use_search" -eq 1 ]; then
    exec "$apt_search" "$@"
elif [ "$needs_sudo" -eq 1 ]; then
    exec /usr/bin/sudo "$new_argv0" "$@"
else
    exec "$new_argv0" "$@"
fi
