# Utils

Collection of SW utilities.

## Folder structure

```text
.
├── git_hooks
├── kubernetes
│   ├── ci-cd
│   │   ├── argo-workflows
│   │   └── argocd
│   ├── cluster-creation
│   │   ├── k3d
│   │   ├── kind
│   │   ├── microk8s
│   │   ├── minikube
│   │   └── vagrant-kubeadm
│   ├── kubectl-plugins
│   └── observability
├── ml
│   └── openai
└── programming
    └── python
```

### Git hooks

Configure git to use the new hook - it will stay with the repository:

```bash
git config core.hooksPath "./git_hooks"
```

## NOTES

This file is generated from [README-TEMPLATE.md](./README-TEMPLATE.md) using the [git_hooks/pre-commit](./git_hooks/pre-commit).
