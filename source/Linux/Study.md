# Linux 系统级开发与调试技术大纲

---

## 第1章：Linux工具链深入解析

### 1.1 GNU工具链和GDB调试
- **核心内容**：
  - GNU 工具链组成（GCC、binutils、glibc、make等）
  - GDB 基本用法：启动、连接进程、查看变量/寄存器
- **重点掌握**：
  - 编译带调试信息的程序 `-g`
  - 使用 `gdb ./program` 或 `gdb -p PID` 调试运行中的进程

---

### 1.2 GCC编译的各个阶段分解
- **四个阶段详解**：
  1. 预处理（`.i`）：宏展开、头文件包含 → `gcc -E`
  2. 编译（`.s`）：C → 汇编代码 → `gcc -S`
  3. 汇编（`.o`）：汇编 → 目标文件 → `as`
  4. 链接（可执行）：符号解析与重定位 → `ld`
- **实践建议**：
  - 手动分步编译一个简单程序，观察中间产物

---

### 1.3 反汇编，objdump
- **objdump 常用命令**：
  ```bash
  objdump -d binary        # 反汇编代码段
  objdump -D binary        # 全部反汇编（含数据）
  objdump -h binary        # 查看节头表
  objdump -x binary        # 显示所有头部信息
  ```
- **用途**：
  - 分析崩溃地址对应函数
  - 理解编译器优化后的机器码行为

---

### 1.4 readelf, nm, strip
| 工具     | 功能 |
|---------|------|
| `readelf -a` | 查看 ELF 文件结构（段、节、符号、重定位等） |
| `nm`         | 列出符号表（T=tex, D=data, B=bss, U=undefined） |
| `strip`      | 删除符号信息以减小体积（发布时常用） |

> ⚠️ 注意：strip 后无法使用 GDB 符号调试！

---

### 1.5 GDB调试技巧: 断点、watch、内存与backtrace等
- **关键技巧**：
  - `break func / file.c:line`
  - `watch var`（硬件 watchpoint，监视变量变化）
  - `x/10xw $sp`（查看栈内存）
  - `bt` / `backtrace`（调用栈回溯）
  - `info registers`, `print/x $pc`
- **进阶技巧**：
  - 条件断点：`b main if argc > 1`
  - 命令脚本自动化：`define cmd ... end`

---

### 1.6 GDB与多线程
- **多线程调试难点**：
  - 默认只关注当前线程
- **GDB 多线程命令**：
  - `info threads` —— 查看所有线程
  - `thread N` —— 切换线程上下文
  - `set scheduler-locking on` —— 锁定调度器避免其他线程干扰
  - `thread apply all bt` —— 所有线程打印 backtrace

---

### 1.7 崩溃转储 core dump
- **开启 core dump**：
  ```bash
  ulimit -c unlimited
  echo "/tmp/core.%e.%p" > /proc/sys/kernel/core_pattern
  ```
- **分析方法**：
  ```bash
  gdb ./myapp /tmp/core.myapp.1234
  (gdb) bt full
  ```
- **注意**：确保二进制未 strip，且版本一致

---

### 1.8 strace 和 ltrace
| 工具    | 作用 |
|--------|------|
| `strace` | 跟踪系统调用（open, read, write, fork, etc） |
| `ltrace` | 跟踪库函数调用（malloc, printf, pthread_create） |

- **典型用途**：
  - 程序卡住？→ `strace -p PID`
  - 找不到配置文件？→ `strace ./app 2>&1 | grep open`
- **性能影响大，仅用于诊断**

---

## 第2章：进程、内存和I/O负载调试剖析

### 2.1 多核负载均衡
- **概念**：
  - CPU 负载不均可能导致瓶颈
- **排查手段**：
  - `mpstat -P ALL 1` 观察各核利用率
  - 检查中断亲和性 `/proc/irq/*/smp_affinity`
  - 使用 `taskset` 控制进程绑定 CPU

---

