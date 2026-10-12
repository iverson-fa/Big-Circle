# Preempt_rt

## 1 简介

### 1.1 基础概念

- **实时系统（Real-Time System）**：
  是指**时间要求本身就是系统功能的一部分**的系统。
  换句话说，不只是结果要对，而且**必须在规定的时间内给出正确的结果**，否则就算失败。

  > 举例：
  > - 汽车安全气囊系统 —— 气囊必须在撞击后**几十毫秒内**弹出，否则后果严重。
  > - 飞机飞控系统 —— 指令处理延迟可能直接影响飞行安全。

---

- **实时操作系统（RTOS, Real-Time Operating System）**：
  是一种特别设计用来**保证应用程序在规定时间内完成特定任务**的操作系统。
  它通过高效的调度、抢占、优先级管理等机制，来确保任务能满足其**确定性时间要求**。

  > 核心特点通常包括：
  > - **确定性（Determinism）**：响应时间可预测。
  > - **优先级调度**：高优先级任务能迅速抢占低优先级任务。
  > - **最小化延迟**：调度延迟、上下文切换时间、响应时间都非常小。
  > - **资源管理**：比如内存、IO 资源调度要严格控制，避免不可控的延迟。

---

一句话总结：
> **实时系统强调"时间就是功能"，RTOS 是为保证这种功能而优化设计的系统软件。**

举例：
```shell
for (;;) {
    t0 = now();
    feedback = sample();
    output = calculate(feedback, setpoint);
    write_new_point(output);
    sleep_until(t0 + T);
}
```

### 1.2 两种延迟

- **唤醒延迟（Wakeup Latency 或 Scheduling Latency）**：
  是指**外部事件发生**（比如定时器到期、中断触发）到**相关线程真正开始运行**之间的时间差。
  > 举个例子：一个定时器在 100 毫秒时到期，但你的线程实际在 100.2 毫秒才开始执行，那么唤醒延迟就是 **200 微秒**。

- **执行延迟（Execution Latency）**：
  是指**线程理想执行时间**和**实际执行时间**之间的差值。它反映了线程在执行过程中因为各种原因（如缓存失效、CPU抢占、调度延迟等）造成的额外耗时。
  > 举个例子：一个任务理想情况下应该在 5 毫秒内完成，但实际完成用了 7 毫秒，那么执行延迟就是 **2 毫秒**。

---

在做**实时系统调优**（比如基于 PREEMPT-RT 的 Linux 系统）时，这两个延迟指标非常重要，直接影响系统的响应速度和稳定性。

```shell
# wakeup test
for (;;) {
    t0 = now();
    sleep(expected_T);
    t1 = now();
    actual_T = t1 – t0;
    plot(actual_T - expected_T); # 16us
}
```
实现程序：
```c
/* expected_T_us 是你希望的理想周期，比如 1000 微秒。
now() 使用 std::chrono::high_resolution_clock::now() 获取当前时间。
sleep(expected_T) 用 std::this_thread::sleep_for()。
每次循环记录 (t1 - t0) - expected_T，即误差。
把结果存到 deviation_data.csv 文件里，之后可以用 Python、Excel、Matplotlib 来画误差曲线。
*/
#include <iostream>
#include <chrono>
#include <thread>
#include <vector>
#include <fstream>

// 简化类型定义
using Clock = std::chrono::high_resolution_clock;
using TimePoint = Clock::time_point;
using Duration = std::chrono::duration<double, std::micro>; // 微秒(us)

int main() {
    const double expected_T_us = 1000.0; // 期望周期：1000微秒 = 1毫秒
    const int iterations = 1000;         // 测试次数
    std::vector<double> deviations;      // 保存误差结果

    deviations.reserve(iterations);

    for (int i = 0; i < iterations; ++i) {
        TimePoint t0 = Clock::now();

        // 睡眠期望时间
        std::this_thread::sleep_for(std::chrono::microseconds((int)expected_T_us));

        TimePoint t1 = Clock::now();

        // 计算实际经过的时间
        Duration actual_T = t1 - t0;

        // 记录误差（实际 - 期望）
        double deviation = actual_T.count() - expected_T_us;
        deviations.push_back(deviation);

        // 打印每次误差（可选）
        std::cout << "Deviation (" << i << "): " << deviation << " us" << std::endl;
    }

    // 把结果输出到文件，方便后续画图
    std::ofstream out("deviation_data.csv");
    for (size_t i = 0; i < deviations.size(); ++i) {
        out << i << "," << deviations[i] << std::endl;
    }
    out.close();

    std::cout << "Test complete. Deviations saved to deviation_data.csv" << std::endl;

    return 0;
}
```
读取文件并画图：
```python
import matplotlib.pyplot as plt
import pandas as pd

# 读取CSV数据
data = pd.read_csv('deviation_data.csv', header=None, names=['index', 'deviation'])

# 提取横轴（循环次数）和纵轴（误差微秒）
x = data['index']
y = data['deviation']

# 画图
plt.figure(figsize=(10, 5))
plt.plot(x, y, marker='o', linestyle='-', markersize=2)
plt.title('Deviation between Actual and Expected Sleep Time')
plt.xlabel('Iteration')
plt.ylabel('Deviation (microseconds)')
plt.grid(True)
plt.tight_layout()
plt.show()
```

### 1.3 抢占

> 1. 当线程由于被更高优先级的线程唤醒和执行而暂停执行时，该线程被视为被抢占。
> 2. 如果更高优先级线程的唤醒会触发抢占事件，则该线程被视为可抢占。
> 3. 抢占模型在编译时定义哪些内核代码路径可以被抢占。

