SUBDIRS = \
	modules/packages \
	tests/unit

if HAVE_CORE
    SUBDIRS += tests/acceptance
endif

# See configure.ac for MASTERFILES_INSTALL_TARGETS.
nobase_dist_masterfiles_DATA = @MASTERFILES_INSTALL_TARGETS@
masterfilesdir=$(datadir)

EXTRA_DIST = README.md inventory/README.md lib/README.md CONTRIBUTING.md LICENSE

# Do not reveal usernames of the buildslave
TAR_OPTIONS = --owner=0 --group=0

# Store the permissions properly in the tarball for acceptance tests to succeed
dist-hook:
	find $(distdir) -name '*.cf*' | xargs chmod go-w
