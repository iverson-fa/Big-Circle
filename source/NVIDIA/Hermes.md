# Hermes 

## 1 HDMI

## 2 EEPROM

## 3 PHY

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