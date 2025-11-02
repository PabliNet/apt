#!/usr/bin/env python3
from pathlib import Path
from os import access, execv, environ, geteuid, X_OK
from os.path import exists
from sys import argv, exit

PATH = '/usr/bin/'
cmd = Path(argv[0].split('_')[0]).stem
WITH_SUDO = ['install', 'remove', 'purge', 'update', 'upgrade',
    'full-upgrade', 'dist-upgrade', 'autoremove', 'clean', 'autoclean' ]

if cmd == 'aptitude':
    WITH_SUDO.extend(['safe-upgrade', 'hold', 'unhold'])
    search = 'APTITUDE_SEARCH'
elif cmd == 'apt-get':
    WITH_SUDO.append('dselect-upgrade')
    search = ''
elif cmd == 'apt':
    WITH_SUDO.append('edit-sources')
    search = 'APT_SEARCH'

argv[0] = PATH + Path(argv[0]).stem.split('.')[0].split('_')[0]

if not environ.get(search):
    apt_search = PATH + Path(environ.get(search, argv[0])).stem
else:
    apt_search = environ.get(search, argv[0])
    apt_search = apt_search if apt_search[:9] == PATH else PATH + apt_search

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
