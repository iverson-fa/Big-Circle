# Linux
## 0 Doc_index

- [鸟哥 Linux 命令大全](https://man.niaoge.com/)
- [Packages for Linux and Unix](https://pkgs.org/)
- [coolshell](https://coolshell.cn/)
- [The Road of Full Stack](https://jason-xy.cn/)
- [The Linux Kernel Documents 5.10](https://www.kernel.org/doc/html/v5.10/index.html\#)
- [南方科技大学镜像站](https://mirrors.sustech.edu.cn/)
- [一文读懂systemd](https://zhuanlan.zhihu.com/p/643259265)

## 1 常用命令

```bash
# 查看内核版本
cat /proc/version
uname -a
uname -m && cat /etc/*release
# 查看显卡信息
lspci -vnn | grep VGA -A 12
lshw -C display
# cpu 型号
cat /proc/cpuinfo | grep 'model name' | sort | uniq
# cpu 颗数
cat /proc/cpuinfo | grep 'physical id' | sort | uniq | wc -l
# 每个cpu的核数
cat /proc/cpuinfo |grep "cores"|uniq|awk '{print $4}'
# 逻辑cpu核数
cat /proc/cpuinfo |grep "processor"|wc -l
# 更换系统源
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo sed -i 's/security.ubuntu/mirrors.aliyun/g' /etc/apt/sources.list
sudo sed -i 's/archive.ubuntu/mirrors.aliyun/g' /etc/apt/sources.list
sudo apt update
sudo apt-get upgrade	#更新已安装的包到最新，这个是可选的
head -n 1 /etc/issue # 查看操作系统版本
# 查看存储
cat /proc/meminfo
free -m #查看内存使用量和交换区使用量
grep MemTotal /proc/meminfo #查看内存总量
grep MemFree /proc/meminfo #查看空闲内存量
uptime #查看系统运行时间、用户数、负载

hostname # 查看计算机名
lspci -tv # 列出所有PCI设备
lsusb -tv # 列出所有USB设备
cat /proc/loadavg # 查看系统负载
mount | column -t # 查看挂接的分区状态
fdisk -l # 查看所有分区
swapon -s # 查看所有交换分区
iptables -L # 查看防火墙设置
route -n # 查看路由表
netstat -lntp # 查看所有监听端口
netstat -antp # 查看所有已经建立的连接
netstat -s # 查看网络统计信息
last # 查看用户登录日志
cut -d: -f1 /etc/passwd # 查看系统所有用户
cut -d: -f1 /etc/group # 查看系统所有组
crontab -l # 查看当前用户的计划任务
/usr/sbin/ffbconfig –rev \? # 测定当前的显示器刷新频率

#查看文件权限
# cut
stat <file> |sed -n '4p'|cut -f2 -d "("|cut -f1 -d "/"
# awk
stat <file> |sed -n '4p'|awk -F [\(/] '{print $2}'
# tr + cut
stat <file> |sed -n '4p'|tr -s "(/" " "|cut -f2 -d " "
# grep
stat <file> |sed -n '4p'|grep  -Eo '[0-9]{4}'
```
软件源：

- [中科大](http://mirrors.ustc.edu.cn/)
- [清华镜像站](https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/)
- [华为](https://mirrors.huaweicloud.com/home)
- [阿里云](https://developer.aliyun.com/mirror/)

```shell
# aliyun arm64 ubuntu20.04
deb https://mirrors.aliyun.com/ubuntu-ports/ focal main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu-ports/ focal main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu-ports/ focal-security main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu-ports/ focal-security main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu-ports/ focal-updates main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu-ports/ focal-updates main restricted universe multiverse

# deb https://mirrors.aliyun.com/ubuntu-ports/ focal-proposed main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu-ports/ focal-proposed main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu-ports/ focal-backports main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu-ports/ focal-backports main restricted universe multiverse

# aliyun arm64 ubuntu22.04

deb https://mirrors.aliyun.com/ubuntu-ports/ jammy main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu-ports/ jammy main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu-ports/ jammy-security main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu-ports/ jammy-security main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu-ports/ jammy-updates main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu-ports/ jammy-updates main restricted universe multiverse

# deb https://mirrors.aliyun.com/ubuntu-ports/ jammy-proposed main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu-ports/ jammy-proposed main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu-ports/ jammy-backports main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu-ports/ jammy-backports main restricted universe multiverse

# aliyun arm64 ubuntu24.04

deb https://mirrors.aliyun.com/ubuntu-ports/ noble main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu-ports/ noble main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu-ports/ noble-security main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu-ports/ noble-security main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu-ports/ noble-updates main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu-ports/ noble-updates main restricted universe multiverse

# deb https://mirrors.aliyun.com/ubuntu-ports/ noble-proposed main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu-ports/ noble-proposed main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu-ports/ noble-backports main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu-ports/ noble-backports main restricted universe multiverse

```

## 2 关于安装包

```shell
sudo apt-get update  # 更新源
sudo apt-get install package # 安装包
sudo apt-get remove package # 删除包
sudo apt-cache search package # 搜索软件包
sudo apt-cache show package  # 获取包的相关信息，如说明、大小、版本等
sudo apt-get install package --reinstall  # 重新安装包
sudo apt-get -f install  # 修复安装
sudo apt-get remove package --purge # 删除包，包括配置文件等
sudo apt-get build-dep package # 安装相关的编译环境
sudo apt-get upgrade # 更新已安装的包
sudo apt-get dist-upgrade # 升级系统
sudo apt-cache depends package # 了解使用该包依赖那些包
sudo apt-cache rdepends package # 查看该包被哪些包依赖
sudo apt-get source package  # 下载该包的源代码
sudo apt-get clean && sudo apt-get autoclean # 清理无用的包
sudo apt-get check # 检查是否有损坏的依赖
```
## 3 终端科学上网
```shell
export http_proxy='http://localhost:12333'   # http代理端口默认的是12333
export https_proxy='http://localhost:12333'
# 如果能把google首页下载到home目录下，说明配置成功
wget www.google.com
```
wget加速

```shell
# touch .wgetrc
https-proxy=https://ghproxy.com
http-proxy=http://ghproxy.com
```

## 4 挂载

```shell
# 查看盘符信息
# `Disk /dev/sdb doesn't contain a valid partition table` 说明 /dev/sdb 没有加载使用
sudo fdisk -l
# 格式化
mkfs -t ext4 /dev/sda1
# 新建文件夹，关联新硬盘
mkdir doc
mount /dev/sda1 doc/
# 取消挂载
sudo umount /dev/sda1
```
设置开机自动挂载
```shell
sudo blkid /dev/sda1 # 查询挂载硬盘的UUID, D67A26A87A268579
vim /etc/fstab
# 最后一行添加, 第一个数字：0表示开机不检查磁盘，1表示开机检查磁盘；
# 第二个数字：0表示交换分区，1代表启动分区（Linux），2表示普通分区
# 在 Windows 系统下创建的分区，磁盘格式为 ntfs
UUID=D67A26A87A268579 /home/dafa/doc ntfs defaults 0 2
```
## 5 安装 comfast 811AC usb 网卡驱动
```shell
git clone https://github.com/brektrou/rtl8821CU.git
cd rtl8821CU
chmod +x dkms-install.sh
sudo ./dkms-install.sh
sudo modprobe 8821cu
```
若显示 `required key not available`，则需要在电脑 BIOS 中关闭 uefi，联想台式机的位置是在 `secure boot`。

命令行连接 wifi

```bash
 sudo service network-manager restart
 sudo nmcli dev wifi
 sudo nmcli dev wifi connect "Saturday" password "123456789"
```

## 6 设置静态 IP 和 DNS
```shell
$ sudo vim /etc/network/interfaces

# eth0 可替换为当前网卡，网卡名称可以通过 ifconfig 查看
auto eth0
# 制定为静态 IP
iface eth0 inet static
# IP 地址
address 192.168.3.2
# 子网掩码
netmask 255.255.255.0
# 网关
gateway 192.168.3.1

# 重启网络
$ sudo /etc/init.d/networking restart
```
直接在 `/etc/resolv.conf` 文件中添加 DNS，重启后文件会被重写，原来配置的 DNS 会消失，所以在 `/etc/resolvconf/resolv.conf.d/` 目录下新建 tail 文件，填写需要的 DNS 服务器即可解决此问题，选择两个阿里巴巴公用的 DNS 服务器。

```shell
$ sudo vim /etc/resolvconf/resolv.conf.d/tail

nameserver 223.5.5.5
nameserver 223.6.6.6
```

## 7 ip 网络配置

**ip命令** 用来显示或操纵Linux主机的路由、网络设备、策略路由和隧道，是Linux下较新的功能强大的网络配置工具。

语法

```shell
ip(选项)(参数)
Usage: ip [ OPTIONS ] OBJECT { COMMAND | help }
       ip [ -force ] -batch filename
```

选项

```shell
OBJECT := { link | address | addrlabel | route | rule | neigh | ntable |
       tunnel | tuntap | maddress | mroute | mrule | monitor | xfrm |
       netns | l2tp | macsec | tcp_metrics | token }

-V：显示指令版本信息；
-s：输出更详细的信息；
-f：强制使用指定的协议族；
-4：指定使用的网络层协议是IPv4协议；
-6：指定使用的网络层协议是IPv6协议；
-0：输出信息每条记录输出一行，即使内容较多也不换行显示；
-r：显示主机时，不使用IP地址，而使用主机的域名。
```

参数

```shell
OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |
        -h[uman-readable] | -iec |
        -f[amily] { inet | inet6 | ipx | dnet | bridge | link } |
        -4 | -6 | -I | -D | -B | -0 |
        -l[oops] { maximum-addr-flush-attempts } |
        -o[neline] | -t[imestamp] | -ts[hort] | -b[atch] [filename] |
        -rc[vbuf] [size] | -n[etns] name | -a[ll] }

网络对象：指定要管理的网络对象；
具体操作：对指定的网络对象完成具体操作；
help：显示网络对象支持的操作命令的帮助信息。
```

实例

```shell
ip link show                     # 显示网络接口信息
ip link set eth0 up             # 开启网卡
ip link set eth0 down            # 关闭网卡
ip link set eth0 promisc on      # 开启网卡的混合模式
ip link set eth0 promisc offi    # 关闭网卡的混个模式
ip link set eth0 txqueuelen 1200 # 设置网卡队列长度
ip link set eth0 mtu 1400        # 设置网卡最大传输单元
ip addr show     # 显示网卡IP信息
ip addr add 192.168.0.1/24 dev eth0 # 设置eth0网卡IP地址192.168.0.1
ip addr del 192.168.0.1/24 dev eth0 # 删除eth0网卡IP地址

ip route show # 显示系统路由
ip route add default via 192.168.1.254   # 设置系统默认路由
ip route list                 # 查看路由信息
ip route add 192.168.4.0/24  via  192.168.0.254 dev eth0 # 设置192.168.4.0网段的网关为192.168.0.254,数据走eth0接口
ip route add default via  192.168.0.254  dev eth0        # 设置默认网关为192.168.0.254
ip route del 192.168.4.0/24   # 删除192.168.4.0网段的网关
ip route del default          # 删除默认路由
ip route delete 192.168.1.0/24 dev eth0 # 删除路由
```

显示网络设备的运行状态

```shell
[root@localhost ~]# ip link list
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:16:3e:00:1e:51 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:16:3e:00:1e:52 brd ff:ff:ff:ff:ff:ff
```

显示更加详细的设备信息

```shell
[root@localhost ~]# ip -s link list
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    RX: bytes  packets  errors  dropped overrun mcast
    5082831    56145    0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    5082831    56145    0       0       0       0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:16:3e:00:1e:51 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    3641655380 62027099 0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    6155236    89160    0       0       0       0
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:16:3e:00:1e:52 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    2562136822 488237847 0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    3486617396 9691081  0       0       0       0
```

显示核心路由表

```shell
[root@localhost ~]# ip route list
112.124.12.0/22 dev eth1  proto kernel  scope link  src 112.124.15.130
10.160.0.0/20 dev eth0  proto kernel  scope link  src 10.160.7.81
192.168.0.0/16 via 10.160.15.247 dev eth0
172.16.0.0/12 via 10.160.15.247 dev eth0
10.0.0.0/8 via 10.160.15.247 dev eth0
default via 112.124.15.247 dev eth1
```

显示邻居表

```shell
[root@localhost ~]# ip neigh list
112.124.15.247 dev eth1 lladdr 00:00:0c:9f:f3:88 REACHABLE
10.160.15.247 dev eth0 lladdr 00:00:0c:9f:f2:c0 STALE
```

获取主机所有网络接口

```shell
ip link | grep -E '^[0-9]' | awk -F: '{print $2}'
```

ip 地址后数字的含义：

> A类IP地址的默认子网掩码为255.0.0.0（由于255相当于二进制的8位1，所以也缩写成“/8”，表示网络号占了8位）; 即11111111.00000000.00000000.00000000
>
> B类的为255.255.0.0（/16）; 即11111111.11111111.00000000.00000000
>
> C类的为255.255.255.0(/24)；即11111111.11111111.11111111.00000000
>
> /30就是255.255.255.252；即11111111.11111111.11111111.11111100
>
> /32就是255.255.255.255；即11111111.11111111.11111111.11111111

## 8. 火狐浏览器

[官网下载](http://firefox.com.cn/download/)

```shell
sudo apt remove firefox*
tar -jxvf Firefox-latest-x86_64.tar.bz2
sudo mv firefox  /opt
sudo vim /usr/share/applications/firefox.desktop
```

将快捷方式放到桌面上，右键赋予启动权限。文件内容为：

```
[Desktop Entry]
Name=firefox
Name[zh_CN]=火狐浏览器
Comment=火狐浏览器
Exec=/opt/firefox/firefox
##Icon=/opt/firefox/browser/icons/mozicon128.png #可能在其他位置
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Application
Encoding=UTF-8
StartupNotify=true
```

## 9. 主题美化

```shell
sudo apt install gnome-tweak-tool
sudo apt install chrome-gnome-shell
```

[美化包下载](https://pan.baidu.com/s/1fhU0dDWqcS2pESK-bzxinw)

也可以在[GTK主题网站](https://www.opendesktop.org/)自己下载，注意安装目录就可以。

```shell
z -d Cupertino.tar.xz
tar xvf Cupertino.tar
sudo cp -r Cupertino /usr/share/icons/Cupertino
```

在[Gnome扩展网站](https://extensions.gnome.org/)安装相应的扩展，一般选两个：

- dash to dock
- user themes

## 10. 安装中文输入法

```shell
sudo apt install ibus-libpinyin
sudo apt install ibus-clutter
```

设置->区域与语言->中文（智能拼音）

## 11. 归档

```bash
# 把文件解压到当前目录下
unzip test.zip
# 把文件解压到指定的目录下
unzip -d /temp test.zip
# 不覆盖已经存在的文件
unzip -n test.zip
unzip -n -d /temp test.zip
# 查看压缩包的文件列表
unzip -l test.zip
# 查看显示的文件列表，包含压缩比率
unzip -v test.zip
# 检查zip文件是否损坏
unzip -t test.zip
# 将压缩文件test.zip在指定目录tmp下解压缩，如果已有相同的文件存在，要求unzip命令覆盖原先的文件
unzip -o test.zip -d /tmp/
```

## 12 网络未托管

```bash
$ sudo vim /usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf
# 在行末添加
,except:type:ethernet
$ sudo systemctl restart NetworkManager
```

## 13 增加虚拟内存

```bash
mkdir swap  #新建文件夹
cd swap
# bs 为块的大小，count 创建多少个块
sudo dd if=/dev/zero of=swapfile bs=1M count=2048
# 修改权限
sudo chmod 0600 swapfile
#把生成的文件转换成 Swap 文件
sudo mkswap swapfile
# 激活文件
sudo swapon swapfile
# 执行命令后，删除创建的swap目录即可
sudo swapoff swapfile
# 如果永久保持下去,在/etc/fstab文件尾添加一下信息，swapfilepath 根据实际路径填写
swapfilepath swap swap defaults 0 0
```

## 14 SSH免密登陆

方法一：

```bash
# A -> B
# on A
ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub B@ip
# 注: ssh-copy-id 把密钥追加到远程主机的 .ssh/authorized_key 上
```

方法二：

```bash
# on A, 生成密钥文件和私钥文件 id_rsa,id_rsa.pub或id_dsa,id_dsa.pub
ssh-keygen -t [rsa|dsa]
# 将 .pub 文件复制到B机器的 .ssh 目录， 并 cat id_rsa.pub >> ~/.ssh/authorized_keys
```

## 15 ubuntu 设置IP

> **静态IP**

```bash
$ sudo vim /etc/netpaln/00-installer-config.yaml
# 输入以下内容
network:
  # renderer: NetworkManager
   ethernets:
    enp4s0:
     dhcp4: no
     addresses: [192.168.0.106/24]
     optional: true
     gateway4: 192.168.0.254
     nameservers:
      addresses: [114.114.114.114]
$ sudo netplan apply
```

> **动态IP**

参数设置有区别

```bash
network:
  # renderer: NetworkManager
   ethernets:
    enp4s0:
     dhcp4: yes
```

> **多网卡设置**

```bash
network:
  # renderer: NetworkManager
   ethernets:
    enp4s0:
     dhcp4: no
     addresses: [192.168.0.106/24]
     optional: true
     gateway4: 192.168.0.254
     nameservers:
      addresses: [114.114.114.114]

    eno1:
     dhcp4: no
     addresses: [192.168.25.250/24]
     optional: true
     gateway4: 192.168.25.253
```

> **ubuntu 22.04**

该版本系统不能使用 `gateway4`，需要按以下方式配置：

```shell
network:
	ethernets:
		ens33:
			dhcp4: no
			dhcp6: no
			addresses:
				- 192.168.0.10/24
			routes:
				- to: default
				  via: 192.168.0.1
			nameservers:
				addresses:
					- 114.114.114.114
					- 8.8.8.8
	version: 2
	renderer: networkd
```

## 16 Use build and pip and other standards-based tools

有可能是 `setuptools` 版本太新

```bash
pip install setuptools==58.2.0
```

## 17 patch 包

### 17.1 一般文件

一般文件生成patch文件的方法可以使用

```bash
diff -Nur file_A file_B > diff.patch
```

参数的含义参考 Linux 命令手册。

```bash
# 打补丁
patch -pn < x.patch
# 还原
patch -Rpn < x.patch
```

```bash
--- src/a/b/c/d/file    2017-07-02 18:41:19.269641100 +0800
+++ src_new/a/b/c/d/file    2017-07-02 18:32:06.687035200 +0800
# 使用p0 表示在当前目录下查找src/a/b/c/d/file
# 使用p1 表示在当前目录下查找a/b/c/d/file
# 使用p2 表示在当前目录下查找b/c/d/file
# 使用p3 表示在当前目录下查找c/d/file
不使用pn表示忽略所有斜杠，在当前目录下查找file
```

### 17.2 Git

Git 有两种补丁方案：

- `git diff` 生成的 UNIX 标准补丁`.diff`文件，只记录文件改变的内容，不带有 commit 记录信息,多个 commit 可以合并成一个 diff 文件
- `git format-patch`生成的`.patch` 文件，带有记录文件改变的内容，也带有 commit 记录信息,每个 commit 对应一个 patch 文件

```bash
git diff pre_commit new_commit > x.patch
git apply XXX.path
# 生成最近的1次commit的patch； git format-patch -1 同作用
git format-patch HEAD^
# 生成最近的2次commit的patch ;有几个^就会打几个patch，从最近一次打起
git format-patch HEAD^^
# 生成两个commit的patch
git format-patch -2 <commit_1>
# 生成两个commit间的修改的patch
git format-patch <commit_1>..<commit_2>
# 生成某commit以来的修改patch（不包含该commit）
git format-patch <commit_1>
# 生成从根到 commit_1 提交的所有patch
git format-patch --root <commit_1>
```

`git apply` 并不会将 commit message 等打上去，打完 patch 后需要重新`git add`和`git commit`， 而`git am`会直接将patch的所有信息打上去，不用重新`git add`和`git commit`，author也是patch的author而不是打patch的用户。

```bash
# 查看patch的情况
git apply --stat xxxx.patch
# 检查patch是否能够打上，如果没有任何输出，则说明无冲突，可以打上
git apply --check xxxx.patch
# 强制打补丁
git apply --reject xxx.patch
# 将名字为xxxx.patch的patch打上
git am xxxx.patch
# 添加-s或者--signoff，还可以把自己的名字添加为signed off by信息，作用是注明打patch的人是谁，因为有时打patch的人并不是patch的作者
git am --signoff xxxx.patch
# 将路径~/patch-set/*.patch 按照先后顺序打上
git am ~/patch-set/*.patch
# 当git am失败，解决完冲突后，这条命令会接着打patch
git am --abort
```

## 18 zsh

```bash
# install zsh
sudo apt-get install zsh
# install oy-my-zsh
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
# install oy-my-zsh 国内源
sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)"
# plugins 放在 .oh-my-zsh/custom/plugins
git clone git@github.com:zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone git@github.com:zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
# theme 放在 .oh-my-zsh/custom/themes
git clone git@github.com:romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
# 变更默认shell
chsh -s /bin/zsh
# 临时切换
zsh
# 配置主题
p10k configure
```

配置 `.zshrc`

```shell
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git
	zsh-syntax-highlighting
	zsh-autosuggestions)
```

下载该主题推荐字体[MesloLGS NF Regular.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)，双击安装，在终端替换字体即可使用。

```bash
# *.ttf 的命令行安装
apt install ttf-mscorefonts-installer fontconfig
mkdir -p /usr/share/fonts/my_fonts
cp *.ttf /usr/share/fonts/my_fonts
cd /usr/share/fonts/my_fonts
mkfontscale
mkfontdir
fc-cache
# check
fc-list | grep -i mes
```

```shell
# 在.zshrc中添加，适配*
setopt no_nomatch
```

## 19 fish

- [fish-shell 官网](https://fishshell.com/docs/current/tutorial.html)
- [oh-my-fish](https://github.com/oh-my-fish/oh-my-fish#getting-started)

```bash
# install fish
sudo apt install fish
# install oh-my-fish
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
# 配置方式1
fish_config
# 配置方式2
omf theme
omf install <theme_name>
omf theme <theme_name>
```

根据 `$HOME/.config/fish/conf.d/omf.fish`，在 `$OMF_PATH/init.fish` 中设置启动时加载的环境参数。

## 20 动态 SNAT 地址转换

设备A的网卡1可以上网，A的网卡2与B的网卡3相连，B借助A的网卡联网，即 B3->A2->A1->baidu.com。

```shell
# on A side
export eth_share=ens39f1
export eth_net=ens39f0

sudo ifconfig $eth_share 192.168.3.1/24
sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
sudo iptables -F
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -t nat -A POSTROUTING -o $eth_net -j MASQUERADE

# on B side
sudo ifconfig eth0 192.168.3.2/24
sudo route add -net 0.0.0.0/0 gw 192.168.3.1
sudo chmod +666 /etc/resolv.conf
sudo echo "nameserver 114.114.114.114" > /etc/resolv.conf
```

MASQUERADE， 地址伪装，可自动化SNAT（source network address translation)，从服务器的网卡上，自动获取当前ip地址来做NAT。

## 21 ntp 系统自动更新时间

时区设置方法1: 使用 `tzselect`， 依次选择 `Asia/China/Shanghai`。

时区设置方法2: `timedatectl set-timezone Asia/Shanghai`。

ntp安装后是自动同步时间，使用ntpdate会显示NTP socket正在使用，可以先禁止ntp服务，禁止方法：

```shell
# 方法1
ps aux | grep ntp
## 找到NTP的PID后删掉
kill -9 <PID>
# 方法2
systemctl stop ntp
# 其他
## 查看ntp服务状态
systemctl status ntp
## ntp相关信息
watch ntpq -p
```

```shell
# ntpq的显示
Every 2.0s: ntpq -p                             dafa: Wed Dec 13 14:54:26 2023

     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
 0.ubuntu.pool.n .POOL.          16 p    -   64    0    0.000    0.000   0.000
 1.ubuntu.pool.n .POOL.          16 p    -   64    0    0.000    0.000   0.000
 2.ubuntu.pool.n .POOL.          16 p    -   64    0    0.000    0.000   0.000
 3.ubuntu.pool.n .POOL.          16 p    -   64    0    0.000    0.000   0.000
 ntp.ubuntu.com  .POOL.          16 p    -   64    0    0.000    0.000   0.000
+time.neu.edu.cn .PTP.            1 u  101  128  377   51.381    0.608   0.359
+dns1.synet.edu. 202.118.1.47     2 u  112  128  377   49.120    0.320   0.689
-time.neu.edu.cn .PTP.            1 u  186  256  377   53.518    2.612   0.131
-electrode.felix 131.188.3.221    2 u  734  256  354  253.694   30.220   1.502
*dns2.synet.edu. .PTP.            1 u   69  128  377   65.324    0.310   0.770
```

参数解释：

| 参数   | 解释                                                 |
| ------ | ---------------------------------------------------- |
| remote | 本地主机所连接的上层NTP服务器                        |
| refid  | 给上层NTP服务器提供时间校对的服务器                  |
| st     | 即stratum阶层，值越小表示ntp serve的精准度越高       |
| when   | 几秒前曾做过时间同步更新的操作                       |
| poll   | 与ntp server的同步周期，单位秒                       |
| reach  | 已经向上层NTP服务器要求更新的次数                    |
| delay  | 网络传输延迟的时间                                   |
| offset | 时间补偿                                             |
| jitter | Linux系统时间与BIOS硬件时间的差异时间                |
| -      | 该NTP服务器被认为是不合格的NTP Server                |
| +      | 上上层NTP服务器，可以作为提高时间更新的候选NTP服务器 |
| *      | 目前使用的ntp server                                 |
| x      | 外网NTP服务器不可用（不一定有）                      |

ntpd 和 ntpdate 的区别：

ntpd不仅仅是时间同步服务器，它还可以做客户端与标准时间服务器进行同步时间，而且是平滑同步，并非ntpdate立即同步，在生产环境中慎用ntpdate，也正如此两者不可同时运行。
时钟的跃变，对于某些程序会导致很严重的问题。许多应用程序依赖连续的时钟，例如数据库事务。ntpdate调整时间的方式就是我们所说的”跃变“：在获得一个时间之后，ntpdate使用settimeofday(2)设置系统时间，这有几个非常明显的问题：
第一，这样做不安全。ntpdate的设置依赖于ntp服务器的安全性，***者可以利用一些软件设计上的缺陷，拿下ntp服务器并令与其同步的服务器执行某些消耗性的任务。由于ntpdate采用的方式是跳变，跟随它的服务器无法知道是否发生了异常（时间不一样的时候，唯一的办法是以服务器为准）。
第二，这样做不精确。一旦ntp服务器宕机，跟随它的服务器也就会无法同步时间。与此不同，ntpd不仅能够校准计算机的时间，而且能够校准计算机的时钟。
第三，这样做不够优雅。由于是跳变，而不是使时间变快或变慢，依赖时序的程序会出错（例如，如果ntpdate发现你的时间快了，则可能会经历两个相同的时刻，对某些应用而言，这是致命的）。因而，唯一一个可以令时间发生跳变的点，是计算机刚刚启动，但还没有启动很多服务的那个时候。其余的时候，理想的做法是使用ntpd来校准时钟，而不是调整计算机时钟上的时间。
NTPD 在和时间服务器的同步过程中，会把 BIOS 计时器的振荡频率偏差——或者说 Local Clock 的自然漂移(drift)——记录下来。这样即使网络有问题，本机仍然能维持一个相当精确的走时。


```bash
sudo apt-get install ntpdate ntp
# 设置系统时间与网络时间同步
sudo ntpdate cn.pool.ntp.org
# 将系统时间写入硬件时间
sudo hwclock --systohc
# 复制文件到/etc/localtime目录下
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
# 查看
```


其他命令

```bash
# 修改日期
sudo date -s 02/04/23
# 修改时间
sudo date -s 16:44:00
```

## 22 连接 wifi

命令行：

```bash
sudo nmcli dev wifi connect <wifi_name> password <wifi_passwd>
```

脚本：

```shell
$ sudo vim /etc/wpa_supplicant/wpa_supplicant.conf
network={
	ssid="wifi_name"
	psk="wifi_passwd"
}
```

重启网卡或重启机器生效。

## 23 开机自启动

准备要执行的脚本 `x.sh`，路径为 `xx/`。

```bash
$ chmod 777 <x.sh>
$ cd ~/.config
$ mkdir autostart
$ cd autostart
$ vim start.desktop
```

```shell
# Exec为脚本路径
[Desktop Entry]
Type=Application
Exec=xx/x.sh
# 以下不重要
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=UGV
Name=Test-start
Comment[en_US]=
Comment=
```

## 24 双网卡

假设路由表如下：
```shell
内核 IP 路由表
目标            网关            子网掩码        标志  跃点   引用  使用 接口
0.0.0.0         192.168.0.1     0.0.0.0         UG    100    0        0 wlan0
0.0.0.0         10.200.47.254   0.0.0.0         UG    101    0        0 eth1
```

是否需要删除其中一个取决于网络配置和实际需求。以下是详细的判断依据：

---

### **判断依据**
1. **默认网关冲突（Destination 0.0.0.0 指向两个不同的网关）：**
   - 如果 `wlan0` 和 `eth1` 都设置为默认网关 (`0.0.0.0`)，且指向不同的网关地址，可能会导致路由冲突。
   - 检查是否确实存在冲突：
     ```bash
     ip route | grep default
     ```
     示例输出：
     ```plaintext
     default via 192.168.1.1 dev wlan0 metric 100
     default via 192.168.2.1 dev eth1 metric 200
     ```
     如果有两个默认路由，但它们的 `metric` 值不同（如上），系统会优先使用 `metric` 较小的路由。如果 `metric` 值相同，可能导致路由混乱。

2. **是否需要同时使用多个网卡：**
   - 如果设备只需通过一个网络连接，可以删除多余的默认路由。
   - 如果需要同时使用多个网络（如无线和有线），可以保留两条路由，但需确保路由策略明确。

3. **优先级设置（`metric`）：**
   - `metric` 是路由优先级的标志，值越小，优先级越高。
   - 如果保留两个网卡，可以调整 `metric` 值，确保优先使用需要的网卡。

---

### **解决方案**
#### **方案 1：删除多余的默认路由**
   删除默认路由的命令：
   ```bash
   sudo ip route del default dev wlan0
   ```
   或：
   ```bash
   sudo ip route del default dev eth1
   ```

#### **方案 2：调整 `metric`**
   如果需要同时保留两个默认路由，可通过调整 `metric` 值，确保优先使用特定的网卡：
   ```bash
   sudo ip route change default via 192.168.1.1 dev wlan0 metric 100
   sudo ip route change default via 192.168.2.1 dev eth1 metric 200
   ```
   确保优先使用 `metric` 值较小的网卡。

#### **方案 3：使用策略路由（Advanced Routing）**
   如果需要两张网卡同时连接不同的网络，可以为每个网卡配置独立的路由表：
   ```bash
   echo "200 wlan0" | sudo tee -a /etc/iproute2/rt_tables
   echo "201 eth1" | sudo tee -a /etc/iproute2/rt_tables
   sudo ip rule add from <wlan0-ip> table wlan0
   sudo ip rule add from <eth1-ip> table eth1
   sudo ip route add default via 192.168.1.1 dev wlan0 table wlan0
   sudo ip route add default via 192.168.2.1 dev eth1 table eth1
   ```

---

### **建议**
- **普通用途**：如果不需要多个网卡同时在线，建议只保留一个默认网关（通过删除多余的路由）。
- **特殊用途**：如需要多网络连接（例如有线和无线共存），推荐调整 `metric` 或配置策略路由来避免冲突。

验证配置后，可以通过以下命令检查路由状态：
```bash
ip route
```
---

方法 3 **策略路由（Policy Routing）** 通过为每个网卡创建独立的路由表，解决多网卡环境下的冲突问题。下面是详细解释和操作步骤。

---

### **背景概念**
在传统路由中，系统根据路由表决定如何转发数据包。当有两个网卡（如 `wlan0` 和 `eth1`）配置了默认网关 (`0.0.0.0`)，系统默认使用优先级（`metric` 值）来决定优先使用哪个网卡。

但是，在某些场景中，简单调整优先级可能不够用，例如：
- **多个网卡连接到不同的子网或网络**。
- **数据流需要从不同网卡发送回各自的网络**。

**策略路由**允许根据数据包的来源 IP、目标 IP 或其他条件，选择不同的路由表进行路由决策。

以下步骤演示如何为 `wlan0` 和 `eth1` 配置独立的路由表，使其各自流量通过各自的默认网关。

#### **1. 确认 IP 地址和网关**
首先确认 `wlan0` 和 `eth1` 的 IP 地址和默认网关：
```bash
ip addr show wlan0
ip addr show eth1
```
假设：
- `wlan0` 的 IP 地址为 `192.168.1.100`，网关为 `192.168.1.1`。
- `eth1` 的 IP 地址为 `192.168.2.100`，网关为 `192.168.2.1`。

#### **2. 添加自定义路由表**
编辑路由表文件 `/etc/iproute2/rt_tables`，添加新的路由表名称：
```bash
sudo nano /etc/iproute2/rt_tables
```
在文件末尾添加以下内容：
```plaintext
200 wlan0
201 eth1
```
> 这里的 `200` 和 `201` 是自定义的路由表 ID，可以是 1-252 之间的整数，名称为路由表标识。

#### **3. 为每个网卡配置独立路由表**
为每个网卡创建独立的路由表：

**为 `wlan0` 配置路由表：**
```bash
sudo ip route add default via 192.168.1.1 dev wlan0 table wlan0
sudo ip route add 192.168.1.0/24 dev wlan0 table wlan0
```

**为 `eth1` 配置路由表：**
```bash
sudo ip route add default via 192.168.2.1 dev eth1 table eth1
sudo ip route add 192.168.2.0/24 dev eth1 table eth1
```

#### **4. 添加策略规则**
通过 `ip rule` 命令，配置策略规则，让每个网卡使用自己的路由表。

**为 `wlan0` 添加规则：**
```bash
sudo ip rule add from 192.168.1.100 table wlan0
```

**为 `eth1` 添加规则：**
```bash
sudo ip rule add from 192.168.2.100 table eth1
```

> **解释：**
`from` 指定来源 IP 地址。当数据包的来源是 `192.168.1.100` 时，系统使用 `wlan0` 的路由表；来源是 `192.168.2.100` 时，使用 `eth1` 的路由表。

#### **5. 验证配置**
查看规则和路由表：
```bash
ip rule show
ip route show table wlan0
ip route show table eth1
```

#### **6. 保存配置（可选）**
为了在系统重启后生效，需要将配置保存。可以将上述命令写入脚本或网络配置文件中。以下是一个示例脚本：

创建脚本 `/etc/network/if-up.d/custom_routes`：
```bash
sudo nano /etc/network/if-up.d/custom_routes
```

内容如下：
```bash
#!/bin/bash

ip route add default via 192.168.1.1 dev wlan0 table wlan0
ip route add 192.168.1.0/24 dev wlan0 table wlan0
ip rule add from 192.168.1.100 table wlan0

ip route add default via 192.168.2.1 dev eth1 table eth1
ip route add 192.168.2.0/24 dev eth1 table eth1
ip rule add from 192.168.2.100 table eth1
```
保存并赋予执行权限：
```bash
sudo chmod +x /etc/network/if-up.d/custom_routes
```

---

### **策略路由的好处**
1. **明确路由选择**：每个网卡的流量通过独立的网关，避免冲突。
2. **灵活性**：可以根据数据包的来源、目标、优先级等条件定制路由行为。
3. **兼容复杂场景**：如 VPN、多网段环境、多出口场景等。

如有其他需求（如目标地址路由规则），可进一步调整策略路由。

## 25 用户信息文件

`/etc/passwd`

用户名:密码:UID:GID:描述:用户目录:登陆shell

```bash
# 创建新用户
sudo adduser dafa1
# 切换成用户dafa1
su dafa1
# 删除用户
sudo deluser --remove-home dafa1
# 创建用户组
sudo groupadd dafa2
# 删除用户组
sudo groupdel dafa2
```

## 26 PYTHON 环境检测

[源码地址](https://github.com/zhaoxuhui/Environment-Check-Tool)

`pip install psutil`

```python
import sys
import platform


def checkPythonVersion():
    return float(sys.version[:3])


def checkOS():
    os_info = platform.system()
    return os_info


def checkPipVersionPy3():
    import subprocess
    code, pip_version = subprocess.getstatusoutput("pip --version")
    if code != 0:
        pip_version = 0
    else:
        pip_version = pip_version.split("pip")[1].split("from")[0].strip()
        parts = pip_version.split(".")
        pip_version = float(parts[0] + "." + parts[1])
    return pip_version


def checkPipVersionPy2():
    import commands
    code, pip_version = commands.getstatusoutput("pip --version")
    if code != 0:
        pip_version = 0
    else:
        pip_version = pip_version.split("pip")[1].split("from")[0].strip()
        parts = pip_version.split(".")
        pip_version = float(parts[0] + "." + parts[1])
    return pip_version


def checkCUDAPy3():
    import subprocess
    code, nvcc_info = subprocess.getstatusoutput("nvcc --version")
    if code != 0:
        nvcc_info = 0
    else:
        nvcc_info = float(nvcc_info.split("release")[1].split(",")[0].strip())
    return nvcc_info


def checkCUDAPy2():
    import commands
    code, nvcc_info = commands.getstatusoutput("nvcc --version")
    if code != 0:
        nvcc_info = 0
    else:
        nvcc_info = float(nvcc_info.split("release")[1].split(",")[0].strip())
    return nvcc_info


def checkCondaPy3():
    import subprocess
    code, conda_info = subprocess.getstatusoutput("conda --version")
    if code != 0:
        conda_info = 0
    else:
        parts = conda_info.split("conda")[1].split(".")
        conda_info = float(parts[0] + "." + parts[1])
    return conda_info


def checkCondaPy2():
    import commands
    code, conda_info = commands.getstatusoutput("conda --version")
    if code != 0:
        conda_info = 0
    else:
        parts = conda_info.split("conda")[1].split(".")
        conda_info = float(parts[0] + "." + parts[1])
    return conda_info


def cpuCount():
    try:
        import psutil
        number = psutil.cpu_count()
        return str(number)
    except:
        return "No 'psutil' on your computer,install it with 'pip install psutil'"


def cpuFreq():
    try:
        import psutil
        info = psutil.cpu_freq()
        info = str(round(float(info[2]) / 1000, 2))
        return str(info)
    except:
        return "No 'psutil' on your computer,install it with 'pip install psutil'"


def cpuUsage():
    try:
        import psutil
        info = psutil.cpu_percent(interval=1, percpu=True)
        return info
    except:
        return "No 'psutil' on your computer,install it with 'pip install psutil'"


def memSize():
    try:
        import psutil
        info = psutil.virtual_memory()
        info = str(round(float(info[0]) / pow(1024, 3), 2))
        return str(info)
    except:
        return "No 'psutil' on your computer,install it with 'pip install psutil'"


def memInfo():
    try:
        import psutil
        info = psutil.virtual_memory()
        usage = str(info[2])
        avail = str(round(float(info[1]) / pow(1024, 3), 2))
        return usage, avail
    except:
        return "No 'psutil' on your computer,install it with 'pip install psutil'"


def diskSize():
    try:
        import psutil
        disk_size = []
        for item in psutil.disk_partitions():
            mountpoint = item[1]
            opts = item[3]
            if opts == 'cdrom':
                continue
            size = psutil.disk_usage(mountpoint)
            size = round(float(size[0]) / pow(1024, 3), 2)
            disk_size.append(size)
        total_size = round(sum(disk_size), 2)
        return str(total_size)
    except:
        return "No 'psutil' on your computer,install it with 'pip install psutil'"


def diskInfo():
    try:
        import psutil
        part_size = []
        part_usage = []
        part_name = []
        part_fstype = []
        for item in psutil.disk_partitions():
            name = item[0]
            mountpoint = item[1]
            fstype = item[2]
            opts = item[3]
            if opts == 'cdrom':
                continue
            info = psutil.disk_usage(mountpoint)
            size = round(float(info[0]) / pow(1024, 3), 2)
            part_size.append(size)
            part_usage.append(str(info[3]) + "%")
            part_name.append(name)
            part_fstype.append(fstype)
        return part_name, part_size, part_usage, part_fstype
    except:
        return "No 'psutil' on your computer,install it with 'pip install psutil'"


if __name__ == '__main__':
    python_v = checkPythonVersion()
    os = checkOS()
    if python_v > 3:
        pip_v = checkPipVersionPy3()
        cuda_v = checkCUDAPy3()
        conda_v = checkCondaPy3()
    else:
        pip_v = checkPipVersionPy2()
        cuda_v = checkCUDAPy2()
        conda_v = checkCondaPy2()

    print("=======================System Information=======================")
    print("* This computer runs " + os + " system.")
    print("* Python version(running this script):" + python_v.__str__())
    if pip_v == 0:
        print("* Pip version:It seems no pip on your computer.")
    else:
        print("* Pip version:" + pip_v.__str__())
    if cuda_v == 0:
        print("* CUDA version:It seems no CUDA on your computer.")
    else:
        print("* CUDA version:" + cuda_v.__str__())
    if conda_v == 0:
        print("* Conda version:It seems no Conda on your computer.")
    else:
        print("* Conda version:" + conda_v.__str__())
    print("=======================System Information=======================")

    cpu_count = cpuCount()
    cpu_freq = cpuFreq()
    cpu_usage = cpuUsage()
    mem_size = memSize()
    mem_usage = memInfo()
    disk_size = diskSize()
    disk_info = diskInfo()

    print("======================Hardware Information======================")
    print("* CPU kernel:" + cpu_count)
    print("* CPU base frequency:" + cpu_freq + " GHz")
    if type(cpu_usage) is str:
        print("* CPU use percentage(current,every kernel):\n  " + cpu_usage)
    else:
        print("* CPU use percentage(current,every kernel):\n  " + str(cpu_usage))
    print("* Memory total size:" + mem_size + " GB")
    if type(mem_usage) is str:
        print("* Memory use percentage(current):" + mem_usage)
    else:
        print("* Memory use percentage(current):" + mem_usage[0] + "%, free:" + mem_usage[1] + " GB")
    print("* Disk total size:" + disk_size + " GB")
    print("* Disk partion info:")
    if type(disk_info) is str:
        print("  " + disk_info)
    else:
        print("  Identifier\tTotal size(GB)\tUsage(percentage)\tFile format")
        for i in range(len(disk_info)):
            try:
                print("  " + disk_info[0][i] + "\t\t\t" + str(disk_info[1][i]) + "\t\t\t" + str(
                    disk_info[2][i]) + "\t\t\t\t" +
                      disk_info[3][i])
            except:
                print("May be have some error in read Disk!")
    print("======================Hardware Information======================")
```

[具体信息监控与保存](https://github.com/LDOUBLEV/AutoLog)

## 27 修改软连接

```shell
sudo ln -s <source> <target>
# 修改软链接指向
sudo ln -fs <source> <target>
# 如果是目录
sudo ln -fns <source> <target>
```

## 28 ntpdate同步时间及修改CST

```shell
# 使用阿里云NTP服务器
ntpdate 203.107.6.88
# 如果提示：no server suitable for synchronization found
ntpdate -u 203.107.6.88
# 每过半个小时同步一次
0 */30 * * * /usr/sbin/ntpdate -u 203.107.6.88 > /dev/null 2>&1; /sbin/hwclock -w
# 开机校验，在rc.local添加
/usr/sbin/ntpdate -u 203.107.6.88 > /dev/null 2>&1; /sbin/hwclock -w
```

修改CST时间格式

```bash
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

## 29 允许root账号登入ssh

```bash
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
```

## 30 cannot create /dev/null: Permission denied

在docker中使用chroot交叉编译的时候，`apt update` 出现如下报错

```
/usr/bin/apt-key: 57: cannot create /dev/null: Permission denied
```

原因是/dev/null 设备可能被常规文件替换了，重启或重新创建即可

```bash
rm -f /dev/null; mknod -m 666 /dev/null c 1 3
```

## 31 批量修改文件名

```shell
# 将所有*.cpp文件中app替换成apk
rename -v 's/app/apk/' *.cpp
# 去掉文件后缀名(比如去掉.obj)
rename 's/\.obj$//' *.obj
# 将文件名改为小写
rename 'y/A-Z/a-z/' *
# 去掉文件名的空格
rename 's/[ ]+//g' *
# 文件开头加入字符串(比如myend)
rename 's/^/myend/' *
# 文件末尾加入字符串(比如myend)
rename 's/$/myend/' *
# 批量文件名加序号
i=1; for x in *; do mv $x $i.png; let i=i+1; done
```

## 32 chattr权限保护

目的：防止root用户勿删文件

```shell
# 设置
chattr [±=][选项] 文件/目录
# 权限增加减少：
#	+：增加权限（属性）
#	-：删除权限（属性）
#	=：设置权限（属性）

# 查看
lsattr 文件名
```

a ：设置a之后，这个文件将只能增加数据，而不能删除也不能修改数据，只有root才能设置这个属性。
 i ：它可以让一个文件不能被删除、改名，设置连接也无法写入或添加数据。只有root才能设置这个属性。

## 33 Ubuntu时间同步

```shell
# 查看系统时钟
data
# 查看硬件时钟
hwclock
hwclock --show
# 查看各时钟状态
timedatectl
# 修改系统时钟
date -s 8/11/2023
date -s 20:30:00
# 硬件时钟同步系统时钟
hwclock -s
# 系统时钟同步硬件时钟
hwclock -w
# Jetson 系统时钟写入到硬件时钟
hwclock -w -f /dev/rtc0
hwclock -w -f /dev/rtc1
# 网络时钟同步系统时钟
ntpdate cn.pool.ntp.org
# 关闭网络时间同步
timedatectl set-ntp false
```

Jetson JP5.1.0（R35.2）及其以后版本，将RTC0制定为系统RTC

```shell
# /lib/udev/rules.d/50-udev-default.rules

SUBSYSTEM=="rtc", ATTR{hctosys}=="0", SYMLINK+="rtc"
SUBSYSTEM=="rtc", KERNEL=="rtc0", SYMLINK+="rtc", OPTIONS+="link_priority=-100"
```

## 34 systemctl命令列出所有服务

systemctl是Systemd 的主命令，可用于管理系统。

```shell
# 列出所有已经加载的systemd units
systemctl
systemctl | grep docker.service
# 列出所有service
systemctl list-units --type=service
systemctl --type=service
# 列出所有active状态（运行或退出）的服务
systemctl list-units --type=service --state=active
# 列出所有正在运行的服务
systemctl list-units --type=service --state=running
# 列出所有正在运行或failed状态的服务
systemctl list-units --type service --state running,failed
# 列出所有enabled状态的服务
systemctl list-unit-files --state=enabled
# 单独显示某个服务的日志
journalctl -u sshd.service
```

## 35 修改字符集locales

```shell
# 确认是否安装locales
dpkg -l locales
# 如果没有，安装
apt-get install locales
# 安装字符集，root权限
dpkg-reconfigure locales
# 检验
locale
```

## 36 修改引导顺序

- efibootmgr

先执行命令查看引导顺序：

```shell
$ efibootmgr
BootCurrent: 0001
Timeout: 5 seconds
BootOrder: 0002,0001,0004,0003,0005,0000,0006
Boot0000* Enter Setup
Boot0001* UEFI eMMC Device
Boot0002* UEFI PXEv4 (MAC:48B02DA8CFCE)
Boot0003* UEFI PXEv6 (MAC:48B02DA8CFCE)
Boot0004* UEFI HTTPv4 (MAC:48B02DA8CFCE)
Boot0005* UEFI HTTPv6 (MAC:48B02DA8CFCE)
Boot0006* UEFI Shell
```

```shell
# 将EMMC设为第一
efibootmgr -o 0001,0002,0004,0003,0005,0000,0006
reboot
```

## 37 apt使用

[参考文档](https://itsfoss.com/apt-command-guide/)

```shell
# 可升级软件包列表
apt list --upgradable
# 升级单个软件包
sudo apt install --only-upgrade package_name
```

## 38 添加及删除用户

```shell
# 添加root密码
sudo passwd root
# 登录root
su - root
```

```shell
# 创建普通用户
# -r：建立系统账号
# -m：自动建立用户的登入目录
# -s：指定用户登入后所使用的shell
sudo useradd -r -m -s /bin/bash dafa
# passwd
sudo passwd dafa
```

修改用户权限

```shell
# 该文件可能没有w权限，添加完之后取消w权限
$ sudo chmod +w /etc/sudoers
# User privilege specification
root    ALL=(ALL:ALL) ALL
dafa    ALL=(ALL:ALL) ALL
```

添加到组

```shell
# add a group
groupadd docergroup
# add dafa to the group, method 1
usermod -g dockergroup dafa
# add dafa to the group, method 2
gpasswd -a dafa dockergroup
# check
id dafa
```

删除用户

```shell
sudo userdel dafa
# 删除用户目录
sudo rm -rf /home/dafa
# /etc/sudoers中删除该用户配置
# 在组里删除用户
gpasswd -d dafa dockergroup
```
## 39 服务器控制风扇转速

```
# 设置为自动
ipmitool raw 0x3c 0x2f 0x00
# 设置为手动
ipmitool raw 0x3c 0x2f 0x01
# 设置转速，以下设置转速为30%
ipmitool raw 0x3c 0x2d 0xff 30
```

## 40 Linux CAN

```shell
# 加载can模块
sudo modprobe can
# 添加can0网卡
sudo ip link add dev can0 type can
# 可以查到当前can网络 can0 can1，包括收发包数量、是否有错误等等
ifconfig -a
# 查看状态
sudo ip -s -d link show can0
# 设置can0的波特率为500kbps，CAN网络波特率最大值为1Mbps，bitrate需要除2才是常规的通讯波特率
ip link set can0 up type can bitrate 500000
# 用于测试can通路,在没有其它硬件连接测试的情况下，可以设定成回环，自发自收，loopback不一定支持
ip link set can0 up type can bitrate 500000 loopback on
# 关闭can0网络
ip link set can0 down
# 启动can0网络
ip link set up can0
# 发送默认ID为0x1的can标准帧，数据为0x11 22 33 44 55 66 77 88
# 每次最大8个byte
# 需要安装 can-utils
cansend can0 0x11 0x22 0x33 0x44 0x55 0x66 0x77 0x88
# 测试can0发送数据 发送单位byte 理论上0-8字节
cansend can0 123#11223344
# -e 表示扩展帧，CAN_ID最大29bit，标准帧CAN_ID最大11bit
# -i 表示CAN_ID 0x800
cansend can0 -i 0x800 0x11 0x22 0x33 0x44 0x55 0x66 0x77 0x88 -e
# --loop 表示发送20个包
cansend can0 -i 0x02 0x11 0x12 --loop=20
# 接收CAN0数据
candump can0
# 统计CAN0信息
ip -details -statistics link show can0
# 联合 cantools 使用dbc文件进行报文解码
candump can0 | cantools decode temp.dbc
```
## 41 打开日志debug和messages
A) 备份系统日志配置
```bash
cp -p /etc/rsyslog.d/50-default.conf /etc/rsyslog.d/50-default.conf.bak
```
B) 修改日志配置 `/etc/rsyslog.d/50-default.conf`
```shell
diff --git a/etc/rsyslog.d/50-default.conf b/etc/rsyslog.d/50-default.conf
index 56217be..e76ef77 100644
--- a/etc/rsyslog.d/50-default.conf
+++ b/etc/rsyslog.d/50-default.conf
@@ -26,12 +26,12 @@ mail.err                    /var/log/mail.err
 # Some "catch-all" log files.
 #
 #*.=debug;\
-#      auth,authpriv.none;\
-#      news.none;mail.none     -/var/log/debug
-#*.=info;*.=notice;*.=warn;\
-#      auth,authpriv.none;\
-#      cron,daemon.none;\
-#      mail,news.none          -/var/log/messages
+       auth,authpriv.none;\
+       news.none;mail.none     -/var/log/debug
+*.=info;*.=notice;*.=warn;\
+       auth,authpriv.none;\
+       cron,daemon.none;\
+       mail,news.none          -/var/log/messages

 #
 # Emergencies are sent to everybody logged in.
```
C) reboot rsyslog
```bash
systemctl restart rsyslog
```

D) 恢复
```shell
cp -p /etc/rsyslog.d/50-default.conf.bak /etc/rsyslog.d/50-default.conf
systemctl restart rsyslog
```

## 42 写一个service

创建文件
```shell
sudo vim /etc/systemd/system/safe.service
```

填写

```shell
[Unit]
Description=Run safe.sh at startup
After=network.target

[Service]
ExecStart=/opt/safe.sh
ExecStartPre=/bin/sleep 60
Type=simple

[Install]
WantedBy=multi-user.target
```

配置开机启用

```shell
sudo systemctl enable safe.service
sudo systemctl start safe.service
```

## 43 nomachine

```shell
# `/usr/NX/etc/node.cfg`，
将其中的AudioInterface pulseaudio更改为AudioInterface disabled
# `/usr/NX/etc/server.cfg`
设置PhysicalDesktopAuthorization 0(如果其中没有需要自己加)
# `/usr/NX/etc/server.cfg`
AutomaticDisconnection 1
# 重启服务
/etc/NX/nxserver --restart
```

## 44 .bash_aliases or .zsh_aliases

```sh
export LS_COLORS='ow=01;94:'
```

## 45 强制绑定或解绑USB设备

```bash
echo "1-2.1" > /sys/bus/usb/drivers/usb/unbind
echo "1-2.1" > /sys/bus/usb/drivers/usb/bind
```

这两条命令用于在 Linux 系统中重新初始化指定的 USB 设备。

---

### **作用**

1. **第一条命令 (`unbind`)**
   - 从 USB 驱动程序中卸载指定的 USB 设备。
   - 设备编号 `1-2.1` 是 USB 设备的路径（需根据实际情况替换）。
   - 实际作用是让操作系统停止管理该设备，等同于模拟拔出设备。

2. **第二条命令 (`bind`)**
   - 将设备重新绑定到 USB 驱动程序。
   - 设备重新初始化，相当于模拟设备重新插入。

---

### **使用场景**
- 当 USB 设备出现异常（例如无法识别、失去响应）时，强制重新初始化设备。
- 测试 USB 驱动加载或设备的热插拔行为。
- 解决某些特殊设备需要重启才能恢复工作的问题。

---

### **步骤**

1. **获取设备路径**
   使用以下命令找到目标设备的路径：
   ```bash
   lsusb
   ```
   或：
   ```bash
   lsusb -t
   ```
   在输出中找到设备路径，例如 `1-2.1`。

2. **解绑设备**
   将路径替换到命令中执行：
   ```bash
   echo "1-2.1" > /sys/bus/usb/drivers/usb/unbind
   ```

3. **重新绑定设备**
   执行以下命令重新初始化设备：
   ```bash
   echo "1-2.1" > /sys/bus/usb/drivers/usb/bind
   ```

### **示例输出**
假设 USB 设备路径为 `1-2.1`：

解绑设备：
```bash
echo "1-2.1" > /sys/bus/usb/drivers/usb/unbind
```
日志：
```text
[ 1234.567890] usb 1-2.1: USB disconnect, device number 5
```

重新绑定设备：
```bash
echo "1-2.1" > /sys/bus/usb/drivers/usb/bind
```
日志：
```text
[ 1235.678901] usb 1-2.1: new full-speed USB device number 6 using xhci_hcd
```