PWD:=$(shell pwd)

ifeq ($(CORE),)
  CORE:=$(PWD)/../core/
endif
ifeq ($(ENTERPRISE),)
  ENTERPRISE:=$(PWD)/../enterprise/
endif

ifeq ($(DESTDIR),)
  DESTDIR:=/var/cfengine/masterfiles
endif

UNAME := $(shell uname)

ifeq ($(UNAME), Solaris)
INSTALL = /usr/local/bin/install
else
INSTALL = /usr/bin/install
endif

INSTALL_DATA = ${INSTALL} -m 600
INSTALL_DIR = ${INSTALL} -m 750 -d

ENV_FILE:=$(PWD)/tests/acceptance/testall.env

copy:
	cp $(CORE)/tests/acceptance/*.cf.sub tests/acceptance

env:
	echo export CORE=\"$(CORE)\" > $(ENV_FILE)
	echo export ENTERPRISE=\"$(ENTERPRISE)\" >> $(ENV_FILE)
	echo export CFENGINE_TEST_OVERRIDE_EXTENSION_LIBRARY_DIR=\"$(ENTERPRISE)/enterprise-plugin/.libs\" >> $(ENV_FILE)

check: copy env
	cd tests/acceptance && ./testall

checklog: copy env
	cd tests/acceptance && ./testall --printlog

install:
	for d in . cfe_internal controls inventory libraries lib/3.5 lib/3.6 reports services services/autorun sketches/meta update; do \
		$(INSTALL_DIR) $(DESTDIR)/$$d; \
		for f in $$d/*.cf; do\
			$(INSTALL_DATA) $$f $(DESTDIR)/$$f; \
		done; \
	done;
	for d in templates; do \
		$(INSTALL_DIR) $(DESTDIR)/$$d; \
		for f in $$d/*.mustache; do\
			$(INSTALL_DATA) $$f $(DESTDIR)/$$f; \
		done; \
	done;
