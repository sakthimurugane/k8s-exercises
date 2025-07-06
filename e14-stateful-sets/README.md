# Statefulsets in Kubernetes cluster

✅ StatefulSet = pods with stable network identity, stable storage, and ordered (graceful) scaling.
✅ Headless Service = gives each pod its own DNS entry (pod-0.service.namespace.svc.cluster.local).

📦 Sample: StatefulSet with Headless Service

This example uses Nginx replicas that write data to persistent volumes

## 📝 1️⃣ Headless Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  clusterIP: None  # 👈 Headless!
  selector:
    app: nginx
  ports:
  - port: 80
    name: web
```

## 📝 2️⃣ StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nginx
spec:
  serviceName: "nginx"  # 👈 Match the headless service
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: local-path  # 👈 Or default StorageClass
      resources:
        requests:
          storage: 1Gi
```