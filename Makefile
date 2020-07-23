#!/usr/bin/xcrun make -f

TOOL_NAME = tunisia
VERSION = $(shell git describe --abbrev=0 --tags)

PREFIX = /usr/local
INSTALL_PATH = $(PREFIX)/bin/$(TOOL_NAME)
BUILD_PATH = .build/release/$(TOOL_NAME)
TAR_FILENAME = $(VERSION).tar.gz

RM=rm -f
MKDIR=mkdir -p
SUDO=sudo
CP=cp

SWIFT_BUILD_FLAGS=--configuration release -Xswiftc -suppress-warnings

SWIFTPM_DISABLE_SANDBOX_SHOULD_BE_FLAGGED:=$(shell test -n "$${HOMEBREW_SDKROOT}" && echo should_be_flagged)
ifeq ($(SWIFTPM_DISABLE_SANDBOX_SHOULD_BE_FLAGGED), should_be_flagged)
SWIFT_BUILD_FLAGS+= --disable-sandbox
endif
SWIFT_STATIC_STDLIB_SHOULD_BE_FLAGGED:=$(shell test -d $$(dirname $$(xcrun --find swift))/../lib/swift_static/macosx && echo should_be_flagged)
ifeq ($(SWIFT_STATIC_STDLIB_SHOULD_BE_FLAGGED), should_be_flagged)
SWIFT_BUILD_FLAGS+= -Xswiftc -static-stdlib
endif

# ZSH_COMMAND · run single command in `zsh` shell, ignoring most `zsh` startup files.
ZSH_COMMAND := ZDOTDIR='/var/empty' zsh -o NO_GLOBAL_RCS -c
# RM_SAFELY · `rm -rf` ensuring first and only parameter is non-null, contains more than whitespace, non-root if resolving absolutely.
RM_SAFELY := $(ZSH_COMMAND) '[[ ! $${1:?} =~ "^[[:space:]]+\$$" ]] && [[ $${1:A} != "/" ]] && [[ $${\#} == "1" ]] && noglob rm -rf $${1:A}' --

.PHONY: all clean install test uninstall linuxmain zip get_sha brew_push

all: installables

installables:
	swift build $(SWIFT_BUILD_FLAGS)

install: build
	install -d "$(PREFIX)/bin"
	install -C -m 755 $(BUILD_PATH) $(INSTALL_PATH)

uninstall:
	$(RM_SAFELY) $(INSTALL_PATH)

clean:
	swift package clean

test:
	$(RM_SAFELY) ./.build/debug/TunisiaPackageTests.xctest
	swift build --build-tests -Xswiftc -suppress-warnings
	swift test --skip-build

linuxmain:
	swift test --generate-linuxmain

zip: build
	zip -D $(TOOL_NAME).macos.zip $(BUILD_PATH)

get_sha:
	curl -OLs https://github.com/minuscorp/$(TOOL_NAME)/archive/$(VERSION).tar.gz
	shasum -a 256 $(TAR_FILENAME) | cut -f 1 -d " " > sha_$(VERSION).txt
	rm $(TAR_FILENAME)

brew_push: get_sha
	SHA=$(shell cat sha_$(VERSION).txt); \
	brew bump-formula-pr --url=https://github.com/minuscorp/$(TOOL_NAME)/archive/$(VERSION).tar.gz --sha256=$$SHA $(TOOL_NAME)