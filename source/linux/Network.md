# Network

## 1 网络分享

B -> A -> www

```shell
# on A
export eth_share=eth1
export eth_net=eth0
ifconfig $eth_share 192.168.3.1/24
# 新命令：ip addr add 192.168.3.1/24 dev $eth_share
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
# 新命令：ip addr add 192.168.3.2/24 dev $eth_www
route add -net 0.0.0.0/0 gw 192.168.3.1
# 新命令：ip route add default via 192.168.3.1
chmod +666 /etc/resolv.conf
echo "nameserver 114.114.114.114" > /etc/resolv.conf
```

## 2 双网卡冲突

```shell
# route -n（新命令：ip route）
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

## 3 ip route 和 ip rule

`ip rule` 和 `ip route` 是 Linux 中用于网络路由管理的重要工具，它们提供了对路由规则和路由表的细致控制。以下是这些命令的概述和常见用法：

### **`ip rule`**（用于管理策略路由）

`ip rule` 用于创建、删除或查看路由规则。这些规则决定了如何根据源地址、目标地址、接口等条件选择路由表。可以通过 `ip rule` 配置更复杂的路由策略。

#### **常用命令：**

1. **查看当前策略路由规则：**
   ```bash
   ip rule show
   ```
   显示当前所有的路由规则。

2. **添加新的策略路由规则：**
   ```bash
   ip rule add from <source_ip> table <table_id> [other_conditions]
   ```
   添加一个基于源地址的规则，例如：
   ```bash
   ip rule add from 192.168.1.0/24 table 100
   ```
   这个规则表示：所有源地址为 `192.168.1.0/24` 的流量都会查找路由表 `100`。

3. **删除策略路由规则：**
   ```bash
   ip rule del from <source_ip> table <table_id> [other_conditions]
   ```
   删除指定的路由规则，例如：
   ```bash
   ip rule del from 192.168.1.0/24 table 100
   ```

4. **添加基于目标地址的规则：**
   ```bash
   ip rule add to <destination_ip> table <table_id>
   ```
   例如：
   ```bash
   ip rule add to 10.0.0.0/8 table 200
   ```
   这条规则表示：所有目标为 `10.0.0.0/8` 的流量会查找路由表 `200`。

5. **添加规则指定接口：**
   ```bash
   ip rule add iif <interface> table <table_id>
   ```
   例如：
   ```bash
   ip rule add iif eth0 table 300
   ```
   这条规则表示：来自接口 `eth0` 的流量会查找路由表 `300`。

6. **设置规则优先级：**
   可以使用 `priority` 来设置规则的优先级：
   ```bash
   ip rule add from <source_ip> table <table_id> priority <priority_number>
   ```
   例如：
   ```bash
   ip rule add from 192.168.1.0/24 table 100 priority 100
   ```

### **`ip route`**（用于管理路由表）

`ip route` 用于显示、添加、删除和修改路由表中的条目。它支持多路由表、策略路由、默认网关设置等。

#### **常用命令：**

1. **查看路由表：**
   ```bash
   ip route show
   ```
   或者简写：
   ```bash
   ip r
   ```
   显示所有路由表条目，包括默认网关、路由表和接口。

2. **添加默认路由：**
   ```bash
   ip route add default via <gateway_ip> dev <interface> metric <metric_value>
   ```
   例如：
   ```bash
   ip route add default via 10.16.10.1 dev eth0 metric 100
   ```
   这表示通过 `eth0` 接口将流量发送到 `10.16.10.1` 网关，`metric` 用于设置路由优先级。

3. **添加具体路由：**
   ```bash
   ip route add <destination_network> via <gateway_ip> dev <interface> metric <metric_value>
   ```
   例如：
   ```bash
   ip route add 10.0.0.0/8 via 10.16.10.1 dev eth0 metric 100
   ```
   这条命令添加了一条路由，使得 `10.0.0.0/8` 的流量通过 `10.16.10.1` 网关，并使用 `eth0` 接口。

4. **删除路由：**
   ```bash
   ip route del <destination_network> via <gateway_ip> dev <interface>
   ```
   例如：
   ```bash
   ip route del 10.0.0.0/8 via 10.16.10.1 dev eth0
   ```

5. **添加路由到特定路由表：**
   如果你使用多个路由表，可以指定某个路由表：
   ```bash
   ip route add <destination_network> via <gateway_ip> dev <interface> table <table_id>
   ```
   例如：
   ```bash
   ip route add 10.0.0.0/8 via 10.16.10.1 dev eth0 table 100
   ```

6. **设置路由优先级（通过 metric）：**
   使用 `metric` 设置优先级，值越小优先级越高。例如：
   ```bash
   ip route add 10.0.0.0/8 via 10.16.10.1 dev eth0 metric 50
   ```

7. **查看指定路由表：**
   如果你在使用多个路由表，可以查看指定的路由表：
   ```bash
   ip route show table <table_id>
   ```
   例如：
   ```bash
   ip route show table 100
   ```

8. **清空路由表：**
   删除所有路由条目：
   ```bash
   ip route flush table <table_id>
   ```
   例如：
   ```bash
   ip route flush table 100
   ```

### **`ip rule` 和 `ip route` 配合使用**

`ip rule` 和 `ip route` 可以结合使用来实现策略路由。比如，你可以使用 `ip rule` 设置基于源地址、目标地址或接口的路由规则，然后使用 `ip route` 来管理相应的路由表。

#### **示例：**
1. 创建一个新的路由表（例如 `100`）并添加路由：
   ```bash
   ip route add 192.168.1.0/24 via 10.16.10.1 dev eth1 table 100
   ```

2. 创建一条规则，指定所有来自 `192.168.1.0/24` 的流量使用 `table 100`：
   ```bash
   ip rule add from 192.168.1.0/24 table 100
   ```

3. 查看路由规则和路由表：
   ```bash
   ip rule show
   ip route show table 100
   ```
4. 举例

如果 eth1 需要单独处理某些流量（比如特定服务），可以为它设置专用的 ip rule：
```bash
# 10.16.10.101 是 eth1 的 IP，请替换为实际 IP
sudo ip rule add from 10.16.10.101 lookup 200
sudo ip route add default via 10.16.10.1 dev eth1 table 200
```
---

### **总结：**

- **`ip rule`** 用于管理**策略路由**，根据源地址、目标地址、接口等条件选择路由表。
- **`ip route`** 用于管理**路由表**，包括添加、删除和修改路由条目，可以实现更具体的流量控制。
- 通过将这两个工具结合使用，可以实现复杂的路由策略，如基于不同条件选择不同路由表，或根据优先级实现流量的动态路由。

这两个工具结合使用，可以提供非常强大的灵活性，尤其是在多网卡、复杂网络拓扑和策略路由的环境中。

## 4 同一网段双网卡避免回程流量不一致

### **目标**
- **`eth0`（10.16.10.17/24）** 负责上网，默认路由通过 `eth0` 发送外部流量。
- **`eth1`（10.16.10.152/24）** 负责局域网 `10.16.10.0/24` 的流量，只用于内部通信。

---

### **配置步骤**
#### **1. 删除可能的默认冲突路由**
首先检查是否已经有 `eth1` 影响 `10.16.10.0/24` 的流量：
```bash
ip route show
```
如果 `eth1` 也有 `10.16.10.0/24` 的默认路由，需要删除：
```bash
sudo ip route del 10.16.10.0/24 dev eth0
```

---

#### **2. 设置默认路由走 `eth0`（用于上网）**
```bash
sudo ip route add default via 10.16.10.1 dev eth0 metric 100
```
这里：
- `10.16.10.1` 是默认网关（请确认你的网关地址是否正确）。
- `metric 100` 确保 `eth0` 的默认路由优先级高于其他可能的路由。

---

#### **3. 设置 `10.16.10.0/24` 流量走 `eth1`**
```bash
sudo ip route add 10.16.10.0/24 dev eth1 metric 50
```
- `metric 50` 让 `eth1` 优先处理 `10.16.10.0/24` 的流量（比默认路由 `metric 100` 更优先）。

---

#### **4. 配置 `ip rule` 让回程流量一致**
**如果 `eth1` 处理的 `10.16.10.0/24` 设备可能回程走 `eth0`，可能导致不对称路由。可以使用 `ip rule` 让 `10.16.10.152`（`eth1`）的流量强制回程 `eth1`。**

```bash
# 创建一个新的路由表
echo "200 eth1_table" | sudo tee -a /etc/iproute2/rt_tables

