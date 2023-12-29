Ubuntu 配置规范

## 1 背景

基于绿盟科技“远程安全评估系统”的安全评估报告整理。但是配置方法里没有涉及Ubuntu系统，因此基于NVIDIA Jetpack 5.1.1/L4T 35.3（based on Ubuntu20.04）整理。[参考文档](https://github.com/WeiyiGeek/SecOpsDev/blob/master/OperatingSystem/Security/Ubuntu/Ubuntu20.04-InitializeReinforce.sh)。



## 2 文件配置

### 2.1 检查设备密码复杂度策略

检查项：

- 特殊字符个数 ocredit
- 大写字母个数 ucredit
- 数字个数 dcredit
- 小写字母个数 lcredit

以上标准值都是 -1，需要安装的软件：

- libpam-cracklib

patch:

```shell
diff --git a/etc/pam.d/common-password b/etc/pam.d/common-password
index 7ec62dc..c56e01d 100644
--- a/etc/pam.d/common-password
+++ b/etc/pam.d/common-password
@@ -33,3 +33,4 @@ password	required			pam_permit.so
 # and here are more per-package modules (the "Additional" block)
 password	optional	pam_gnome_keyring.so 
 # end of pam-auth-update config
+password requisite pam_cracklib.so ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1
```

shell:

```shell
sed -i '$a\password requisite pam_cracklib.so ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1' /etc/pam.d/common-password
```

### 2.2 设置口令生存周期

在文件`/etc/login.defs`中设置 `PASS_MAX_DAYS` 不大于标准值90，如果该文件不存在，则创建并按照要求进行编辑 

patch:

```shell
diff --git a/etc/login.defs b/etc/login.defs
index 7c32d63..56efb12 100644
--- a/etc/login.defs
+++ b/etc/login.defs
@@ -157,7 +157,7 @@ UMASK		022
 #	PASS_MIN_DAYS	Minimum number of days allowed between password changes.
 #	PASS_WARN_AGE	Number of days warning given before a password expires.
 #
-PASS_MAX_DAYS	99999
+PASS_MAX_DAYS	90
 PASS_MIN_DAYS	0
 PASS_WARN_AGE	7
```

shell:

```bash
sed -i 's/PASS_MAX_DAYS       99999/PASS_MAX_DAYS     90/g' /etc/login.defs			 
```

### 2.3 检查口令最小长度

(1) 在`/etc/pam.d/common-password`中有默认的值：8

```shell
password	requisite			pam_cracklib.so retry=3 minlen=8 difok=3
```

(2) 在文件/etc/login.defs中设置 PASS_MIN_LEN 不小于标准值

patch

```shell
diff --git a/etc/login.defs b/etc/login.defs
index d67e0bf..c06aa79 100644
--- a/etc/login.defs
+++ b/etc/login.defs
@@ -315,7 +315,7 @@ ENCRYPT_METHOD SHA512
 #ENVIRON_FILE
 #NOLOGINS_FILE
 #ISSUE_FILE
-#PASS_MIN_LEN
+PASS_MIN_LEN 8
 #PASS_MAX_LEN
 #ULIMIT
 #ENV_HZ
```

shell

```bash
sed -i 's/#PASS_MIN_LEN/PASS_MIN_LEN 8/' /etc/login.defs
```

### 2.4 设置口令更改最小间隔天数

在文件`/etc/login.defs`中设置 `PASS_MIN_DAYS` 不小于标准值 						 						 

patch:

```shell
diff --git a/etc/login.defs b/etc/login.defs
index 56efb12..dbff502 100644
--- a/etc/login.defs
+++ b/etc/login.defs
@@ -158,7 +158,7 @@ UMASK		022
 #	PASS_WARN_AGE	Number of days warning given before a password expires.
 #
 PASS_MAX_DAYS	90
-PASS_MIN_DAYS	0
+PASS_MIN_DAYS	6
 PASS_WARN_AGE	7
```

shell

```bash
sed -i 's/PASS_MIN_DAYS       0/PASS_MIN_DAYS 6/g' /etc/login.defs
```

### 2.5 检测是否存在空口令

按照密码设置策略设置非空密码 命令： passwd [OPTION...] <accountName> 						 						 

### 2.6 设置口令过期前警告天数

patch

```shell
diff --git a/etc/login.defs b/etc/login.defs
index dbff502..d67e0bf 100644
--- a/etc/login.defs
+++ b/etc/login.defs
@@ -159,7 +159,7 @@ UMASK		022
 #
 PASS_MAX_DAYS	90
 PASS_MIN_DAYS	6
-PASS_WARN_AGE	7
+PASS_WARN_AGE	30
 
 #
 # Min/max values for automatic uid selection in useradd
```

shell

```bash
sed -i 's/PASS_WARN_AGE       7/PASS_WARN_AGE 30/g' /etc/login.defs
```

### 2.7 检测是否设置除root外UID为0的用户

文件`/etc/passwd`中除root所在行外所有行第二个与第三个冒号之间UID不应设置为0 

### 2.8 检查重要目录或文件权限设置

```shell
# BSP无法修改
chmod 644 /etc/passwd 
chmod 400 /etc/shadow # 应将权限配置为600以下
# BSP 可以修改
chmod 644 /etc/group
chmod 644 /etc/services
chmod 600 /etc/security
chmod 750 /tmp
chmod 750 /etc/rc0.d/
chmod 750 /etc/rc1.d
chmod 750 /etc/rc2.d
chmod 750 /etc/rc3.d
chmod 750 /etc/rc4.d
chmod 750 /etc/rc5.d
chmod 750 /etc/rc6.d
# ubuntu 不存在
chmod 600 /etc/xinetd.conf
chmod 750 /etc/rc.d/init.d
chmod 600 /etc/grub.conf
chmod 600 /boot/grub/grub.conf
chmod 600 /etc/lilo.conf
chmod 600 /etc/grub2.cfg
chmod 600 /boot/grub2/grub.cfg
```

## 3 组件升级

### 3.1 sudo

从[sudo官网](https://www.sudo.ws/)下载最新的安装包，EIS860和EIS200R用的是`sudo-1.9.14p3.tar.gz`，进行安装：

```shell
tar xf sudo-1.9.14p3.tar.gz
cd sudo-1.9.14p3
# root
./configure --prefix=/usr  --libexecdir=/usr/lib  --with-secure-path  --with-all-insults  --with-env-editor  --docdir=/usr/share/doc/sudo-1.9.14p3 --with-passprompt="[sudo] password for %p: "
make
make install
cp lib/util/.libs/libsudo_util.so.0 /usr/lib/sudo/
# check
sudo -V
```

若执行`./configure`时遇到报错`configure: error: cannot guess build type; you must specify one`，加上`--build=arm-linux`。

### 3.2 openssl

```shell
wget https://www.openssl.org/source/old/1.1.1/openssl-1.1.1v.tar.gz
tar xf openssl-1.1.1v.tar.gz 
cd openssl-1.1.1v
./config  --prefix=/usr/local/openssl -d shared
make && make install
echo "/usr/local/openssl/lib" >> /etc/ld.so.conf.d/openssl.conf
```

添加到系统环境变量：

```shell
# /etc/profile
# 可执行文件路径
export PATH=$PATH:/usr/local/openssl/bin
# 动态链接库路径
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/openssl/lib
# 静态链接库路径，可不添加
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/openssl/lib  
# gcc所需头文件路径，可不添加
export C_INCLUDE_PATH=$C_INCLUDE_PATH:/usr/local/openssl/include  
# g++所需头文件路径，可不添加
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/usr/local/openssl/include
```

覆盖原始二进制文件，可选

```shell
cd /usr/local/openssl/bin
cp * /bin/
```

如果报错：`openssl: symbol lookup error: openssl: undefined symbol: EVP_mdc2, version OPENSSL_1_1_0`，因为有的程序执行需要链接动态库，但是自己安装的openssl的动态库并不在`/usr/lib`，于是把openssl安装目录的lib路径贴到`/etc/ld.so.conf.d/libc.conf`中：

```shell
sudo echo "/my/own/path" >> /etc/ld.so.conf.d/openssl.conf && ldconfig
```

### 3.3 绿盟软件扫描结果

此软件给的结果有问题，其建议升级的组件有：

#### 3.3.1 bash

| 版本           | 绿盟扫描版本   |
| -------------- | -------------- |
| 5.0-6ubuntu1.2 | 5.0-6ubuntu1.2 |

说明：

1. 当前版本为ubuntu20.04最新版本，[官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/b/bash/bash_5.0-6ubuntu1.2/changelog)中对CVE-2019-18276的漏洞已经修复，但是扫描软件显示此版本未修复

#### 3.3.2 thunderbird

| 版本                              | 绿盟扫描版本                       |
| --------------------------------- | ---------------------------------- |
| 1:115.4.1+build1-0ubuntu0.20.04.1 | 1:102.11.0+build1-0ubuntu0.20.04.1 |

说明：

1. 扫描的软件版本不对，当前版本为ubuntu20.04最新版本

2. [官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/t/thunderbird/thunderbird_115.4.1+build1-0ubuntu0.20.04.1/changelog)中对CVE-2021-29966/CVE-2021-29970/CVE-2021-29976/CVE-2021-29959/CVE-2021-29960/CVE-2021-29961漏洞无修复说明

#### 3.3.3 xdg-user-dirs

| 版本          | 绿盟扫描版本  |
| ------------- | ------------- |
| 0.17-2ubuntu1 | 0.17-2ubuntu1 |

说明：

1. 当前版本为ubuntu20.04最新版本，[官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/x/xdg-user-dirs/xdg-user-dirs_0.17-2ubuntu1/changelog)中对CVE-2017-15131漏洞无修复说明

#### 3.3.4 xorg

| 版本             | 绿盟扫描版本     |
| ---------------- | ---------------- |
| 1:7.7+19ubuntu14 | 1:7.7+19ubuntu14 |

说明：

1. 当前版本为ubuntu20.04最新版本，[官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/x/xorg/xorg_7.7+19ubuntu14/changelog)中对CVE-2012-1093的漏洞已经修复，但是扫描软件显示此版本未修复

#### 3.3.5 nginx

| 版本              | 绿盟扫描版本 |
| ----------------- | ------------ |
| 1.18.0-0ubuntu1.4 | 1.18.0       |

说明：

1. 当前版本为ubuntu20.04最新版本，[官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/n/nginx/nginx_1.18.0-0ubuntu1.4/changelog)中对CVE-2022-3638漏洞无修复说明
2. [官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/n/nginx/nginx_1.18.0-0ubuntu1.4/changelog)中对CVE-2021-23017的漏洞已经修复，但是扫描软件显示此版本未修复

#### 3.3.6 aspell

| 版本              | 绿盟扫描版本      |
| ----------------- | ----------------- |
| 0.60.8-1ubuntu0.1 | 0.60.8-1ubuntu0.1 |

说明：

1. 当前版本为ubuntu20.04最新版本，[官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/a/aspell/aspell_0.60.8-1ubuntu0.1/changelog)中对CVE-2019-25051的漏洞已经修复，但是扫描软件显示此版本未修复

#### 3.3.7 libgcrypt20

| 版本             | 绿盟扫描版本     |
| ---------------- | ---------------- |
| 1.8.5-5ubuntu1.1 | 1.8.5-5ubuntu1.1 |

说明：

1. 当前版本为ubuntu20.04最新版本，[官方日志](https://launchpad.net/ubuntu/+source/libgcrypt20)中对CVE-2021-33560的漏洞已经修复，但是扫描软件显示此版本未修复

#### 3.3.8 gnome-keyring

| 版本            | 绿盟扫描版本    |
| --------------- | --------------- |
| 3.36.0-1ubuntu1 | 3.36.0-1ubuntu1 |

说明：

1. 当前版本为ubuntu20.04最新版本，[官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/g/gnome-keyring/gnome-keyring_3.36.0-1ubuntu1/changelog)中对CVE-2018-19358漏洞无修复说明

#### 3.3.9 binutils

| 版本            | 绿盟扫描版本    |
| --------------- | --------------- |
| 2.34-6ubuntu1.6 | 2.34-6ubuntu1.5 |

说明：

1. 扫描的软件版本不对，当前版本为ubuntu20.04最新版本

2. [官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/b/binutils/binutils_2.34-6ubuntu1.6/changelog)中对CVE-2021-3487在2.34-6ubuntu1.3版本已经修复，扫描软件显示在2.34-6ubuntu1.5未修复，显示错误

#### 3.3.10 gedit

| 版本            | 绿盟扫描版本    |
| --------------- | --------------- |
| 3.36.2-0ubuntu1 | 3.36.2-0ubuntu1 |

说明：

1. 当前版本为ubuntu20.04最新版本，[官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/g/gedit/gedit_3.36.2-0ubuntu1/changelog)中对CVE-2017-14108漏洞无修复说明

#### 3.3.11 flex

| 版本      | 绿盟扫描版本 |
| --------- | ------------ |
| 2.6.4-6.2 | 2.6.4-6.2    |

说明：

1. 当前版本为ubuntu20.04最新版本，[官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/f/flex/flex_2.6.4-6.2/changelog)中对CVE-2017-14108漏洞无修复说明

#### 3.3.12 gdb

| 版本                 | 绿盟扫描版本         |
| -------------------- | -------------------- |
| 9.2-0ubuntu1~20.04.1 | 9.2-0ubuntu1~20.04.1 |

说明：

1. 当前版本为ubuntu20.04最新版本，[官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/g/gdb/gdb_9.2-0ubuntu1~20.04.1/changelog)中对CVE-2017-9778漏洞无修复说明

#### 3.3.13 git

| 版本                 | 绿盟扫描版本         |
| -------------------- | -------------------- |
| 1:2.25.1-1ubuntu3.11 | 1:2.25.1-1ubuntu3.11 |

说明：

1. 当前版本为ubuntu20.04最新版本，[官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/g/git/git_2.25.1-1ubuntu3.11/changelog)中对CVE-2018-1000021漏洞无修复说明

#### 3.3.14 ntp

| 版本                             | 绿盟扫描版本                     |
| -------------------------------- | -------------------------------- |
| 1:4.2.8p12+dfsg-3ubuntu4.20.04.1 | 1:4.2.8p12+dfsg-3ubuntu4.20.04.1 |

说明：

1. 当前版本为ubuntu20.04最新版本，[官方日志](https://launchpad.net/ubuntu/+source/ntp/1:4.2.8p12+dfsg-3ubuntu4.20.04.1)中对CVE-2020-1000021漏洞无修复说明

#### 3.3.15 bison

| 版本           | 绿盟扫描版本   |
| -------------- | -------------- |
| 2:3.5.1+dfsg-1 | 2:3.5.1+dfsg-1 |

说明：

1. 当前版本为ubuntu20.04最新版本，[官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/b/bison/bison_3.5.1+dfsg-1/changelog)中对CVE-2020-24240漏洞无修复说明

#### 3.3.16 python3.8

| 版本                    | 绿盟扫描版本            |
| ----------------------- | ----------------------- |
| 3.8.10-0ubuntu1~20.04.8 | 3.8.10-0ubuntu1~20.04.8 |

说明：

1. 当前版本为ubuntu20.04最新版本，[官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/p/python3.8/python3.8_3.8.10-0ubuntu1~20.04.8/changelog)中对CVE-2021-23336漏洞无修复说明
2. 在[CVE官方页面](https://ubuntu.com/security/CVE-2021-23336)中，CVE-2021-23336漏洞等级为**Ignored**

#### 3.3.17 sudo

| 版本              | 绿盟扫描版本 |
| ----------------- | ------------ |
| 1.8.31-1ubuntu1.5 | 1.8.31       |

说明：

1. 当前版本为ubuntu20.04最新版本，[官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/s/sudo/sudo_1.8.31-1ubuntu1.5/changelog)中对CVE-2023-22809漏洞在1.8.31-1ubuntu1.4版本已修复，扫描软件显示错误

#### 3.3.18 openssl

| 版本               | 绿盟扫描版本 |
| ------------------ | ------------ |
| 1.1.1f-1ubuntu2.20 | 1.1.1f       |

说明：

1. 当前版本为ubuntu20.04最新版本，[官方日志](http://changelogs.ubuntu.com/changelogs/pool/main/s/sudo/sudo_1.8.31-1ubuntu1.5/changelog)中对CVE-2022-0778/CVE-2022-2068漏洞版本已修复，扫描软件显示错误

### 3.4 openssh

```shell
#!/bin/bash

apt install libpam0g-dev
#wget https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.3p1.tar.gz
tar zxvf openssh-9.3p1.tar.gz -C /tmp

# Change to OpenSSH directory
cd /tmp/openssh-9.3p1 || exit

# Configure and install OpenSSH
./configure --prefix=/usr/local/openssh --sysconfdir=/etc/ssh --with-ssl-dir=/usr/local/openssl --with-pam --without-openssl-header-check
make && make install

# Backup and replace sshd binary
mv /usr/sbin/sshd /usr/sbin/sshd.bak
if [ -f /usr/local/openssh/sbin/sshd ]; then
        cp -rf /usr/local/openssh/sbin/sshd /usr/sbin/sshd
fi

 Backup and replace ssh binary
#mv /usr/bin/ssh /usr/bin/ssh.bak
if [ -f /usr/local/openssh/bin/ssh ]; then
        cp -rf /usr/local/openssh/bin/ssh /usr/bin/ssh
fi

# Backup and replace ssh-keygen binary
mv /usr/bin/ssh-keygen /usr/bin/ssh-keygen.bak
if [ -f /usr/local/openssh/bin/ssh-keygen ]; then
        cp -rf /usr/local/openssh/bin/ssh-keygen /usr/bin/ssh-keygen
fi

ssh_version=$(ssh -V 2>&1)

# 提取版本号部分
openssh_version=$(echo "$ssh_version" | awk '{print $1}' | cut -d '_' -f 2 | sed 's/,//')

# 设定目标版本
target_version="9.3p1"

# 比较版本号
if [ "$openssh_version" = "$target_version" ]; then
    echo "OpenSSH 版本为 $target_version 更新成功"
else
    echo "OpenSSH 版本不是 $target_version 更新失败"
fi
```
