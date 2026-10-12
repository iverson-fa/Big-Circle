# NFS 的安装和配置

## 1 简介

 网络文件系统（Network File System，NFS），基于内核的文件系统。Sun 公司开发，通过使用 NFS，用户和程序可以像访问本地文件一样访问远端系统上的文件。主要用于Linux之间文件共享。

基于远程过程调用（Remote Procedure Call Protocol，RPC）实现，采用 C/S 模式，客户机发送一个请求信息给服务进程，然后等待访问端应答。服务器端在收到信息之前会保持睡眠状态。

NFS文件系统常运用于内网，因为它部署方便、简单易用、稳定、可靠，如果是大型环境则会用到分布式文件系统比如 FastDFS、HDFS、MFS。

下面基于 X86 服务器（以下简称 CPU端）和 Jetson AGX Xavier（以下简称 Xavier 端） 在 Ubuntu 18.0 中使用 NFS 服务，其中在CPU端建立共享文件夹，在 Xavier 端访问和操作该共享文件夹，测试建立在二者已经完成 Root point 和 End point 配置成功的基础上。

## 2 配置

CPU 端需要安装软件包`nfs-kernel-server`，这是 Ubuntu 中 NFS 服务器的主要软件包。`rpcbind` 是NFS服务的依赖包，一般情况下安装了nfs-kernel-server以后会自动安装。Xavier 端需要 `nfs-common`，Ubuntu 中一般默认安装。在此前的 IP 设置中，CPU 端的 IP 为 **192.168.2.22**，Xavier 端的 IP 为 **192.168.2.11**。

### 2.1 服务器端配置

在服务器端安装服务并设置共享文件夹：

```shell
$ sudo apt install nfs-kernel-server
# 设置共享文件夹
$ mkdir /nfsfile
$ sudo chmod 777 /nfsfile
$ sudo vim /etc/exports
```

配置文件格式：**共享目录 主机(权限) [主机2(权限)]** ，举例：

```bash
/doc	*(ro,sync)
/tool	*(rw,sync,no_root_squash)
```

可同时授权多个主机及权限，使用空格分隔，详细参数查询命令 `man exports`。介绍主要的参数含义：

- 共享目录

  - 指定需要共享给其他主机的目录，格式为绝对路径

- 主机

  - 单个主机IP地址：192.168.2.11

  - 一个子网：192.168.2.11/24

  - 单个主机域名：www.htype.top

  - 域下的所有子域名：*.htype.top

  - 所有主机：*

- 权限
  - 权限里包括目录访问权限，用户映射权限等等，权限之间用 `，` 分隔
  - **只读**：ro
  - **读写**：rw
  - **sync**：同步，数据同时写入内存与磁盘中，效率低，但可以保证数据的一致性（1.0.0版本后为默认）
  - **async**：异步，数据先保存在内存中，必要时写入磁盘，可提高性能但服务器意外停止会丢失数据
  - **all_squash**：不论登陆者以什么身份，都会被映射为匿名用户（nfsnobody）
  - **no_all_squash**：以登陆者的身份，不做映射，包括文件所属用户和组（默认）
  - **root_squash**：将 root 用户及所属组都映射为匿名用户或用户组（默认）
  - **no_root_squash**：开放客户端使用root的身份来操作服务器文件系统，命令文档写的“主要用于无盘客户端”
  - **anonuid=xxx**：所以用户都映射为匿名账户，并指定UID（用户ID）
  - **anongid=xxx**：所有用户都映射为匿名账户，并指定GID（组ID）

在打开的 `/etc/exports` 文件中加入一行：

```bash
/nfsfile *(insecure,rw,sync,no_root_squash)  
```

启动 NFS 服务

```shell 
/etc/init.d/nfs-kernel-server start
```

查看共享信息

```shell
exportfs -v		# 查看共享目录信息 #
exportfs -r		# 立即生效配置 #
```

开机自启等设置

```shell
systemctl enable nfs-kernel-server.service		# 开机自启 #
systemctl start nfs-kernel-server.service 		# 开启服务 #
systemctl stop nfs-kernel-server.service		# 停止服务 # 
systemctl restart nfs-kernel-server.service		# 重启服务 #
```

### 2.2 客户端配置

查看服务器共享目录

```shell
showmount -e 192.168.2.22
```

如果提示没有此命令，则执行

```shell
apt install nfs-common
```

挂载目录命令：`mount IP:目录 挂载点`，本测试将 CPU 端的共享文件夹挂载在 Xavier 端。

