# Shell

## 1 8路相机出图
```shell
#!/bin/bash

# 视频设备数组
devices=(/dev/video0 /dev/video1 /dev/video2 /dev/video3 /dev/video4 /dev/video5 /dev/video6 /dev/video7)

# 视频格式设置
width=1920
height=1080
pixelformat=BA12
bypass_mode=0

# 命令模板
cmd_template="v4l2-ctl -d DEVICE --set-fmt-video=width=$width,height=$height,pixelformat=$pixelformat --set-ctrl bypass_mode=$bypass_mode --stream-mmap"

# 启动终端并执行命令
for i in "${!devices[@]}"; do
    device=${devices[$i]}
    cmd=${cmd_template/DEVICE/$device}
    gnome-terminal --title="Camera $i" -- bash -c "$cmd; exec bash" &
done

```

## 2 添加Orin功耗监控的服务
以下是一个脚本，使用 `tegrastats` 命令每秒记录一次结果到 `/var/log/tegrastats.log` 中。你可以将它保存为一个脚本文件，并设置为服务以确保持续运行。

### 2.1 创建脚本文件
创建一个脚本文件，例如 `/usr/local/bin/log_tegrastats.sh`：

```bash
#!/bin/bash

LOGFILE="/var/log/tegrastats.log"

# 确保日志文件存在并设置权限
if [ ! -f "$LOGFILE" ]; then
    touch "$LOGFILE"
    chmod 666 "$LOGFILE"
fi

# 循环每秒记录一次 tegrastats 输出
while true; do
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    tegrastats_output=$(tegrastats --interval 1000 | head -n 1)
    echo "$timestamp $tegrastats_output" >> "$LOGFILE"
    sleep 1
done
```

保存后，为脚本添加可执行权限：

```bash
sudo chmod +x /usr/local/bin/log_tegrastats.sh
```

---

### 2.2 创建 Systemd 服务
为确保脚本在启动时自动运行，可以创建一个 Systemd 服务。

**创建服务文件**

创建文件 `/etc/systemd/system/log-tegrastats.service`：

```ini
[Unit]
Description=Log tegrastats output every second
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/log_tegrastats.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
```

---

### 2.3 启动服务
执行以下命令以启用并启动服务：

```bash
sudo systemctl daemon-reload
sudo systemctl enable log-tegrastats.service
sudo systemctl start log-tegrastats.service
```

---

### 2.4 检查运行状态
查看服务状态：

```bash
sudo systemctl status log-tegrastats.service
```

查看日志文件内容：

```bash
sudo tail -f /var/log/tegrastats.log
```

### 2.5 说明
- 如果 `/var/log/tegrastats.log` 权限问题导致脚本无法写入，可手动更改文件夹权限。
- 运行该脚本需要确保设备已安装 `tegrastats` 工具且可以正常使用。

## 3 格式化硬盘并挂载

🚀 **推荐做法**：
1. **先创建分区（`fdisk` 或 `parted`）**
2. **再格式化分区（`mkfs.ext4 /dev/sdb1`）**
3. **最后挂载使用（`mount /dev/sdb1 /mnt/mydisk`）**

如果想让整个磁盘作为单一存储设备（适用于 U 盘、外接硬盘等），可以**直接格式化整个磁盘**（不推荐用于系统盘）：
```bash
sudo mkfs.ext4 /dev/sdb
```

在 Ubuntu 中，`parted` 是一个强大的硬盘分区工具，可以用来创建、删除、格式化和管理硬盘分区。以下是使用 `parted` 格式化硬盘的步骤：

---

### 3.1 检查硬盘设备名称
运行以下命令以查看系统中的硬盘设备：
```bash
lsblk
```
**示例输出：**
```plaintext
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda      8:0    0   500G  0 disk
├─sda1   8:1    0   200G  0 part /
├─sda2   8:2    0   300G  0 part /data
sdb      8:16   0   1T    0 disk
```
根据硬盘大小和挂载点，找到目标硬盘的名称（如 `/dev/sdb`）。

