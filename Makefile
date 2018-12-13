
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

build: dependencies
	$(GO_BUILD_RECIPE)

dependencies:
	$(DEP) ensure -v

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
