# Kubernetes cluster - Vagrant based

The project depends Vagrant (HashiCorp): <https://www.vagrantup.com/docs/installation>, <https://www.vagrantup.com/downloads>.

## How to use

- Check the status: `vagrant status`
- Create the images (first time): `vagrant up`
- Suspend/Resume: `vagrant suspend` / `vagrant resume`
- SSH into the *kubemaster* node: `vagrant ssh kubemaster`
- SSH into the *kubenode01* node: `vagrant ssh kubenode01`
- Shutdown: `vagrant halt`
- Destroy images: `vagrant destroy`
- Official documentation regarding [users/passwords](https://www.vagrantup.com/docs/boxes/base#default-user-settings):
  - root password: `vagrant`

## Vagrant machines

Update the config settings in the [Vagrantfile](./Vagrantfile), in particular:

- `NUM_WORKER_NODE`: number of worker nodes. Default is 1. VM names will be in the range *kubenode01 - kubenode0N*
- `NUM_MASTER_NODE`: number of master nodes. Default is 1. VM names is *kubemaster*
- `WORKER_NODE_MEM`: amount of Ram in MB configured for the worker node. Default is 1024.
- `WORKER_NODE_CPU`: number of CPU(s) configured for the worker node. Default is 1.
- `config.vm.box`: Linux distribution. Default is *ubuntu/bionic64*

### Kubernetes setup

- install-kubeadm: <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/>

**NOTE**: verify that steps *2* and *3* <https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker> are correctly automated by the script [./ubuntu/install-docker.sh](./ubuntu/install-docker.sh).

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

- create-cluster-kubeadm: <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/>

```bash
sudo su -
kubeadm init --apiserver-advertise-address=192.168.56.2 --pod-network-cidr="192.168.0.0/16"
exit
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# if you are the root user, you can run:
# export KUBECONFIG=/etc/kubernetes/admin.conf
# You should now deploy a pod network to the cluster.
# Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
# https://kubernetes.io/docs/concepts/cluster-administration/addons/
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl get pods -A
# kubeadm join ...
```
