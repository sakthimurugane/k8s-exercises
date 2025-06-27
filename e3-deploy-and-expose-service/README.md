
Build docker image and push to local registry

```bash
docker build -t cart-nginx:1.0.1 ../commons/cart-app

kind load docker-image cart-nginx:1.0.1

kubectl apply -f cart-app-deployment.yaml
```

Service is exposed on port 80 and can be access via node port 30050

since the worker node is running as container as the docker machine, we can access the service via localhost:30051

```bash
curl http://localhost:30051

curl http://localhost:30052
```