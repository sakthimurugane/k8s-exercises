# 1. Create Cluster
## LoadBalancer

Create a kind cluster and run Cloud Provider KIND to enable the loadbalancer controller which ingress-nginx will use through the loadbalancer API.
```bash 
kind create cluster --config kind-multi-node.yaml
```

# 2. Ingress Controller from NGINX 

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

Also deploy the cloud-provider-kind to assign external IP for the for the ingress controller
```bash
sudo cloud-provider-kind
```

# 4. Deploy application with service

## Lets deploy the application with V1 and V2
We will deploy 
```bash
kubectl apply -f foo-bar-deployment.yaml
```

# 5. Primary Ingress (v1 = 100% traffic)
This routes all traffic to ```my-app-v1```.

```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app-v1
            port:
              number: 80
```

# 6. Canary Ingress (v2 = 20% traffic)
This sends 20% of the traffic to my-app-v2 and the remaining 80% stays with v1.

```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress-canary
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "20" # 20% of traffic
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app-v2
            port:
              number: 80
````

# 7. How to verify

You should see ~80% responses from v1 and ~20% from v2:

```bash
for i in {1..20}; do curl -s --resolve myapp.example.com:80:172.18.0.4 http://myapp.example.com; done

Hello from v2
Hello from v2
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v2
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v1
sakthimurugan@MacBookPro e13-ingress-weighted-routing % 
```

