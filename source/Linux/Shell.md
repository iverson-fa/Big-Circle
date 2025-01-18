# Shell

```latex
\frac{x^2}{k+1}
x^{\frac{2}{k+1}}
x^{1/2}
```

```latex
$$
\begin{align*}
y = y(x,t) &= A e^{i\theta} \\
&= A (\cos \theta + i \sin \theta) \\
&= A (\cos(kx - \omega t) + i \sin(kx - \omega t)) \\
&= A\cos(kx - \omega t) + i A\sin(kx - \omega t)  \\
&= A\cos \Big(\frac{2\pi}{\lambda}x - \frac{2\pi v}{\lambda} t \Big) + i A\sin \Big(\frac{2\pi}{\lambda}x - \frac{2\pi v}{\lambda} t \Big)  \\
&= A\cos \frac{2\pi}{\lambda} (x - v t) + i A\sin \frac{2\pi}{\lambda} (x - v t)
\end{align*}
$$
```

`:math:`\sum\limits_{k=1}^\infty \frac{1}{2^k} = 1``

```latex
$$y(n)=(f\ast g)(n)=\sum_{\tau =\infty}^{\infty}f(\tau )g(n-\tau )d\tau $$
```

```latex
$$\frac{1}{9}\begin{bmatrix}
1 & 1 & 1\\
1 & 1 & 1\\
1 & 1 & 1
\end{bmatrix}$$
```
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

### 1. 创建脚本文件
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

### 2. 创建 Systemd 服务
为确保脚本在启动时自动运行，可以创建一个 Systemd 服务。

#### 创建服务文件
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

### 3. 启动服务
执行以下命令以启用并启动服务：

```bash
sudo systemctl daemon-reload
sudo systemctl enable log-tegrastats.service
sudo systemctl start log-tegrastats.service
```

---

### 4. 检查运行状态
查看服务状态：

```bash
sudo systemctl status log-tegrastats.service
```

查看日志文件内容：

```bash
sudo tail -f /var/log/tegrastats.log
```

### 说明
- 如果 `/var/log/tegrastats.log` 权限问题导致脚本无法写入，可手动更改文件夹权限。
- 运行该脚本需要确保设备已安装 `tegrastats` 工具且可以正常使用。

## 3 格式化硬盘并挂载

在 Ubuntu 中，`parted` 是一个强大的硬盘分区工具，可以用来创建、删除、格式化和管理硬盘分区。以下是使用 `parted` 格式化硬盘的步骤：

---

### 1. 检查硬盘设备名称
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

---

### 2. 进入 `parted` 命令行
以管理员身份运行 `parted`，指定硬盘设备：
```bash
sudo parted /dev/sdX
```
将 `sdX` 替换为目标硬盘（如 `/dev/sdb`）。

---

### 3. 设置分区表类型
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

### 4. 创建新分区
输入以下命令创建分区：
```bash
mkpart primary ext4 0% 100%
```
- **`primary`**：指定主分区。
- **`ext4`**：分区文件系统类型（可更换为其他类型）。
- **`0%`**：起始位置（从硬盘开头）。
- **`100%`**：结束位置（到硬盘结尾）。

---

### 5. 查看分区信息
使用以下命令查看当前硬盘分区信息：
```bash
print
```

---

### 6. 格式化分区
退出 `parted`：
```bash
quit
```
然后格式化刚创建的分区：
- 格式化为 ext4：
  ```bash
  sudo mkfs.ext4 /dev/sdX1
  ```
- 格式化为 NTFS：
  ```bash
  sudo mkfs.ntfs /dev/sdX1
  ```
- 格式化为 FAT32：
  ```bash
  sudo mkfs.vfat -F 32 /dev/sdX1
  ```

---

### 7. 挂载分区
创建一个挂载点：
```bash
sudo mkdir -p /mnt/mydisk
```
将分区挂载到该挂载点：
```bash
sudo mount /dev/sdX1 /mnt/mydisk
```

---

### 8. （可选）更新 `fstab` 文件
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

### 注意事项
- 使用 `parted` 会立即对硬盘进行写入操作，务必确认设备名称无误。
- 如果硬盘上有数据，建议先备份。
- 若操作失败或不确定，请随时询问详细步骤。

## 4 将CPU占用率前10%的进程写入日志文件

以下是一个监测系统中 CPU 占用率前 10 的进程的 Shell 脚本，并可以定时运行以输出结果。

### 脚本代码

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

### 脚本说明

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

### 如何使用

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

### 自定义改进

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