### 2.2 top, htop, mpstat 工具
| 工具       | 特点 |
|-----------|------|
| `top`     | 实时监控进程资源占用 |
| `htop`    | 更友好的交互界面，支持鼠标、颜色、树形视图 |
| `mpstat`  | 来自 sysstat 包，按 CPU 核心统计性能 |

> 推荐组合使用：`htop` 快速定位问题进程 + `mpstat` 分析 CPU 分布

---

### 2.3 系统、进程内存占用分析
- 关键指标：
  - RSS（Resident Set Size）：物理内存使用
  - VSZ（Virtual Memory Size）：虚拟内存大小
  - Shared Memory、Cache、Buffers
- 工具：
  - `/proc/PID/status`, `/proc/meminfo`
  - `pmap -x PID`：详细内存映射
  - `smem`：按 USS/PSS 统计内存（更适合容器环境）

---

### 2.4 内存泄露调试
- **常见工具**：
  - **Valgrind (memcheck)**：
    ```bash
    valgrind --tool=memcheck --leak-check=full ./app
    ```
  - **AddressSanitizer (ASan)**（见下一节）
  - **mtrace() / dmalloc**：传统 C 库辅助检测

---

### 2.5 内存踩踏调试：ASAN, KASAN, MTE
| 技术 | 平台 | 用途 |
|------|------|------|
| **ASan (AddressSanitizer)** | 用户态 | 检测越界访问、use-after-free、double-free |
| **KASan (Kernel ASan)** | 内核态 | 类似 ASan，用于内核模块 |
| **MTE (Memory Tagging Extension)** | ARM64 v8.5+ | 硬件级内存安全机制，轻量级检测堆栈溢出 |

- 示例（ASan）：
  ```bash
  gcc -fsanitize=address -g myapp.c -o myapp
  ```

---

### 2.6 iowait调试
- **现象**：CPU idle 高但系统响应慢，`%iowait` 占比高
- **排查步骤**：
  1. `iostat -x 1` 查看设备利用率 `%util` 和延迟 `await`
  2. `iotop` 查看哪个进程在大量读写
  3. 检查磁盘是否老化、RAID状态、文件系统日志模式
- **优化方向**：
  - 异步 I/O（aio/io_uring）
  - 减少 sync 写操作
  - 使用更快存储介质（NVMe）

---

### 2.7 swap调试
- **何时触发 swap？**
  - 内存紧张时，内核将不活跃页换出到 swap 分区
- **判断是否异常**：
  - `free -h`, `vmstat 1`
  - 若 `si/so`（swap in/out）持续非零 → 内存压力大
- **解决方案**：
  - 增加 RAM
  - 调整 `swappiness`（默认 60）：
    ```bash
    sysctl vm.swappiness=10
    ```
  - 避免滥用 mmap 大文件

---

## 第3章：内核调试

### 3.1 printk 及其变体
- `printk()` 是内核最基础的日志输出方式
- 日志级别：`KERN_EMERG` ~ `KERN_DEBUG`
- 输出位置：`dmesg` 或 `/var/log/kern.log`
- 替代方案：
  - `dev_info/dev_err`：更规范的驱动日志
  - `trace_printk()`：用于 ftrace 追踪

---

### 3.2 内核崩溃 OOPS 分析
- **OOPS 是什么？**
  - 内核错误但未完全崩溃（如空指针解引用）
- **如何分析？**
  - 获取 `dmesg` 中的调用栈
  - 使用 `scripts/decode_stacktrace.sh`（配合VMLINUX）
  - 结合 `addr2line` 定位源码行
- **关键字段**：
  - EIP/RIP 寄存器值
  - Call Trace

---

### 3.3 内核 debug 选项
- 编译时开启调试功能：
  - `CONFIG_DEBUG_KERNEL=y`
  - `CONFIG_DEBUG_INFO=y`（生成调试符号）
  - `CONFIG_FRAME_POINTER=y`（便于 backtrace）
  - `CONFIG_SLUB_DEBUG`（检测 slab 分配错误）
