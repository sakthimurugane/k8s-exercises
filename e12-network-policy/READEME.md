# Lets learn about network policies in K8s
KinD cluser uses default CNI called kindnet and it doesn't support network policies fully.

## 1️⃣ Install Calico
Install Calico by using the following command.

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/calico.yaml
```
console output after installation
```bash
sakthimurugan@MacBookPro e12-network-policy % kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/calico.yaml
poddisruptionbudget.policy/calico-kube-controllers created
serviceaccount/calico-kube-controllers created
serviceaccount/calico-node created
serviceaccount/calico-cni-plugin created
configmap/calico-config created
customresourcedefinition.apiextensions.k8s.io/bgpconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/bgpfilters.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/bgppeers.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/blockaffinities.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/caliconodestatuses.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/clusterinformations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/felixconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworksets.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/hostendpoints.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamblocks.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamconfigs.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamhandles.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ippools.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipreservations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/kubecontrollersconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networksets.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/stagedglobalnetworkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/stagedkubernetesnetworkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/stagednetworkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/tiers.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/adminnetworkpolicies.policy.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/baselineadminnetworkpolicies.policy.networking.k8s.io created
clusterrole.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrole.rbac.authorization.k8s.io/calico-node created
clusterrole.rbac.authorization.k8s.io/calico-cni-plugin created
clusterrole.rbac.authorization.k8s.io/calico-tier-getter created
clusterrolebinding.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrolebinding.rbac.authorization.k8s.io/calico-node created
clusterrolebinding.rbac.authorization.k8s.io/calico-cni-plugin created
clusterrolebinding.rbac.authorization.k8s.io/calico-tier-getter created
daemonset.apps/calico-node created
deployment.apps/calico-kube-controllers created
sakthimurugan@MacBookPro e12-network-policy % 
```

Verify Calico installation
 ```bash
 watch kubectl get pods -l k8s-app=calico-node -A
```

## 2️⃣ Deploy sample application

```bash
kubectl create namespace np-test

# Pod A
kubectl run pod-a --image=busybox --restart=Never -n np-test -- sleep 3600

# Pod B
kubectl run pod-b --image=busybox --restart=Never -n np-test -- sleep 3600

# Service + Pod
kubectl run nginx --image=nginx --restart=Never -n np-test
kubectl expose pod nginx --port=80 -n np-test
```

## 3️⃣ Create a NetworkPolicy
This allows only pod-a to access nginx:
 ```bash
 cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-pod-a
  namespace: np-test
spec:
  podSelector:
    matchLabels:
      run: nginx
  ingress:
  - from:
    - podSelector:
        matchLabels:
          run: pod-a
    ports:
    - protocol: TCP
      port: 80
  policyTypes:
  - Ingress
EOF
```

## 4️⃣ Test the policy
Exec into the pods and try to curl the nginx service:

✅ From pod-a (should succeed):
```bash
kubectl exec -n np-test pod-a -- wget -qO- nginx
```

❌ From pod-b (should fail):
```bash
kubectl exec -n np-test pod-b -- wget -qO- nginx
```

If the NetworkPolicy is enforced correctly, pod-b’s curl will fail.
