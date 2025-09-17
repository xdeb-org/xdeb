### Caution: Ignoring bold red error messages can mess up your system. This is the result of a missing error check in xbps. Do not blame the script for this.

# xdeb
xdeb is a posix shell script for converting deb(ian) packages to the xbps format.

## Usage

### Converting packages
Conversion will create files in your current working directory. Refer to [the installation instruction](#Installation) for more information.

1. Install dependencies: `xbps-install binutils tar curl xbps xz gettext yad`
2. Download xdeb: `curl -LO github.com/xdeb-org/xdeb/releases/latest/download/xdeb`
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
export XDEB_OPT_INSTALL=true
export XDEB_OPT_FIX_CONFLICT=true
export XDEB_OPT_WARN_CONFLICT=true
```

More information:
```sh
usage: xdeb [-S] [-d] [-Sd] [--deps] ... FILE
  -d                          Automatic dependency resolution
  -S                          Download shlibs file for automatic dependencies
  -c                          Like -C, excluding shlibs and binpkgs
  -r                          Remove repodata file (Use for re-building)
  -R                          Do not register package in repository pool.
  -q                          Extract .deb into destdir only, do not build
  -C                          Remove all files created by this script
  -b                          Build from destdir directly without a .deb file
  -e                          Remove empty directories from the package
  -m                          Add the -32bit suffix to the package name
  -i                          Don't warn if package could break the system
  -f                          Try to fix certain file conflicts (deprecated)
  -F                          Don't try to fix certain file conflicts
  -I                          Automatically install the package
  --deps=...                  Packages that shall be added as dependencies
  --not-deps=...              Packages that shall not be used as dependencies
  --arch=...                  Package arch
  --name=...                  Package name
  --version=...               Package version
  --revision=... --rev=...    Package revision
  --post-extract=...          File with post-extract commands (i.e. /dev/stdin)
  --help | -h                 Show help page

example:
  xdeb -Cq                    Remove all files and quit
  xdeb -Sd FILE               Sync depdendency list and create package
  xdeb --deps='tar>0' FILE    Add tar as manual dependency and create package
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

#### Using manual dependencies
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


#### Ignoring dependencies

When converting packages for electron based appliciations, `xdeb` may
mistakenly add `musl` as a dependency. This can be resolved by using the
`--not-deps` flag to blacklist certain dependencies:

```
$ ./xdeb -Sedf --not-deps="musl" ~/Downloads/gitkraken-amd64.deb
I Synced shlibs
I Extracted files
W Unable to find dependency for libcrypto.so.1.0.0
W Unable to find dependency for libcrypto.so.1.1
W Unable to find dependency for libcrypto.so.10
W Unable to find dependency for libssl.so.1.0.0
W Unable to find dependency for libssl.so.1.1
W Unable to find dependency for libssl.so.10
I Resolved dependencies (alsa-lib>=1.0.20_1 at-spi2-atk>=2.6.0_1 at-spi2-core>=1.91.91_1 atk>=1.26.0_1 cairo>=1.8.6_1 dbus-libs>=1.2.10_1 e2fsprogs-libs>=1.41.5_1 expat>=2.0.0_1 glib>=2.80.0_1 glibc>=2.39_1 gtk+3>=3.0.0_1 libX11>=1.2_1 libXcomposite>=0.4.0_1 libXdamage>=1.1.1_1 libXext>=1.0.5_1 libXfixes>=4.0.3_1 libXrandr>=1.3.0_1 libcups>=1.5.3_1 libcurl>=7.75.0_2 libdrm>=2.4.6_1 libgbm>=9.0_1 libgcc>=4.4.0_1 libstdc++>=4.4.0_1 libxcb>=1.2_1 libxkbcommon>=0.2.0_1 libxkbfile>=1.0.5_1 mit-krb5-libs>=1.8_1 nspr>=4.8_1 nss>=3.12.4_1 pango>=1.24.0_1 zlib>=1.2.3_1)
index: skipping `gitkraken-9.13.0_1' (x86_64), already registered.
index: 1 packages registered.
I Install using `xbps-install -R ./binpkgs gitkraken-9.13.0_1`
```

## Rationale

- The VoidLinux-Team refuses to ship more chromium based browsers.
- Electron based applications, like [Simplenote](https://simplenote.com/)
- Proprietary applications like [Discord](https://discord.gg) or [Minecraft](https://minecraft.net).

Manually building packages is bothersome and would require learning the build system, cloning the (~150MB) [void-packages](https://github.com/void-linux/void-packages) repository, etc.<br>
This script handles everything automatically and without even accessing the internet by default.
