#-- Create build environment

FROM docker.io/openshift/origin-release:golang-1.10 as build

ENV GOPATH="/go/" \
    SRCDIR="/go/src/github.com/gluster/anthill-heketi/" \
    SCRIPTSDIR="${SRCDIR}scripts/" \
    TESTDIR="${SRCDIR}test/"

# Install go tools
ARG GO_DEP_VERSION=
ARG GO_METALINTER_VERSION=latest
COPY scripts/install-go-tools.sh "${SCRIPTSDIR}"
RUN mkdir -p /go/bin; ${SCRIPTSDIR}/install-go-tools.sh

# Vendor dependencies
COPY Gopkg.lock Gopkg.toml "${SRCDIR}"
WORKDIR "${SRCDIR}"
RUN /go/bin/dep ensure -v -vendor-only

# Copy source directories
COPY cmd/ "${SRCDIR}/cmd"
COPY pkg/ "${SRCDIR}/pkg"
COPY scripts/ "${SCRIPTSDIR}"
COPY test/ "${TESTDIR}"

#-- Test phase

ARG RUN_TESTS=1
ARG GO_METALINTER_THREADS=1
ENV TEST_COVERAGE=stdout \
    GO_COVER_DIR=/build/

RUN mkdir /build
RUN [ $RUN_TESTS -eq 0 ] || ${SCRIPTSDIR}/lint-go.sh
RUN [ $RUN_TESTS -eq 0 ] || ${TESTDIR}/go-test.sh

#-- Build phase

ARG BUILDDIR=/build

RUN ./scripts/build.sh

#-- Final container

FROM registry.svc.ci.openshift.org/openshift/origin-v4.0:base as final

COPY --from=build /build /

# The version of the driver (git describe --dirty --always --tags | sed 's/-/./2' | sed 's/-/./2')
ARG version="(unknown)"
# Container build time (date -u '+%Y-%m-%dT%H:%M:%S.%NZ')
ARG builddate="(unknown)"
ARG name="Anthill-Heketi"
ARG desc="An Operator for deploying and managing Gluster clusters."

LABEL io.openshift.release.operator true \
      build-date="${builddate}" \
      name="${name}" \
      io.k8s.display-name="${name}" \
      io.k8s.description="${desc}" \
      maintainer="Gluster Developers <gluster-devel@gluster.org>" \
      Summary="${desc}" \
      vcs-type="git" \
      vcs-url="https://github.com/gluster/anthill-heketi" \
      vendor="gluster.org" \
      version="${version}"

RUN useradd anthill-heketi
USER anthill-heketi
ENTRYPOINT ["/anthill-heketi"]
