# Observability

This page describes how to configure Kubernetes to ship logs and metric data to an external Observability stack (LMA) for logging, monitoring and alerting. The Observability stack used in this example consists of:

- Prometheus
- Alertmanager

## Metrics Server

[Metrics server](https://github.com/kubernetes-sigs/metrics-server) collects resource metrics from kubelets and exposes them in Kubernetes apiserver through the Metrics API. Metrics server is not meant for non-autoscaling purposes.

Metrics API can also be accessed by `kubectl top`.

The focus of the metrics server is on CPU and memory as these metrics are used by the Horizontal and Vertical Pod Autoscalers. As a user you can view the metrics gathered with the microk8s kubectl top command.

### Installation

Metrics Server can be installed either directly from YAML manifest or via the official Helm chart. To install the latest Metrics Server release from the components.yaml manifest, run the following command.

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## Prometheus

[Prometheus](https://prometheus.io) scrapes metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts when specific conditions are observed.

Scrape remote k8s clusters: Run the prometheus node-exporter and the prometheus adapter for kubernetes metrics APIs (or any other exporter) to gather information from each k8s cluster to a central Prometheus installation.

### Installation

The [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator) provides Kubernetes native deployment and management of Prometheus and related monitoring components.

Deployment instructions at: <https://prometheus-operator.dev/docs/prologue/quick-start/#deploy-kube-prometheus>

#### Node exporter

[Prometheus exporter](https://github.com/prometheus/node_exporter) for hardware and OS metrics exposed by *NIX kernels.

To expose NVIDIA GPU metrics, [prometheus-dcgm](https://github.com/NVIDIA/dcgm-exporter) can be used.

#### kube-state-metrics (KSM)

[kube-state-metrics](https://github.com/kubernetes/kube-state-metrics) is a simple service that listens to the Kubernetes API server and generates metrics about the state of the objects. (See examples in the Metrics section below.) It is not focused on the health of the individual Kubernetes components, but rather on the health of the various objects inside, such as deployments, nodes and pods.

kube-state-metrics is about generating metrics from Kubernetes API objects without modification.

#### Helm

The [prometheus-community/kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) helm chart provides a similar feature set to kube-prometheus. This chart is maintained by the Prometheus community.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
# default install
helm install [RELEASE_NAME] prometheus-community/kube-prometheus-stack
# check values for eventual configuration
helm show values prometheus-community/kube-prometheus-stack
# install with custom values (create the myvalues.yaml file first)
helm install -f myvalues.yaml [RELEASE_NAME] prometheus-community/kube-prometheus-stack
# check its status by running:
kubectl --namespace default get pods -l "release=prometheus"
```

### Grafana

To access to the Grafana portal:

```bash
kubectl port-forward svc/prometheus-grafana 8080:80
# credentials (admin/prom-operator) are stored in the secret
kubectl get secrets prometheus-grafana -o yaml
```

### Alertmanager

The Alertmanager handles alerts sent by client applications such as the Prometheus server. It takes care of deduplicating, grouping, and routing them to the correct receiver integration such as email, PagerDuty, or OpsGenie.

For installation, please refer to the [Alertmanager documentation](https://github.com/prometheus/alertmanager).
