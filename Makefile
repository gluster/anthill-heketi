.EXPORT_ALL_VARIABLES:

BUILDDIR ?= build
DEP ?= dep

all: container-build

vendor-update:
	@echo Updating vendored packages
	$(DEP) ensure -update -v
	@echo

vendor-install:
	@echo Installing vendored packages
	$(DEP) ensure -vendor-only -v
	@echo

build:
	@./scripts/build.sh
	@echo

install-tools:
	@./scripts/install-text-linters.sh
	@./scripts/install-go-tools.sh

lint:
	@./scripts/lint-text.sh
	@./scripts/lint-go.sh
	@echo

test:
	@./test/go-test.sh
	@echo

container-build:
	@./scripts/container-build.sh
	@echo

clean:
	go clean -r -x
	rm -rf $(BUILDDIR)
