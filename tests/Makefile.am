SUBDIRS = . unit

if HAVE_CORE
SUBDIRS += acceptance
endif

fix-python-hashbang:
	test -x /usr/bin/python || find $(srcdir) \( -name '*.py' -o -name 'mock_*' -o -name 'test_*' \) -exec sed -ri '\~/usr/bin/python($$|[^0-9])~ s|/usr/bin/python|/usr/bin/python3|' '{}' \;

# fix-python-hashbang is in check-local here (masterfiles/tests) instead of where it is
# needed in masterfiles/tests/unit since there is no hook for pre-check there.
check-local: fix-python-hashbang

.PHONY: fix-python-hashbang
