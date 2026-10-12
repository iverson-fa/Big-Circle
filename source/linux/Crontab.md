# 定时开关机实践及deb创建测试

## 1 脚本版

下面是一个完整的 **自动配置脚本**，可实现：

* 每天晚上 **22:30 自动关机**
* 每天早上 **08:00 自动开机**（使用 RTC 唤醒）

---

### 脚本内容：`setup_daily_power_schedule.sh`

```bash
#!/bin/bash

###########################################
# 自动配置每日定时关机与开机
# 关机时间：每天 22:30
# 开机时间：每天 08:00
# 适用于 Ubuntu，要求支持 RTC 唤醒
###########################################

# 检查 RTC 是否支持
if [ ! -e /sys/class/rtc/rtc0/wakealarm ]; then
  echo "当前系统不支持 RTC 自动开机（/sys/class/rtc/rtc0/wakealarm 不存在）"
  exit 1
fi

echo "检测到 RTC 支持"

# 创建每日定时关机任务（crontab）
echo "正在添加定时关机任务到 root 的 crontab..."
sudo crontab -l 2>/dev/null | grep -v 'shutdown -h now' > /tmp/crontab.bak
echo "30 22 * * * /sbin/shutdown -h now" >> /tmp/crontab.bak
sudo crontab /tmp/crontab.bak
rm /tmp/crontab.bak
echo "已配置每天 22:30 定时关机"

# 配置 RTC 唤醒服务
echo "正在创建 RTC 唤醒定时器服务..."

# 创建 systemd 定时器 service 脚本
RTC_WAKEUP_SCRIPT="/usr/local/bin/set_rtc_wakeup.sh"
sudo tee "$RTC_WAKEUP_SCRIPT" > /dev/null << 'EOF'
#!/bin/bash
# 设置 RTC 唤醒时间为明天早上 08:00

# 清除旧的 RTC 唤醒时间
echo 0 > /sys/class/rtc/rtc0/wakealarm

# 获取明天 08:00 的时间戳
WAKE_TIMESTAMP=$(date -d "08:00 tomorrow" +%s)

# 设置新的 RTC 唤醒时间
echo $WAKE_TIMESTAMP > /sys/class/rtc/rtc0/wakealarm
EOF

sudo chmod +x "$RTC_WAKEUP_SCRIPT"

# 创建 systemd 定时器服务文件
sudo tee /etc/systemd/system/rtc-wakeup.service > /dev/null << EOF
[Unit]
Description=Set RTC Wakeup Time to 08:00

[Service]
Type=oneshot
ExecStart=$RTC_WAKEUP_SCRIPT
EOF

sudo tee /etc/systemd/system/rtc-wakeup.timer > /dev/null << EOF
[Unit]
Description=Run RTC Wakeup Script Every Day at 22:25

[Timer]
OnCalendar=*-*-* 22:25:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

# 启用定时器
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now rtc-wakeup.timer

echo "✅ 已配置每天 22:25 设置 RTC，08:00 自动开机"

echo "📌 请确认 BIOS 中已启用：Wake on RTC / Resume by RTC / RTC Alarm Power On"
echo "✅ 所有配置完成"
```

---

### 使用方法

**保存脚本**

将上面脚本保存为 `setup_daily_power_schedule.sh`。

**赋予执行权限并运行**

```bash
chmod +x setup_daily_power_schedule.sh
sudo ./setup_daily_power_schedule.sh
```

**确认 BIOS 设置已开启 RTC 唤醒功能**

重启 → 进入 BIOS → 启用类似如下项：

* `Wake on RTC`
* `Resume by RTC Alarm`
* `Power On by RTC`

---

### 后续管理（可选命令）

* 查看关机计划：

```bash
sudo crontab -l
```

* 查看开机计划：

```bash
systemctl list-timers --all | grep rtc-wakeup
```

* 手动触发 RTC 设置：

