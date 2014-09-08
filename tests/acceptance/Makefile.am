ENV_FILE=testall.env

copy:
	cp $(core_dir)/tests/acceptance/*.cf.sub .

env:
	echo export CORE=\"$(core_dir)\" > $(ENV_FILE)
if HAVE_ENTERPRISE
	echo export ENTERPRISE=\"$(enterprise_dir)\" >> $(ENV_FILE)
	echo export CFENGINE_TEST_OVERRIDE_EXTENSION_LIBRARY_DIR=\"$(enterprise_dir)/enterprise-plugin/.libs\" >> $(ENV_FILE)
endif

check_SCRIPTS=testall
testall: copy env

TESTS =
check-local:
	@+MAKE=$(MAKE) ./testall
