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

## 5 连接隐藏网络

将设备连接到隐藏的无线网络 **Metabrain** 的具体步骤：

---

### **1. 确定无线网卡名称**
运行以下命令，确认无线网卡名称（通常为 `wlan0`）：

```bash
iw dev
```

---

### **2. 配置 `wpa_supplicant.conf` 文件**
编辑 `/etc/wpa_supplicant/wpa_supplicant.conf` 配置文件：

添加以下内容（适配你的隐藏网络）：

```bash
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=CN  # 根据你所在的国家选择，比如中国为 CN

network={
    ssid="Metabrain"          # 隐藏网络的SSID
    scan_ssid=1               # 1表示扫描隐藏的SSID
    psk="Info@1998.10"        # 隐藏网络的密码
    key_mgmt=WPA-PSK          # 加密方式
}
```

### **3. 启动 `wpa_supplicant`**
运行以下命令使配置生效：

```bash
sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
```

参数解释：
- `-B`：在后台运行。
- `-i wlan0`：指定无线网卡名称（替换为实际的网卡名称）。
- `-c /etc/wpa_supplicant/wpa_supplicant.conf`：指定配置文件路径。

---

### **4. 获取IP地址**
如果 `wpa_supplicant` 成功运行，使用以下命令获取IP地址：

```bash
sudo dhclient wlan0
```

---

### **5. 验证网络连接**
检查连接状态：

```bash
iwconfig
```

确认是否获取到IP地址：

```bash
ip addr show wlan0
```

测试网络连通性：

```bash
ping -c 4 8.8.8.8
```

---

### **6. 开机自动连接**
确保设备在启动时自动连接到无线网络：

#### 启用 `wpa_supplicant` 服务：
```bash
sudo systemctl enable wpa_supplicant
```

#### 启用 `dhcpcd` 服务：
```bash
sudo systemctl enable dhcpcd
```

### **7. wpa报错**

```shell
# 报错
ctrl_iface exists and seems to be in use - cannot override it
Delete '/var/run/wpa_supplicant/wlan0' manually if it is not used anymore
Failed to initialize control interface 'DIR=/var/run/wpa_supplicant GROUP=netdev'.
You may have another wpa_supplicant process already running or the file was
left by an unclean termination of wpa_supplicant in which case you will need
to manually remove this file before starting wpa_supplicant again.
```

上述错误表明可能存在以下问题之一：

1. **已有一个正在运行的 `wpa_supplicant` 实例**：
   - 当前系统已经启动了一个 `wpa_supplicant` 进程，因此尝试启动另一个进程时失败。

2. **遗留的 socket 文件冲突**：
   - 在路径 `/var/run/wpa_supplicant/wlan0` 中可能存在未清理的控制文件，导致新的 `wpa_supplicant` 实例无法启动。

---

**解决方法：**

**1. 停止相关服务**

```bash
sudo systemctl stop NetworkManager
sudo systemctl stop wpa_supplicant
```

**2. 检查是否有其他 `wpa_supplicant` 实例正在运行**
运行以下命令检查：

```bash
ps aux | grep wpa_supplicant
```

如果发现有正在运行的 `wpa_supplicant` 进程，记录其 `PID`，然后终止它：

```bash
sudo killall wpa_supplicant
```

确保进程被完全终止后，再次运行：

```bash
ps aux | grep wpa_supplicant
```

确认没有运行中的 `wpa_supplicant`。

---

**3. 删除遗留的 socket 文件**
检查并删除可能存在的遗留文件：

```bash
sudo rm -f /var/run/wpa_supplicant/wlan0
```

---

**4. 重启 `wpa_supplicant`**
清理后，重新运行命令启动 `wpa_supplicant`：

```bash
sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
```

---

**5. 检查 `wpa_supplicant` 服务是否自动启动**
有些系统可能会自动启动 `wpa_supplicant` 服务，这可能导致你手动启动时出现冲突。可以禁用自动启动：

```bash
sudo systemctl disable wpa_supplicant
sudo systemctl stop wpa_supplicant
```

如果需要手动启动：

```bash
sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
```
