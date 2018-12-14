# Gluster operator for Kubernetes and OpenShift

[![Build Status](https://travis-ci.org/gluster/anthill-heketi.svg?branch=master)](https://travis-ci.org/gluster/anthill-heketi)
[![Documentation Status](https://readthedocs.org/projects/gluster-anthill-heketi/badge/?version=latest)](http://gluster-anthill-heketi.readthedocs.io/)
[![Go Report Card](https://goreportcard.com/badge/github.com/gluster/anthill-heketi)](https://goreportcard.com/report/github.com/gluster/anthill-heketi)
<!-- Badges: TravisCI, CentOS CI, Coveralls, GoDoc, GoReport, ReadTheDocs -->

**Found a bug?** [Let us know.](https://github.com/gluster/operator/issues/new?template=bug_report.md)

**Have a request?** [Tell us about it.](https://github.com/gluster/operator/issues/new?template=feature_request.md)

**Interested in helping out?** Take a look at the [contributing
doc](CONTRIBUTING.md) to find out how.

## Build

The default build is to do a docker containerized build. To run it:

```bash
make
```

Depending on your configuration, you may need to provide an alternate
container runtime command. You can do that like so:

```bash
RUNTIME_CMD="sudo docker" make
```

## Installation

Install the CRDs into the cluster:

```bash
$ kubectl apply -f deploy/crds/operator_v1alpha1_glustercluster_crd.yaml
customresourcedefinition.apiextensions.k8s.io "glusterclusters.operator.gluster.org" created
```

Install the service account, role, and rolebinding:

```bash
$ kubectl apply -f deploy/service_account.yaml
serviceaccount "anthill" created

$ kubectl apply -f deploy/role.yaml
role.rbac.authorization.k8s.io "anthill" created
rolebinding.rbac.authorization.k8s.io "anthill" created
```

There are two options for deploying the operator.

1. It can be run normally, inside the cluster. For this, see
   `deploy/operator.yaml` for a skeleton.
1. It can also be run outside the cluster for development purposes. This
   removes the need to push the container to a registry by running the operator
   executable locally. For this:

   ```bash
   $ OPERATOR_NAME=anthill-heketi operator-sdk up local --namespace=default
   INFO[0000] Running the operator locally.
   {"level":"info","ts":1542396040.2412076,"logger":"cmd","caller":"manager/main.go:57","msg":"Registering Components."}
   {"level":"info","ts":1542396040.2413611,"logger":"kubebuilder.controller","caller":"controller/controller.go:120","msg":"Starting EventSource","Controller":"glustercluster-controller","Source":"kind source: /, Kind="}
   ...
   ```
