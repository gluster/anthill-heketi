#!/bin/bash

set -e

BIN="${BIN:-anthill-heketi}"
BUILDDIR="${BUILDDIR:-build}"

echo "=== Building ${BIN} ==="

mkdir -p "${BUILDDIR}"

CGO_ENABLED=0 GOOS=linux go build -ldflags '-extldflags "-static"' -o "${BUILDDIR}/${BIN}" "cmd/manager/main.go"
ldd "${BUILDDIR}/${BIN}" | grep -q "not a dynamic executable"
