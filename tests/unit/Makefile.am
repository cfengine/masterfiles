check_SCRIPTS =

# Depends on Python.
if LINUX
check_SCRIPTS += \
	test_package_module_apt_get \
	test_package_module_yum
endif

if HAVE_SHUNIT2
check_SCRIPTS += test_package_module_freebsd_ports
if HAVE_PKG_INSTALL
check_SCRIPTS += test_package_module_pkgsrc
endif
endif

if FREEBSD
if HAVE_SHUNIT2
check_SCRIPTS += test_package_module_pkg
endif
endif

TESTS = $(check_SCRIPTS)

EXTRA_DIST = \
	harness_freebsd_ports \
	mock_apt_get \
	mock_dpkg \
	mock_dpkg_deb \
	mock_dpkg_query \
	mock_pkgin \
	mock_pkg_info \
	mock_freebsd_pkg \
	mock_pkgng \
	mock_rpm \
	mock_yum

EXTRA_DIST += $(check_SCRIPTS)
