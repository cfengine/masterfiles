ACLOCAL_AMFLAGS = -I m4

SUBDIRS = \
	tests/

# See configure.ac for MASTERFILES_INSTALL_TARGETS.
nobase_dist_masterfiles_DATA = @MASTERFILES_INSTALL_TARGETS@
masterfilesdir=$(prefix)/masterfiles

EXTRA_DIST = README.md inventory/README.md lib/README.md CONTRIBUTING.md LICENSE CFVERSION modules/promises

# Normalize tar header fields so two builds of the same source tree produce a
# byte-identical tarball, following the GNU tar reproducibility guidance:
# https://www.gnu.org/software/tar/manual/html_section/Reproducibility.html
#   --format=posix      stable, version-independent header encoding (configure.ac
#                       selects tar-pax so $(am__tar) emits posix)
#   --pax-option=...    keep tar's PID out of extended-header names and omit
#                       atime/ctime, leaving the archive in the ustar subset
#   --sort=name         stable member order
#   --numeric-owner     do not record buildslave user/group names
#   --owner=0 --group=0 deterministic ownership
#   --mode=go+u,go-w    deterministic permissions
# mtime clamping (the manual's --clamp-mtime --mtime) is handled by the
# touch -d @$$SOURCE_DATE_EPOCH calls in dist-hook and tar-package below.
TAR_OPTIONS = \
	--format=posix \
	--pax-option=exthdr.name=%d/PaxHeaders/%f \
	--pax-option=delete=atime,delete=ctime \
	--sort=name \
	--numeric-owner --owner=0 --group=0 \
	--mode=go+u,go-w
export TAR_OPTIONS

# The same guidance says to "run GNU tar in the C locale" alongside the options
# above; its example invokes "LC_ALL=C tar ...". Exporting LC_ALL=C covers both
# "make dist" and "make tar-package", which invoke $(am__tar).
LC_ALL = C
export LC_ALL

# Store the permissions properly in the tarball for acceptance tests to succeed.
# Also normalize directory permissions (which would otherwise be affected by the
# builder's umask). When SOURCE_DATE_EPOCH is set, clamp every mtime to it so
# the "make dist" source tarball is reproducible.
dist-hook:
	find $(distdir) -name '*.cf*' | xargs chmod go-w
	find $(distdir) -type d -exec chmod 755 {} +
	if [ -n "$$SOURCE_DATE_EPOCH" ]; then \
	    find $(distdir) -exec touch -d @$$SOURCE_DATE_EPOCH {} + ; \
	fi

tar-package:
	pkgdir=`mktemp -d`  &&  export pkgdir  &&  \
	origdir=`pwd`       &&  export origdir &&  \
	umask 0022          &&  chmod 755 $$pkgdir && \
	$(MAKE) prefix=$$pkgdir install  &&  \
	(   cd $$pkgdir  &&  \
            find . -name '*.cf*' | xargs -n1 chmod go-w  &&  \
	    if [ -n "$$SOURCE_DATE_EPOCH" ]; then \
	        find . -exec touch -d @$$SOURCE_DATE_EPOCH {} + ; \
	    fi  &&  \
	    tardir=.  &&  $(am__tar) |  \
	        GZIP=$(GZIP_ENV) gzip --no-name --stdout  \
	        > "$$origdir"/$(PACKAGE)-$(VERSION)-$(RELEASE).pkg.tar.gz  \
	)  ;  \
	[ x$$pkgdir != x ]  &&  rm -rf $$pkgdir

clean-local:
	rm -rf build

non-priv-install:
	mkdir -p "$$HOME/.cfagent/bin"
	ln -sf $$(command -v cf-promises) "$$HOME/.cfagent/bin"
	mkdir -p "$$HOME/.cfagent/inputs/lib"
	rsync -avz ./lib/  "$$HOME/.cfagent/inputs/lib/"
	[ ! -s "$$HOME/.cfagent/inputs/promises.cf" ] && echo "bundle agent main { reports: 'Hello, CFEngine!'; }" > "$$HOME/.cfagent/inputs/promises.cf"
