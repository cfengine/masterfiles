PWD:=$(shell pwd)

ifeq ($(CORE),)
  CORE:=$(PWD)/../core/
endif

ifeq ($(DESTDIR),)
  DESTDIR:=/var/cfengine/masterfiles
endif

INSTALL = /usr/bin/install
INSTALL_DATA = ${INSTALL} -m 600
INSTALL_DIR = ${INSTALL} -m 750 -d

copy:
	cp $(CORE)/tests/acceptance/default.cf.sub tests/acceptance
	cp $(CORE)/tests/acceptance/testall tests/acceptance

check: copy
	cd tests/acceptance && ./testall --agent=$(CORE)/cf-agent/cf-agent --cfpromises=$(CORE)/cf-promises/cf-promises --cfserverd=$(CORE)/cf-serverd/cf-serverd --cfkey=$(CORE)/cf-key/cf-key

checklog: copy
	cd tests/acceptance && ./testall --agent=$(CORE)/cf-agent/cf-agent --cfpromises=$(CORE)/cf-promises/cf-promises --cfserverd=$(CORE)/cf-serverd/cf-serverd --cfkey=$(CORE)/cf-key/cf-key --printlog

install:
	for d in . controls inventory lib/3.5 lib/3.6 services sketches/meta update; do \
		$(INSTALL_DIR) $(DESTDIR)/$$d; \
		for f in $$d/*.cf; do\
			$(INSTALL_DATA) $$f $(DESTDIR)/$$f; \
		done; \
	done;
