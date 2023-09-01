# Ubuntu 配置规范

## 1 背景

基于绿盟科技“远程安全评估系统”的安全评估报告整理。但是配置方法里没有涉及Ubuntu系统，因此基于NVIDIA Jetpack 5.1.1/L4T 35.3（based on Ubuntu20.04）整理。

## 2 账号口令

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
index 7ec62dc..65c95e2 100644
--- a/etc/pam.d/common-password
+++ b/etc/pam.d/common-password
@@ -33,3 +33,4 @@ password	required			pam_permit.so
 # and here are more per-package modules (the "Additional" block)
 password	optional	pam_gnome_keyring.so 
 # end of pam-auth-update config
+password requisite pam_cracklib.so ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1
```

### 2.2 设置口令生存周期

在文件`/etc/login.defs`中设置 `PASS_MAX_DAYS` 不大于标准值90，如果该文件不存在，则创建并按照要求进行编辑 						 						 

### 2.3 设置口令更改最小间隔天数

### 2.4 检测是否存在空口令

### 2.5 设置口令过期前警告天数

### 2.6 检测是否设置除root外UID为0的用户

## 3 认证授权



## 4 日志审计



## 5 协议安全



## 6 其他安全

