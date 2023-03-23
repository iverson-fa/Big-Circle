# 软件
## 1 Windows 烧录
- 内存卡修复工具：SDFormatter.exe
- 烧录工具：Win32DiskImager-0.9.5-install.exe

先格式化 TF 卡，然后打开烧录工具，选择要烧写的镜像，点击 `write`。

手动更新软件源：
```bash
# /etc/apt/sources.list
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free

# deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free
# # deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free

deb https://security.debian.org/debian-security bullseye-security main contrib non-free
# deb-src https://security.debian.org/debian-security bullseye-security main contrib non-free
```

如果因为公钥出现无法验证签名的情况，使用如下命令：

```bash
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys <id>
```

## 2 安装字体

下载字体文件：x.ttf

```bash
sudo apt-get install ttf-mscorefonts-installer fontconfig
cd /usr/share/fonts/truetype
sudo mv <x.ttf> .
# 建立字体缓存
sudo mkfontscale
sudo mkfontdir
fc-cache -fv
```

在终端修改字体就可以使用了。

## 3 开机自启动

参考linux相关内容配置。

如果树莓派没有连接显示器，可能会出现添加了启动文件后，开机不会自动启动的问题，此时需要修改 `/boot/config.txt` 文件，将`hdmi_force_hotplug=1`选项打开.。