- **首选 exFAT（推荐）**：适合大文件，Windows 和 Ubuntu 都能稳定读写。
- **次选 NTFS**：适合主要在 Windows 上使用，同时兼容 Ubuntu。
- **EXT4 不适合**：除非只在 Linux 下使用，否则不推荐。

---

### 3.2 进入 `parted` 命令行
以管理员身份运行 `parted`，指定硬盘设备：
```bash
sudo parted /dev/sdX
```
将 `sdX` 替换为目标硬盘（如 `/dev/sdb`）。

---

### 3.3 设置分区表类型
选择分区表类型为 GPT（推荐）或 MBR（旧硬盘可能需要）：
```bash
mklabel gpt
```
或：
```bash
mklabel msdos
```
**提示：** GPT 支持 2TB 以上的硬盘和更多分区，推荐使用。

---

### 3.4 创建新分区
输入以下命令创建分区：
```bash
mkpart primary ext4 0% 100%
```
- **`primary`**：指定主分区。
- **`ext4`**：分区文件系统类型（**可更换为其他类型，也可不指定，不支持exfat**）。
- **`0%`**：起始位置（从硬盘开头）。
- **`100%`**：结束位置（到硬盘结尾）。

---

### 3.5 查看分区信息
使用以下命令查看当前硬盘分区信息：
```bash
print
```

---

### 3.6 格式化分区
退出 `parted`：
```bash
quit
```
然后格式化刚创建的分区：

🔸 **格式化为 ext4（Linux 专用）**
```bash
sudo mkfs.ext4 /dev/sdb1
```

🔸 **格式化为 NTFS（Windows & Linux）**
```bash
sudo mkfs.ntfs /dev/sdb1
```

🔸 **格式化为 exFAT（Windows & Linux & macOS）**
```bash
# 需要安装 exfat-fuse exfat-utils
sudo mkfs.exfat /dev/sdb1
```

🔸 **格式化为 FAT32（兼容性最高，但单文件限制 4GB）**
```bash
sudo mkfs.vfat -F32 /dev/sdb1
```


---

### 3.7 挂载分区
创建一个挂载点：
```bash
sudo mkdir -p /mnt/mydisk
```
将分区挂载到该挂载点：
```bash
sudo mount /dev/sdX1 /mnt/mydisk
```

---

### 3.8 （可选）更新 `fstab` 文件
编辑 `/etc/fstab` 文件以实现开机自动挂载：
```bash
sudo nano /etc/fstab
```
添加如下行：
```plaintext
/dev/sdX1   /mnt/mydisk   ext4   defaults   0   2
```
保存并退出。

---

### 3.9 注意事项
- 使用 `parted` 会立即对硬盘进行写入操作，务必确认设备名称无误。
- 如果硬盘上有数据，建议先备份。
- 若操作失败或不确定，请随时询问详细步骤。

### 3.10 读写速度测试

你可以使用一些工具来测试硬盘的 **读写速度**，最常用的工具有 `hdparm` 和 `dd`。以下是这两种工具的使用方法。

---

#### **方法 1：使用 `hdparm` 测试硬盘读取速度**

`hdparm` 是一个命令行工具，用于查看和测试硬盘的性能。

**测试读取速度**

```bash
sudo hdparm -Tt /dev/sdb
```
- `-T` 测试缓存的读取速度
- `-t` 测试直接读取硬盘的速度

示例输出：
```
/dev/sdb:
 Timing cached reads:   2128 MB in  2.00 seconds = 1063.61 MB/sec
 Timing buffered disk reads:  600 MB in  3.03 seconds = 198.70 MB/sec
```

- **缓存读取速度**：测试读取缓存中的数据。
- **缓冲区读取速度**：测试从硬盘读取数据的速度。

---

#### **方法 2：使用 `dd` 测试写入和读取速度**

`dd` 是另一个常用工具，它可以直接通过写入和读取文件来测试硬盘速度。