# 让 eth1 的流量回程走 eth1
sudo ip rule add from 10.16.10.152 table eth1_table
sudo ip route add default via 10.16.10.1 dev eth1 table eth1_table
```

这样：
- **从 `eth1`（10.16.10.152）发送的流量，会回程走 `eth1`，不会影响 `eth0`。**
- **所有其他流量仍然走 `eth0`，不会影响上网。**

---

### **验证配置**
#### **1. 检查路由**
```bash
ip route show
```
应该看到：
```
default via 10.16.10.1 dev eth0 metric 100
10.16.10.0/24 dev eth1 metric 50
```

#### **2. 检查 `ip rule`**
```bash
ip rule show
```
应该看到：
```
0:      from all lookup local
32765:  from 10.16.10.152 lookup eth1_table
32766:  from all lookup main
32767:  from all lookup default
```

#### **3. 测试**
- 测试上网是否通过 `eth0`：
  ```bash
  curl --interface eth0 http://ifconfig.me
  ```
- 测试 `eth1` 是否处理 `10.16.10.0/24` 的流量：
  ```bash
  ping -I eth1 10.16.10.100
  ```
- 测试回程流量：
  ```bash
  ip route get 8.8.8.8 from 10.16.10.152
  ```
  **输出应该显示流量走 `eth1`。**

---

### **总结**
✅ **默认流量（上网）通过 `eth0`**
✅ **局域网流量 `10.16.10.0/24` 通过 `eth1`**
✅ **回程流量保持一致，避免不对称路由问题**