```bash
sudo systemctl start rtc-wakeup.service
```

## 2 deb版

### 2.1 最终效果说明

安装该 `.deb` 包后会自动：

* 设置每天 **22:30 自动关机**（通过 `crontab`）
* 设置每天 **08:00 自动开机**（通过 RTC + systemd 定时器）
* 自动启用 systemd `rtc-wakeup.timer`

---

### 2.2 目录结构

构建如下目录结构来打包：

```
power-scheduler/
├── DEBIAN/
│   └── control
├── usr/
│   └── local/
│       └── bin/
│           └── set_rtc_wakeup.sh
├── etc/
│   └── systemd/
│       └── system/
│           ├── rtc-wakeup.service
│           └── rtc-wakeup.timer
└── postinst   <-- 安装后自动执行脚本（写入 crontab）
```

---

### 2.3 创建 `.deb` 脚本

使用如下命令一键构建该 `.deb` 包：

#### 2.3.1 生成打包目录

```bash
mkdir -p power-scheduler/DEBIAN
mkdir -p power-scheduler/usr/local/bin
mkdir -p power-scheduler/etc/systemd/system
```

#### 2.3.2 写入 `control` 文件

路径：`power-scheduler/DEBIAN/control`

```text
Package: power-scheduler
Version: 1.0
Section: utils
Priority: optional
Architecture: all
Maintainer: Your Name <you@example.com>
Description: Daily auto shutdown (22:30) and auto power-on (08:00) via RTC
```

---

#### 2.3.3 写入 `set_rtc_wakeup.sh`

路径：`power-scheduler/usr/local/bin/set_rtc_wakeup.sh`

```bash
#!/bin/bash
echo 0 > /sys/class/rtc/rtc0/wakealarm
WAKE_TIMESTAMP=$(date -d "08:00 tomorrow" +%s)
echo $WAKE_TIMESTAMP > /sys/class/rtc/rtc0/wakealarm
```

```bash
chmod +x power-scheduler/usr/local/bin/set_rtc_wakeup.sh
```

---

#### 2.3.4 写入 `rtc-wakeup.service`

路径：`power-scheduler/etc/systemd/system/rtc-wakeup.service`

```ini
[Unit]
Description=Set RTC Wakeup Time to 08:00

[Service]
Type=oneshot
ExecStart=/usr/local/bin/set_rtc_wakeup.sh
```

---

#### 2.3.5 写入 `rtc-wakeup.timer`

路径：`power-scheduler/etc/systemd/system/rtc-wakeup.timer`

```ini
[Unit]
Description=Run RTC Wakeup Script Every Day at 22:25

[Timer]
OnCalendar=*-*-* 22:25:00
Persistent=true

[Install]
WantedBy=timers.target
```

---

#### 2.3.6 写入安装后脚本 `postinst`

路径：`power-scheduler/DEBIAN/postinst`

```bash
#!/bin/bash

# 写入 crontab 定时关机任务
crontab -l 2>/dev/null | grep -v 'shutdown -h now' > /tmp/cron.tmp
echo "30 22 * * * /sbin/shutdown -h now" >> /tmp/cron.tmp
crontab /tmp/cron.tmp
rm /tmp/cron.tmp

# 启用 systemd 定时器
systemctl daemon-reload
systemctl enable --now rtc-wakeup.timer

echo "✅ 安装成功：已配置每天 22:30 关机，08:00 开机"
```

```bash
chmod +x power-scheduler/DEBIAN/postinst
```

---

### 2.4 打包生成 `.deb`

执行以下命令：

```bash
dpkg-deb --build power-scheduler
```

完成后会生成：

```
power-scheduler.deb
```

---

### 2.5 安装 `.deb` 包

将该文件拷贝到目标机器上，执行：

```bash
sudo dpkg -i power-scheduler.deb
```

---

### 2.6 卸载方法

```bash
sudo dpkg -r power-scheduler
```
