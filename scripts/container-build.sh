#! /bin/bash

set -e

# Set driver name
IMAGE="${IMAGE:-anthill-heketi}"

# Set image tag
TAG="${TAG:-latest}"
if [[ -n $TAG ]]; then
  TAG=":${TAG}"
fi

# Set which docker repo to tag
REPO="${REPO:-gluster}"
if [[ -n $REPO ]]; then
  REPO="${REPO}/"
fi

# Allow overriding default docker command
RUNTIME_CMD=${RUNTIME_CMD:-docker}

build="build"
if [[ "${RUNTIME_CMD}" == *buildah ]]; then
  build="bud"
fi

# Allow disabling tests during build
RUN_TESTS=${RUN_TESTS:-0}

# This sets the version variable to (hopefully) a semver compatible string. We
# expect released versions to have a tag of vX.Y.Z (with Y & Z optional), so we
# only look for those tags. For version info on non-release commits, we want to
# include the git commit info as a "build" suffix ("+stuff" at the end). There
# is also special casing here for when no tags match.
VERSION_GLOB="v[:digit:]*"
# Get the nearest "version" tag if one exists. If not, this returns the full
# git hash
NEAREST_TAG="$(git describe --always --tags --match "$VERSION_GLOB" --abbrev=0)"
# Full output of git describe for us to parse: TAG-<N>-g<hash>-<dirty>
FULL_DESCRIBE="$(git describe --always --tags --match "$VERSION_GLOB" --dirty)"
# If full matches against nearest, we found a valid tag earlier
if [[ $FULL_DESCRIBE =~ ${NEAREST_TAG}-(.*) ]]; then
        # Build suffix is the last part of describe w/ "-" replaced by "."
        version="$NEAREST_TAG+${BASH_REMATCH[1]//-/.}"
else
        # We didn't find a valid tag, so assume version 0 and everything ends up
        # in build suffix.
        version="0.0.0+g${FULL_DESCRIBE//-/.}"
fi

builddate="$(date -u '+%Y-%m-%dT%H:%M:%S.%NZ')"

GO_DEP_VERSION="${GO_DEP_VERSION}"
GO_METALINTER_VERSION="${GO_METALINTER_VERSION:-v2.0.11}"
GO_METALINTER_THREADS=${GO_METALINTER_THREADS:-4}

build_args=()
build_args+=( --build-arg "RUN_TESTS=$RUN_TESTS" )
build_args+=( --build-arg "GO_DEP_VERSION=$GO_DEP_VERSION" )
build_args+=( --build-arg "GO_METALINTER_VERSION=$GO_METALINTER_VERSION" )
build_args+=( --build-arg "GO_METALINTER_THREADS=$GO_METALINTER_THREADS" )
build_args+=( --build-arg "version=$version" )
build_args+=( --build-arg "builddate=$builddate" )

# Print Docker version
echo "=== $RUNTIME_CMD version ==="
$RUNTIME_CMD version

#-- Build container
$RUNTIME_CMD $build \
  -t "${REPO}${IMAGE}${TAG}" \
  "${build_args[@]}" \
  . \
|| exit 1

# If running tests, extract profile data
if [ "$RUN_TESTS" -ne 0 ]; then
  rm -f profile.cov
  $RUNTIME_CMD run --entrypoint cat "${REPO}${IMAGE}${TAG}" \
    /profile.cov > profile.cov
fi
