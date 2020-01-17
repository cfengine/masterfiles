#!/bin/sh


ORIGDIR=`pwd`

srcdir=`dirname $0`
[ -n "$srcdir" ] && cd $srcdir

echo "$0: Running determine-version.sh ..."
rm -f CFVERSION
misc/determine-version.sh .CFVERSION > CFVERSION \
    || echo "$0: Unable to auto-detect CFEngine version, continuing"

echo "$0: Running autoreconf ..."
[ ! -d m4 ] && mkdir m4
autoreconf -Wno-portability --force --install -I m4  ||  exit $?

cd -               # back to original directory

if [ -z "$NO_CONFIGURE" ]
then
    $srcdir/configure --enable-maintainer-mode "$@"  ||  exit $?
fi

exit 0