**测试写入速度**
```bash
sudo dd if=/dev/zero of=/tmp/testfile bs=1M count=1024 oflag=direct
```
- `if=/dev/zero`：表示从 `/dev/zero`（虚拟设备，输出零数据）读取数据。
- `of=/tmp/testfile`：表示写入到 `/tmp/testfile`。
- `bs=1M`：表示使用 1MB 的块大小。
- `count=1024`：表示写入 1024 块（即 1024MB = 1GB）。
- `oflag=direct`：表示绕过操作系统缓存，直接写入硬盘。

运行时会显示类似以下的结果：
```
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB) copied, 5.67864 s, 189 MB/s
```

- **写入速度**：在上面的输出中，`189 MB/s` 就是写入速度。

**测试读取速度**
```bash
sudo dd if=/tmp/testfile of=/dev/null bs=1M count=1024 iflag=direct
```
- `if=/tmp/testfile`：读取你刚才创建的文件。
- `of=/dev/null`：将数据丢弃到 `null`，只测试读取速度。
- `bs=1M` 和 `count=1024`：与写入测试一样，读取 1GB 数据。

运行时会显示类似以下的结果：
```
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB) copied, 2.34567 s, 458 MB/s
```

- **读取速度**：在上面的输出中，`458 MB/s` 就是读取速度。

---

#### **方法 3：使用 `fio` 测试性能（更专业）**

`fio` 是一个更专业的磁盘基准测试工具，可以测试多种 I/O 性能。你可以通过安装并配置不同的 I/O 模式来测试硬盘性能。

**安装 `fio`**
```bash
sudo apt install fio
```

**简单的随机读写测试**
```bash
fio --name=test --ioengine=sync --rw=randwrite --bs=4k --numjobs=1 --size=10G --time_based --runtime=30m
```
- `--rw=randwrite`：随机写入。
- `--bs=4k`：使用 4KB 块大小。
- `--numjobs=1`：1 个线程。
- `--size=10G`：每个文件大小为 10GB。
- `--runtime=30m`：运行 30 分钟。

这个命令会给出更加详细的读写性能指标。

---

**总结**
- **`hdparm`**：简单直接，测试硬盘的读取速度。
- **`dd`**：测试硬盘的写入和读取速度，适合快速检查。
- **`fio`**：专业性能测试工具，支持更多 I/O 模式和配置选项。

根据需求选择合适的工具来测试硬盘性能。如果只是简单的速度测试，`dd` 和 `hdparm` 就足够了。

## 4 将CPU占用率前10%的进程写入日志文件

以下是一个监测系统中 CPU 占用率前 10 的进程的 Shell 脚本，并可以定时运行以输出结果。

### 4.1 脚本代码

```bash
#!/bin/bash

# 输出文件路径
OUTPUT_FILE="/var/log/top10_cpu_usage.log"

# 检查输出文件的写权限
if [ ! -w "$(dirname "$OUTPUT_FILE")" ]; then
    echo "No write permission for $(dirname "$OUTPUT_FILE"). Please run as root or change the output file path."
    exit 1
fi

# 定时监控
while true; do
    echo "----------------------------------------" >> "$OUTPUT_FILE"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> "$OUTPUT_FILE"
    echo "Top 10 processes by CPU usage:" >> "$OUTPUT_FILE"
    echo "----------------------------------------" >> "$OUTPUT_FILE"

    # 获取占用 CPU 前 10 的进程
    ps -eo pid,ppid,comm,%cpu,%mem --sort=-%cpu | head -n 11 >> "$OUTPUT_FILE"

    echo "" >> "$OUTPUT_FILE"

    # 每 10 秒更新一次
    sleep 10
done
```

---

### 4.2 脚本说明

1. **`ps` 命令**：
   - `-eo`：自定义输出格式，包括 PID、PPID、命令名、CPU 和内存占用。
   - `--sort=-%cpu`：按 CPU 使用率降序排列。
   - `head -n 11`：显示前 10 行，包含标题行。

2. **日志输出**：
   - 将结果保存到 `/var/log/top10_cpu_usage.log` 文件中。
   - 如果需要自定义路径，可以修改 `OUTPUT_FILE` 的值。