### 1.4 Execution Contexts

> 1. 线程上下文是由软件启动的任何执行流。
> 2. 中断上下文是由硬件启动的任何执行流程。

## 2 测试

### 2.1 测试工具 Cyclictest

- https://rt.wiki.kernel.org/index.php/Cyclictest
- https://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git

```bash
# 举例
cyclictest -S -p 98 -m -h 350 --histfile=h.txt
```
用 `cyclictest` 工具做实时性延迟测试，参数如下：

| 参数 | 解释 |
|:-----|:-----|
| `-S` | 单次模式（**Single shot mode**），每次定时器触发后只调度一次，不是周期性地一直循环。适合测一次响应时间。 |
| `-p 98` | 设置实时调度优先级为 98（范围通常是 1～99，越高优先级越高）。|
| `-m` | 锁住内存（**mlockall**），防止测试时因为缺页或内存交换造成的延迟。|
| `-h 350` | 开启直方图功能，记录延迟值，最大记录 350 微秒以内的数据（如果超过这个范围，需要重新调整 `-h` 参数）。|
| `--histfile=h.txt` | 把延迟直方图保存到文件 `h.txt`。方便后续分析。 |

|问题 | 特征 | 排查思路|
|:-----|:-----|:-----|
|CPU 负载太高 | 整体延迟高，平均也高 | htop 看负载；绑核、降负载|
|IRQ 没绑定好 | 偶尔跳出大延迟峰 | 查 /proc/interrupts + irqbalance 是否禁用，自己绑核|
|CPU 没隔离 | 非实时任务乱跑到实时核上打扰 | 用 isolcpus 隔离核|
|SMI (系统管理中断) | 延迟突然大（毫秒级别） | 查 BIOS，关掉 SMI（部分主板才有）|
|内存换页/压栈 | 偶发大延迟 | 开 -m 锁内存（你已经加了👍）|
|睡眠/频率调节 | 延迟慢慢上升再跳一下 | 固定 CPU 频率，关掉省电模式 (cpufreq governor 改成 performance)|

## 3 chrt 和 taskset

### 一、`chrt` — 设置进程的实时调度策略与优先级

#### 基本作用

`chrt` 用于**查看或修改一个进程的调度策略和实时优先级**。

在 PREEMPT-RT 环境中，你可以使用它来让进程以 `SCHED_FIFO`（实时抢占）或 `SCHED_RR`（实时轮转）等调度策略运行，从而提高进程的调度确定性。

✅ 常见调度策略

| 策略名称             | 说明                  |
| ---------------- | ------------------- |
| `SCHED_OTHER`    | 普通调度策略（默认）          |
| `SCHED_FIFO`     | 先到先服务的实时调度          |
| `SCHED_RR`       | 时间片轮转的实时调度          |
| `SCHED_DEADLINE` | 适用于带截止时间任务（需特殊内核支持） |

🔧 使用示例

```bash
# 启动新进程并以 SCHED_FIFO 调度优先级 90 运行
sudo chrt -f 90 ./your_program

# 查看已有进程的调度策略和优先级
chrt -p <PID>
```

🎯 注意事项

* 优先级范围：`SCHED_FIFO` 和 `SCHED_RR` 的优先级范围通常是 1～99，数值越高，优先级越高；
* 必须使用 `sudo`；
* 优先级高的实时进程可能“饿死”其他进程，因此要合理规划 CPU。

---

### 二、`taskset` — 设置进程的 CPU 亲和性

#### 基本作用

`taskset` 用于**绑定进程到特定 CPU 核心运行**，控制进程在哪些 CPU 上执行，从而避免 CPU 抢占、Cache 抖动等不确定性。

✅ 示例用途

* 为实时任务绑定核心，避免和非实时进程混用；
* 实现核内隔离，提高系统确定性。

🔧 使用示例

```bash
# 将进程绑定到 CPU 核心 2 运行
sudo taskset -c 2 ./your_program

# 与 chrt 联合使用，绑定核心 + 实时优先级
sudo taskset -c 2 chrt -f 90 ./your_program
```

🎯 注意事项

* 核心编号从 0 开始；
* 可指定多个核心，例如 `-c 2,3` 或 `-c 0-3`；
* 可用于已有进程，例如：

```bash
# 给已有 PID 设置绑定核心
sudo taskset -cp 3 <PID>
```

---

### 三、两者对比与配合使用

| 特性        | `chrt`   | `taskset`  |
| --------- | -------- | ---------- |
| 控制什么？     | 调度策略与优先级 | CPU 亲和性    |
| 是否影响实时性？  | ✅ 高度相关   | ✅ 非常关键     |
| 是否可以同时用？  | ✅ 推荐一起使用 | ✅          |
| 是否需 sudo？ | ✅ 是      | ✅ 是（对系统进程） |

### ✅ 联合使用示例：

```bash
# 把节点运行在 CPU2 上，优先级90，调度策略 FIFO
sudo taskset -c 2 chrt -f 90 ros2 run your_package your_node
```

这能显著提升 ROS 2 或 Cyclone DDS 节点在 PREEMPT-RT 下的**通信实时性与可预测性**。

---

### 四、总结

| 工具        | 用途              | 在实时中的作用        |
| --------- | --------------- | -------------- |
| `chrt`    | 设置调度策略和优先级      | 控制调度抢占顺序，实现低延迟 |
| `taskset` | 限制进程在哪些 CPU 上运行 | 实现 CPU 隔离，减少干扰 |

