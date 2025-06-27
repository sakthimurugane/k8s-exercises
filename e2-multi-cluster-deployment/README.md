We will create a multi-cluster deployment using the following steps:

```bash
kind create cluster --config kind-multi-node.yaml

kubectl apply -f first-pod.yaml
```

