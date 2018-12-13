FROM registry.svc.ci.openshift.org/openshift/release:golang-1.10 AS builder
WORKDIR /go/src/github.com/gluster/anthill-heketi
COPY . .
RUN go get -u github.com/golang/dep/cmd/dep \
    && make build

FROM registry.svc.ci.openshift.org/openshift/origin-v4.0:base
COPY --from=builder /go/src/github.com/gluster/anthill-heketi/gluster-anthill-heketi /usr/bin/
COPY manifests /manifests
RUN useradd gluster-anthill-heketi
USER gluster-anthill-heketi
ENTRYPOINT ["/usr/bin/gluster-anthill-heketi"]
LABEL io.openshift.release.operator true

LABEL io.k8s.display-name="OpenShift cluster-storage-operator" \
      io.k8s.description="This is a component of OpenShift Container Platform and manages the lifecycle of cluster storage components." \
      maintainer="Gluster Developers <gluster-devel@gluster.org>"
