# Let's do our first deployment on the cluster
We will create a multi-cluster deployment using the following steps:

## Initiate cluster with multiple workers
kind-multi-node.yaml:
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

```bash
kind create cluster --config kind-multi-node.yaml
```

## Deploy the first pod
```bash
kubectl apply -f first-pod.yaml
```

