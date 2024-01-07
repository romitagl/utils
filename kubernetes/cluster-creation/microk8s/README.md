# Kubernetes cluster - Microk8s based

The project depends on [Microk8s](https://microk8s.io), [GitHub](https://github.com/canonical/microk8s).

MicroK8s is a low-ops, minimal production Kubernetes. MicroK8s is small, fast, single-package Kubernetes for developers, IoT and edge.

MicroK8s is fully conformant Kubernetes.

*It does not require Docker unlike k3d*.

## Microk8s Binary

There are a number of options to install latest release. [Get started](https://microk8s.io/docs/getting-started).

### MacOS install

It can be installed via the the [brew](https://brew.sh/) utility on MacOS:

```bash
brew install ubuntu/microk8s/microk8s
```

### Alternative install

<https://microk8s.io/docs/getting-started> and <https://microk8s.io/docs/install-alternatives>

## How to use

MicroK8s includes a microk8s kubectl command.

- [How To guides](https://microk8s.io/docs/how-to)
- [Command Reference](https://microk8s.io/docs/command-reference)

Create a cluster:

```bash
# install k8s 1.29 using a drive of max 30GB
microk8s install --disk=30 --channel=1.29
# check the status while Kubernetes starts
microk8s status --wait-ready
microk8s kubectl get nodes -o wide
# list all resources
microk8s kubectl get all --all-namespaces
```

Start and stop Kubernetes:

```bash
# start
microk8s start
# stop
microk8s stop
```

Reset. This commands makes it easy to revert your MicroK8s to an ‘install fresh’ state wihout having to reinstall anything:

```bash
microk8s reset
```

Getting the cluster’s kubeconfig.

```bash
microk8s kubectl config view --raw > kubeconfig.yaml
# verifiy that kubectl version is aligned with the cluster
kubectl --kubeconfig kubeconfig.yaml get nodes
kubectl --kubeconfig kubeconfig.yaml cluster-info
# or
export KUBECONFIG=kubeconfig.yaml
kubectl get nodes
# or (to override default kubectl config)
microk8s kubectl config view --raw > ~/.kube/config
```

To delete the microk8s cluster:

```bash
microk8s uninstall
```

## Addons

Turn on the services you want:

```bash
microk8s status
# community            # (core) The community addons repository
# dashboard            # (core) The Kubernetes dashboard
# dns                  # (core) CoreDNS
# helm                 # (core) Helm 2 - the package manager for Kubernetes
# helm3                # (core) Helm 3 - Kubernetes package manager
# host-access          # (core) Allow Pods connecting to Host services smoothly
# hostpath-storage     # (core) Storage class; allocates storage from host directory
# ingress              # (core) Ingress controller for external access
# mayastor             # (core) OpenEBS MayaStor
# metallb              # (core) Loadbalancer for your Kubernetes cluster
# metrics-server       # (core) K8s Metrics Server for API access to service metrics
# prometheus           # (core) Prometheus operator for monitoring and logging
# rbac                 # (core) Role-Based Access Control for authorisation
# registry             # (core) Private image registry exposed on localhost:32000
# storage              # (core) Alias to hostpath-storage add-on, deprecated
microk8s enable dns prometheus ingress
# microk8s disable command turns off a service.
```

### Ingress

To enable an NGINX Ingress Controller: `microk8s enable ingress`. Official reference at <https://microk8s.io/docs/ingress>. Some additional resources also at <https://kubernetes.io/docs/concepts/services-networking/ingress/>, <https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/>.

Check that ingress is working:

```bash
kubectl get all -n ingress
```

Please note that the ingress resource should be placed inside the same namespace of the backend resource.

See Grafana example [here](#ingress-grafana).

## SSH into cluster nodes

It's possible to ssh into cluster nodes (VMs) using the following command:

```bash
# in the example the node name is microk8s-vm
multipass shell microk8s-vm
```

### kube-apiserver

Configuration available at: `/var/snap/microk8s/current/args/kube-apiserver`

### kubelet

Configuration available at: `/var/snap/microk8s/current/args/kubelet`

### Logs

To gather logs for the Kubernetes services you should be aware that all services are systemd services:

snap.microk8s.daemon-cluster-agent
snap.microk8s.daemon-containerd
snap.microk8s.daemon-apiserver
snap.microk8s.daemon-apiserver-kicker
snap.microk8s.daemon-proxy
snap.microk8s.daemon-kubelet
snap.microk8s.daemon-scheduler
snap.microk8s.daemon-controller-manager

```bash
sudo journalctl -u snap.microk8s.daemon-kubelet -r
```

### Observability

To install the observability module:

```bash
microk8s enable observability
# check the pods
kubectl -n observability get pods
```

#### Ingress-Grafana

Create the ingress resource to expose Grafana:

```bash
export NAMESPACE=observability
cat <<EOF | kubectl apply -n $NAMESPACE -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kube-prom-stack-grafana
            port:
              number: 80
EOF
```

Get the node IP address:

```bash
kubectl get nodes -o wide
# NAME          STATUS   ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
# microk8s-vm   Ready    <none>   14h   v1.29.0   192.168.64.11   <none>        Ubuntu 22.04.3 LTS   5.15.0-91-generic   containerd://1.6.15
```

Open the browser and go to <http://192.168.64.11>. Login with username `admin` and password `prom-operator`.

**NOTE**: *If you host grafana under subpath* make sure your `grafana.ini` root_url setting includes subpath. If not using a reverse proxy make sure to set serve_from_sub_path to true.
