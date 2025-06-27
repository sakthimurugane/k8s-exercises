Create Cluster
Option 1: LoadBalancer

Create a kind cluster and run Cloud Provider KIND to enable the loadbalancer controller which ingress-nginx will use through the loadbalancer API.
kind create cluster

kind create cluster

Option 2: extraPortMapping

Create a single node kind cluster with extraPortMappings to allow the local host to make requests to the Ingress controller over ports 80/443.
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

If you want to run with multiple nodes you must ensure that your ingress-controller is deployed on the same node where you have configured the PortMapping, in this example you can use a nodeSelector to specify the control-plane node name.
nodeSelector:
  kubernetes.io/hostname: "kind-control-plane"

nodeSelector:
  kubernetes.io/hostname: "kind-control-plane"



Ingress NGINX
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml

kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml

Now the Ingress is all setup. Wait until is ready to process requests running:
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s



