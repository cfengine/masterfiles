SUBDIRS = \
	modules/packages \
	tests/unit

if HAVE_CORE
    SUBDIRS += tests/acceptance
endif

# See configure.ac for MASTERFILES_INSTALL_TARGETS.
nobase_dist_masterfiles_DATA = @MASTERFILES_INSTALL_TARGETS@
masterfilesdir=$(prefix)/masterfiles

EXTRA_DIST = README.md inventory/README.md lib/README.md lib/3.7/README.md CONTRIBUTING.md LICENSE CFVERSION

# Do not reveal usernames of the buildslave
TAR_OPTIONS = --owner=0 --group=0
export TAR_OPTIONS

# Store the permissions properly in the tarball for acceptance tests to succeed
dist-hook:
	find $(distdir) -name '*.cf*' | xargs chmod go-w

tar-package:
	pkgdir=`mktemp -d`  &&  export pkgdir  &&  \
	origdir=`pwd`       &&  export origdir &&  \
	umask 0022          &&  chmod 755 $$pkgdir && \
	$(MAKE) prefix=$$pkgdir install  &&  \
	(   cd $$pkgdir  &&  \
            find . -name '*.cf*' | xargs -n1 chmod go-w  &&  \
	    tardir=.  &&  $(am__tar) |  \
	        GZIP=$(GZIP_ENV) gzip -c  \
	        > "$$origdir"/$(PACKAGE)-$(VERSION).pkg.tar.gz  \
	)  ;  \
	[ x$$pkgdir != x ]  &&  rm -rf $$pkgdir
