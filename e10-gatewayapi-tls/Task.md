## Q2: Create a deployment named logging-deployment in the namespace logging-ns with 1 replica, with the following specifications:

The main container should be named app-container, use the image busybox, and should run the following command to simulate writing logs:

```bash
sh -c "while true; do echo 'Log entry' >> /var/log/app/app.log; sleep 5; done"
````

Add a sidecar container named log-agent that also uses the busybox image and runs the command:

```bash
tail -f /var/log/app/app.log
````

log-agent logs should display the entries logged by the main app-container

### solution
```yaml
# logger-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: logging-deployment
  namespace: logging-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: logger
  template:
    metadata:
      labels:
        app: logger
    spec:
      volumes:
        - name: log-volume
          emptyDir: {}
      initContainers:
        - name: log-agent
          image: busybox
          command:
            - sh
            - -c
            - "touch /var/log/app/app.log; tail -f /var/log/app/app.log"
          volumeMounts:
            - name: log-volume
              mountPath: /var/log/app
          restartPolicy: Always 
      containers:
        - name: app-container
          image: busybox
          command:
            - sh
            - -c
            - "while true; do echo 'Log entry' >> /var/log/app/app.log; sleep 5; done"
          volumeMounts:
            - name: log-volume
              mountPath: /var/log/app
  ```
## Q3: A Deployment named webapp-deploy is running in the ingress-ns namespace and is exposed via a Service named webapp-svc.

Create an Ingress resource called webapp-ingress in the same namespace that will route traffic to the service. The Ingress must:

Use ```pathType: Prefix```
Route requests sent to path / to the backend service
Forward traffic to port 80 of the service
Be configured for the host kodekloud-ingress.app
Test app availablility using the following command:

```bash
curl -s http://kodekloud-ingress.app/
```

## Q6: Create an nginx pod called nginx-resolver using the image nginx and expose it internally with a service called nginx-resolver-service. 

Test that you are able to look up the service and pod names from within the cluster. Use the image: busybox:1.28 for dns lookup. Record results in /root/CKA/nginx.svc and /root/CKA/nginx.pod

Solution
Use the command kubectl run and create a nginx pod and busybox pod. Resolve it, nginx service and its pod name from busybox pod.

To create a pod nginx-resolver and expose it internally:

```bash
kubectl run nginx-resolver --image=nginx
kubectl expose pod nginx-resolver --name=nginx-resolver-service --port=80 --target-port=80 --type=ClusterIP
````

To create a pod test-nslookup. Test that you are able to look up the service and pod names from within the cluster:

```bash
kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service
kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service > /root/CKA/nginx.svc
```

Get the IP of the nginx-resolver pod and replace the dots(.) with hyphon(-) which will be used below.
```bash
kubectl get pod nginx-resolver -o wide
kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup <P-O-D-I-P.default.pod> > /root/CKA/nginx.pod
```

## Q9: Modify the existing web-gateway on cka5673 namespace to handle HTTPS traffic on port 443 for kodekloud.com, using a TLS certificate stored in a secret named kodekloud-tls.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: cka5673
  resourceVersion: "21919"
  uid: a1d0e35d-5126-4000-88ec-f440941eed75
spec:
  gatewayClassName: kodekloud
  listeners:
  - allowedRoutes:
      namespaces:
        from: Same
    name: https
    port: 80
    protocol: HTTP
```

correct:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: cka5673
spec:
  gatewayClassName: kodekloud
  listeners:
    - name: https
      protocol: HTTPS
      port: 443
      hostname: kodekloud.com
      tls:
        certificateRefs:
          - name: kodekloud-tls
```

## Q11: Network policy

You are requested to create a NetworkPolicy to allow traffic from frontend apps located in the frontend namespace, to backend apps located in the backend namespace, but not from the databases in the databases namespace. There are three policies available in the /root folder. Apply the most restrictive policy from the provided YAML files to achieve the desired result. Do not delete any existing policies.

Read through all provided NetworkPolicy YAML files carefully. Only one of them restricts traffic from the databases namespace while allowing it from frontend.

On controlplane, Review the contents of the three YAML files:
```bash
cat /root/net-pol-1.yaml
cat /root/net-pol-2.yaml
cat /root/net-pol-3.yaml
```

Understand the differences:

net-pol-1.yaml: Too broad; allows traffic from any namespace with a certain label.

net-pol-2.yaml: Incorrect; explicitly allows both frontend and databases.

net-pol-3.yaml: Correct; only allows traffic from the frontend namespace.

Apply the correct policy (net-pol-3.yaml):
```bash
kubectl apply -f /root/net-pol-3.yaml
```

Verify it’s the only one applied:
```bash
kubectl get netpol -n backend
```

You should only see net-policy-3 listed

net-policy-1.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: net-policy-1
  namespace: backend
spec:
  podSelector: {}
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          access: allowed
    ports:
    - protocol: TCP
      port: 80
```

net-policy-2.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: net-policy-2
  namespace: backend
spec:
  podSelector: {}
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
    - namespaceSelector:
        matchLabels:
          name: databases
    ports:
    - protocol: TCP
      port: 80
```

net-policy-3.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: net-policy-3
  namespace: backend
spec:
  podSelector: {}
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
    ports:
    - protocol: TCP
      port: 80
```