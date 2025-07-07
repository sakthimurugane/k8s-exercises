# 🌉 In Kubernetes

## Kubernetes uses IP masquerading in:

    kube-proxy

    CNI plugins
    To let pods communicate with the outside world via the node’s IP.

There’s even a config ```file: /etc/kubernetes/ip-masq-agent``` for controlling which CIDRs should not be masqueraded (to avoid NAT inside the cluster).

## In Linux, IP masquerading is done using the iptables NAT table:

```bash
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

Here:

- ```-t``` nat: use NAT table.
- ```POSTROUTING```: modify packets leaving the system.
- ```-o``` eth0: apply to packets going out interface eth0.
- ```MASQUERADE```: rewrite source IP to the outgoing interface’s IP.


# 🧑‍💻 What is kube-proxy?

    ✅ kube-proxy runs on every node in a Kubernetes cluster.
    ✅ It manages network rules that allow:
    Pods to communicate with Services.
    Load balancing traffic to backend Pods.

It implements Service networking by programming rules into the OS.

 ## 🟢 1️⃣ Userspace mode (oldest, legacy)
 The default mode in early Kubernetes versions.

Works by running a userspace proxy:

    Listens on Service Cluster IPs and ports.
    Accepts incoming traffic.
    Looks up a backend Pod.
    Opens a new connection to that Pod.
    Forwards traffic between client and Pod.

📉 Downsides

    ❌ Extra hop (proxy process) → slower.
    ❌ Can’t handle high traffic well.
    ❌ Deprecated in most environments.

## 🟡 2️⃣ iptables mode (default in most clusters)

Uses Linux iptables rules for NAT (Network Address Translation).

kube-proxy programs iptables rules:

    Service IP maps to a random Pod IP (DNAT).
    Randomized Pod selection for load-balancing.

### ⚡ How it works
 ```bash
 ClusterIP:Port → PodIP:Port
 ```

✅ Advantages

    ✅ No userspace hop – traffic flows directly to Pods.
    ✅ Scales better than userspace.

❗ Limitations

    iptables scales poorly when there are thousands of Services (rules get huge).
    Pod selection is random (probabilistic load balancing).

## 🔵 3️⃣ ipvs mode (modern, high-performance)

    Uses Linux IPVS (IP Virtual Server) kernel module.
    kube-proxy programs IPVS rules:

        Service IP handled by IPVS load balancer.
        Efficient kernel-level load balancing.
---
    rr	Round-robin (default)
    lc	Least connection
    dh	Destination hashing

✅ Advantages

    ✅ Handles thousands of Services efficiently.
    ✅ Faster connection setup and teardown.
    ✅ Connection tracking and health checking
