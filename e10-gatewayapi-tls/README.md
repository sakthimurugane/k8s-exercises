1. Create a KinD cluster with extra ports (for LoadBalancer/Gateway testing)
Save the following to ```kind-config.yaml```:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
```

Then create the cluster:

```bash
kind create cluster --config kind-config.yaml
```

2. Install Gateway API CRDs
You can install the official Gateway API CRDs from Kubernetes SIG:

```bash
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.0.1" | kubectl apply -f -
```

```bash
customresourcedefinition.apiextensions.k8s.io/gatewayclasses.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/gateways.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/grpcroutes.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/httproutes.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/referencegrants.gateway.networking.k8s.io created
```

Verify CRDs:
```bash
kubectl get crds | grep gateway
```

3. Install a Gateway API-compatible controller
You need an actual implementation of the Gateway API. Popular choices:

🟦 Option A: NGINX Gateway
Deploy the NGINX Gateway Fabric CRDs

```bash
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.0.1/deploy/crds.yaml
```
Deploy NGINX Gateway Fabric

```bash
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.0.1/deploy/default/deploy.yaml
```

🟣 Option B: Istio
If you're using Istio (e.g., with Istio Operator), enable the Gateway API support

🟢 Option C: Envoy Gateway

4. Verify the Deployment
To confirm that NGINX Gateway Fabric is running, check the pods in the nginx-gateway namespace:
```bash
kubectl get pods -n nginx-gateway
```
The output should look similar to this (note that the pod name will include a unique string):
```bash
sakthimurugan@magi e10-gatewayapi-tls % kubectl get pods -n nginx-gateway
NAME                                 READY   STATUS      RESTARTS   AGE
nginx-gateway-767bc675bf-2p8gp       1/1     Running     0          52s
nginx-gateway-cert-generator-vlwsd   0/1     Completed   0          52s
```

5. Deploy the application
```bash
kubectl create ns application
kubectl apply -f foo-bar-deployment.yaml
```
6. 📁 Generate TLS Certificate (Self-Signed)

```bash
openssl req -x509 -newkey rsa:2048 \
  -nodes -keyout tls.key -out tls.crt -days 365 \
  -subj "/CN=esmfalcon.com"
```

Create TLS secret:
```bash
kubectl create secret tls foo-gateway-secret --cert=tls.crt --key=tls.key -n application
```
7. 📄 Define a Gateway with HTTPS Listener
```bash
kubectl apply -f gateway.yaml
```

8. 📄 Define a Matching HTTPRoute
```bash
kubectl apply -f httproute.yaml
```

9. Since the Kind doesnt have load balancer, lets run the cloud-provider-kind
which will allocate external ip address on the host machine
```bash
sudo cloud-provider-kind
```

10. Check the IP address assigned to load balancer
```bash
sakthimurugan@magi ~ % kubectl get svc -n application -o=jsonpath="{.items[*].status.loadBalancer}"
{} {"ingress":[{"ip":"172.18.0.3","ipMode":"Proxy","ports":[{"port":443,"protocol":"TCP"}]}]} {}
```

11. 🧪 Test with curl and --resolve

```bash
curl -k --resolve esmfalcon.com:443:172.18.0.3 https://esmfalcon.com
```

##console output
```bash
sakthimurugan@magi e10-gatewayapi-tls % curl -vk --resolve esmfalcon.com:443:172.18.0.3 https://esmfalcon.com/foo
* Added esmfalcon.com:443:172.18.0.3 to DNS cache
* Hostname esmfalcon.com was found in DNS cache
*   Trying 172.18.0.3:443...
* Connected to esmfalcon.com (172.18.0.3) port 443
* ALPN: curl offers h2,http/1.1
* (304) (OUT), TLS handshake, Client hello (1):
* (304) (IN), TLS handshake, Server hello (2):
* (304) (IN), TLS handshake, Unknown (8):
* (304) (IN), TLS handshake, Certificate (11):
* (304) (IN), TLS handshake, CERT verify (15):
* (304) (IN), TLS handshake, Finished (20):
* (304) (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / AEAD-AES256-GCM-SHA384 / [blank] / UNDEF
* ALPN: server accepted h2
* Server certificate:
*  subject: CN=esmfalcon.com
*  start date: Jul  2 15:04:19 2025 GMT
*  expire date: Jul  2 15:04:19 2026 GMT
*  issuer: CN=esmfalcon.com
*  SSL certificate verify result: self signed certificate (18), continuing anyway.
* using HTTP/2
* [HTTP/2] [1] OPENED stream for https://esmfalcon.com/foo
* [HTTP/2] [1] [:method: GET]
* [HTTP/2] [1] [:scheme: https]
* [HTTP/2] [1] [:authority: esmfalcon.com]
* [HTTP/2] [1] [:path: /foo]
* [HTTP/2] [1] [user-agent: curl/8.7.1]
* [HTTP/2] [1] [accept: */*]
> GET /foo HTTP/2
> Host: esmfalcon.com
> User-Agent: curl/8.7.1
> Accept: */*
> 
* Request completely sent off
< HTTP/2 200 
< server: nginx
< date: Wed, 02 Jul 2025 15:48:30 GMT
< content-type: text/plain; charset=utf-8
< content-length: 7
< 
* Connection #0 to host esmfalcon.com left intact
foo-app%                                                                                                                                                                                                        
sakthimurugan@magi e10-gatewayapi-tls %
```