```shell
cd
mkdir share
mount 192.168.2.22:/nfsfile share
```

开机自动挂载

编辑 `/etc/fstab` 文件，加入一行

```bash
192.168.2.22:/nfsfile /home/nvbj/share nfs defaults	0 0
```

其中，第一个数字 0 表示开机不检查磁盘，第二个数字 0 表示交换分区，也可以设置为2（普通分区）。

## 3 测试

在 CPU 端建立文件

```shell
echo "I am writting on X86." > /nfsfile/x86file
```

在 Xavier 端执行

```shell
cd
echo "I am writting on Xavier." > share/xavierfile
```

在其中一端应该可以看到另一端建立的文件及内容，说明配置成功。

## 4 /etc/exports 配置示例

例子只是为了更好理解配置参数，实际应用中一般不会这样配置。

### 4.1 例1

需求：以异步方式共享一个所有主机都可以登陆的目录，这个目录允许所有账户都以匿名用户方式创建/修改/运行文件（包括 root 用户）。

**配置文件应该这样写：**

```bash
/mnt/sangeng    *(rw,sync,all_squash)
Copy
```

all_squash 将所有用户都映射为匿名用户；root_squash 将 root 用户也映射为匿名用户，因为是默认值所有没写。

**当其他主机在目录里建立文件时：**

```
## 客户端：
## 建立的文件权限：
[redhat@localhost sangeng]$ ll
total 0
-rw-rw-r-- 1 nobody nobody 0 Aug 10 00:00 sangen1
-rw-rw-r-- 1 nobody nobody 0 Aug 10 00:00 sangen2
Copy
```

### 4.2 例2

需求：以同步方式共享一个所有主机都可登陆的目录，这个目录允许客户端里所有用户都具有读写权限，且每个用户独立维护自己的内容，用户之间不能更改对方文件的权限，并且保留 Root 权限。

**配置文件应该这样写：**

```
/mnt/sangeng	*(rw,sync,no_root_squash)
Copy
```

no_root_squash 表示映射出 root 的权限；no_all_squash 使用户建立内容的所有者和组都为自己，因为默认值所以可不写

**被共享的目录权限：**

```
## 服务端：
## 其他用户权限里加 rwxt 表示所有用户可读/写/执行/自己拥有唯一的权限
[root@RedHat mnt]# chmod o+rwxt /mnt/sangeng/
[root@RedHat mnt]# ll
drwxr-xrwt. 2 root root 26 Aug  9 23:21 sangeng
Copy
```

**当其他主机在目录里建立文件时：**

```
## 客户端：
[redhat@localhost sangeng]$ ll
total 0
drwxr-xr-x. 2 root root 6 Aug  9 23:16 sangeng
-rw-rw-r--. 1 sangeng sangeng  0 Aug 10 00:03 sangeng1
-rw-rw-r--. 1 sg sg  0 Aug 10 00:03 sangeng2
Copy
```

### 4.3 例3

需求：同步方式共享一个目录，允许192.168.1.9主机读写并且映射root权限，其他主机为只读

**配置文件应该这样写：**

```
/mnt/sangeng	192.168.1.9(rw,sync,no_root_squash) *(ro,sync)
Copy
```

这个时候就只有服务端和 192.168.1.9 拥有读写和root权限，而其他主机只可以下载查看和运行。

### 4.4 例4

需求：同步方式共享一个目录，允许 192.168.1.0/24 网段的主机和 [www.htype.top](http://www.htype.top/)  域名的主机读写并且映射 root 权限，其他主机不允许访问。

**配置文件应该这样写：**

```
/mnt/sangeng	192.168.1.0/24(rw,sync,no_root_squash) www.htype.top(rw,sync,no_root_squash)
Copy
```

这个时候就只有服务端和 192.168.1.0/24 网段的主机和主机 [www.htype.top](http://www.htype.top/)  拥有读写和root权限，而其他主机不能访问。

### 4.5 例5

需求：共享一个目录，只允许 192.168.1.9 主机读写，但是存储的文件所有者属于 sangeng 用户，所有组属于 htype 组（sangeng用户UID为1234；htype组GID为4321），其他主机不允许访问。

```
/mnt/sangeng	192.168.1.9(rw,all_squash,anonuid=1234,anongid=xxx)
Copy
```

这时只有主机 192.168.1.9 可以访问并且可读写文件，但上传的文件会自动归为 sangeng 用户，和 htype 组，包括 root 用户上传的文件。