- 开发推荐配置 `.config` 启用这些选项

---

### 3.4 proc 和 sys
| 路径 | 用途 |
|------|------|
| `/proc` | 进程与系统运行时信息（文本接口） |
| `/sys`  | 设备模型、电源管理、uevent 等（sysfs） |

- 示例：
  - `/proc/cpuinfo`, `/proc/meminfo`
  - `/sys/class/net/eth0/operstate`
  - 动态修改参数：`echo 1 > /proc/sys/net/ipv4/ip_forward`

---

### 3.5 内核启动过程调试
- 方法：
  - 添加 `initcall_debug` 参数记录每个 initcall 时间
  - 使用 `earlyprintk` 输出早期启动日志
  - `bootparam` 设置 `loglevel=8`
- 工具：
  - U-Boot 日志
  - Serial Console（串口抓 log）

---

### 3.6 内核启动时间优化调试
- **测量方法**：
  - `dmesg | grep "Call Ret"` 或 `trace-cmd record -e sched:sched_process_exec`
  - 使用 `bootgraph.pl` 生成启动时间图
- **优化手段**：
  - 异步初始化：`__async_initcall`
  - 延迟非必要模块加载
  - 使用 initramfs 减少挂载延迟

---

### 3.7 待机和电源管理调试
- 关键子系统：
  - CPU Idle states (C-states)
  - Device runtime PM
  - System Suspend (S3/S4)
- 调试工具：
  - `cpupower idle-info`
  - `cat /sys/power/state` → 查看支持的休眠模式
  - `pm_trace`：帮助定位唤醒源
- 常见问题：
  - 设备未进入低功耗状态
  - Wake-up source 未清除

---

### 3.8 gdb调试内核
- **前提条件**：
  - 编译内核时启用 `CONFIG_DEBUG_INFO`
  - 获取 `vmlinux`（未压缩的内核镜像）
- **使用方式**：
  - QEMU + KGDB：
    ```bash
    qemu-system-x86_64 -s -S -kernel bzImage ...
    gdb vmlinux
    (gdb) target remote :1234
    ```
  - 或通过 kgdb over serial 调试真实硬件

---

### 3.9 内核 lockup，锁，sched，mm问题调试
- **Soft Lockup**： watchdog 检测到进程长时间占用 CPU
- **Hard Lockup**： NMI watchdog 检测到 CPU 完全无响应
- **相关机制**：
  - `nmi_watchdog`, `softlockup_panic`
- **调试工具**：
  - `ftrace`（function tracer, irqsoff, preemptoff）
  - `perf sched` 分析调度延迟
  - `kmemleak` 检测内核内存泄漏
  - `lockdep`：检测死锁潜在风险

---

## 第4章：Linux多进程、多线程模型和调试

### 4.1 多进程通信
- IPC 方式：
  - Pipe / FIFO（匿名/命名管道）
  - Signal（信号）
  - Socket（本地 AF_UNIX）
  - Message Queue / Shared Memory / Semaphore（System V / POSIX）

---

### 4.2 多线程通信
- 共享内存为主（同一进程地址空间）
- 同步机制：mutex、cond var、rwlock、barrier
- TLS（Thread Local Storage）隔离数据

---

### 4.3 正确的互斥和同步方法
- **最佳实践**：
  - 尽量减少临界区
  - 避免嵌套锁（防死锁）
  - 使用 RAII（C++）或 cleanup handlers（pthread_cleanup_push）
- **推荐 API**：
  - `pthread_mutex_timedlock()` 防止无限等待
  - `std::mutex` + `std::lock_guard`（C++）

---

### 4.4 可重入与线程安全
| 概念 | 定义 |
|------|------|
| **可重入（Reentrant）** | 函数可被多个上下文同时调用（例如信号处理） |
| **线程安全（Thread-safe）** | 多线程并发调用不会出错 |

