# Depends on Python.
if LINUX
check_SCRIPTS = \
	test_package_module_apt_get \
	test_package_module_yum
endif

TESTS = $(check_SCRIPTS)

EXTRA_DIST = \
	mock_apt_get \
	mock_dpkg \
	mock_dpkg_deb \
	mock_dpkg_query \
	mock_rpm \
	mock_yum

EXTRA_DIST += $(check_SCRIPTS)
