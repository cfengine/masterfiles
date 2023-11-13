dnl ##########################################################################
dnl #
dnl # Build CFEngine
dnl #
dnl # Run ./autogen.sh to build configure script
dnl #
dnl ##########################################################################

AC_PREREQ(2.63)


m4_define([cfversion_from_env], m4_normalize(m4_esyscmd([echo $EXPLICIT_VERSION])))
m4_define([cfversion_from_file], m4_normalize(m4_esyscmd([cat CFVERSION])))
m4_ifval(cfversion_from_env, [
    m4_define([cfversion], cfversion_from_env)
], [
    m4_ifval(cfversion_from_file, [
        m4_define([cfversion], cfversion_from_file)
    ], [
        m4_fatal([Could not determine CFEngine version;
                  please set EXPLICIT_VERSION in the environment,
                  or make sure all git tags are up to date and rerun autogen.sh])
    ])
])


AC_INIT([cfengine-masterfiles], cfversion)

cfengine_version=cfversion

m4_undefine([cfversion])
m4_undefine([cfversion_from_file])
m4_undefine([cfversion_from_env])

m4_define([cfrelease], m4_normalize(m4_esyscmd([cat CFRELEASE])))
AC_SUBST([RELEASE], [cfrelease])
cfengine_release=cfrelease
m4_undefine([cfrelease])

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

bindir="${bindir:-${exec_prefix}/bin}"
dnl Expand ${prefix} and whatnot in bindir
adl_RECURSIVE_EVAL("${bindir}", bindir)
AC_SUBST(bindir, "${bindir}")

dnl ######################################################################
dnl OS specific stuff
dnl ######################################################################

m4_include([m4/cf3_platforms.m4])

AC_CHECK_PROG([ac_cv_pkg_install], [pkg_install], [yes], [no])
AC_CHECK_PROG([ac_cv_shunit2], [shunit2], [yes], [no])

AM_CONDITIONAL([HAVE_PKG_INSTALL], [test "$ac_cv_pkg_install" = "yes"])
AM_CONDITIONAL([HAVE_SHUNIT2], [test "$ac_cv_shunit2" = "yes"])

dnl ######################################################################
dnl Print summary
dnl ######################################################################

AC_MSG_RESULT()
AC_MSG_RESULT(Summary:)
AC_MSG_RESULT(Version              -> $cfengine_version)
AC_MSG_RESULT(Release              -> $cfengine_release)
AM_COND_IF(HAVE_CORE,
    AC_MSG_RESULT(Core directory       -> $core_dir),
    AC_MSG_RESULT(Core directory       -> not set - tests are disabled)
)
AM_COND_IF(HAVE_ENTERPRISE,
    AC_MSG_RESULT(Enterprise directory -> $enterprise_dir),
    AC_MSG_RESULT(Enterprise directory -> not set - some tests are disabled)
)
AC_MSG_RESULT(Install prefix       -> $prefix)
AC_MSG_RESULT(bindir               -> $bindir)
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

MASTERFILES_INSTALL_TARGETS=
find $srcdir -maxdepth 1 -name '*.cf' > tmp
while IFS= read -r j
do
    # Only add those that don't have a corresponding .in file.
    # They will be added later.
    if ! test -f "$j.in"
    then
        MASTERFILES_INSTALL_TARGETS="$MASTERFILES_INSTALL_TARGETS $j"
    fi
done < tmp
rm tmp
for j in `echo $srcdir/*.cf.in`
do
    # Add .in files, but without the .in suffix.
    MASTERFILES_INSTALL_TARGETS="$MASTERFILES_INSTALL_TARGETS `echo $j | sed -e 's/\.in$//'`"
done

for i in cfe_internal controls inventory lib services
do
    for j in `find "$srcdir/$i" -name '*.cf'`
    do
        # Only add those that don't have a corresponding .in file.
        # They will be added later.
        if ! test -f "$j.in"
        then
            MASTERFILES_INSTALL_TARGETS="$MASTERFILES_INSTALL_TARGETS $j"
        fi
    done
    for j in `find "$srcdir/$i" -name '*.cf.in'`
    do
        # Add .in files, but without the .in suffix.
        MASTERFILES_INSTALL_TARGETS="$MASTERFILES_INSTALL_TARGETS `echo $j | sed -e 's/\.in$//'`"
    done
done
for i in templates cfe_internal modules/packages/vendored lib/templates
do
    for j in `find "$srcdir/$i" -name '*.mustache' -o -name '*.sh' -o -name '*.awk' -o -name '*.sed' -o -name '*.ps1' -o -name '*.py'`
    do
        MASTERFILES_INSTALL_TARGETS="$MASTERFILES_INSTALL_TARGETS $j"
    done
done


AC_SUBST(MASTERFILES_INSTALL_TARGETS)

dnl ######################################################################
dnl Now make the Makefiles
dnl ######################################################################

AC_CONFIG_FILES([Makefile
                controls/update_def.cf
                update.cf
                promises.cf
                standalone_self_upgrade.cf
                tests/Makefile
                tests/acceptance/Makefile
                tests/unit/Makefile
])

AC_OUTPUT


AC_MSG_RESULT()
AC_MSG_RESULT(DONE: Configuration done. Run "make install" to install CFEngine Masterfiles.)
AC_MSG_RESULT()
