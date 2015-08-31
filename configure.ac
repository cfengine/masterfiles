dnl ##########################################################################
dnl #
dnl # Build CFEngine
dnl #
dnl # Run ./autogen.sh to build configure script
dnl #
dnl ##########################################################################

AC_PREREQ(2.59)

define([revision], m4_esyscmd_s([git rev-list -1 --abbrev-commit HEAD]))

AC_INIT([cfengine-masterfiles], [3.7.1])

AC_CANONICAL_TARGET

_AM_SET_OPTION([tar-ustar])
AM_INIT_AUTOMAKE([foreign])
AM_MAINTAINER_MODE([enable])

AC_DEFINE_UNQUOTED(ABS_TOP_SRCDIR,
"`cd -- "$srcdir"; pwd`",
[Absolute path of source tree])

m4_ifdef([AM_SILENT_RULES],[AM_SILENT_RULES([yes])])

dnl Libtool madness

AC_CONFIG_MACRO_DIR([m4])

dnl
dnl hide [s]include macros, so old aclocal (automake < 1.10) won't find them and
dnl won't complain about something/something.m4 not found
dnl
m4_define(incstart,sinc)
m4_define(incend,lude)

AC_PROG_MKDIR_P

AC_PROG_INSTALL

dnl ######################################################################
dnl Figure out core and enterprise directory.
dnl ######################################################################

AC_ARG_WITH(core,
    AS_HELP_STRING(--with-core=<core>,
        [Build against core in directory <core>. Defaults to "../core". \
        If not found there or if --with-core=no then tests are disabled]
    ),
    AS_IF(test "x$with_core" == "xno",
    [
        core_dir=
    ],
    [
        dnl The user passed --with-core=path but we must check if it's a
        dnl valid core directory.
        AS_IF(test -d "$with_core/libpromises",
        [
            core_dir="$with_core"
        ],
        [
            AC_MSG_ERROR([$with_core is not a valid core directory (--with-core=$with_core)])
        ])
    ]),

    dnl If --with-core was not passed at all, then default to ../core
    dnl only if that is a valid core directory.
    [if test -d `pwd`/../core/libpromises
    then
        core_dir="`pwd`/../core"
    else
        core_dir=
    fi]
)

dnl export HAVE_CORE for makefiles
AM_CONDITIONAL(HAVE_CORE, test "x$core_dir" != x)
dnl Transform the path from relative to absolute
AS_IF(test "x$core_dir" != x,
    [
        AS_CASE([$core_dir], [/*], [],
            [core_dir=`pwd`/$core_dir])
    ]
)
AC_SUBST([core_dir])


AC_ARG_WITH(enterprise,
    AS_HELP_STRING(--with-enterprise=<enterprise>,
        [Build against enterprise in directory <enterprise>. \
        Defaults to "../enterprise"]
    ),
    AS_IF(test "x$with_enterprise" == "xno",
    [
        enterprise_dir=
    ],
    [
        enterprise_dir=$with_enterprise
    ]),
    enterprise_dir=`pwd`/../enterprise
)
AS_CASE([$enterprise_dir], [/*], [], [enterprise_dir=`pwd`/$enterprise_dir])
AM_CONDITIONAL([HAVE_ENTERPRISE], [test -d "$enterprise_dir/libcfenterprise"])
AC_SUBST([enterprise_dir])

dnl ######################################################################
dnl Set prefix to correct directory.
dnl ######################################################################

AS_IF([test x"$prefix" = xNONE],
    prefix=/var/cfengine
)
datadir=${prefix}/masterfiles

dnl ######################################################################
dnl OS specific stuff
dnl ######################################################################

m4_include([m4/cf3_platforms.m4])

dnl ######################################################################
dnl Print summary
dnl ######################################################################

AC_MSG_RESULT()
AC_MSG_RESULT(Summary of options:)
AM_COND_IF(HAVE_CORE,
    AC_MSG_RESULT(Core directory       -> $core_dir),
    AC_MSG_RESULT(Core directory       -> not set - tests are disabled)
)
AM_COND_IF(HAVE_ENTERPRISE,
    AC_MSG_RESULT(Enterprise directory -> $enterprise_dir),
    AC_MSG_RESULT(Enterprise directory -> not set - some tests are disabled)
)
AC_MSG_RESULT(Install prefix       -> $prefix)
AC_MSG_RESULT()


dnl ######################################################################
dnl Generate install target list.
dnl ######################################################################

AC_MSG_NOTICE([generating makefile targets])

# Do not try to unroll these for loops by putting the find commands directly in
# the assignments, it will overflow on the Solaris and HP-UX shells.
MASTERFILES_TESTS=''
for i in `cd "$srcdir/tests/acceptance/" && find . -name '*.cf*'`
do
    MASTERFILES_TESTS="$MASTERFILES_TESTS $i"
done
AC_SUBST(MASTERFILES_TESTS)

MASTERFILES_INSTALL_TARGETS=`echo $srcdir/*.cf`

for i in cfe_internal controls inventory lib services sketches/meta update
do
    for j in `find "$srcdir/$i" -name '*.cf'`
    do
        MASTERFILES_INSTALL_TARGETS="$MASTERFILES_INSTALL_TARGETS $j"
    done
done
for i in templates
do
    for j in `find "$srcdir/$i" -name '*.mustache'`
    do
        MASTERFILES_INSTALL_TARGETS="$MASTERFILES_INSTALL_TARGETS $j"
    done
done

AC_SUBST(MASTERFILES_INSTALL_TARGETS)


dnl ######################################################################
dnl Now make the Makefiles
dnl ######################################################################

AC_CONFIG_FILES([Makefile
                modules/packages/Makefile
                tests/acceptance/Makefile
                tests/unit/Makefile])

AC_OUTPUT

AC_MSG_RESULT()
AC_MSG_RESULT(DONE: Configuration done. Run "make install" to install CFEngine Masterfiles.)
AC_MSG_RESULT()
