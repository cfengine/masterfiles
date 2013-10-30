PWD:=$(shell pwd)

ifeq ($(CORE),)
  CORE:=../
endif

copy:
	cp $(CORE)/tests/acceptance/default.cf.sub tests/acceptance
	cp $(CORE)/tests/acceptance/testall tests/acceptance

check: copy
	cd tests/acceptance && ./testall --agent=$(CORE)/cf-agent/cf-agent --cfpromises=$(CORE)/cf-promises/cf-promises --cfserverd=$(CORE)/cf-serverd/cf-serverd --cfkey=$(CORE)/cf-key/cf-key

checklog: copy
	cd tests/acceptance && ./testall --agent=$(CORE)/cf-agent/cf-agent --cfpromises=$(CORE)/cf-promises/cf-promises --cfserverd=$(CORE)/cf-serverd/cf-serverd --cfkey=$(CORE)/cf-key/cf-key --printlog
