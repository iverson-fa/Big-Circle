# PCIe Endpoint Mode

## 1 简介

按照 NVIDIA 的说法，Orin 模组的工作方式分为 `Root port` 和 `Endpoint` 两种。Hermes 上的模组已配置为 EP 模式，可以与 X86 模组通过 PCIe 进行通信。Orin 模组作为 EP 支持 共享内存 和 Ethernet 两种工作方式，即作为扩展 RAM 或者通过以太网通信设备来使用，下面分别对这两种使用方式进行介绍。

## 2 共享内存 

1）在 Orin 模组上使用如下脚本激活 EP 模式：

```shell
#!/bin/bash
cd /sys/kernel/config/pci_ep/
mkdir functions/pci_epf_nv_test/func1
echo 0x10de > functions/pci_epf_nv_test/func1/vendorid
echo 0x0001 > functions/pci_epf_nv_test/func1/deviceid
ln -s functions/pci_epf_nv_test/func1 controllers/141a0000.pcie_ep/
echo 1 > controllers/141a0000.pcie_ep/start
```

2）重启 X86，执行 `lspci | grep NVIDIA`，出现如下信息说明配置成功：

```bash
06:00.0 RAM memory: NVIDIA Corporation Device 0001
```

3）测试

使用直接读写本地内存的工具进行测试，本次测试使用 busybox。

```bash
# 安装工具
$ sudo apt install busybox pciutils
# 记录 BAR0 RAM phys地址，以下简记为``<BAR0_RAM_phys>``
$ sudo dmesg | grep pci_epf_nv_test
# 读该地址的值
$ busybox devmem ``<BAR0_RAM_phys>``
# 写该地址的值
$ busybox devmem ``<BAR0_RAM_phys>`` 32 0xfa950000
```





## 3 通过以太网方式通信

1）在 Orin 模组上使用如下脚本激活 EP 模式：

```shell
#!/bin/bash 
cd /sys/kernel/config/pci_ep/
mkdir functions/pci_epf_tvnet/func1
echo 16 > functions/pci_epf_tvnet/func1/msi_interrupts
ln -s functions/pci_epf_tvnet/func1 controllers/141a0000.pcie_ep/
echo 1 > controllers/141a0000.pcie_ep/start
```

2）在 X86 上解压 `tvnet.zip`，执行如下命令安装此驱动：

```bash 
$ make
$ sudo insmod tegra_vnet.ko
# 查看是否安装成功
$ sudo lsmod | grep -i tegra
```

3）重启 X86，在 X86 执行 `lspci | grep NVIDIA`，出现如下信息说明配置成功：

```bash
06:00.0 Network controller: NVIDIA Corporation Device 2296
```

此时通过 `ifconfig`可以看到扩展的网卡，名为 eth0、eth1等，配置几个 Orin 模组就会出现几个ethX。以 eth1 为例配置静态IP：

```bash
On Orin system: ifconfig eth1 up
On X86 system: ifconfig eth1 up
On Orin system: ifconfig eth1 192.168.2.11
On X86 system: ifconfig eth1 192.168.2.22
```

4）此时 X86 和各 Orin 之间可以 ping 通，但是 Orin 之间不能 ping 通，可以通过在 X86 上搭建网桥的方式实现各 Orin 间通信，若用户无此需求，可以不做配置，若有此需求，执行以下脚本（以两个 Orin 为例）：

```shell
#! /bin/bash
brctl addbr br0
ifconfig eth0 0 up
ifconfig eth1 0 up
brctl addif br0 eth0 eth1
ifconfig br0 192.168.2.2/24 up
#route add default gw 192.168.2.1
iptables -A FORWARD -i br0 -o br0 -j ACCEPT
```
5）Hermes 在使用 Orin EP 模式下的 IP 使用 netplan 工具的 yaml 文件配置，在 Ubuntu 20.04 中，使用如下格式配置：
```shell
# 安装工具
$ sudo apt install netplan.io
$ sudo vim /etc/netplan/cfg.yaml
# yaml 内容
network:
    version: 2
    renderer: networkd
    ethernets:
        eth0:
            addresses:
                - 192.168.3.1/24
            gateway4: 192.168.3.1
            nameservers:
                addresses: [114.114.114.114, 8.8.8.8]
$ sudo apt netplan apply
```
5个模组的 IP 配置如下：

| 模组 | 用户名 | IP |
| -- | -- | -- |
| X86 | inspur  | 192.168.3.1 |
| Orin | orin-a | 192.168.3.2 |
| Orin | orin-b | 192.168.3.3 |
| Orin | orin-c | 192.168.3.4 |
| Orin | orin-d | 192.168.3.5 |


