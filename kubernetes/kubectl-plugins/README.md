# Extend kubectl with plugins

This page describes how to install and write extensions for [kubectl](https://kubernetes.io/docs/reference/kubectl/kubectl/).

Official documentation: <https://kubernetes.io/docs/tasks/extend-kubectl/kubectl-plugins/>

You can also discover and install kubectl plugins available in the open source using [Krew](https://krew.dev/). Krew is a plugin manager maintained by the Kubernetes SIG CLI community.

```bash
# search your PATH for valid plugin executables
kubectl plugin list
```

## Example plugin

```bash
cat << EOF > "kubectl-foo"
#!/bin/bash
# optional argument handling
if [[ "$1" == "version" ]]
then
    echo "1.0.0"
    exit 0
fi

# optional argument handling
if [[ "$1" == "config" ]]
then
    echo "$KUBECONFIG"
    exit 0
fi

echo "I am a plugin named kubectl-foo"
EOF
# make the plugin executable
chmod +x kubectl-foo
# place it anywhere in your PATH:
sudo mv ./kubectl-foo /usr/local/bin
# you may now invoke your plugin as a kubectl command:
kubectl foo
```
