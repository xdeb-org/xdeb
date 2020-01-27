#!/bin/sh

XDEB_DESTDIR="destdir"
XDEB_DATADIR="data"
XDEB_BINPKGS="binpkgs"

if [ -z "$1" ]; then exit 1; fi

mkdir -p $XDEB_BINPKGS
rm -rf $XDEB_DATADIR; mkdir $XDEB_DATADIR
rm -rf $XDEB_DESTDIR; mkdir $XDEB_DESTDIR
rm -rf control.tar.gz
rm -rf data.tar.gz
rm -rf debian-binary

ar -xf "$1"
tar -xf control.tar.gz -C $XDEB_DATADIR
tar -xf data.tar.xz -C $XDEB_DESTDIR

pkgname=$(grep -Po "Package:[ \t]*\K.*" "$XDEB_DATADIR/control")
version=$(grep -Po "Version:[ \t]*\K.*" "$XDEB_DATADIR/control")
license=$(grep -Po "License:[ \t]*\K.*" "$XDEB_DATADIR/control")
archs=$(grep -Po "Architecture:[ \t]*\K.*" "$XDEB_DATADIR/control")
maintainer=$(grep -Po "Maintainer:[ \t]*\K.*" "$XDEB_DATADIR/control")
short_desc=$(grep -Po "Description:[ \t]*\K.*" "$XDEB_DATADIR/control")
long_desc=$(grep -Pzo "Description:[ \t\n]*\K.*" "$XDEB_DATADIR/control")

if [ -z "$short_desc" ]; then short_desc=$long_desc; fi

version=$(echo "$version" | grep -Po "^(\d|\.)*")
case "$archs" in
	amd64) archs="x86_64"
esac

xbps-create -A "$archs" -n "$pkgname-${version}_1" -m "$maintainer" -s "$short_desc" -l "$license" "$XDEB_DESTDIR"
mv "$pkgname-${version}_1.$archs.xbps" "$XDEB_BINPKGS"
xbps-rindex -a $XDEB_BINPKGS/*.xbps
