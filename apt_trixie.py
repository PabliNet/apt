#!/usr/bin/env python3
from pathlib import Path
from os import access, execv, environ, geteuid, X_OK
from os.path import exists
from sys import argv, exit

PATH = '/usr/bin/'
argv[0] = PATH + Path(argv[0]).stem.split('.')[0].split('_')[0]
if not environ.get('APT_SEARCH_CUSTOM'):
    apt_search = PATH + Path(environ.get("APT_SEARCH", argv[0])).stem
else:
    apt_search = environ.get("APT_SEARCH", argv[0])

WITH_SUDO = ['install', 'remove', 'purge', 'update', 'upgrade',
    'full-upgrade', 'dist-upgrade', 'autoremove', 'clean', 'autoclean',
    'download', 'hold', 'unhold', 'edit-sources',]

cmds = ['/usr/bin/aptitude', '/usr/bin/apt-cache', argv[0]]

if len(argv) > 1:
    for e in argv[1:]:
        if e == 'search' and exists(apt_search) and access(apt_search, X_OK):
            argv[0] = apt_search
            break
        elif geteuid() > 0 and e in WITH_SUDO:
            argv.insert(0, '/usr/bin/sudo')
            break
        elif e[0] != '-':
            break
else:
    argv.append('--help')

execv(argv[0], argv)
