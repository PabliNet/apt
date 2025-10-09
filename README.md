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

----

## Granting sudo privileges to a user in Debian

If your user does not have `sudo` privileges, follow these steps:
1. Switch to the root user:
```sh
su -
```
2. Add the user to the sudo group  
Replace \<username\> with your actual username:
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
