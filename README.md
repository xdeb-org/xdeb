#### Don't ignore the logs! XDEB will notify you about package conflicts
#### The code pushed to master might not fully work. Please use releases instead

# XDEB
Simple utility to convert deb(ian) packages to xbps packages. Written fully posix compliant.

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

#### Automatic Dependencies
xdeb can now resolve the runtime dependencies.<br>
This allows reliable conversion for nearly all deb packages.

#### Multilib
The `-m` flag adds the `-32bit` suffix to the package and all it's dependencies.
The example shows how to convert a `32bit` package.
```sh
./xdeb -Sedm --arch x86_64 ~/Downloads/Simplenote-linux-1.16.0-beta1-i386.deb
```
Installing the newly converted package requires the multilib repositories to be installed.

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
  -d                       # Automatic dependencies
  -S                       # Sync runtime dependency file
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
  --revision               # Set package revision. Alternative to -R, to not remove the repodata
  --help | -h              # Show this page

example:
  xdeb -Cq                 # Remove all files and quit
  xdeb -Sd FILE            # Sync depdendency list and create package
  xdeb --deps 'ar>0' FILE  # Add ar as a manual dependency and create package
```

#### Using Manual dependencies
Converting `Minecraft.deb`:
```sh
$ ./xdeb -Sedr --deps 'oracle-jre>=8' ~/Downloads/Minecraft.deb
[+] Extracted files
[-] Unable to find dependency for libcef.so
[-] Unable to find dependency for libGLdispatch.so.0
[+] Resolved dependencies (oracle-jre>=8 alsa-lib>=0 atk>=0 at-spi2-atk>=0 at-spi2-core>=0 avahi-libs>=0 avahi-libs>=0 libblkid>=0 bzip2>=0 cairo>=0 cairo>=0 glibc>=0 glibc>=0 libcups>=0 libdatrie>=0 dbus-libs>=0 glibc>=0 libEGL>=0 libepoxy>=0 expat>=0 libffi>=0 fontconfig>=0 freetype>=0 fribidi>=0 libgcc>=0 GConf>=0 gtk+3>=0 gdk-pixbuf>=0 gtk+>=0 glib>=0 glib>=0 libGL>=0 libglvnd>=0 glib>=0 gmp>=0 gnutls>=0 glib>=0 graphite>=0 gtk+3>=0 gtk+>=0 libharfbuzz>=0 nettle>=0 libidn2>=0 libmount>=0 glibc>=0 nettle>=0 nspr>=0 nss>=0 nss>=0 p11-kit>=0 pango>=0 pango>=0 pango>=0 libpcre>=0 pixman>=0 nspr>=0 nspr>=0 libpng>=0 glibc>=0 glibc>=0 glibc>=0 nss>=0 libstdc++>=0 libtasn1>=0 libthai>=0 libunistring>=0 libuuid>=0 wayland>=0 wayland>=0 wayland>=0 libX11>=0 libX11>=0 libXau>=0 libxcb>=0 libxcb>=0 libxcb>=0 libXcomposite>=0 libXcursor>=0 libXdamage>=0 libXdmcp>=0 libXext>=0 libXfixes>=0 libXinerama>=0 libXi>=0 libxkbcommon>=0 libXrandr>=0 libXrender>=0 libXScrnSaver>=0 libXtst>=0 zlib>=0 )
[+] 'Parsed' deb control file
[+] Created Package
index: skipping `minecraft-launcher-2.1.17417_1' (x86_64), already registered.
index: 5 packages registered.
[+] Done. Install using `xbps-install -R binpkgs minecraft-launcher-2.1.17417_1`

$ sudo xbps-install -R ./binpkgs minecraft-launcher-2.1.17417_1

Name               Action    Version           New version            Download size
GConf              install   -                 3.2.6_9                - 
minecraft-launcher install   -                 2.1.17417_1            - 

Size required on disk:         198MB
Space available on disk:       276GB

Do you want to continue? [Y/n] n
```
If the package just depends on a package with no specific version, add `>0` to match any version (i.e. `--deps 'ar>0 base-system>0 curl>0'`)

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
