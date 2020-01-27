# XDEB
Simple utility to convert deb(ian) packages to xbps packages. Written in posix compliant shell.

## Usage
First of all, clone this repository into any directory you like.
Copy the debian package you want to convert into the same directory and open a terminal in the directory.
Convert the package with `./convert.sh EXAMPLE.deb`. The rest is handled by the script.
Install the newly created package with `# xbps-install -R binpkgs EXAMPLE`.

**The script will remove files from your current working directory**.
It is advised to execute it in the folder you cloned the repository to.

## Features
 - The bare minimum to convert a package
