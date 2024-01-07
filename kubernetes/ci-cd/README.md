# CI-CI

This page describes how to configure some CI-CD solutions in Kubernetes.

Currently tested:

- CI:
  - Argo Workflows
- CD:
  - Argo CD

## Argo Workflows

Argo Workflows is an open source container-native workflow engine for orchestrating parallel jobs on Kubernetes.

- [Argo Workflows - Website](https://argoproj.github.io/argo-workflows/).
- [Argo Workflows - Git](https://github.com/argoproj/argo-workflows).

### Install - Quick Start

Official Documentation: <https://argoproj.github.io/argo-workflows/quick-start/>

```bash
kubectl create namespace argo
# pick the desired version: https://github.com/argoproj/argo-workflows/releases/
export ARGO_WORKFLOWS_VERSION=v3.5.2
kubectl apply -n argo -f "https://github.com/argoproj/argo-workflows/releases/download/${ARGO_WORKFLOWS_VERSION}/install.yaml"
# patch argo-server authentication
kubectl patch deployment \
  argo-server \
  --namespace argo \
  --type='json' \
  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": [
  "server",
  "--auth-mode=server",
  "--access-control-allow-origin=https://localhost:2746",
  "--insecure-skip-verify=false"
]}]'
# port-forward the UI
kubectl -n argo port-forward deployment/argo-server 2746:2746
# https://localhost:2746
```

### Create a WorkflowTemplate

```bash
# use the default namespace
# workflow with input parameter
kubectl create -f ./argo-workflows/template-input-param.yaml
# workflow with input resources
kubectl create -f ./argo-workflows/template-input-resources.yaml
```

### Prometheus Integration

Custom Prometheus metrics can be defined to be emitted on a Workflow and Template level basis: <https://argoproj.github.io/argo-workflows/metrics/>.

## Argo CD

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.

- [Argo CD - Website](https://argo-cd.readthedocs.io/en/stable/).
- [Argo CD - Git](https://github.com/argoproj/argo-cd/).

Why Argo CD?

Application definitions, configurations, and environments should be declarative and version controlled. Application deployment and lifecycle management should be automated, auditable, and easy to understand.

### Install - Quick Start

Official Documentation: <https://argo-cd.readthedocs.io/en/stable/getting_started/>

```bash
# install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# port-forwarding can also be used to connect to the API server without exposing the service
kubectl port-forward svc/argocd-server -n argocd 8080:443
# OR expose the service
kubectl patch service -n argocd argocd-server -p '{"spec": {"type": "NodePort"}}'
# get the nodeport
PORT=$(kubectl get svc -n argocd argocd-server -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
# TODO replace microk8s-vm as per node available in the target cluster
NODE=microk8s-vm
HOST=$(kubectl get nodes $NODE -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
# open in the browser
echo $HOST:$PORT
# LOGIN credentials `admin`, password:
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

### Create a custom Application

Official documentation: <https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#app-of-apps>.

Example [application](./argocd/application-example.yaml) covering helm, kustomize, plugin directory configurations.

An example repository containing a guestbook application is available at <https://github.com/redhat-developer-demos/openshift-gitops-examples> to demonstrate how Argo CD works.

<https://redhat-scholars.github.io/argocd-tutorial/argocd-tutorial/02-getting_started.html>:

- Repo URL: <https://github.com/redhat-developer-demos/openshift-gitops-examples>, [path](https://github.com/redhat-developer-demos/openshift-gitops-examples/tree/main/apps/bgd/overlays/bgd): `apps/bgd/overlays/bgd`.
- Destination: local cluster, `server: https://kubernetes.default.svc`.

```bash
kubectl create -f ./argocd/application.yaml
# list applications
kubectl get applications.argoproj.io -A
# let’s introduce a change! Patch the live manifest to change the color of the box from blue to green:
kubectl -n bgd patch deploy/bgd --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/env/0/value", "value":"green"}]'
```

#### Argo Workflows Application

To install Argo Workflows using ArgoCD, the [argo-workflows.yaml](./argo-workflows.yaml) Application can be used:

```bash
kubectl create -f ./argo-workflows.yaml
```

**Note** that the `authMode` is set to `server`, which implies no explicit authentication (argo-workflows-server service account is being used).
