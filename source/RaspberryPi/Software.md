# 软件
## 1 Windows 烧录
- 内存卡修复工具：SDFormatter.exe
- 烧录工具：Win32DiskImager-0.9.5-install.exe

先格式化 TF 卡，然后打开烧录工具，选择要烧写的镜像，点击 `write`。

[手动更新软件源](https://mirrors.tuna.tsinghua.edu.cn/help/raspberrypi/)：

```bash
# /etc/apt/sources.list.d/raspi.list
deb https://mirrors.tuna.tsinghua.edu.cn/raspberrypi/ bullseye main/
# /etc/apt/sources.list
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free
# 根据实际情况确定是否执行
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9165938D90FDDD2E
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

## 4 内网穿透

参考文档：

1. [树莓派4B“重启计划”Ⅱ——内网穿透](https://juejin.cn/post/7025219123135119368)
2. [Ngrok主页](https://www.ngrok.cc/user.html) 账号：fa1053@163.com
3. [omv-extras.org](https://wiki.omv-extras.org/doku.php?id=start)
4. [OMV官网](https://forum.openmediavault.org/wsc/)
