#### Don't ignore the logs! XDEB will notify you about package conflicts
#### The code pushed to master might not fully work. Please use releases instead

# XDEB
Simple utility to convert deb(ian) packages to xbps packages. Written in posix compliant shell.

## Contents
 - [Usage](#Usage)
   - [Installation](#Installation)
   - [Converting your package](#Converting-your-package)
     - [Which flags to use?](#Flags)
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
If you like to install xdeb, copy the script to `/usr/local/bin/`.
In addition to copying the script, a couple of dependencies are needed:<br>
Install them using `xbps-install binutils tar curl xbps`.

Unless you set `XDEB_PKGROOT` yourself (ie. `${HOME}/.config/xdeb`), the script will operate in the current directory.
The resulting binary will be exported to `${XDEB_PKGROOT}/binpkgs`. (`./binpkgs` by default)

### Converting your package
1. Download the latest release
2. Make the xdeb script executable (`chmod 0744 xdeb`)
3. Convert the package (`./xdeb -Sde <name>_<version>_<arch>.deb`)
4. Install the package (`xbps-install -R binpkgs <name>`)

#### Flags
You should generally run xdeb with `-Sde`, which stands for "Sync dependency file, enable dependencies, remove empty directories".
Alternatively, use your shells rc, to always run xdeb with the suggested options.
```
export XDEB_OPT_DEPS=true
export XDEB_OPT_SYNC=true
export XDEB_OPT_WARN_CONFLICT=true
export XDEB_OPT_FIX_CONFLICT=true
```

#### Automatic Dependencies
xdeb can now resolve the runtime dependencies.<br>
This allows reliable conversion for nearly all deb packages.

#### Multilib
The `-m` flag adds the `-32bit` suffix to the package and all it's dependencies.
The example shows how to convert a `32bit` package.
```sh
./xdeb -Sedm --arch=x86_64 ~/Downloads/Simplenote-linux-1.16.0-beta1-i386.deb
```
Installing the newly converted package requires the multilib repositories to be installed.
Note, that `/lib` will not be converted to `/lib32`

#### File Conflicts
By default, xdeb will show a warning if a file is already present on the system (And not a directory).
This behavior ensures that the converting package won't break the system.<br>
If xdeb complains about conflicting files,
manually removing them from the destdir directory and rebuilding with `-rb` might help.<br>
Having a package already installed (For example when updating it) will output a lot of conflicts.
To counteract this, xdeb has the `-i` flag, which silences file conflicts.

### Help Page
```sh
usage: xdeb [-S] [-d] [-Sd] [--deps] ... FILE
  -d                         # Automatic dependencies
  -S                         # Sync runtime dependency file
  -c                         # Clean everything except shlibs and binpkgs
  -r                         # Clean repodata (Use when rebuilding a package)
  -q                         # Don't build the package at all
  -C                         # Clean all files
  -b                         # No extract, just build files in destdir
  -e                         # Remove empty directories
  -m                         # Add the -32bit suffix
  -i                         # Ignore file conflicts
  -f                         # Attempt to automatically fix common conflicts
  --deps=...                 # Add manual dependencies
  --arch=...                 # Add an arch for the package to run on
  --revision=... | --rev=... # Set package revision. Alternative to -r
  --help | -h                # Show this page

example:
  xdeb -Cq                   # Remove all files and quit
  xdeb -Sd FILE              # Sync depdendency list and create package
  xdeb --deps='ar>0' FILE    # Add ar as a manual dependency and create package
```

#### Using Manual dependencies
Converting `Minecraft.deb`:
```sh
$ ./xdeb -Sedr --deps='oracle-jre>=8' ~/Downloads/Minecraft.deb
[+] Synced shlibs
[+] Extracted files
[+] Resolved dependencies (oracle-jre>=8 alsa-lib>=1.0.20_1 atk>=1.26.0_1
cairo>=1.8.6_1 dbus-libs>=1.2.10_1 expat>=2.0.0_1 fontconfig>=2.6.0_1
gdk-pixbuf>=2.22.0_1 glib>=2.18.0_1 glibc>=2.29_1 gtk+>=2.16.0_1 gtk+3>=3.0.0_1
libcups>=1.5.3_1 libgcc>=4.4.0_1 libstdc++>=4.4.0_1 libuuid>=2.18_1
libX11>=1.2_1 libxcb>=1.2_1 libXcomposite>=0.4.0_1 libXcursor>=1.1.9_1
libXdamage>=1.1.1_1 libXext>=1.0.5_1 libXfixes>=4.0.3_1 libXi>=1.2.1_1
libXrandr>=1.3.0_1 libXrender>=0.9.4_1 libXScrnSaver>=1.1.3_1 libXtst>=1.0.3_1
nspr>=4.8_1 nss>=3.12.4_1 pango>=1.24.0_1 zlib>=1.2.3_1)
index: added `minecraft-launcher-2.1.17627_1' (x86_64).
index: 1 packages registered.
[+] Done. Install using `xbps-install -R binpkgs minecraft-launcher-2.1.17627_1`

$ sudo xbps-install -R ./binpkgs minecraft-launcher-2.1.17417_1

Name               Action    Version           New version            Download size
GConf              install   -                 3.2.6_9                - 
minecraft-launcher install   -                 2.1.17417_1            - 

Size required on disk:         198MB
Space available on disk:       276GB

Do you want to continue? [Y/n] n
```
If the package just depends on a package with no specific version, add `>0` to match any version (i.e. `--deps='ar>0 base-system>0 curl>0'`)

## Explanation
### Reasons to use
- The VoidLinux-Team refuses to ship more chromium based browsers.
- Electron based applications, like [Simplenote](https://simplenote.com/)
- Proprietary applications like [Discord](https://discord.gg) or [Minecraft](https://minecraft.net).

Using one of the packages listed above on VoidLinux, requires having to build them yourself.<br>
This requires getting to know the build system, cloning the (~150MB) [void-packages](https://github.com/void-linux/void-packages) repository, etc.
This script handles everything automatically, without accessing the internet by default.

### Why deb packages?
The deb package format is undoubtedly the most commonly used format, since Debian is the most popular Linux distro.<br>
You can expect nearly every Linux application to provide a binary deb package.

### Features
* [x] Convert a package
* [x] Restore changes made by this script
* [x] Dependency resolving (`xdeb -Sd`)
* [x] Show conflicting files
* [ ] Remove bundled shlibs
* [ ] Exclude dependencies