3. **循环监控**：
   - 使用 `while true` 循环，每隔 10 秒获取一次数据。
   - 如果需要更改时间间隔，可修改 `sleep 10`。

4. **权限检查**：
   - 在输出文件路径没有写权限时，脚本会提醒并退出。

---

### 4.3 如何使用

1. **保存脚本**：
   将脚本保存为文件，例如 `monitor_top10.sh`。

   ```bash
   nano monitor_top10.sh
   ```

2. **赋予执行权限**：
   ```bash
   chmod +x monitor_top10.sh
   ```

3. **运行脚本**：
   使用 `bash` 或直接运行：
   ```bash
   ./monitor_top10.sh
   ```

4. **后台运行（可选）**：
   使用 `nohup` 或 `screen` 将脚本放在后台运行：
   ```bash
   nohup ./monitor_top10.sh &
   ```

5. **查看日志**：
   查看输出日志：
   ```bash
   tail -f /var/log/top10_cpu_usage.log
   ```

---

### 4.4 自定义改进

- **内存占用监控**：
  如果需要同时监控内存使用情况，可以添加过滤或排序条件，例如按 `%mem` 排序：
  ```bash
  ps -eo pid,ppid,comm,%cpu,%mem --sort=-%mem | head -n 11
  ```

- **异常检测**：
  添加 CPU 占用率阈值，记录异常进程：
  ```bash
  ps -eo pid,comm,%cpu --sort=-%cpu | awk '$3 > 80' >> "$OUTPUT_FILE"
  ```

如果需要其他定制功能，可以随时调整脚本！

## 5 多网口iperf测试

### 5.1 环境准备
1. **安装 iperf**：
   如果设备默认未安装 `iperf`，可以通过以下命令安装：
   ```bash
   sudo apt update
   sudo apt install iperf
   ```

2. **配置 IP 地址**：
   配置方法与使用 `iperf3` 时相同，确保设备 A 和设备 B 的每个网口都有唯一的 IP 地址，并在相同子网中。例如：

   **设备 A**:
   - eth0: 192.168.1.1/24
   - eth1: 192.168.2.1/24
   - eth2: 192.168.3.1/24
   - eth3: 192.168.4.1/24
   - eth4: 192.168.5.1/24

   **设备 B**:
   - eth0: 192.168.1.2/24
   - eth1: 192.168.2.2/24
   - eth2: 192.168.3.2/24
   - eth3: 192.168.4.2/24
   - eth4: 192.168.5.2/24

---

### 5.2 测试方法
#### 5.2.1 **在设备 B 上启动 iperf 服务器**：
   使用以下命令为每个网口分别启动 `iperf` 服务：
   ```bash
   iperf -s -B 192.168.1.2 -p 5001 &
   iperf -s -B 192.168.2.2 -p 5002 &
   iperf -s -B 192.168.3.2 -p 5003 &
   iperf -s -B 192.168.4.2 -p 5004 &
   iperf -s -B 192.168.5.2 -p 5005 &
   ```
   - `-s`：启动服务器模式。
   - `-B`：绑定到特定的 IP 地址。
   - `-p`：指定监听的端口号。

#### 5.2.2 **在设备 A 上运行 iperf 客户端**：
   使用以下命令逐一测试设备 A 和设备 B 每个网口之间的网络性能：
   ```bash
   iperf -c 192.168.1.2 -B 192.168.1.1 -p 5001
   iperf -c 192.168.2.2 -B 192.168.2.1 -p 5002
   iperf -c 192.168.3.2 -B 192.168.3.1 -p 5003
   iperf -c 192.168.4.2 -B 192.168.4.1 -p 5004
   iperf -c 192.168.5.2 -B 192.168.5.1 -p 5005
   ```
   - `-c`：启动客户端模式。
   - `-B`：绑定到特定的本地 IP 地址。
   - `-p`：指定连接的端口号。

---

### 5.3 并发测试（多线程）
如果想同时测试多个网口，可以使用多线程模式，或编写脚本来自动化运行测试。例如，启动 5 个并发线程：
```bash
iperf -c 192.168.1.2 -B 192.168.1.1 -p 5001 -P 5
```
- `-P`：指定并发线程数量。

