if HAVE_CORE
    TESTS_SUBDIRS = tests/acceptance
endif

SUBDIRS = $(TESTS_SUBDIRS)

# See configure.ac for MASTERFILES_INSTALL_TARGETS.
nobase_dist_masterfiles_DATA = @MASTERFILES_INSTALL_TARGETS@
masterfilesdir=$(datadir)

EXTRA_DIST = README.md inventory/README.md lib/README.md CONTRIBUTING.md LICENSE

# Include no symlinks/hard links in the dist tarball, reveal no
# usernames of the buildslave
TAR_OPTIONS = --hard-dereference --owner=0 --group=0

# Store the permissions properly in the tarball for acceptance tests to succeed
dist-hook:
	find $(distdir) -name '*.cf*' | xargs chmod go-w
