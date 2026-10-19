# ip/ss 命令

`ip` 和 `ss` 均来自 **iproute2** 包，基于 netlink 接口，取代 2001 年起废弃的 net-tools。

## 1 新旧命令对照

| 旧命令 (net-tools) | 新命令 (iproute2) | 功能 |
|---|---|---|
| `ifconfig` | `ip addr` / `ip link` | 查看/配置网卡与地址 |
| `ifconfig eth0 up` | `ip link set eth0 up` | 启用网卡 |
| `ifconfig eth0 192.168.1.10/24` | `ip addr add 192.168.1.10/24 dev eth0` | 配置 IP 地址 |
| `route` / `route -n` | `ip route` | 查看/管理路由表 |
| `arp` / `arp -n` | `ip neigh` | 查看/管理 ARP 邻居表 |
| `netstat` | `ss` | 查看网络状态 |
| `netstat -r` | `ip route` | 查看路由表 |
| `netstat -i` | `ip -s link` | 查看网卡收发统计 |
| `netstat -lntp` | `ss -lntp` | 查看所有监听端口 |
| `netstat -antp` | `ss -antp` | 查看所有已经建立的连接 |
| `netstat -s` | `ss -s` | 查看网络统计信息 |
| `iwconfig` | `iw`（另一套，wireless-tools） | 无线网卡配置 |

## 2 ip 常用命令

### 2.1 网卡管理（ip link）

```bash
ip link show                    # 查看所有网络接口（相当于 ifconfig -a 的接口部分）
ip link show eth0               # 查看指定接口
ip -s link show eth0            # 查看接口 statistics（相当于 netstat -i）
ip -s -s link show eth0         # statistics 带错误/丢包明细
ip link set eth0 up             # 启用接口（相当于 ifconfig eth0 up）
ip link set eth0 down           # 禁用接口
ip link set eth0 mtu 9000       # 设置 MTU（巨帧）
ip link set eth0 name eth100    # 重命名接口
ip link add dev can0 type can   # 添加 CAN 接口
```

### 2.2 IP 地址管理（ip addr）

```bash
ip addr show                    # 查看所有接口的 IP 地址
ip addr show dev eth0           # 查看指定接口
ip addr add 192.168.1.10/24 dev eth0     # 添加地址（可叠加多个）
ip addr add 192.168.1.11/24 dev eth0 label eth0:1  # 添加别名地址
ip addr del 192.168.1.10/24 dev eth0     # 删除地址
ip addr flush dev eth0          # 清空接口所有地址
ip -4 addr show                 # 只显示 IPv4
ip -6 addr show                 # 只显示 IPv6
```

### 2.3 路由管理（ip route）

```bash
ip route show                   # 查看路由表（相当于 route -n）
ip route                        # 同上
ip route add default via 192.168.1.1 dev eth0     # 添加默认网关
ip route add 10.0.0.0/8 via 192.168.1.254         # 添加静态路由
ip route add 192.168.4.0/24 via 192.168.0.254 dev eth0
ip route del default            # 删除默认路由
ip route del 10.0.0.0/8         # 删除静态路由
ip route change default via 10.0.0.2 dev eth0     # 修改默认路由
ip route replace default via 10.0.0.2 dev eth0    # 无则加，有则改（推荐）
ip route get 8.8.8.8            # 查询到指定地址实际走的路由
```

`ifconfig` 设置的地址重启丢失；持久化需写入 netplan / systemd-networkd / `/etc/network/interfaces`。

### 2.4 策略路由（ip rule + table）

```bash
ip rule show                    # 查看路由策略（rpdb）
ip rule add from 192.168.2.0/24 table 100        # 源地址走 table 100
ip rule add from 192.168.2.10/32 table 100 priority 100
ip route add default via 192.168.2.1 dev eth1 table 100
ip route flush table 100        # 清空 table 100
ip rule del from 192.168.2.0/24 table 100        # 删除规则
```