---

### 5.4 测试结果分析
`iperf` 的测试结果包括：
- **带宽（Bandwidth）**：显示每个网口的网络传输速率。
- **传输数据量（Data Transferred）**：总传输的数据大小。
- **丢包率（Packet Loss）**：在 UDP 模式下可以显示丢包率。

### 5.5 UDP 测试
如果想测试丢包率或网络延迟，可以启用 UDP 模式：
```bash
iperf -c 192.168.1.2 -u -B 192.168.1.1 -p 5001 -b 100M
```
- `-u`：启用 UDP 模式。
- `-b`：指定带宽，如 `100M` 表示 100 Mbps。

---

## 6 办公电脑配置

```shell
# file name : /etc/systemd/system/dafainit.service
[Unit]
Description=dafa_init
After=network.target local-fs.target dev-sda1.device
Requires=dev-sda1.device

[Service]
Type=oneshot
#ExecStartPre=/bin/sh -c "for i in {1..30}; do [ -e /dev/sda1 ] && exit 0 || sleep 2; done; exit 1"
ExecStart=/usr/local/bin/dafainit.sh
RemainAfterExit=yes
User=root

[Install]
WantedBy=multi-user.target

```

```shell
#!/bin/bash
# file name : /usr/local/bin/dafainit.sh

ETH_SHARE="enp3s0"
ETH_NET="wlxe0e1a912118a"
MOUNT_POINT="/home/dafa/doc"
DISK_DEVICE="/dev/sda1"

POWER_OFF_TIME="22:00"
POWER_ON_TIME="07:00"

# 1. 配置网络共享
configure_network() {
    echo "Configuring network sharing..."
    ifconfig $ETH_SHARE 192.168.3.1/24
    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -F
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -t nat -A POSTROUTING -o $ETH_NET -j MASQUERADE
    echo "Network configured successfully."
}

# 2. 挂载外部存储
mount_storage() {
    echo "Mounting storage device..."
    if mount | grep -q "$MOUNT_POINT"; then
        echo "Storage is already mounted."
    else
        mount $DISK_DEVICE $MOUNT_POINT && echo "Mounted $DISK_DEVICE to $MOUNT_POINT"
    fi
}

# 3. 计算 RTC 唤醒时间
calculate_wakeup_time() {
    CURRENT_TIMESTAMP=$(date +%s)
    WAKE_TIMESTAMP=$(date -d "$POWER_ON_TIME" +%s)

    if [ "$CURRENT_TIMESTAMP" -gt "$WAKE_TIMESTAMP" ]; then
        WAKE_TIMESTAMP=$(date -d "tomorrow $POWER_ON_TIME" +%s)
    fi

    WAKE_SECONDS=$(( WAKE_TIMESTAMP - CURRENT_TIMESTAMP ))
    echo $WAKE_SECONDS
}

# 4. 设置 RTC 定时开机
setup_rtc_wakeup() {
    local WAKE_SECONDS=$(calculate_wakeup_time)
    echo "Setting RTC wake-up time in $WAKE_SECONDS seconds..."
    rtcwake -m no -s $WAKE_SECONDS  # 只设置唤醒时间，不立即关机
}

# 5. 计划关机任务
schedule_shutdown() {
    echo "Scheduling system shutdown at $POWER_OFF_TIME..."
    shutdown -h "$POWER_OFF_TIME"
}

# --------------------- 主执行流程 --------------------- #
configure_network
mount_storage
setup_rtc_wakeup
schedule_shutdown

echo "System setup completed. It will shut down at $POWER_OFF_TIME and wake up at $POWER_ON_TIME."

```

## 7 进程监测

以下是一个 **Bash 监测脚本**，用于记录 **CPU、内存、I/O** 占用前 10 名的进程，并将结果保存到日志文件中。

### **功能：**
- 记录 **CPU** 占用率前 10 名进程
- 记录 **内存** 占用前 10 名进程
- 记录 **I/O** 读写前 10 名进程
- 每 5 秒记录一次，日志文件保存在 `/var/log/process_monitor.log`

