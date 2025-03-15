# Orin配置PPS与NTP
## 1 参考文档
- [GPSD文档](https://gpsd.gitlab.io/gpsd/gpsd.html)
- [NTP server配置](https://www.eecis.udel.edu/~mills/ntp/html/drivers/)
- [Linux使用gpsd获取GPS数据](https://blog.csdn.net/yiyu20180729/article/details/136340493?spm=1001.2101.3001.6650.3&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7EYuanLiJiHua%7EPosition-3-136340493-blog-119249223.235%5Ev43%5Epc_blog_bottom_relevance_base2&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7EYuanLiJiHua%7EPosition-3-136340493-blog-119249223.235%5Ev43%5Epc_blog_bottom_relevance_base2&utm_relevant_index=6)
- [基于LinuxPPS的高精度校时系统实现](https://www.doc88.com/p-7478992186790.html?r=1)
- [嵌入式Linux时间同步gpsd+chrony](https://blog.csdn.net/sep4075/article/details/119249223?spm=1001.2014.3001.5506)
- [时间同步之给工控机授时（PPS+GPRMC）](https://blog.csdn.net/m0_46611008/article/details/126289705?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-8-126289705-blog-120728557.235^v43^pc_blog_bottom_relevance_base2&spm=1001.2101.3001.4242.5&utm_relevant_index=11)
- [Xavier+GPS/PPS+NTP时间设置](https://blog.csdn.net/enlaihe/article/details/120728557?spm=1001.2014.3001.5506)

## 2 驱动修改
### 2.1 Hermes
Hermes用的GPIO29，进行如下修改
```shell
# 新建 Linux_for_Tegra/source/public/hardware/nvidia/platform/t23x/concord/kernel-dts/cvb/tegra234-p3737-0000-pps-gpio29-a00.dtsi
/* pps control gpio definitions */

/ {
    pps: pps-gpio {
        compatible = "pps-gpio";
        gpios = <&tegra_main_gpio TEGRA234_MAIN_GPIO(AC, 4) GPIO_ACTIVE_HIGH>;
        assert-rising-edge;
        // assert-falling-edge;
        status = "okay";
    };
};
```
NOTE: EIS860用的引脚是GPIO08，查表知对应的customer usage为`PBB01`，根据`Linux_for_Tegra/bootloader/tegra234-gpio.h`中`TEGRA234_AON_GPIO_PORT_BB 1`,修改此文件内容为
```shell
/* pps control gpio definitions */

/ {
    pps: pps-gpio {
        compatible = "pps-gpio";
        gpios = <&tegra_aon_gpio TEGRA234_AON_GPIO(BB, 1) GPIO_ACTIVE_HIGH>;
        assert-rising-edge;
        // assert-falling-edge;
        status = "okay";
    };
};
```
修改总设备树，修改`Linux_for_Tegra/source/public/hardware/nvidia/platform/t23x/concord/kernel-dts/tegra234-p3701-0000-p3737-0000.dts`
```shell
#include "cvb/tegra234-p3737-0000-pps-gpio29-a00.dtsi"
```
修改编译选项`source/public/kernel/kernel-5.10/arch/arm64/configs/defconfig`
```shell
CONFIG_PPS=y
CONFIG_PPS_CLIENT_GPIO=y
CONFIG_PPS_CLIENT_LDISC=y
```
如果dmesg有报错，需要将`CONFIG_PPS_CLIENT_GPIO`和`CONFIG_PPS_CLIENT_LDISC`设置为m，手动加载`pps-gpio.ko`和`pps-ldisc.ko`文件。这三个 `CONFIG_` 选项是 Linux 内核的 PPS（Pulse Per Second）客户端驱动配置，它们的作用如下：

**1. `CONFIG_PPS_CLIENT_KTIMER=y`**
- **启用基于内核定时器的 PPS 客户端。**
- 当没有硬件 PPS 信号时，使用软件定时器模拟 PPS（精度较低）。
- 适用于没有专用 PPS 设备的情况，比如某些软件实现的时间同步方案。

👉 **适用于** 需要软件模拟 PPS 场景，但精度较差，不推荐用于高精度时间同步。

---

**2. `CONFIG_PPS_CLIENT_LDISC=y`**
- **启用串口（UART）PPS 行规（Line Discipline）。**
- 允许通过 `ldattach 18 /dev/ttySx` 方式在串口设备上启用 PPS 支持。
- 但 **USB 转串口（ttyUSBx）通常不支持 KPPS**，因为它们缺乏低延迟的时间戳捕获功能。

👉 **适用于** 直接通过物理串口（如 `/dev/ttyS0`）接收 GPS PPS 信号，而 **不适用于 `/dev/ttyUSB0`**。

---

**3. `CONFIG_PPS_CLIENT_GPIO=y`**
- **启用 GPIO 作为 PPS 客户端。**
- 允许通过 GPIO **接收** PPS 信号，比如 GPS 模块的 `PPS` 引脚可以接到 Jetson 或 Raspberry Pi 的 GPIO 引脚。
- 一般需要配合 `pps-gpio` 设备树或手动加载 `pps-gpio` 模块：
  ```bash
  sudo modprobe pps-gpio
  ```
  然后查看 `/dev/pps0` 是否存在：
  ```bash
  ls /dev/pps*
  ```
  测试 PPS：
  ```bash
  sudo ppstest /dev/pps0
  ```

👉 **适用于** 直接连接 GPS 1PPS 信号到 GPIO 的情况，推荐用于 Jetson 这样的嵌入式平台。

---

#### **总结**
- **`CONFIG_PPS_CLIENT_KTIMER=y`** → 软件定时器 PPS（精度较低）。
- **`CONFIG_PPS_CLIENT_LDISC=y`** → 串口行规 PPS，但 **不支持 USB 串口**（`ttyUSB0`）。
- **`CONFIG_PPS_CLIENT_GPIO=y`** → **推荐方案**，用于 GPIO 获取 PPS，适用于嵌入式平台（Jetson）。

如果使用 **Jetson 或嵌入式设备**，建议使用 **GPIO 方式** 而不是 `ttyUSB0`，因为 USB 串口通常不支持 KPPS。

编译并升级dtb文件，待机器重启后，查看如下设备节点：
PPS 设备节点： /dev/pps0
Sysfs文件节点: /sys/class/pps/pps0/
每当GPS的PPS过来后，会在对应的GPIO上升沿时会产生一个中断信号，此时也会产生一个timestamp时间戳，通过如下命令查看：
```shell
cat /sys/class/pps/pps0/assert
```
## 3 配置gpsd
安装依赖
```shell
apt install gpsd gpsd-clients pps-tools
```
修改 `/etc/default/gpsd`，根据实际串口名
```shell
# Default settings for gpsd.
# Please do not edit this file directly - use `dpkg-reconfigure gpsd' to
# change the options.
# Default settings for gpsd
START_DAEMON="true"
GPSD_OPTIONS="-n"
DEVICES="/dev/ttyUSB0 /dev/pps0"
USBAUTO="false"
GPSD_SOCKET="/var/run/gpsd.sock"

#注意DEVICE的一行需要根据实际情况填写，上面为COM2口，默认是pps0
#推荐事先验证并查找对应的端口和pps
#使用 ppsfind --help
#输出示例：pps0: name=serial1 path=/dev/ttyUSB0   也就代表着我们现在用的是ttyUSB0以及pps0
```
测试NMEA
```shell
#可以使用cgps或者gpsmon
cgps -s
gpsmon
```



## 4 配置NTP server
```shell
apt install ntp -y
```
修改 `/etc/ntp.conf`：
```bash
sudo vim /etc/ntp.conf
```
添加以下内容：

```shell
# 允许本机时间同步
restrict 127.0.0.1
restrict ::1

# 其他 NTP 服务器（可选，作为辅助时间源）
server ntp.aliyun.com iburst
server time.google.com iburst

# GPS 共享内存驱动 (单位: 秒)
server 127.127.28.0 minpoll 4 maxpoll 4 prefer
fudge 127.127.28.0 time1 0.0 refid GPS

# PPS 设备 (精确时间同步)
server 127.127.22.0 minpoll 3 maxpoll 3 prefer
fudge 127.127.22.0 refid PPS flag3 1

# 允许本机访问 NTP
restrict 127.0.0.1
restrict ::1
```

**参数解释：**
- `server 127.127.28.0` → 使用 `SHM` 驱动从 `gpsd` 读取 GPS 时间
- `server 127.127.22.0` → 使用 `PPS` 进行高精度同步
- `fudge 127.127.28.0 time1 0.0 refid GPS` → 设置 GPS 数据的偏移
- `fudge 127.127.22.0 refid PPS flag3 1` → 使 PPS 为主时钟

---


重启服务验证
```shell
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
*PPS(0)          .PPS.        0 l   7   16  377    0.000    0.002   0.001
+SHM(0)          .GPS.        0 l   9   64  377    0.000   -0.024   0.012
+time.google.com .GOOG.       1 u   8   64  377   10.344
```

## 5 Debug

如果运行命令 `cat /sys/class/pps/pps0/assert` 后返回`0.000000000#0`，这通常表明未检测到有效的 PPS（Pulse Per Second）信号。GPS未接收到信号可能是造成这种情况的原因。以下是解决问题的步骤：

---

### 5.1 **检查硬件连接**
   - 确保 GPS 模块的信号线（PPS 和 TX）已正确连接到系统的 GPIO 或串口。
   - 检查电源是否正常供给 GPS 模块。
   - 使用万用表测量 PPS 引脚是否有脉冲信号输出。

---

### 5.2 **检查 GPS 天线**
   - 确保 GPS 天线已正确连接并放置在开阔的环境中，避免天线被建筑物遮挡。
   - 如果使用的是主动天线，检查是否已为天线供电。

---

### 5.3 **验证 GPS 模块工作状态**
   - **通过串口查看 GPS 数据**：
     使用串口工具（如 `minicom` 或 `screen`）查看 GPS 模块是否输出 NMEA 数据：
     ```bash
     # 自带工具stty查看波特率
     stty -F /dev/ttyUSB0
     # 自带工具stty设置波特率
     stty -F /dev/ttyUSB0 9600
     # minicom设置波特率
     sudo minicom -D /dev/ttyS0 -b 9600
     ```
     根据 GPS 模块的默认波特率调整参数。如果 GPS 模块正常工作，应能看到类似以下内容：
     ```
     $GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47
     ```
   - 如果无数据输出：
     - 检查波特率是否正确。
     - 确认设备是否被系统识别（`ls /dev/tty*`）。
     - 确认串口连接是否正常。
   - EIS860可以使用`/opt/tools/EIS860_GPS/`下的脚本来获取GPS数据。

---

### 5.4 **检查 PPS 配置**
   - 验证内核是否支持 PPS：
     ```bash
     dmesg | grep pps
     ```
     如果内核支持 PPS，应能看到类似以下信息：
     ```
     [    1.432801] pps_core: LinuxPPS API ver. 1 registered
     [    1.437766] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
     [   16.744127] pps pps0: new PPS source pps-gpio.-1
     [   16.749792] pps pps0: Registered IRQ 314 as PPS source
     [  384.656306] pps_ldisc: PPS line discipline registered
     ```
结果显示，**Kernel PPS (KPPS) 已成功注册**，PPS 设备 (`pps0`) 正常工作：

**📌 结果分析**

1. ✅ **Kernel PPS (KPPS) 已启用**
   - `pps_core` 和 `pps_ldisc` 已加载，说明 Linux 已经支持 PPS。
   - `pps pps0: new PPS source pps-gpio.-1` → `pps-gpio` 驱动已经注册了一个 PPS 源。
   - `Registered IRQ 314` → 硬件中断已注册，PPS 信号可以被 Kernel 直接捕获。

2. ✅ **`/dev/pps0` 设备已成功创建**
   - 可以用 `ls -l /dev/pps*` 检查：
     ```bash
     ls -l /dev/pps*
     ```
   - 应该能看到 `/dev/pps0`。

3. ✅ **可以进行 `ppstest` 测试**
   运行：
   ```bash
   sudo ppstest /dev/pps0
   ```
   如果输出：
   ```
   source 0 - assert 1700000000.123456789, sequence: 100
   source 0 - assert 1700000001.123456789, sequence: 101
   ```
   说明 PPS **信号稳定**。

---

### 5.5 **确认 GPS 定位状态**
   - NMEA 数据中 `$GPGGA` 的第 7 个字段（E后面的字段）表示定位状态：
     - `0` 表示未定位。
     - `1` 表示已获得固定位置（定位成功）。
     - `2` 表示差分定位。
   - 如果状态为 `0`：
     - 检查 GPS 模块是否已初始化。
     - 确保天线放置环境适合接收卫星信号。

---

### 5.6 **诊断工具**
   - 安装 `gpsd` 和 `gpsmon` 进行调试：
     ```bash
     sudo apt install gpsd gpsd-clients
     sudo gpsmon /dev/ttyS0
     ```
     在 `gpsmon` 界面中可以观察卫星数量和信号质量。如果未显示卫星，可能是天线问题或模块未工作。

---

### 5.7 **日志检查**
   查看系统日志中的 GPS 和 PPS 相关信息：
   ```bash
   dmesg | grep -i gps
   dmesg | grep -i pps
   ```

---

### 5.8 **环境和配置问题**
   - 检查系统时间是否正确：
     ```bash
     timedatectl
     ```
   - 如果 GPS 需要冷启动，等待更长时间以便完成首次定位（通常需要几分钟）。

### 5.9 **检查 NTP 追踪状态**
```bash
ntptime
```
示例输出：
```
ntp_gettime() returns code 0 (OK)
  time e8a5d3f2.c3b7d000  Mon, Feb 11 2025 15:10:42.765 UTC
  precision -20 (0.953us)
  root delay 0.000000 s
  root dispersion 0.000061 s
  reference time:  e8a5d3f2.c3b7d000  (Mon, Feb 11 2025 15:10:42.765 UTC)
```

如果 `reference time` 来源是 `PPS`，说明 Jetson AGX Orin 正确使用 PPS 进行授时。

---


### 5.10 **手动强制同步时间（如果时间偏差较大）**
如果 `ntpd` 运行后时间偏差较大，可以手动同步：
```bash
sudo ntpd -gq
```
或者：
```bash
sudo ntpq -c "rv 0"
```

## 6 通过 `ntpq` 或 `chronyc` 检查偏差
### **如果使用 `ntpd`，运行：**
```bash
ntpq -p
```
示例输出：
```
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
*PPS(0)          .PPS.        0 l   7   16  377    0.000    0.002   0.001
+SHM(0)          .GPS.        0 l   9   64  377    0.000   -0.024   0.012
+time.google.com .GOOG.       1 u   8   64  377   10.344    0.300   0.150
```
关键参数：
- `offset`（偏移量，单位：毫秒或微秒）：反映本机时间与授时源的偏差。
  - 如果 `PPS` 为 `*`，并且 `offset` 在 `±0.002 ms` 内，则授时精度在 **2 µs** 级别。
- `jitter`（抖动，单位：毫秒或微秒）：表示授时数据的波动范围。

---

### **如果使用 `chrony`，运行：**
```bash
chronyc tracking
```
示例输出：
```
Reference ID    : PPS
Stratum         : 1
Ref time (UTC)  : Mon Feb 11 15:20:42 2025
System time     : 0.000000001 seconds fast of NTP time
Last offset     : +0.000000002 seconds
RMS offset      : 0.000000001 seconds
```
- `Last offset` 和 `RMS offset` 反映当前授时精度，如果数值在 **±1 ns ~ ±100 ns** 之间，则说明授时精度极高（纳秒级）。

---

### ** 典型授时精度范围**
| 授时方式           | 典型精度  | 备注                  |
| ------------------ | --------- | --------------------- |
| 仅 NTP（公网）     | 1~100 ms  | 受网络延迟影响        |
| GPS 无 PPS         | 10~100 ms | 受 GPS 计算延迟影响   |
| GPS + PPS + NTPD   | 1~10 µs   | 受系统 jitter 影响    |
| GPS + PPS + Chrony | 10~100 ns | 最佳配置，适合 Jetson |

如果需要更高精度（如 10 ns 级别），建议使用 **Chrony**，并优化系统内核（如 `PREEMPT-RT` 实时内核）。 🚀

## 7 PPS信号监测


### **1️⃣ `PPS` 监测脚本**
**功能更新：**
- 记录 `Error` 数据到 `pps_errors.log`
- 记录时间戳，便于后续分析
- 输出统计信息

保存为 `monitor_pps.py`：
```python
import subprocess
import re
import time
import statistics

LOG_FILE = "pps_errors.log"

# 运行 ppstest 进程
cmd = ["ppstest", "/dev/pps0"]
process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

assert_times = []
errors = []

print("Monitoring PPS assert intervals...\n")

with open(LOG_FILE, "w") as log_file:
    log_file.write("Timestamp,Error (μs)\n")  # 写入表头

try:
    while True:
        line = process.stdout.readline()
        if not line:
            break

        # 匹配 assert 事件时间
        match = re.search(r"assert (\d+\.\d+)", line)
        if match:
            timestamp = float(match.group(1))
            assert_times.append(timestamp)

            # 计算相邻 assert 之间的时间误差
            if len(assert_times) > 1:
                interval = assert_times[-1] - assert_times[-2]
                expected_interval = 1.0  # 期望间隔 1 秒
                error = (interval - expected_interval) * 1e6  # 误差转换为 μs（微秒）

                errors.append(error)
                current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(timestamp))
                print(f"{current_time} | Interval: {interval:.9f} s, Error: {error:.3f} μs")

                # 记录到日志文件
                with open(LOG_FILE, "a") as log_file:
                    log_file.write(f"{current_time},{error:.3f}\n")

            # 每 10 个数据点，计算误差统计
            if len(errors) >= 10:
                min_error = min(errors)
                max_error = max(errors)
                avg_error = sum(errors) / len(errors)
                std_dev = statistics.stdev(errors) if len(errors) > 1 else 0

                print(f"\n[Stats] Min: {min_error:.3f} μs, Max: {max_error:.3f} μs, "
                      f"Avg: {avg_error:.3f} μs, StdDev: {std_dev:.3f} μs\n")

                errors.clear()  # 清空误差列表，继续统计

except KeyboardInterrupt:
    print("\nStopping monitoring...")
    process.terminate()
```
---

### **2️⃣ 误差变化趋势绘图脚本**
**功能更新：**
- 读取 `pps_errors.log` 文件
- 绘制 `Error` 误差的变化趋势
- 显示误差随时间的分布

保存为 `plot_pps_errors.py`：
```python
import matplotlib.pyplot as plt
import pandas as pd
from pandas.plotting import register_matplotlib_converters

register_matplotlib_converters()

LOG_FILE = "pps_errors.log"

# 读取日志文件
df = pd.read_csv(LOG_FILE)

# 解析时间戳
df["Timestamp"] = pd.to_datetime(df["Timestamp"])
df = df.sort_values(by="Timestamp")  # 确保数据按时间排序

# 画图
plt.figure(figsize=(10, 5))
plt.plot(df["Timestamp"], df["Error (μs)"], marker="o", linestyle="-", color="b", label="PPS Error (μs)")
plt.axhline(y=0, color="r", linestyle="--", label="Ideal Error = 0")
plt.xlabel("Time")
plt.ylabel("Error (μs)")
plt.title("PPS Error Over Time")
plt.legend()
plt.grid()

# 显示图表
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
```
---

### **3️⃣ 使用方法**
**运行 `PPS` 监测脚本（记录数据）：**
```bash
python3 monitor_pps.py
```
**运行绘图脚本（分析数据）：**
```bash
python3 plot_pps_errors.py
```
---

### **4️⃣ 输出示例**
#### **📜 日志 (`pps_errors.log`) 示例**
```
Timestamp,Error (μs)
2025-03-04 12:00:01,-3.250
2025-03-04 12:00:02,1.873
2025-03-04 12:00:03,-2.540
...
```
#### **📈 绘图示例**
✅ **误差变化趋势图**
- X 轴：时间戳
- Y 轴：`PPS Error (μs)`
- 蓝色折线：误差变化趋势
- 红色虚线：理想误差 `0 μs` 参考线

---

这样，不仅可以监测 `PPS` 误差，还可以通过 `plot_pps_errors.py` 可视化分析误差的变化趋势

## 8 chrony.conf

修改 `/etc/chrony/chrony.conf`（或 `/etc/chrony.conf`），确保添加：
```ini
# 使用 GPS 共享内存（SHM 0）作为主要时间来源
refclock SHM 0 offset 0.5 delay 0.2 refid GPS noselect

# 使用 PPS 设备作为高精度同步源
refclock PPS /dev/pps0 lock GPS refid PPS
```
然后重启 chronyd：
```bash
sudo systemctl restart chronyd
```

检查 `chronyc sources`：
```bash
chronyc sources -v
```
如果 `PPS` 仍未生效，请检查 `journalctl` 日志：
```bash
sudo journalctl -u chronyd --no-pager | tail -n 50
```

---

### ** 确保 GPSD 提供 NMEA 数据**
你的 `/etc/default/gpsd` 配置如下：
```ini
GPSD_OPTIONS="-n"
DEVICES="/dev/ttyUSB0"
USBAUTO="false"
```
但是，`chronyc sources -v` 显示 GPS 时间偏差很大（+5383ms），可能是：
1. GPS 设备 `/dev/ttyUSB0` 可能未正确提供 NMEA 时间数据。
2. GPSD 未正确与 chrony 共享时间数据。

**检查 GPS 数据是否正常**
运行：
```bash
cgps -s
```
或：
```bash
gpsmon /dev/ttyUSB0
```
确保 GPS 设备有 `3D FIX` 并提供有效的 `GPRMC` 或 `GPGGA` 数据。如果 `cgps -s` 无法获取数据，可能是 `gpsd` 设备路径错误，尝试：
```bash
sudo gpsd -n /dev/ttyUSB0
```
然后再次运行 `cgps -s` 检查数据是否正常。

如果 GPS 数据正常但 `chrony` 仍然不认 `GPS`，可能是 `gpsd` 没有向 `/dev/shm` 共享时间数据。尝试：
```bash
ls -l /dev/shm
```
如果 `/dev/shm` 里没有 `gpsd` 相关的 SHM 设备，可能需要手动启动 `gpsd`：
```bash
sudo systemctl restart gpsd
```

---

### ** 检查 Chrony 是否成功访问 `/dev/pps0`**
`PPS` 信号 reach 为 `0`，可能是 Chrony 无法访问 `/dev/pps0`。检查：
```bash
ls -l /dev/pps0
```
输出应类似：
```
crw-rw---- 1 root dialout 251, 0 Feb 19 12:00 /dev/pps0
```
如果 `chronyd` 运行的用户没有 `dialout` 组权限，执行：
```bash
sudo usermod -aG dialout chrony
sudo systemctl restart chronyd
```

如果 `ls -l /dev/pps0` 发现设备不存在，可能是 `pps-gpio` 或 `pps_core` 模块未加载：
```bash
sudo modprobe pps-gpio
sudo modprobe pps_core
```
然后检查：
```bash
lsmod | grep pps
```
应返回：
```
pps_gpio               16384  0
pps_core               20480  1 pps_gpio
```

---

### **4. 检查 Chrony 是否正确使用 GPS+PPS**
在 `chronyc tracking` 中，你应该看到：
```
Reference ID    : PPS
Stratum         : 1
```
如果 `Reference ID` 仍然是 `203.107.6.88`，说明 Chrony 仍然未使用 `PPS`。

---

### **最终测试**
按以下步骤重新测试：
1. 确保 `gpsd` 正在运行：
   ```bash
   sudo systemctl restart gpsd
   cgps -s
   ```
2. 确保 `/dev/pps0` 存在：
   ```bash
   ls -l /dev/pps0
   ```
3. 确保 `chrony` 读取了 `GPS` 和 `PPS`：
   ```bash
   sudo systemctl restart chronyd
   chronyc sources -v
   ```