# K8s HPA - Horizontal Pod Autoscaler 

## HPA relies on the metrics from the metrics-server, we need to have metrics-server running in the cluster.

How to check whether HPA can be used

```bash
sakthimurugan@magi e9-hpa % kubectl top nodes
error: Metrics API not available
sakthimurugan@magi e9-hpa % kubectl top pods 
error: Metrics API not available
sakthimurugan@magi e9-hpa % 
```

# Install metrics server

1. Apply the metrics-server manifests (works with Kind):
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```
### console reponse
```bash
sakthimurugan@magi e9-hpa % kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

serviceaccount/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
service/metrics-server created
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
```

2. Patch metrics-server for Kind compatibility

Kind uses a self-signed cert, so metrics-server needs special args:

```bash
kubectl patch deployment metrics-server -n kube-system \
  --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
```

3. Wait for it to be ready

```bash
kubectl get pods -n kube-system | grep metrics-server
```

4. Verify it works

```bash
kubectl top nodes
kubectl top pods -A
```

### sample response
```bash
sakthimurugan@magi e9-hpa % kubectl top nodes
NAME                 CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
kind-control-plane   522m         26%      849Mi           21%         
sakthimurugan@magi e9-hpa % kubectl top pods 
No resources found in default namespace.
sakthimurugan@magi e9-hpa % 
```

# 🚀 Apply the deployment

We will deploy hpa-example image with hpa configuration of min 1 and max 5 with initial replicas of 3

HPA will overwrite replicas in deployment based on the cpu usage from the pod

```bash
kubectl apply -f app-manifest.yaml
```

🔥 Generate Load (from another pod)

Run this command to create a busybox pod to simulate load:


```bash
kubectl run -it --rm busybox --image=busybox -- /bin/sh
```

```bash
while true; do wget -q -O- http://hpa-demo.default.svc.cluster.local; done
```

# 📊 Watch autoscaler in action:

```bash
kubectl get hpa -w
kubectl get pods -l app=hpa-demo -w
```