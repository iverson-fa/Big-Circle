# Jetson 测试相关配置

## 1 提高时钟频率

这组命令的作用是 **锁定并设置 Jetson 平台上一些关键时钟（VI、ISP、NVCSI）为最大频率**，以提高性能，尤其是在图像处理和视频相关任务中。

### **🚀 一键执行**
可以将这些命令写入一个 **shell 脚本**，每次启动时自动执行：
```sh
#!/bin/bash
# file_name : set_max_clk.sh
echo 1 > /sys/kernel/debug/bpmp/debug/clk/vi/mrq_rate_locked
echo 1 > /sys/kernel/debug/bpmp/debug/clk/isp/mrq_rate_locked
echo 1 > /sys/kernel/debug/bpmp/debug/clk/nvcsi/mrq_rate_locked

cat /sys/kernel/debug/bpmp/debug/clk/vi/max_rate | tee /sys/kernel/debug/bpmp/debug/clk/vi/rate
cat /sys/kernel/debug/bpmp/debug/clk/isp/max_rate | tee /sys/kernel/debug/bpmp/debug/clk/isp/rate
cat /sys/kernel/debug/bpmp/debug/clk/nvcsi/max_rate | tee /sys/kernel/debug/bpmp/debug/clk/nvcsi/rate
```

---

### **📌 解析各条命令**
#### **1. 切换到 root 权限**
```sh
sudo su
```
确保后续命令有足够的权限修改 `sysfs` 相关的内核参数。

---

#### **2. 锁定时钟速率**
```sh
echo 1 > /sys/kernel/debug/bpmp/debug/clk/vi/mrq_rate_locked
echo 1 > /sys/kernel/debug/bpmp/debug/clk/isp/mrq_rate_locked
echo 1 > /sys/kernel/debug/bpmp/debug/clk/nvcsi/mrq_rate_locked
```
- `mrq_rate_locked` 设置为 `1`，表示 **锁定时钟频率**，防止自动调节（DVFS）。
- 这些时钟相关于：
  - `vi`（Video Input）：处理摄像头数据
  - `isp`（Image Signal Processor）：图像信号处理
  - `nvcsi`（NVIDIA Camera Serial Interface）：MIPI CSI 接口

🔹 **作用**：确保摄像头和 ISP 相关模块运行在固定频率，以减少性能波动，提高稳定性。

---

#### **3. 设置时钟到最大频率**
```sh
cat /sys/kernel/debug/bpmp/debug/clk/vi/max_rate | tee /sys/kernel/debug/bpmp/debug/clk/vi/rate
cat /sys/kernel/debug/bpmp/debug/clk/isp/max_rate | tee /sys/kernel/debug/bpmp/debug/clk/isp/rate
cat /sys/kernel/debug/bpmp/debug/clk/nvcsi/max_rate | tee /sys/kernel/debug/bpmp/debug/clk/nvcsi/rate
```
- `cat /sys/kernel/debug/bpmp/debug/clk/xxx/max_rate`：获取该时钟的 **最大可用频率**
- `tee /sys/kernel/debug/bpmp/debug/clk/xxx/rate`：将最大频率写入 `rate`，强制设置为最大频率

🔹 **作用**：确保 VI、ISP 和 NVCSI 运行在最高时钟频率，以获得最高性能。

---

### **🚀 适用场景**
✅ **摄像头高帧率采集**（如 4K 60FPS）
✅ **图像处理、ISP 加速**（提高图像质量和吞吐）
✅ **深度学习推理**（特别是基于摄像头输入的任务）
✅ **防止时钟频率下降**（避免性能抖动）

---

### **⚠ 注意事项**
1. **可能会增加功耗和温度**
   - Jetson 平台会自动动态调整频率来平衡功耗，锁定最大频率可能导致功耗增加，发热增多。
   - 可以使用 `tegrastats` 监测功耗：
     ```sh
     sudo tegrastats
     ```

2. **可能导致不稳定**
   - 如果设备电源或散热不充分，锁频可能导致过热降频（throttling）。
   - 可以监控温度：
     ```sh
     cat /sys/devices/virtual/thermal/thermal_zone0/temp
     ```

3. **仅在 Jetson 平台上可用**
   - 这些 `/sys/kernel/debug/bpmp/debug/clk/` 接口是 Jetson 设备专有的，其他 Linux 设备不可用。

## 2 测试相机时启用 `trace`

这组命令用于 **在 Jetson 平台上启用内核跟踪（ftrace）并捕获摄像头相关的调试信息**，主要用于调试 **VI（Video Input）、ISP（Image Signal Processor）、NVCSI（NVIDIA Camera Serial Interface）** 等模块。

