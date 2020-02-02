# XDEB
Simple utility to convert deb(ian) packages to xbps packages. Written in posix compliant shell.

## Contents
 - [Usage](#Usage)
   - [Installation](#Installation)
   - [Converting your package](#Converting%20your%20package)
     - [Manually](#Manually)
     - [With commands](#With%20commands)
   - [Help Page](#Help%20Page)
 - [Explanation](#Explanation)
   - [Reasons to use](#Reasons%20to%20use)
   - [Why DEB packages?](#Why%20DEB%20packages%3F)
   - [Features](#Features)

## Usage

### Installation
There is no need to install this script, because it is not meant to be installed.\
However if you like to install it, copy it to `/usr/local/bin/`.

### Converting your package
#### Manually
1. Clone this repository into any directory you like.
2. Create a new directory (Your working directory will be altered) (for example `$HOME/.xdeb`).
3. Open a terminal in the newly created directory
4. Convert your package using  `./xdeb <path>/<name>-<version>-<arch>.deb`

To get help on converting a package, use `./xdeb -h`\
\
When building a package multiple times (for example if you forgot to add the `-d` flag),\
**You have to** supply the `-r` flag, or delete the repodata manually.\
\
Your package will be located at `binpkgs/<name>-<version>.<arch>.xbps`.\
Install the package using `sudo xbps-install -R binpkgs <name>`.

#### With commands
```sh
git clone https://github.com/toluschr/xdeb
cd xdeb
./xdeb <name>-<version>-<arch>.deb
sudo xbps-install -R binpkgs <name>
```

### Help Page
```sh
usage: xdeb [-S] [-d] [-Sd] ... FILE
  -d            # Automatic dependencies. Not advised for electron packages
  -S            # Sync runtime dependency file
  -h            # Show this page
  -c            # Clean everything except shlibs and binpkgs
  -r            # Clean repodata (Use when rebuilding a package)
  -q            # Don't build the package at all
  -C            # Clean all files
  -b            # No extract, just build files in destdir
  -e            # Remove empty directories

example:
  xdeb -Cq      # Remove all files and quit
  xdeb -Sd FILE # Sync depdendency list and create package
```

## Explanation
### Reasons to use
- The VoidLinux-Team refuses to ship more chromium based browsers.
- Electron based applications, like [Simplenote](https://simplenote.com/)
- Proprietary applications like [Discord](https://discord.gg) or [Minecraft](https://minecraft.net).

If you want to use these packages, you would have to build them yourself. This requires getting to know the build system, cloning the (~150MB) [void-packages](https://github.com/void-linux/void-packages) repository, etc.
This script handles everything for you, without accessing the internet by default.

### Why deb packages?
The deb package format is undoubtedly the most commonly used format, since Debian is the most popular Linux distro.\
You can expect nearly every Linux application to provide a binary deb package.

### Features
 - Convert a package
 - Restore changes made by this script
 - Dependency resolving (`xdeb -Sd`)
