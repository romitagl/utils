# Utils

Collection of SW utilities.

## Folder structure

```text
.
├── git_hooks
└── kubernetes
    ├── cluster-creation
    │   ├── k3d
    │   ├── kind
    │   ├── microk8s
    │   ├── minikube
    │   └── vagrant-kubeadm
    └── observability
```

### Git hooks

Configure git to use the new hook - it will stay with the repository:

```bash
git config core.hooksPath "./git_hooks"
```
