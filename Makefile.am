ACLOCAL_AMFLAGS = -I m4

SUBDIRS = \
	tests/

# See configure.ac for MASTERFILES_INSTALL_TARGETS.
nobase_dist_masterfiles_DATA = @MASTERFILES_INSTALL_TARGETS@
masterfilesdir=$(prefix)/masterfiles

EXTRA_DIST = README.md inventory/README.md lib/README.md CONTRIBUTING.md LICENSE CFVERSION

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
	        > "$$origdir"/$(PACKAGE)-$(VERSION)-$(RELEASE).pkg.tar.gz  \
	)  ;  \
	[ x$$pkgdir != x ]  &&  rm -rf $$pkgdir

# copy package modules for tests to build directory
vendored := modules/packages/vendored
modules := $(patsubst $(vendored)/%.mustache,build/modules/packages/%,$(wildcard $(vendored)/*.mustache))

all-local: $(modules)

build/modules/packages/%:
	mkdir -p build/modules/packages
	TEMPLATE=$$(echo $@ | sed 's,build/modules/packages,modules/packages/vendored,'); \
	cp $$TEMPLATE.mustache $@
	chmod +x $@

clean-local:
	rm -rf build
