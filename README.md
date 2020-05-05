#### Don't ignore the logs! XDEB will notify you about package conflicts
#### The code pushed to master might not fully work. Please use releases instead

# XDEB

Simple utility to convert deb(ian) packages to xbps packages. Written in posix compliant shell.

## Contents
 - [Usage](#Usage)
   - [Installation](#Installation)
   - [Converting your package](#Converting%20your%20package)
     - [Automatic Dependencies](#Automatic%20Dependencies)
   - [Help Page](#Help%20Page)
     - [Using Manual dependencies](#Using%20Manual%20dependencies)
 - [Explanation](#Explanation)
   - [Reasons to use](#Reasons%20to%20use)
   - [Why DEB packages?](#Why%20DEB%20packages%3F)
   - [Features](#Features)

## Usage

### Installation
There is no need to install this script, because it is not meant to be installed.\
However if you like to install it, copy it to `/usr/local/bin/`.

### Converting your package
1. Download the latest release
2. Make the xdeb script executable (`chmod 0744 xdeb`)
3. Convert the package (`./xdeb -Sde <name>_<version>_<arch>.deb`)
4. Install the package (`xbps-install -R binpkgs <name>`)

#### Automatic Dependencies
xdeb can now resolve the runtime dependencies.\
This allows reliably conversion for nearly all deb packages.

### Help Page
```sh
usage: xdeb [-S] [-d] [-Sd] [--deps] ... FILE
  -d                       # Automatic dependencies
  -S                       # Sync runtime dependency file
  -h                       # Show this page
  -c                       # Clean everything except shlibs and binpkgs
  -r                       # Clean repodata (Use when rebuilding a package)
  -q                       # Don't build the package at all
  -C                       # Clean all files
  -b                       # No extract, just build files in destdir
  -e                       # Remove empty directories
  --deps                   # Add manual dependencies
  --arch                   # Add an arch for the package to run on

example:
  xdeb -Cq                 # Remove all files and quit
  xdeb -Sd FILE            # Sync depdendency list and create package
  xdeb --deps 'ar>0' FILE  # Add ar as a manual dependency and create package

```

#### Using Manual dependencies
Converting `Minecraft.deb`:
```sh
$ ./xdeb --deps 'oracle-jre>8' Minecraft.deb
# [+] Extracted files
# ./xdeb: line 182: warning: command substitution: ignored null byte in input
# [+] Resolved dependencies (oracle-jre>8)
# [+] 'Parsed' deb control file
# [+] Created Package
# index: added `minecraft-launcher-2.1.11314_1' (x86_64).
# index: 1 packages registered.
# [+] Registered package
$ sudo xbps-install -R binpkgs minecraft-launcher
# Name               Action    Version           New version            Download size
# wget               install   -                 1.20.3_2               - 
# oracle-jre         install   -                 8u202_1                82KB 
# minecraft-launcher install   -                 2.1.11314_1            - 
# 
# Size to download:               83KB
# Size required on disk:         177MB
# Space available on disk:       416GB
# 
# Do you want to continue? [Y/n] n
# Aborting!
```
If the package just depends on a package with no specific version, you have to add `>0` to match any version (i.e. `--deps 'ar>0 base-system>0 curl>0'`)

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
