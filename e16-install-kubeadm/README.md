## Install the kubeadm and kubelet packages on the controlplane and node01 nodes.
Use the exact version of ```1.33.0-1.1``` for both.

These steps have to be performed on both nodes.

set net.bridge.bridge-nf-call-iptables to 1:

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
```

🌉 What is br_netfilter?

    br_netfilter is a Linux kernel module.

    It enables bridge network traffic to be visible to iptables rules.

    This is critical for Kubernetes networking (especially when using kube-proxy in iptables mode and CNI plugins).

Without br_netfilter, Kubernetes might not see traffic between pods on the same node (since Linux bridges bypass iptables by default).

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
```

🌉 What do these sysctl settings mean?

    Parameter	Value	Purpose

    net.bridge.bridge-nf-call-ip6tables	1	Ensures IPv6 traffic on Linux bridges is passed to ip6tables for filtering.

    net.bridge.bridge-nf-call-iptables	1	Ensures IPv4 traffic on Linux bridges is passed to iptables for filtering.

```bash
sudo sysctl --system
```

Install kubeadm, kubectl and kubelet on all nodes:
```bash
sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

# To see the new version labels
sudo apt-cache madison kubeadm

sudo apt-get install -y kubelet=1.33.0-1.1 kubeadm=1.33.0-1.1 kubectl=1.33.0-1.1

sudo apt-mark hold kubelet kubeadm kubectl
```

🗂 apt-mark

This tool is used to change or view the “mark” (status) of packages for the package manager.

Some common marks:

    install: package is installed normally.

    hold: prevents upgrades.

    unhold: removes hold.

🛑 What is “hold”?

When a package is held, APT:

    Will not upgrade it automatically.

    Still allows you to manually install a different version if you choose.
    
## Task 2:

Initialize Control Plane Node (Master Node). Use the following options:


```apiserver-advertise-address``` - Use the IP address allocated to ```eth0``` on the controlplane node

```apiserver-cert-extra-sans``` - Set it to ```controlplane```

```pod-network-cidr``` - Set to ```172.17.0.0/16```

```service-cidr``` - Set to ```172.20.0.0/16```

Once done, set up the default kubeconfig file and wait for node to be part of the cluster.

Run ```kubeadm init --apiserver-cert-extra-sans=controlplane --apiserver-advertise-address 192.217.72.10 --pod-network-cidr=172.17.0.0/16 --service-cidr=172.20.0.0/16```

The IP address used here is just an example. 

```bash
root@controlplane:~# ifconfig eth0
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1450
        inet 192.217.72.10  netmask 255.255.255.0  broadcast 192.217.72.255
        ether 02:42:c0:d9:48:0a  txqueuelen 0  (Ethernet)
        RX packets 4730  bytes 674845 (674.8 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 4550  bytes 1572687 (1.5 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

root@controlplane:~#
```
```bash
kubeadm join 192.168.104.49:6443 --token teluya.w62q7yxl598dz109 \
        --discovery-token-ca-cert-hash sha256:92306d82fe7bce73c76f5dbab532bfc129514d86ac9266ff24693004f1b0ea9a 
```
once the command has been run successfully, set up the kubeconfig:

```bash
mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

On the controlplane node, run the following set of commands to deploy the network plugin:

Download the original YAML file and save it as ```kube-flannel.yml```:
```bash
curl -LO https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml
```
Open the ```kube-flannel.yml``` file using a text editor.

We are using a custom ```PodCIDR (172.17.0.0/16)``` instead of the default ```10.244.0.0/16``` when bootstrapping the Kubernetes cluster. However, the Flannel manifest by default is configured to use ```10.244.0.0/16``` as its network, which does not align with the specified PodCIDR. To resolve this, we need to update the Network field in the kube-flannel-cfg ConfigMap to match the custom PodCIDR defined during cluster initialization.
```yaml
net-conf.json: |
    {
      "Network": "10.244.0.0/16", # Update this to match the custom PodCIDR
      "Backend": {
        "Type": "vxlan"
      }
```

Locate the args section within the kube-flannel container definition. It should look like this:
```yaml
  args:
  - --ip-masq
  - --kube-subnet-mgr

```
Add the additional argument ```- --iface=eth0``` to the existing list of arguments.

Now apply the modified manifest kube-flannel.yml file using kubectl:
```bash
kubectl apply -f kube-flannel.yml
```

After applying the manifest, wait for all the pods to become in the Ready state. You can use the watch command to monitor the pod status:

```bash
watch kubectl get pods -A

controlplane ~ ➜  kubectl get pods -A
NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
kube-flannel   kube-flannel-ds-gc5kf                  1/1     Running   0          54s
kube-flannel   kube-flannel-ds-mtjd6                  1/1     Running   0          54s
kube-system    coredns-668d6bf9bc-7lf7s               1/1     Running   0          3m31s
kube-system    coredns-668d6bf9bc-jl8t6               1/1     Running   0          3m31s
kube-system    etcd-controlplane                      1/1     Running   0          3m37s
kube-system    kube-apiserver-controlplane            1/1     Running   0          3m37s
kube-system    kube-controller-manager-controlplane   1/1     Running   0          3m37s
kube-system    kube-proxy-t5wrt                       1/1     Running   0          3m31s
kube-system    kube-proxy-trmhs                       1/1     Running   0          3m8s
kube-system    kube-scheduler-controlplane            1/1     Running   0          3m37s
```
After all the pods are in the Ready state, the status of both nodes should now become Ready:

```bash
controlplane ~ ➜  kubectl get nodes 
NAME           STATUS   ROLES           AGE   VERSION 
controlplane   Ready    control-plane   15m   v1.33.0 
node01         Ready    <none>          15m   v1.33.0 
```
