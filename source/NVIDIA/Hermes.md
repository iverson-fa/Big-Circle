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

# 目标 MAC 地址
TARGET_MAC="48:b0:2d:78:85:6c"

# 查找网卡名称
NET_IFACE=$(ip -o link | grep "$TARGET_MAC" | awk -F': ' '{print $2}')

# 检查是否找到对应网卡
if [ -z "$NET_IFACE" ]; then
    echo "错误: 找不到MAC地址为 $TARGET_MAC 的网卡。"
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
```