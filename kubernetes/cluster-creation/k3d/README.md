# Kubernetes cluster - K3D based

The project depends on [k3d](https://github.com/rancher/k3d) (Rancher): <https://k3d.io>.

k3d is a lightweight wrapper to run k3s (Rancher Lab’s minimal Kubernetes distribution) in docker.

## K3D Binary

There are a number of options to install latest release.

### MacOS install

It can be installed via the the [brew](https://brew.sh/) utility on MacOS:

```bash
brew install k3d
```

### curl install

```bash
# install latest
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
# install specific release (e.g. v4.4.7)
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v4.4.7 bash
# to uninstall
sudo rm -f /usr/local/bin/k3d
```

### How to use

Create a cluster named `test-cluster`:

```bash
# create a 1 node cluster
k3d cluster create test-cluster
# OR
# We map localhost ports 80 and 443 to the k3s virtual loadbalancer. This will allow us to reach the ingress resources directly from the localhost on our machine
k3d cluster create test-cluster \
--api-port 127.0.0.1:6443 \
-p 80:80@loadbalancer \
-p 443:443@loadbalancer
# create a 1 master - 2 nodes cluster
k3d cluster create test-cluster --servers 1 --agents 2 \
--api-port 127.0.0.1:6443 \
-p 80:80@loadbalancer \
-p 443:443@loadbalancer
# NAME                      STATUS   ROLES                  AGE    VERSION
# k3d-devcluster-agent-1    Ready    <none>                 91s    v1.21.2+k3s1
# k3d-devcluster-agent-0    Ready    <none>                 111s   v1.21.2+k3s1
# k3d-devcluster-server-0   Ready    control-plane,master   2m8s   v1.21.2+k3s1
```

Getting the cluster’s kubeconfig (included in k3d cluster create).

```bash
k3d kubeconfig get test-cluster > kubeconfig.yaml

kubectl --kubeconfig kubeconfig.yaml get nodes

kubectl --kubeconfig kubeconfig.yaml cluster-info
```

Exposing services: <https://k3d.io/usage/guides/exposing_services/>

```bash
# expose NodePort range 30000-30002 on the master node
k3d cluster create test-cluster --servers 1 --agents 2 \
--api-port 127.0.0.1:6443 \
-p 80:80@loadbalancer \
-p 443:443@loadbalancer \
-p "30000-30002:30000-30002@server[0]"
```

Get the new cluster’s connection details merged into your default kubeconfig (usually specified using the KUBECONFIG environment variable or the default path $HOME/.kube/config) and directly switch to the new context:

```bash
k3d kubeconfig merge test-cluster --kubeconfig-switch-context

kubectl get nodes
```

To delete the k3d cluster:

```bash
k3d cluster delete test-cluster
```

#### Embedded etcd

Create a cluster with 3 server nodes using k3s’ embedded etcd database. The first server to be created will use the --cluster-init flag and k3d will wait for it to be up and running before creating (and connecting) the other server nodes.

**NOTE**: Current setup tested with the Prometheus stack described under [observability/README.md](../../observability/README.md)

```bash
# expose NodePort range 30000-30002 on 127.0.0.1
# do not install servicelb and traefik on all servers
k3d cluster create test-cluster --k3s-arg "--no-deploy=servicelb@server:*" --k3s-arg "--no-deploy=traefik@server:*" --servers 3 \
--api-port 127.0.0.1:6443 \
-p 80:80@loadbalancer \
-p 443:443@loadbalancer \
-p "30000-30002:30000-30002"
# to access to an exposed nginx service on port 30000
curl 127.0.0.1:30000
```

Some additional config options at: <https://k3d.io/v5.4.1/usage/configfile/>

## K3S Docker-Compose

Running K3d (K3s in Docker) and docker-compose: <https://rancher.com/docs/k3s/latest/en/advanced/#running-k3d-k3s-in-docker-and-docker-compose>.

[docker-compose.yml](https://github.com/k3s-io/k3s/blob/master/docker-compose.yml) is in the root of the K3s repo that serves as an example of how to run K3s from Docker. To run from docker-compose from this repo, run:

```bash
# download the official Docker Compose file
curl -LO https://raw.githubusercontent.com/k3s-io/k3s/master/docker-compose.yml
# to run define K3S_TOKEN
export K3S_TOKEN=${RANDOM}${RANDOM}${RANDOM}
# create a 2 nodes cluster
docker-compose up -d --scale agent=2
# to check the logs (follow)
docker-compose logs -f

# kubeconfig is written to current dir
kubectl --kubeconfig kubeconfig.yaml get nodes
# NAME           STATUS   ROLES                  AGE     VERSION
# 340c8229a90a   Ready    control-plane,master   3m2s    v1.22.2+k3s2
# 5ac4a9b21b48   Ready    <none>                 2m46s   v1.22.2+k3s2
# 280fc0a70aef   Ready    <none>                 2m46s   v1.22.2+k3s2

# to stop the cluster
docker-compose down
# (optional) to perform full cleanup - losing the k8s state
docker volume rm -f k3d_k3s-server
```
