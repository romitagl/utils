# Kubernetes cluster - minikube based

The project depends on [minikube](https://minikube.sigs.k8s.io).

minikube is local Kubernetes, focusing on making it easy to learn and develop for Kubernetes.
All you need is Docker (or similarly compatible) container or a Virtual Machine environment.

## Installation

### MacOS install

It can be installed via the the [brew](https://brew.sh/) utility on MacOS:

```bash
brew install minikube
```

### curl install

Releases: <https://github.com/kubernetes/minikube/releases>.

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-arm64
sudo install minikube-darwin-arm64 /usr/local/bin/minikube
```

## How to use

Official Quick Start Guide: <https://minikube.sigs.k8s.io/docs/start/>.

Create a cluster:

```bash
minikube start
```

Getting the cluster’s kubeconfig.

```bash
minikube kubectl config view > kubeconfig.yaml
# or
minikube update-context
kubectl --kubeconfig kubeconfig.yaml get nodes
kubectl --kubeconfig kubeconfig.yaml cluster-info
```

**kubectl**, you can add the following alias: `alias kubectl="minikube kubectl --`

List services to get access to:

```bash
minikube service list
minikube service [NAME] -n [NAMESPACE]
```

To delete all the minikube clusters:

```bash
minikube delete --all
```

### Addons

Browse the catalog of easily installed Kubernetes services:

```bash
minikube addons list
```

## Connecting to the nodes

To connect to the cluster running in Docker: `docker exec -it minikube bash`