---

### **脚本代码**
```shell
#!/bin/bash

LOG_FILE="/var/log/process_monitor.log"

# 确保日志文件存在
touch $LOG_FILE

echo "====== 进程监测脚本启动，日志存储于 $LOG_FILE ======"

while true; do
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "===== 监测时间: $TIMESTAMP =====" >> $LOG_FILE

    # 记录 CPU 占用前 10 的进程
    echo "【CPU 占用 TOP 10】" >> $LOG_FILE
    ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 11 >> $LOG_FILE

    # 记录 内存 占用前 10 的进程
    echo "【内存占用 TOP 10】" >> $LOG_FILE
    ps -eo pid,ppid,cmd,%mem --sort=-%mem | head -n 11 >> $LOG_FILE

    # 记录 I/O 读写前 10 的进程（需要 iotop）
    echo "【I/O 读写 TOP 10】" >> $LOG_FILE
    iotop -b -o -n 1 -d 1 | head -n 12 >> $LOG_FILE

    echo "==============================" >> $LOG_FILE
    sleep 5  # 每 5 秒记录一次
done
```

---

### **使用方法**
1. **保存脚本**
   将代码保存为 `process_monitor.sh`：
   ```bash
   nano process_monitor.sh
   ```
   然后粘贴代码并保存 (`Ctrl + X`, `Y`, `Enter`)。

2. **赋予可执行权限**
   ```bash
   chmod +x process_monitor.sh
   ```

3. **运行脚本**
   ```bash
   sudo ./process_monitor.sh
   ```
   > **需要 `sudo` 以获取 I/O 监测权限**

4. **后台运行**
   如果希望脚本在后台运行：
   ```bash
   nohup sudo ./process_monitor.sh &
   ```
   **查看日志**
   ```bash
   tail -f /var/log/process_monitor.log
   ```

5. **停止脚本**
   查找 `process_monitor.sh` 进程：
   ```bash
   ps aux | grep process_monitor.sh
   ```
   杀死进程：
   ```bash
   kill <PID>
   ```

---

### **额外说明**
- **`ps`** 命令用于列出 CPU/内存占用的进程
- **`iotop`** 用于查看 I/O 读写，需要 `sudo` 运行
  - **安装 `iotop`（如果未安装）**
    ```bash
    sudo apt install iotop  # Ubuntu/Debian
    sudo yum install iotop  # CentOS/RHEL
    ```
- **可调整日志存储路径**（如 `/home/orin/process_monitor.log`）

## 8 扫描不必要服务和请求联网的进程

```shell
#!/bin/bash
# Jetson 自动扫描不必要服务 & 外发数据进程

echo "===== 1. 正在运行的可能不必要服务 ====="
enabled_services=$(systemctl list-unit-files --type=service | grep enabled | awk '{print $1}')

UNNEEDED_SERVICES=(
    "bluetooth.service"
    "ModemManager.service"
    "cups.service"
    "avahi-daemon.service"
    "whoopsie.service"
    "snapd.service"
    "nv-l4t-usb-device-mode.service"
    "nv-l4t-bootloader-update.service"
    "nv-oem-config.service"
)

for svc in "${UNNEEDED_SERVICES[@]}"; do
    if echo "$enabled_services" | grep -q "$svc"; then
        echo "[可能可关] $svc"
    fi
done

echo
echo "===== 2. 当前有外网连接的进程 ====="
# 只取包含 pid= 的行
ss -tupn | grep ESTAB | grep -v "127.0.0.1" | grep -v "::1" | grep "pid=" | while read -r line; do
    pid=$(echo "$line" | grep -oP "pid=\K[0-9]+")
    if [[ -n "$pid" && -d "/proc/$pid" ]]; then
        exe=$(readlink -f /proc/$pid/exe 2>/dev/null)
        cmd=$(ps -p "$pid" -o cmd --no-headers 2>/dev/null)
        echo "PID: $pid | 可执行文件: $exe | 命令: $cmd"
    fi
done

echo
echo "===== 3. 建议 ====="
echo "1. 对不必要的服务，可用: sudo systemctl disable --now 服务名"
echo "2. 对可疑外发进程，先确认用途，再考虑阻断（iptables/firewalld）"
```

