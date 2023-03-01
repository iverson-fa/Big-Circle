# 软件
## 1 Windows 烧录
- 内存卡修复工具：SDFormatter.exe
- 烧录工具：Win32DiskImager-0.9.5-install.exe

先格式化 TF 卡，然后打开烧录工具，选择要烧写的镜像，点击 `write`。

手动更新软件源：
```bash
# /etc/apt/sources.list
deb http://mirrors.aliyun.com/raspbian/raspbian/ buster main contrib non-free rpi
deb-src http://mirrors.aliyun.com/raspbian/raspbian/ buster main contrib non-free rpi
```
