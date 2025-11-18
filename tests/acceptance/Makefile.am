ENV_FILE=testall.env

copy:
	cp $(core_dir)/tests/acceptance/*.cf.sub .

env:
	echo export CORE=\"$(core_dir)\" > $(ENV_FILE)
if HAVE_ENTERPRISE
	echo export ENTERPRISE=\"$(enterprise_dir)\" >> $(ENV_FILE)
	echo export CFENGINE_TEST_OVERRIDE_EXTENSION_LIBRARY_DIR=\"$(enterprise_dir)/enterprise-plugin/.libs\" >> $(ENV_FILE)
endif

create-env: copy env


clean-local:
	rm -rf workdir


check-local: create-env
	MAKE=$(MAKE) ./testall ./17_packages/11_old/unsafe/package-inventory.cf

CLEANFILES  = testall.env summary.log test.log test.xml Makefile.testall
#These are created by running the submakefile
CLEANFILES += dcs.cf.sub default.cf.sub plucked.cf.sub


EXTRA_DIST  = README.md
# Distribute library subdirectory (besides .cf files)
EXTRA_DIST += lib
# Distribute all custom test packages and related files
EXTRA_DIST += 17_packages
# Distribute custom promise type tests
EXTRA_DIST += 30_custom_promise_types
# Also distribute the '.cf*' files and the testall script itself.
# TODO this should be set as a dependency to check-local, e.g. with
# check-local_SOURCE. Unfortunately I couldn't find a way so that
# automake would include these files in the dist tarball.
EXTRA_DIST += testall @MASTERFILES_TESTS@
