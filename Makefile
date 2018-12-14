
IMG ?= gluster/anthill-heketi:latest

PACKAGE=github.com/gluster/anthill-heketi
MAIN_PACKAGE=$(PACKAGE)/cmd/manager

BIN=gluster-anthill-heketi

ENVVAR=GOOS=linux CGO_ENABLED=0
GOOS=linux
GO_BUILD_RECIPE=GOOS=$(GOOS) go build -o $(BIN) $(MAIN_PACKAGE)

BINDATA=pkg/generated/bindata.go
GOBINDATA_BIN=$(GOPATH)/bin/go-bindata
DEP:=dep

CONTAINER_BUILD_RECIPE:=docker build

all: build

build: vendor-install
	$(GO_BUILD_RECIPE)

vendor-update:
	@echo Updating vendored packages
	$(DEP) ensure -update -v
	@echo

vendor-install:
	@echo Installing vendored packages
	$(DEP) ensure -vendor-only -v
	@echo

# TODO: need code generation?
#generate: $(GOBINDATA_BIN)
#	$(GOBINDATA_BIN) -nometadata -pkg generated -o $(BINDATA) assets/...

#$(GOBINDATA_BIN):
#	go get github.com/jteeuwen/go-bindata/go-bindata

test:
	go test ./pkg/...

verify:
	echo "TODO: add verify scripts"

container: build test verify
	$(CONTAINER_BUILD_RECIPE) . -t $(IMG)

clean:
	go clean
	rm -f $(BIN)
