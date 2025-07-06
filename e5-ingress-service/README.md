## Create Cluster
### Option 1: LoadBalancer

Create a kind cluster and run Cloud Provider KIND to enable the loadbalancer controller which ingress-nginx will use through the loadbalancer API.

```bash
kind create cluster
```
### Option 2: extraPortMapping

Create a single node kind cluster with extraPortMappings to allow the local host to make requests to the Ingress controller over ports 80/443.

```bash
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
```

If you want to run with multiple nodes you must ensure that your ingress-controller is deployed on the same node where you have configured the PortMapping, in this example you can use a nodeSelector to specify the control-plane node name.

```bash
nodeSelector:
  kubernetes.io/hostname: "kind-control-plane"
```
## Deploy Ingress Controller
Ingress NGINX
```bash
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
```

Now the Ingress is all setup. Wait until is ready to process requests running:
```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

## Run Cloud provider KIND
```bash
sudo cloud-provider-kind
```
## Deploy the application with Ingress service
```bash
kind applt -f foo-bar-deployment.yaml
```
### Get the External IP address of Ingress controller
```bash
LB_IP=$(kubectl get svc/ingress-nginx-controller -n ingress-nginx  -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

# should output foo and bar on separate lines 
```bash
for _ in {1..10}; do
  curl ${LB_IP}/foo
done
```

console output:
```bash
sakthimurugan@MacBookPro e5-ingress-service % for _ in {1..10}; do
  curl ${LB_IP}/bar    
done
bar-appbar-appbar-appbar-appbar-appbar-appbar-appbar-appbar-appbar-app%
sakthimurugan@MacBookPro e5-ingress-service % for _ in {1..10}; do
  curl ${LB_IP}/foo    
done
foo-appfoo-appfoo-appfoo-appfoo-appfoo-appfoo-appfoo-appfoo-appfoo-app% 
sakthimurugan@MacBookPro e5-ingress-service % 
```