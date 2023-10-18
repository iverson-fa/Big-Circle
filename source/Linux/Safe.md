# Ubuntu 配置规范

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
./configure --prefix=/usr  --libexecdir=/usr/lib  --with-secure-path  --with-all-insults  --with-env-editor  --docdir=/usr/share/doc/sudo-1.9.5p2 --with-passprompt="[sudo] password for %p: "
make
make install && ln -sfv libsudo_util.so.0.0.0 /usr/lib/sudo/libsudo_util.so.0
# check
sudo -V
```

若执行`./configure`时遇到报错`configure: error: cannot guess build type; you must specify one`，加上`--build=arm-linux`。

### 3.2 openssl

```shell
wget https://www.openssl.org/source/old/1.1.1/openssl-1.1.1v.tar.gz
tar xf openssl-1.1.1v.tar.gz 
cd openssl-1.1.1v
./config  --prefix=/usr/local/openssl
make
make install
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
sudo echo "/my/own/path" >> /etc/ld.so.conf.d/libc.conf && ldconfig
```

