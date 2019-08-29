SUBDIRS = . unit

if HAVE_CORE
SUBDIRS += acceptance
endif

fix-python-hashbang:
	@-test -x /usr/bin/python || find $(srcdir) -mindepth 2 -type f -exec sed -ri '\~/usr/bin/python($$|[^0-9])~ s|/usr/bin/python|/usr/bin/python3|' '{}' \;

check-local: fix-python-hashbang

.PHONY: fix-python-hashbang
