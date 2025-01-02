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


