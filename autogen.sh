#!/bin/sh


ORIGDIR=`pwd`
srcdir=`dirname $0`
[ -n "$srcdir" ] && cd $srcdir

[ ! -d m4 ] && mkdir m4
autoreconf -Wno-portability --force --install -I m4  ||  exit $?

cd $ORIGDIR
[ -z "$NO_CONFIGURE" ] && $srcdir/configure --enable-maintainer-mode "$@"
