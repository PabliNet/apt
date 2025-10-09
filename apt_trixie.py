#!/usr/bin/env python3
from pathlib import Path
from os import access, execv, geteuid, X_OK
from os.path import exists
from sys import argv, exit

argv[0] = '/usr/bin/' + Path(argv[0]).stem[:3]

WITH_SUDO = [
    'install','remove', 'purge', 'update', 'upgrade', 'full-upgrade',
    'dist-upgrade', 'autoremove', 'clean', 'autoclean', 'download', 'hold',
    'unhold', 'edit-sources',
]

cmds = ['/usr/bin/aptitude', '/usr/bin/apt-cache', argv[0]]

if len(argv) > 1:
    for e in argv[1:]:
        if e == 'search':
            for cmd in cmds:
                if exists(cmd) and access(cmd, X_OK):
                    argv[0] = cmd
                    break
            break
        elif geteuid() > 0 and e in WITH_SUDO:
            argv.insert(0, '/usr/bin/sudo')
            break
        elif e[0] != '-':
            break
else:
    argv.append('--help')

execv(argv[0], argv)
