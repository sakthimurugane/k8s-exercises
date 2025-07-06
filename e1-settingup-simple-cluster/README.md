# KinD Cluster

## kind is a tool for running local Kubernetes clusters using Docker container “nodes”.

kind was primarily designed for testing Kubernetes itself, but may be used for local development or CI.

## Installation

```bash
go install sigs.k8s.io/kind@v0.29.0

kind create cluster
```

Console output:
```bash
sakthimurugan@MacBookPro k8s-exercises % kind create cluster

Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.33.1) 🖼
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Have a nice day! 👋
sakthimurugan@MacBookPro k8s-exercises % 
```
## Verifying the node status
```bash
kubectl get nodes
```

```bash
sakthimurugan@MacBookPro k8s-exercises % kubectl get nodes
NAME                 STATUS   ROLES           AGE   VERSION
kind-control-plane   Ready    control-plane   78s   v1.33.1
sakthimurugan@MacBookPro k8s-exercises % 
```
## Cleaning up cluster
```bash
kind delete cluster
```
