
MIX_ENV ?= prod
COOKIE ?= undefined_cookie
MIX_BIN ?= $(shell which mix)
MIX_COMMAND = COOKIE=$(COOKIE) MIX_ENV=$(MIX_ENV) $(MIX_BIN)

.PHONY: all build release clean

all: build

build:
	$(MIX_COMMAND) deps.get --force
	$(MIX_COMMAND) deps.compile --force
	$(MIX_COMMAND) compile --force

release: clean reset_build build
	$(MIX_COMMAND) release
	mkdir -p release
	find _build/$(MIX_ENV)/rel/boker_tov_nissim/releases/ -type f -name '*.tar.gz' -exec mv {} release/ \;

clean:
	$(MIX_COMMAND) deps.clean --all

reset_build:
	rm -rf _build
