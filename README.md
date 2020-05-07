#### Don't ignore the logs! XDEB will notify you about package conflicts
#### The code pushed to master might not fully work. Please use releases instead

# XDEB

Simple utility to convert deb(ian) packages to xbps packages. Written in posix compliant shell.

## Contents
 - [Usage](#Usage)
   - [Installation](#Installation)
   - [Converting your package](#Converting-your-package)
     - [Automatic Dependencies](#Automatic-Dependencies)
     - [Converting i386 package](#Multilib)
					- [File Conflicts](#File-Conflicts)
   - [Help Page](#Help-Page)
     - [Using Manual dependencies](#Using-Manual-dependencies)
 - [Explanation](#Explanation)
   - [Reasons to use](#Reasons-to-use)
   - [Why DEB packages?](#Why-DEB-packages%3F)
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

#### Multilib
The `-m` flag adds the `-32bit` suffix to the package and all dependencies.
You need to enable the multilib repositories first.\
The example shows how to convert a `32bit` package.
```sh
./xdeb -Sedm --arch x86_64 ~/Downloads/Simplenote-linux-1.16.0-beta1-i386.deb
```

#### File Conflicts
By default, xdeb will show a warning if a file is already present on your system (And not a directory).
This behavior ensures that the converting package won't break the system.\
If xdeb complains about conflicting files,
manually removing them from the destdir directory and rebuilding with `-rb` might help.\
Having a package already installed (For example when updating it) will output a lot of conflicts.
To counteract this, xdeb has the `-i` flag, which silences file conflicts.

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
  -m                       # Add the -32bit suffix
  -i                       # Ignore file conflicts
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
