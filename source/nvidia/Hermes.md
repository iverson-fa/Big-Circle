# Hermes

## 1 Docs Index

- [米文双Orin手册](https://doc.miivii.com/Apex-Dual-Orin-User-Manual-CH/index.html)

## 2 HDMI

## 3 EEPROM

## 4 PHY

```sh
#! /bin/bash
./mdio-tool r eth0 0x16
./mdio-tool r eth0 0x2
./mdio-tool w eth0 0x16 0x0012
./mdio-tool r eth0 0x16
./mdio-tool r eth0 0x14
./mdio-tool w eth0 0x14 0x2
./mdio-tool r eth0 0x14
./mdio-tool w eth0 0x16 0x0
./mdio-tool w eth0 0x0 0x140
./mdio-tool w eth0 0x0 0x8140
./mdio-tool r eth0 0x0
```

注意网卡的名字不一定是`eth0`，根据mac地址来区分: `48:b0:2d:78:85:6c`

预期结果为：
```sh
0x0000
0x0141
0x0012
0x0007
0x0002
0x0140
```

修改后的脚本：

```sh
#!/bin/bash

# 目标 MAC 地址前三个字段
TARGET_MAC_PREFIX="48:b0:2d"

# 查找网卡名称（匹配 MAC 地址前缀）
NET_IFACE=$(ip -o link | awk -v prefix="$TARGET_MAC_PREFIX" '$0 ~ prefix {print $2}' | tr -d ':')

# 检查是否找到对应网卡
if [ -z "$NET_IFACE" ]; then
    echo "错误: 找不到MAC地址前缀为 $TARGET_MAC_PREFIX 的网卡。"
    exit 1
else
    echo "找到网卡: $NET_IFACE"
fi

# 使用找到的网卡名称运行 mdio-tool
./mdio-tool r $NET_IFACE 0x16
./mdio-tool r $NET_IFACE 0x2
./mdio-tool w $NET_IFACE 0x16 0x0012
./mdio-tool r $NET_IFACE 0x16
./mdio-tool r $NET_IFACE 0x14
./mdio-tool w $NET_IFACE 0x14 0x2
./mdio-tool r $NET_IFACE 0x14
./mdio-tool w $NET_IFACE 0x16 0x0
./mdio-tool w $NET_IFACE 0x0 0x140
./mdio-tool w $NET_IFACE 0x0 0x8140
./mdio-tool r $NET_IFACE 0x0

# 配置IP地址和网关
IP_ADDR="192.168.2.2"
GATEWAY="192.168.2.1"
NETMASK="255.255.255.0"

echo "配置 $NET_IFACE 的 IP 地址为 $IP_ADDR ..."
ip addr flush dev $NET_IFACE  # 清除已有 IP
ip addr add $IP_ADDR/$NETMASK dev $NET_IFACE
ip link set $NET_IFACE up

# 配置网关
echo "设置网关为 $GATEWAY ..."
ip route add default via $GATEWAY dev $NET_IFACE

echo "网络配置完成！"
```