> ✅ 所有可重入函数都是线程安全，反之不一定成立

---

### 4.5 多进程、多线程调试
- 工具：
  - GDB 多线程调试（见 1.6）
  - Valgrind + Helgrind / DRD 检测数据竞争
    ```bash
    valgrind --tool=helgrind ./mythread_app
    ```
- 技巧：
  - 设置线程创建断点：`catch syscall clone`

---

### 4.6 IPC调试、死锁
- **死锁四大条件**：
  1. 互斥
  2. 占有并等待
  3. 不可剥夺
  4. 循环等待
- **预防方法**：
  - 统一加锁顺序
  - 使用超时锁
  - 死锁检测工具（如 lockdep for kernel）
- **用户态调试**：
  - `pstack PID` 查看各线程调用栈
  - `gdb thread apply all bt` 分析阻塞点

---

## 第5章：Linux性能优化

### 5.1 perf
- Linux 性能分析神器（基于 perf_events 子系统）
- 常用命令：
  ```bash
  perf stat ./app               # 统计性能事件
  perf record -g ./app          # 记录调用栈
  perf report                   # 展示热点函数
  perf top -p PID               # 实时查看热点
  ```
- 支持硬件事件（cache miss, branch mispredict）和软件事件

---

### 5.2 kernel-shark
- 图形化分析 `ftrace` 数据（trace.dat）
- 显示任务调度、中断、函数跟踪的时间轴
- 适合分析实时性、延迟、抢占延迟等问题

---

### 5.3 top-down分析方法
- 自顶向下性能分析法（Intel 提出）：
  1. Front-end bound?
  2. Back-end bound?
  3. Bad speculation?
  4. Retiring (good)?
- 工具支持：
  - `ocperf.py`（Linux 版）
  - 结合 `perf` 使用

---

### 5.4 Linux的常见benchmark
| 类型 | 工具 |
|------|------|
| CPU | `sysbench cpu`, `openssl speed` |
| Memory | `mbw`, `stream` |
| Disk I/O | `fio`, `dd`, `bonnie++` |
| Network | `iperf3`, `netperf` |
| 综合 | `lmbench`, `phoronix-test-suite` |

---

### 5.5 基于eBPF的性能剖析
- **eBPF（extended Berkeley Packet Filter）**：
  - 在内核中安全运行沙箱程序
  - 无需修改内核即可动态插桩
- 工具生态（BCC/BPFTrace）：
  - `execsnoop`：追踪新进程创建
  - `opensnoop`：追踪文件打开
  - `biolatency`：块设备 I/O 延迟分布
  - `tcpconnect`：TCP 连接跟踪
- 示例（BPFTrace）：
  ```bash
  bt' tracepoint:syscalls:sys_enter_write { printf("%s %d\n", comm, arg0); }'
  ```

---

### 5.6 各种火焰图
- **Flame Graph**：可视化性能热点（由 Brendan Gregg 发明）
- 生成流程：
  1. `perf record -g`
  2. `perf script > out.perf`
  3. `stackcollapse-perf.pl out.perf | flamegraph.pl > graph.svg`
- 类型：
  - On-CPU Time
  - Off-CPU Time（睡眠时间分析）
  - Memory Allocation
  - Disk I/O Latency

> 🔗 推荐网站：https://github.com/brendangregg/FlameGraph

---

## 总结

该大纲覆盖了从 **用户态到内核态、从调试到性能优化** 的完整知识体系，适合：

- 系统程序员
- 内核开发者
- DevOps/SRE 工程师
- 嵌入式 Linux 工程师
- 高性能服务端开发人员

### 学习路径建议：

1. **先掌握第1章工具链** → 熟练使用 GDB、perf、strace
2. **结合实战练习第2章内存/I/O问题排查**
3. **逐步深入第3章内核调试**（需搭建 QEMU 测试环境）
4. **最后掌握 eBPF 和火焰图** 实现生产级性能分析能力