```shell
#!/bin/bash
# file_name : camera_trace.sh
echo 1 > /sys/kernel/debug/tracing/tracing_on
echo 30720 > /sys/kernel/debug/tracing/buffer_size_kb
echo 1 > /sys/kernel/debug/tracing/events/tegra_rtcpu/enable
echo 1 > /sys/kernel/debug/tracing/events/freertos/enable
echo 2 > /sys/kernel/debug/camrtc/log-level
echo 1 > /sys/kernel/debug/tracing/events/camera_common/enable
echo > /sys/kernel/debug/tracing/trace
cat /sys/kernel/debug/tracing/trace
```

---

### **1. 启用内核跟踪**
```sh
echo 1 > /sys/kernel/debug/tracing/tracing_on
```
- `tracing_on` 控制 **ftrace（内核跟踪框架）**，`1` 代表启用跟踪。

---

### **2. 设置跟踪缓冲区大小**
```sh
echo 30720 > /sys/kernel/debug/tracing/buffer_size_kb
```
- `buffer_size_kb` 设置 **跟踪数据缓冲区大小**，单位是 KB，这里设为 `30720 KB`（30MB）。
- **如果数据量大，可以适当调高，避免丢失关键日志。**

---

### **3. 启用 `tegra_rtcpu` 事件**
```sh
echo 1 > /sys/kernel/debug/tracing/events/tegra_rtcpu/enable
```
- `tegra_rtcpu` 代表 **Jetson 运行在 Realtime CPU（RTCPU）上的事件**，主要用于 **摄像头和图像处理**。
- 可能包括 **帧捕获、CSI 传输、ISP 处理等时序信息**。

---

### **4. 启用 FreeRTOS 事件**
```sh
echo 1 > /sys/kernel/debug/tracing/events/freertos/enable
```
- `freertos` 事件用于捕获 **Jetson 内部运行的 FreeRTOS 实时调度信息**，这些线程可能涉及摄像头任务。

---

### **5. 设置 `camrtc` 日志级别**
```sh
echo 2 > /sys/kernel/debug/camrtc/log-level
```
- `camrtc/log-level` 控制摄像头相关的日志级别：
  - `0`：关闭日志
  - `1`：只记录严重错误
  - `2`：记录警告和错误（**推荐**）
  - `3`：详细日志（包含调试信息）
- 这里设置为 `2`，可捕获 **警告和错误信息**，避免日志过多影响性能。

---

### **6. 启用 `camera_common` 事件**
```sh
echo 1 > /sys/kernel/debug/tracing/events/camera_common/enable
```
- `camera_common` 事件包含摄像头驱动相关的 **通用日志**，可以看到设备初始化、错误状态等信息。

---

### **7. 清空现有跟踪日志**
```sh
echo > /sys/kernel/debug/tracing/trace
```
- 清空 `trace` 缓冲区，防止旧日志影响调试。

---

### **8. 读取跟踪日志**
```sh
cat /sys/kernel/debug/tracing/trace
```
- 读取当前跟踪日志，获取所有 **tegra_rtcpu、freertos、camera_common** 相关的调试信息。

---

**🚀 适用场景**
✅ **摄像头调试**（排查驱动、ISP、CSI 相关问题）
✅ **时序分析**（检查帧处理时间、数据传输是否有延迟）
✅ **系统优化**（找出影响摄像头性能的瓶颈）
✅ **摄像头异常诊断**（黑屏、掉帧、崩溃、I2C 失败等）

---

### **🔍 实时查看日志**
可以使用 `tail -f` 持续监控：
```sh
tail -f /sys/kernel/debug/tracing/trace
```
这样可以 **实时观察摄像头的调试信息**。

---

### **📂 导出日志到文件**
如果需要保存日志用于分析：
```sh
cat /sys/kernel/debug/tracing/trace > camera_debug.log
```
然后可以用 `grep` 过滤关键字：
```sh
grep "error" camera_debug.log
```

---

**🔴 注意事项**
1. **可能会影响系统性能**
   - `ftrace` 记录的日志较多，**长时间启用可能影响系统性能**。
   - 如果不再需要跟踪，建议关闭：
     ```sh
     echo 0 > /sys/kernel/debug/tracing/tracing_on
     ```

2. **日志大小受限**
   - `buffer_size_kb` 设为 30MB 可能不够，如果数据量大，可以增大：
     ```sh
     echo 65536 > /sys/kernel/debug/tracing/buffer_size_kb
     ```

3. **确保 `debugfs` 已挂载**S
   - 如果 `/sys/kernel/debug/tracing/` 不存在，可能需要先挂载：
     ```sh
     mount -t debugfs none /sys/kernel/debug
     ```

---

**🔥 总结**
✅ 这组命令用于 **调试 Jetson 摄像头时序、ISP 处理、数据流问题**
✅ 通过 `ftrace` 记录 **tegra_rtcpu、freertos、camera_common** 事件
✅ 可 **实时查看日志、分析时序、排查摄像头异常**
✅ **建议配合 `grep` 过滤关键日志，提高调试效率**