多路由表共存时，`ip rule` 按 priority 从小到大匹配，命中后查 `table N`。

### 2.5 邻居表/ARP（ip neigh）

```bash
ip neigh show                   # 查看 ARP/邻居表（相当于 arp -n）
ip neigh show dev eth0          # 查看指定接口
ip neigh del 192.168.1.1 dev eth0     # 删除指定邻居表项
ip neigh flush all              # 清空所有邻居表
```

### 2.6 其他常用

```bash
ip maddr show                   # 查看组播地址
ip tunnel show                  # 查看隧道（ipip/gre 等）
ip netns list                   # 列出网络命名空间
ip netns exec ns1 ip addr       # 在指定 netns 里执行命令
ip monitor                      # 实时监听 netlink 事件（地址/路由变化）
ip -c addr                      # 彩色输出
ip -br addr                     # brief 输出（一行一接口）
ip -br link                     # brief 接口状态
```

## 3 ss 常用命令

### 3.1 总览

```bash
ss                             # 查看所有连接
ss -t                          # TCP 连接
ss -u                          # UDP 连接
ss -x                          # Unix socket
ss -s                          # 统计摘要（相当于 netstat -s）
```

### 3.2 监听端口

```bash
ss -lntp                       # 查看所有监听端口（含进程名）
ss -lun                        # 监听中的 UDP
ss -lnp 'sport = :22'          # 只看 22 端口
```

### 3.3 连接状态过滤

```bash
ss -antp                       # 查看所有已经建立的连接
ss -tan state established      # ESTABLISHED 状态
ss -tan state time-wait        # TIME-WAIT 统计
ss -tan '( dst 192.168.1.0/24 )'    # 按目标网段过滤
ss -tn dst 10.0.0.1            # 按目标 IP 过滤
ss -o state established '( dport = :443 )'    # HTTPS 连接带 timer 信息
```

### 3.4 进程关联

```bash
ss -tnp                        # 显示连接对应的进程
ss -tnp | grep sshd            # 找出 sshd 的连接
```

`-p` 需要 root 权限才能看到所有进程信息。

### 3.5 与 netstat 参数对照

| netstat | ss | 功能 |
|---|---|---|
| `netstat -a` | `ss -a` | 所有 socket |
| `netstat -t` | `ss -t` | TCP |
| `netstat -u` | `ss -u` | UDP |
| `netstat -l` | `ss -l` | 监听中 |
| `netstat -n` | `ss -n` | 不解析域名 |
| `netstat -p` | `ss -p` | 显示进程 |
| `netstat -e` | `ss -e` | 扩展信息 |
| `netstat -r` | `ip route` | 路由表 |
| `netstat -i` | `ip -s link` | 接口统计 |
| `netstat -M` | `ss -M` | masqueraded 连接 |

## 4 为什么迁移到 iproute2

1. **net-tools 已废弃**：2001 年起 Linux 内核转向 netlink，net-tools 无法获取内核新特性（策略路由、多路由表、VLAN、隧道等）
2. **功能覆盖更全**：`ip rule`/`ip route table` 实现策略路由，net-tools 完全不支持
3. **性能更好**：net-tools 依赖 `/proc` 文件系统，遍历慢；iproute2 通过 netlink socket 与内核交互，支持增量过滤
4. **输出可编程**：`ip -json addr` 输出 JSON，方便脚本处理（net-tools 只能靠 grep/awk 解析）

## 5 持久化配置

`ip` 命令的修改都是临时的（重启丢失），持久化方式：

```bash
# Ubuntu 22.04+（netplan）
sudo nano /etc/netplan/01-netcfg.yaml
sudo netplan apply

# systemd-networkd
# /etc/systemd/network/10-eth0.network
sudo systemctl restart systemd-networkd

# 传统方式（Debian/旧系统）
# /etc/network/interfaces
sudo systemctl restart networking
```
