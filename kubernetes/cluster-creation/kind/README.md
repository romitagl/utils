# Kubernetes cluster - kind based

The project depends on [kind](https://kind.sigs.k8s.io).

kind is a tool for running local Kubernetes clusters using Docker container “nodes”.
kind was primarily designed for testing Kubernetes itself, but may be used for local development or CI.

## kind Binary

There are a number of options to install latest release.

### MacOS install

It can be installed via the the [brew](https://brew.sh/) utility on MacOS:

```bash
brew install kind
```

### curl install

Releases: <https://github.com/kubernetes-sigs/kind/releases>.

```bash
# install v0.11.1 linux amd64
curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.11.1/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
# to uninstall
sudo rm -f /usr/local/bin/kind
```

### How to use

Official Quick Start Guide: <https://kind.sigs.k8s.io/docs/user/quick-start/>.

Create a cluster named `test-cluster`:

```bash
# create a 1 node cluster
kind create cluster --name test-cluster

# create a 1 master - 2 nodes cluster
cat << EOF > kind-multinode-cluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOF

kind create cluster --name test-cluster --config kind-multinode-cluster.yaml
# NAME                 STATUS     ROLES                  AGE   VERSION
# kind-control-plane   Ready      control-plane,master   89s   v1.21.1
# kind-worker          NotReady   <none>                 49s   v1.21.1
# kind-worker2         NotReady   <none>                 49s   v1.21.1
```

*~/.kube/config* contexts are updated by kind upon cluster creation/deletion. To interact with the cluster:

```bash
# to get the kind clusters
kind get clusters

# In order to interact with a specific cluster, you only need to specify the cluster name as a context in kubectl:
kubectl cluster-info --context kind-test-cluster

# list cluster nodes
kubectl get nodes --context kind-test-cluster
```

Mapping ports to the host machine: you can map extra ports from the nodes to the host machine with extraPortMappings:

```bash
# create a 1 master - 2 nodes cluster and mapping port NodePort and host port to 30000
cat << EOF > kind-multinode-port-mapping-cluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30001
    hostPort: 30001
    listenAddress: "0.0.0.0" # Optional, defaults to "0.0.0.0"
    protocol: tcp # Optional, defaults to tcp
- role: worker
- role: worker
EOF

kind create cluster --name test-cluster --config kind-multinode-port-mapping-cluster.yaml
```

To delete the kind cluster:

```bash
kind delete cluster --name test-cluster
```
