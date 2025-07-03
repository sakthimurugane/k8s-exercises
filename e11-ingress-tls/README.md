# 1. Create Cluster
## Option 1: LoadBalancer

Create a kind cluster and run Cloud Provider KIND to enable the loadbalancer controller which ingress-nginx will use through the loadbalancer API.
```bash 
kind create cluster 
```

## Option 2: extraPortMapping

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

```yaml
nodeSelector:
  kubernetes.io/hostname: "kind-control-plane"

nodeSelector:
  kubernetes.io/hostname: "kind-control-plane"
```


# 2. Ingress NGINX

## Deploy Ingress Controller and Admission webhook

```bash
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
```
OR

```bash
kubectl apply -f deploy-ingress-nginx.yaml
```
## Verify Ingress controller is running
Now the Ingress is all setup. Wait until is ready to process requests running:

```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

# 3. Deploy application with Ingress service
## 📁 Generate TLS Certificate (Self-Signed)

```bash
openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout tls.key -out tls.crt -days 365 \
  -subj "/CN=esmfalcon.com" \
  -addext "subjectAltName=DNS:esmfalcon.com,DNS:*.esmfalcon.com"
```

Create TLS secret:
```bash
kubectl create secret tls foo-bar-ingress-secret --cert=tls.crt --key=tls.key
```

## Lets deploy the application
```bash
kubectl apply -f foo-bar-deployment.yaml
```
