#### Ignoring the logs might break your system. Please use releases.

# xdeb
xdeb is a posix shell script for converting deb(ian) packages to the xbps format.

## Usage

### Converting packages
Conversion will create files in your current working directory. Refer to [the installation instruction](#Installation) for more information.

1. Download xdeb: `curl -LO github.com/xdeb-org/xdeb/releases/latest/download/xdeb`
2. Install dependencies: `xbps-install binutils tar curl xbps xz`
3. Set executable bit: `chmod 0744 xdeb`
4. Convert: `./xdeb -Sedf <name>_<version>_<arch>.deb`
5. Install: `xbps-install -R ./binpkgs <name>`

### Installation
Copy the script to `/usr/local/bin/`and set `XDEB_PKGROOT=${HOME}/.config/xdeb` to avoid cluttering your current working directory.
Binaries will then be exported to `${XDEB_PKGROOT-.}/binpkgs`.

### Flags
In short: Just use `-Sedf` (Sync dependency list, remove empty directories, enable dependency resolution, resolve conflicts = don't break system)

Options can also be set via environment variables:
```
export XDEB_OPT_DEPS=true
export XDEB_OPT_SYNC=true
export XDEB_OPT_WARN_CONFLICT=true
export XDEB_OPT_FIX_CONFLICT=true
```

More information:
```sh
usage: xdeb [-S] [-d] [-Sd] [--deps] ... FILE
  -d                         # Automatic dependencies
  -S                         # Sync runtime dependency file
  -c                         # Clean everything except shlibs and binpkgs
  -r                         # Clean repodata (Use when rebuilding a package)
  -q                         # Extract files, quit before building
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
  xdeb --deps='tar>0' FILE   # Add tar as manual dependency and create package
```

#### Automatic Dependencies
Using the automatic dependency feature allows reliable conversion of nearly all deb packages.

Use `-Sd` to sync [the dependency list](https://raw.githubusercontent.com/void-linux/void-packages/master/common/shlibs) and build with dependency resolution enabled.
Subsequent runs do not require `-S` and xdeb will not require internet. Just make sure to sync it once in a while.

#### Multilib
The `-m` (multilib) flag adds the suffix `-32bit` to the package and dependencies.
Example with host arch `x86_64`:
```sh
./xdeb -Sedfm --arch=x86_64 ~/Downloads/Simplenote-linux-1.16.0-beta1-i386.deb
```
**`/lib` will not be rewritten to `/lib32`**

#### File Conflicts
Due to a missing check, the xbps package manager might break the system if a package contains a file that is already present on the system.
As a workaround, xdeb shows warnings for conflicting files, **do not ignore them**.
**This only works when installing packages on the same machine they were converted on!**

Updating a package may show lots of unnecessary warnings. Disable using `-i` (s**i**lence).

##### Resolving conflicts
Conflicts can either be resolved automatically (`-f`) or manually.

1. Build package: `xdeb ...`
2. Observe warnings
3. Fix files (Example: remove): `rm -rf ${XDEB_PKGROOT-.}/destdir/usr/lib`
4. Build package without conflicts: `./xdeb -rb`

#### Using Manual dependencies
Converting `Minecraft.deb` with manual dependency `oracle-jre` (Version 8 or later):
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
Add `>0` to match any version (i.e. `--deps='tar>0 base-system>0 curl>0'`)

## Rationale

- The VoidLinux-Team refuses to ship more chromium based browsers.
- Electron based applications, like [Simplenote](https://simplenote.com/)
- Proprietary applications like [Discord](https://discord.gg) or [Minecraft](https://minecraft.net).

Manually building packages is bothersome and would require learning the build system, cloning the (~150MB) [void-packages](https://github.com/void-linux/void-packages) repository, etc.<br>
This script handles everything automatically and without even accessing the internet by default.