进程信息的监测（添加 jetsonstats 信息）：

```shell
#!/bin/bash
# 用法: sudo ./proc_info.sh <PID>
# 输出会打印到屏幕，并保存到 logs/proc_<PID>_YYYYMMDD_HHMMSS.log

if [ -z "$1" ]; then
    echo "用法: $0 <PID>"
    exit 1
fi

PID=$1

if [ ! -d "/proc/$PID" ]; then
    echo "错误: PID $PID 不存在"
    exit 1
fi

# 创建日志目录
LOG_DIR="./logs"
mkdir -p $LOG_DIR
LOG_FILE="$LOG_DIR/proc_${PID}_$(date +%Y%m%d_%H%M%S).log"

# 输出函数，同时写入日志
log() {
    echo -e "$@" | tee -a "$LOG_FILE"
}

log "===== 进程信息采集: PID $PID ====="
log "采集时间: $(date)"
log

log "===== 进程基本信息 ====="
ps -p $PID -o pid,ppid,user,group,stat,%cpu,%mem,etime,cmd | tee -a "$LOG_FILE"
log

log "===== /proc/$PID/status ====="
cat /proc/$PID/status | tee -a "$LOG_FILE"
log

log "===== 启动命令 ====="
tr '\0' ' ' < /proc/$PID/cmdline | tee -a "$LOG_FILE"
log

log "===== 环境变量 ====="
tr '\0' '\n' < /proc/$PID/environ | tee -a "$LOG_FILE"
log

log "===== 资源限制 (ulimit) ====="
cat /proc/$PID/limits | tee -a "$LOG_FILE"
log

log "===== 调度信息 ====="
cat /proc/$PID/sched | tee -a "$LOG_FILE"
log

log "===== 线程信息 ====="
ps -T -p $PID | tee -a "$LOG_FILE"
log "线程总数: $(ls /proc/$PID/task | wc -l)" | tee -a "$LOG_FILE"
log

log "===== CPU 绑定 (CPU Affinity) ====="
taskset -p $PID | tee -a "$LOG_FILE"
log

log "===== 打开的文件描述符总览 ====="
FD_COUNT=$(ls /proc/$PID/fd | wc -l)
log "打开的文件描述符总数: $FD_COUNT"
log "文件描述符类型统计:"
ls -l /proc/$PID/fd | awk '{print $1}' | sort | uniq -c | tee -a "$LOG_FILE"
log

log "===== 内存映射总览 ====="
MAP_COUNT=$(cat /proc/$PID/maps | wc -l)
log "内存映射总数: $MAP_COUNT"
log

log "===== 内存总览 ====="
if [ -f /proc/$PID/smaps_rollup ]; then
    cat /proc/$PID/smaps_rollup | tee -a "$LOG_FILE"
else
    sudo awk '/Rss:/ {sum+=$2} END {print "Total RSS: " sum " kB"}' /proc/$PID/smaps | tee -a "$LOG_FILE"
fi
log

log "===== IO 统计 ====="
cat /proc/$PID/io | tee -a "$LOG_FILE"
log

log "===== 网络连接 (需要 root) ====="
sudo lsof -Pan -p $PID -i | tee -a "$LOG_FILE"
log

log "===== cgroup 信息 ====="
cat /proc/$PID/cgroup | tee -a "$LOG_FILE"
log

log "===== GPU 占用分析 (Jetson 专用) ====="
if command -v sudo tegrastats >/dev/null 2>&1; then
    log "采样 GPU 占用率 (2秒)："
    sudo timeout 2 tegrastats | grep -E "GR3D|NVDEC|NVENC" --color=always | tee -a "$LOG_FILE"
else
    log "未检测到 tegrastats，请确保已安装 Jetson 工具包"
fi

log
log "===== 进程信息采集完成，日志保存在 $LOG_FILE ====="
```