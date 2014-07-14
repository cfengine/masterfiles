dnl ##########################################################################
dnl #
dnl # Build CFEngine
dnl #
dnl # Run ./autogen.sh to build configure script
dnl #
dnl ##########################################################################

AC_PREREQ(2.59)

dnl Version is unused, it will be grabbed from core.
AC_INIT([cfengine], [1.0])

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

AC_ARG_WITH(core, [AS_HELP_STRING(--with-core=<core>, [Build against core in directory <core>. Defaults to "../core"])],
            [AS_IF([test "x$with_core" == "xno"], [AC_MSG_ERROR([You cannot build without a core directory (--without-core)], [2])],
                   core_dir=$with_core
            )],
            core_dir=$(pwd)/../core
)
AS_IF([test ! -d "$core_dir/libpromises"],
      [AC_MSG_ERROR([$with_core is not a valid core directory (--with-core=$core_dir)], [2])])
AS_CASE([$core_dir], [/*], [], [core_dir=$(pwd)/$core_dir])
AC_SUBST([core_dir])


AC_ARG_WITH(enterprise, [AS_HELP_STRING(--with-enterprise=<enterprise>, [Build against enterprise in directory <enterprise>. Defaults to "../enterprise"])],
            [AS_IF([test "x$with_enterprise" == "xno"], [
                   enterprise_dir=
            ],[
                   enterprise_dir=$with_enterprise
            ])],
            enterprise_dir=$(pwd)/../enterprise
)
AS_CASE([$enterprise_dir], [/*], [], [enterprise_dir=$(pwd)/$enterprise_dir])
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
dnl Generate install target list.
dnl ######################################################################

AC_MSG_NOTICE([generating install targets])
MASTERFILES_INSTALL_TARGETS=
for i in cfe_internal controls inventory lib services sketches/meta update; do
    MASTERFILES_INSTALL_TARGETS="$MASTERFILES_INSTALL_TARGETS $(find "$srcdir/$i" -name '*.cf' -exec printf '%s ' '{}' ';')"
done
for i in templates; do
    MASTERFILES_INSTALL_TARGETS="$MASTERFILES_INSTALL_TARGETS $(find "$srcdir/$i" -name '*.mustache' -exec printf '%s ' '{}' ';')"
done
MASTERFILES_INSTALL_TARGETS="$MASTERFILES_INSTALL_TARGETS $(echo ./*.cf)"
AC_SUBST(MASTERFILES_INSTALL_TARGETS)

dnl ######################################################################
dnl Now make the Makefiles
dnl ######################################################################

AC_CONFIG_FILES([Makefile
                tests/acceptance/Makefile])

AC_OUTPUT

AC_MSG_RESULT(DONE: Configuration done. Run make/gmake install to install CFEngine Community Masterfiles.)
