# Loadbalancer service tpye in k8s
Load balancer is network service supported by kubernetes cluster.

If we want to expose our application to the external world, we need. LoadBalancer service type.

But the actual load balancer (hardware appliances) or the virtual compoenent has to be provided by the Infrastructure like cloud provider or some load balancer controller.

We will use Cloud povider Kind which mocks the cloud provider controller and allocates load balancer using envoy proxy.

## Installing Cloud Provider KIND

Cloud Provider KIND can be installed using golang

```bash
go install sigs.k8s.io/cloud-provider-kind@latest
```
## Running cloud provider
```bash
sudo cloud-provider-kind
```
## Deploy the application with Load Balancer service
```yaml
kind: Pod
apiVersion: v1
metadata:
  name: foo-app
  labels:
    app: http-echo
spec:
  containers:
  - command:
    - /agnhost
    - serve-hostname
    - --http=true
    - --port=8080
    image: registry.k8s.io/e2e-test-images/agnhost:2.39
    name: foo-app
---
kind: Pod
apiVersion: v1
metadata:
  name: bar-app
  labels:
    app: http-echo
spec:
  containers:
  - command:
    - /agnhost
    - serve-hostname
    - --http=true
    - --port=8080
    image: registry.k8s.io/e2e-test-images/agnhost:2.39
    name: bar-app
---
kind: Service
apiVersion: v1
metadata:
  name: foo-service
spec:
  type: LoadBalancer
  selector:
    app: http-echo
  ports:
  - port: 5678
    targetPort: 8080
```
### Get the External IP address of Load Balancer
```bash
LB_IP=$(kubectl get svc/foo-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

# should output foo and bar on separate lines 
```bash
for _ in {1..10}; do
  curl ${LB_IP}:5678
done
```

