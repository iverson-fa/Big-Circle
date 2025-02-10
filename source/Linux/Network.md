# Network

## 1 网络分享

B -> A -> www

```shell
# on A
export eth_share=eth1
export eth_net=eth0
ifconfig $eth_share 192.168.3.1/24
bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
iptables -F
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -o $eth_net -j MASQUERADE
```
```shell
# on B
eth_www=eth2
ifconfig $eth_www 192.168.3.2/24
route add -net 0.0.0.0/0 gw 192.168.3.1
chmod +666 /etc/resolv.conf
echo "nameserver 114.114.114.114" > /etc/resolv.conf
```

## 2 双网卡冲突

```shell
# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.3.1     0.0.0.0         UG    0      0        0 eth0
0.0.0.0         10.126.59.254   0.0.0.0         UG    0      0        0 wlan0
```

显示 `eth0` 和 `wlan0` 都有默认网关 (`0.0.0.0`)，可能导致路由冲突或网络问题。

### **分析**
- **`eth0` 默认网关：`192.168.3.1`**
- **`wlan0` 默认网关：`10.126.59.254`**
- 由于 `0.0.0.0` 只能有一个默认路由，系统可能会随机选择其中一个，或者按优先级决定。

### **可能的影响**
1. **网络连接不稳定**
   - 系统可能会随机使用 `eth0` 或 `wlan0` 出网，导致网络连接时断时续。

2. **某些网络访问失败**
   - 可能有的流量从 `eth0` 走，有的从 `wlan0` 走，导致部分访问失败。

---

### **解决方案**
#### **方法 1：手动删除一个默认路由**
如果希望 **`eth0` 作为默认路由**，删除 `wlan0` 的默认路由：
```bash
sudo route del default gw 10.126.59.254 wlan0
```
如果希望 **`wlan0` 作为默认路由**，删除 `eth0` 的默认路由：
```bash
sudo route del default gw 192.168.3.1 eth0
```
但这样做 **重启后会恢复**，需要在 `/etc/network/interfaces` 或 `systemd-networkd` 里修改。

---

#### **方法 2：使用 `metric` 设定优先级**
可以让 `eth0` 的 `metric` 更小，优先使用有线：
```bash
sudo ip route change default via 192.168.3.1 dev eth0 metric 100
sudo ip route change default via 10.126.59.254 dev wlan0 metric 200
```
或者反过来，让 `wlan0` 优先：
```bash
sudo ip route change default via 10.126.59.254 dev wlan0 metric 100
sudo ip route change default via 192.168.3.1 dev eth0 metric 200
```
这样，系统会 **优先选择 `metric` 小的路由**。

---

#### **方法 3：使用 `ip rule` 和 `ip route` 分流**
如果你希望：
- **192.168.3.x 走 `eth0`**
- **其他流量走 `wlan0`**

可以这样设置：
```bash
# 给 wlan0 创建一个路由表 100
sudo ip rule add from 10.126.59.0/24 table 100
sudo ip route add default via 10.126.59.254 dev wlan0 table 100
```
这样 `eth0` 主要负责 `192.168.3.x`，而 `wlan0` 负责其他流量。

---

#### **方法 4：在 `/etc/network/interfaces` 配置**
如果你想 **永久修改默认网关**，可以在 `/etc/network/interfaces` 里设置：
```ini
auto eth0
iface eth0 inet static
    address 192.168.3.2
    netmask 255.255.255.0
    gateway 192.168.3.1
    metric 100

auto wlan0
iface wlan0 inet dhcp
    metric 200
```
然后重启网络：
```bash
sudo systemctl restart networking
```
或者：
```bash
sudo ifdown eth0 && sudo ifup eth0
```

---

### **总结**
- **如果只想用 `eth0` 上网** 👉 删除 `wlan0` 默认网关
- **如果只想用 `wlan0` 上网** 👉 删除 `eth0` 默认网关
- **如果希望 `eth0` 优先** 👉 设置 `metric`
- **如果想按 IP 段分流** 👉 使用 `ip rule` + `ip route`
- **如果要永久生效** 👉 修改 `/etc/network/interfaces`
