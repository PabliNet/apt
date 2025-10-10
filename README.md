# APT WRAPPER

This repository provides two wrappers for the Debian `apt` command:
- A Python version (`apt_trixie.py`)
- A POSIX shell version (`apt_trixie.sh`)

Both wrappers automatically determine when to use `sudo` and redirect `search` commands to `aptitude` or `apt-cache` if available.

## Install from GitHub

Clone the repository:
```sh
git clone https://github.com/PabliNet/apt
```

Change into the `apt` directory:
```sh
cd apt
```

Run the installer:
```sh
./install-sh
```
You can also specify the version directly with `--python` or `--sh-posix`.

## Customizing the search command

By default, the wrapper uses apt for search operations.  
You can change this behavior by setting the environment variable `APT_SEARCH` to another command, such as aptitude or apt-cache.

```sh
export APT_SEARCH=/usr/bin/aptitude
```

This variable can also be set permanently in your shell configuration file (e.g. ~/.bashrc or ~/.profile).

### Allowing custom binary paths

Normally, the wrapper forces all binaries to be located inside `/usr/bin` for safety reasons.
If you want to allow fully custom paths (e.g. `/usr/local/bin/aptitude` or a script in your `$HOME`), you must also define the variable `APT_SEARCH_CUSTOM` (its value is irrelevant — only its presence matters):

```sh
export APT_SEARCH_CUSTOM=1
export APT_SEARCH=$HOME/bin/my-custom-search
```

When `APT_SEARCH_CUSTOM` is set, the wrapper does not prepend `/usr/bin/` and instead uses exactly the path (or command name) defined in APT_SEARCH.

----

## Granting `sudo` privileges to a user in Debian

If your user does not have `sudo` privileges, follow these steps:
1. Switch to the root user:
```sh
su -
```
2. Add the user to the sudo group  
Replace **\<username\>** with your actual username:
```sh
usermod -aG sudo <username>
```
3. Verify that the user was added to the group
```sh
groups <username>
```
4. Log out and log back in  
The new permissions take effect only after logging out and back in.
5. Run any command with sudo:
```sh
sudo whoami
```
If it returns root, everything is set up correctly.
