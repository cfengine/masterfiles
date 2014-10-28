#!/bin/sh


ORIGDIR=`pwd`
srcdir=`dirname $0`
[ -n "$srcdir" ] && cd $srcdir

[ ! -d m4 ] && mkdir m4
autoreconf -Wno-portability --force --install -I m4  ||  exit $?

cd $ORIGDIR
if [ -z "$NO_CONFIGURE" ]
then
    $srcdir/configure --enable-maintainer-mode "$@"  ||  exit $?
fi

exit 0
