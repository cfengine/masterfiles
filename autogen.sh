#!/bin/sh


ORIGDIR=`pwd`

srcdir=`dirname $0`
[ -n "$srcdir" ] && cd $srcdir

echo "$0: Running determine-version.sh ..."
rm -f CFVERSION
misc/determine-version.sh .CFVERSION > CFVERSION \
    || echo "$0: Unable to auto-detect CFEngine version, continuing"

echo "$0: Running determine-release.sh ..."
rm -f CFRELEASE
misc/determine-release.sh CFRELEASE \
    || { echo "$0: Unable to auto-detect CFEngine release, continuing"; echo 1 >CFRELEASE; }

echo "$0: Running autoreconf ..."
[ ! -d m4 ] && mkdir m4
autoreconf -Wno-portability --force --install -I m4  ||  exit $?

cd -               # back to original directory

if [ -z "$NO_CONFIGURE" ]
then
    # prepend 'sh -x' if you want to debug
    "$srcdir"/configure --enable-maintainer-mode "$@" || exit $?
fi

exit 0
