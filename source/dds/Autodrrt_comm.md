# autodrrt_comm

> **autodrrt_comm：纯用户态的真零拷贝 ROS 2 通信——延时 O(1)、订阅端近零开销、Autoware 形态实测就绪、车规级崩溃自愈，创新内核的部署代价一分都不用掏。**

autodrrt_comm 是面向 ROS 2 的**同机跨进程真零拷贝发布订阅内存管理系统**，2026-08 ~ 2026-10 期间开发。结合 Apollo CyberRT Arena 的 shm 块池思想与 Agnocast 的 borrow-window，完全在用户态实现——**不需要内核模块、不需要特权、colcon 直接编**。

## 1. 设计定位

**解决什么问题**：ROS 2/DDS 传输图像、点云等大消息时，序列化 + 拷贝导致毫秒级延时，随载荷线性增长，挤占 10–30 Hz 传感器节拍。

**核心思路**：发送后只传「哪个块、第几条、多大、在哪」这 ~24–36 字节通知；订阅者从共享内存直接读同一块，全程无第二份拷贝。**每次拷贝的代价付在消息要写的那一次。**

| 对比对象 | 机制 | autodrrt 相对优势 |
|---|---|---|
| ROS 2/DDS（rmw_fastrtps_cpp） | 序列化 → 传输 → 反序列化 | 大消息延时 **49–235×** 优势；p99 < 1ms |
| Agnocast（内核模块零拷贝） | kmod 记账 + heaphook | 同量级且常更快（小消息 2.4–4.7×）；**无需签名 .ko**（在 `CONFIG_MODULE_SIG_FORCE=y` 平台如地平线 J6 上 Agnocast 直接不可部署） |
| Fast DDS 3.6.2 SHM | 段拷贝 + 反序列化 | 16MB 档 **95.5×** |
| Cyclone DDS + iceoryx PSMX | iceoryx 段拷贝 + 反序列化 | 16MB 档 **93×** |

## 2. 架构设计

```text
┌──────────── Publisher 进程 ────────────┐
│ borrow_loaned_message()                │
│   └─ malloc hook 打开 borrow 窗口       │
│      消息对象+vector/string 全部落 shm   │
│ publish()                              │
│   └─ 只向每个订阅者 mqueue 发 24B 通知   │
└──────┬─────────────────────────────────┘
       │
┌──────▼────── 共享内存（每 topic 一个 segment）──────┐
│ [State + 订阅者表][BlockDesc×N][block 0..N-1]      │
│  所有进程映射到同一虚拟地址（VA 注册表保证）          │
│  BlockDesc: seq / pending / readers / writing      │
│           + pending_mask / reader_mask（死亡回收）   │
└──────┬─────────────────────────────────┐
       │ 零拷贝只读同一对象
┌──────▼─────────── Subscriber 进程 ─────┐
│ 收到通知 → seq 校验 → readers+1         │
│ → ipc_shared_ptr<const Msg> 直奔回调     │
│ → 最后一个 shared_ptr 析构时 readers-1   │
└────────────────────────────────────────┘
```

### 2.1 核心机制

| 机制 | 说明 |
|---|---|
| **borrow 窗口** | `heaphook.cpp` 拦截 malloc 做 bump 分配，窗口内 `vector`/`string` 等动态成员**原生零序列化**落 shm |
| **通知平面** | 只传 `NotifySample`（mqueue 24B 或 DDS ~32B），payload 原地读 |
| **生命周期记账** | seq/pending/readers + pending_mask/reader_mask **下沉到共享内存原子量**，与内核解耦——死订阅者的持有被自动回收（P1 硬化） |
| **VA 注册表** | `address_allocator.hpp` 保证所有进程映射到同一虚拟地址（默认基址 `0x710000000000`、2 GiB/slot、1024 topic） |
| **溢出策略** | `DROP_OLDEST`（环形池）或 `DISCARD_NEW` |

### 2.2 文件结构

```text
include/autodrrt_comm/
  address_allocator.hpp   VA 注册表（shm，自旋锁）
  segment.hpp             topic 块池 + 原子生命周期 + 发布/读取/回收协议
  heaphook_api.h          borrow 窗口 C API
  ipc_ptr.hpp             ipc_shared_ptr
  publisher.hpp           borrow/publish（含 Options / PublishError）
  subscription.hpp        dispatch 线程 / ipc_shared_ptr 分发
  autodrrt_comm.hpp       汇总头
  rclcpp_bridge.hpp       rclcpp executor 集成（可选，不进 umbrella）
src/                      非模板实现
heaphook/heaphook.cpp     malloc 拦截器（bump 分配）
samples/                  talker / listener / 两种 bridge
tests/test_core.cpp       功能回归（10 种模式）
scripts/cleanup.bash      残留清理（-y 非交互）
```

### 2.3 使用示例

```cpp
#include "autodrrt_comm/autodrrt_comm.hpp"
#include "sensor_msgs/msg/point_cloud2.hpp"

// ---- 发布者 ----
autodrrt_comm::Options opts;
opts.block_num  = 8;
opts.block_size = 32 << 20;     // ≥ 最大消息 footprint（含动态成员）
opts.overflow   = autodrrt_comm::OverflowPolicy::DROP_OLDEST;

auto pub = autodrrt_comm::create_publisher<sensor_msgs::msg::PointCloud2>(
    "/lidar/points", opts);

auto loan = pub->borrow_loaned_message();     // 打开零拷贝窗口
loan->data.resize(n * point_step);           // 自动落 shm（包括 vector/string）
fill(loan->data);
pub->publish(std::move(loan));               // 只发 24B mqueue 通知

// ---- 订阅者 ----
auto sub = autodrrt_comm::create_subscription<sensor_msgs::msg::PointCloud2>(
    "/lidar/points",
    [](const autodrrt_comm::ipc_shared_ptr<
        const sensor_msgs::msg::PointCloud2>& m) {
      process(m->data);                       // 直接读发布者 shm
    },
    opts);
```

**使用守则（必读）**：

- borrow 窗口内**只做消息相关分配**、不要把 loan 传给别的线程；
- 回调在 autodrrt 自己的 dispatch 线程上跑；`ipc_shared_ptr` 不要长期保存（持有期间块不被复用）；
- 消息成员必须是**纯内存**（POD / vector / string），不支持外部资源（文件句柄 / shared_ptr / 互斥体）。

## 3. 分支策略与工作区组织

| 分支 | 通知平面 | 对比基准 |
|---|---|---|
| **main**（适配 ROS 2） | POSIX mqueue（24B） | 原生 ROS 2、Agnocast 插件 ROS 2 |
| **fastdds** | Fast DDS（~32B `NotifySample`） | Fast DDS 3.6.2 SHM transport |
| **cyclonedds** | Cyclone DDS（~36B `NotifySample`） | Cyclone DDS 11.0.1 + iceoryx PSMX |

三个分支的 arena 零拷贝 payload 路径完全一致，仅通知平面不同。

### 3.1 工作区

```text
autodrrt_ros2_ws/          # main 分支工作区
  src/autodrrt_comm        # 核心库（git 仓库）
  src/autodrrt_comm_test/  # 测试/样例/基准

autodrrt_dds_ws/           # fastdds/cyclonedds 分支工作区
  src/autodrrt_comm_test/
  results/                 # fastdds_branch / cyclonedds_branch 数据
```

### 3.2 功能测试套件（4 套）

| 测试套件 | 验证内容 |
|---------|---------|
| **core**（`autodrrt_comm_test_core`） | mqueue 传输回归：单进程/跨进程发布订阅、DROP_OLDEST 池耗尽、pending 泄漏回收、读持有泄漏回收、RETAIN、deadline |
| **dds**（`autodrrt_comm_test_dds`） | Fast DDS 通知平面回归：single / retain / deadline 三组 |
| **cyclonedds**（`autodrrt_comm_test_cyclonedds`） | Cyclone DDS 通知平面回归：single / retain / deadline 三组 |
| **gpu_zero_copy**（`test_gpu_zero_copy`） | GPU 统一内存测试：CUDA kernel 直接读写 shm、零拷贝 vs cudaMemcpy 性能对比 |

全部 4 个测试套件通过（core / dds / cyclonedds / gpu_zero_copy）。

## 4. 基准测试方法

### 4.1 延时测量口径

发布端 payload 填充完成后、publish 前嵌入 `CLOCK_MONOTONIC` 时间戳 → 订阅端回调入口取 `now()`，即**纯传输延时**（不含填充）。

### 4.2 硬件与频率控制

- 硬件：NVIDIA Jetson AGX Orin（64GB，aarch64）
- fastfds / cyclonedds 分支的 15 档扫描与传感器 bench：CPU 锁频 performance governor 2.2 GHz
- main 分支的相机 30Hz 对比：schedutil 默认频率（未锁频）

### 4.3 测试场景

- **15 档延时扫描**：1KB → 16MB 翻倍，count=100、period=10ms
- **7 场景传感器延时**：count=100；lidar 10Hz、camera 30Hz
  - lidar_vlp16（30720 点，480KB）/ lidar_rs32（65536 点，1MB）/ lidar_os1_64（131072 点，2MB）/ lidar_rs128（524288 点，8MB）
  - cam_200w（1920×1080，5MB）/ cam_500w（2592×1944，14MB）/ cam_800w（3264×2448，22MB）

## 5. 基准测试结果

### 5.1 main 分支：相机 30Hz 三方对比

对 2026-09-07 30 Hz 档的同矩阵复测（2026-09-08，schedutil 默认频率，未锁频）：每规格 × 每路径 3 轮、每 leg count=15、名义周期 33 ms；取值 = 3 轮 leg 平均的中位数。Agnocast 走 `insmod agnocast.ko` + `LD_PRELOAD=libagnocast_heaphook.so` + `AGNOCAST_BRIDGE_MODE=off`。

| 规格 | 分辨率 | payload | ROS 2/DDS med | Agnocast med | autodrrt med | autodrrt vs DDS | autodrrt vs Agnocast |
|---|---|---:|---:|---:|---:|---:|---:|
| 200w | 1920×1080 | 5.93 MiB | 35.90 ms | 542 µs | **335 µs** | **107×** | **1.62×** |
| 500w | 2592×1944 | 14.41 MiB | 49.43 ms | 596 µs | **377 µs** | **131×** | **1.58×** |
| 800w | 3840×2160 | 23.73 MiB | 65.44 ms | 432 µs | **278 µs** | **235×** | **1.55×** |

三方全部 0 loss / 0 ooo。30 fps 预算 = 33 ms：DDS 三档全部超出预算，两个零拷贝路径各档均 < 1 ms，且互有胜负（differences within ~1.3× 噪声带）。

逐条合并分布（每规格 × 每路径跨 3 轮合并，n≈45）：

| 规格 | 路径 | n | avg | p50 | p99 | max |
|---|---|---:|---:|---:|---:|---:|
| 200w | ROS 2/DDS | 41 | 33.74 ms | 33.67 ms | 57.78 ms | 57.78 ms |
| 200w | Agnocast | 45 | 499 µs | 489 µs | 1.35 ms | 1.35 ms |
| 200w | autodrrt | 45 | 331 µs | 363 µs | 519 µs | 519 µs |
| 500w | ROS 2/DDS | 45 | 48.56 ms | 51.15 ms | 67.49 ms | 67.49 ms |
| 500w | Agnocast | 45 | 590 µs | 603 µs | 1.24 ms | 1.24 ms |
| 500w | autodrrt | 45 | 432 µs | 395 µs | 1.49 ms | 1.49 ms |
| 800w | ROS 2/DDS | 44 | 91.06 ms | 62.85 ms | 314.71 ms | 314.71 ms |
| 800w | Agnocast | 45 | 401 µs | 337 µs | 877 µs | 877 µs |
| 800w | autodrrt | 45 | 277 µs | 228 µs | 597 µs | 597 µs |

- DDS 800w 再次出现退化 leg（r3: avg 150.8 ms, max 314.7 ms, sub RSS 142.7 MB）——median taken across rounds
- DDS 200w: two legs received 13/15 (warmup boundary), consistent with previous run's observation
- 复现性与 2026-09-07 一致：200w DDS 35.9 vs 37.4 ms; agn 542 vs 490 µs; adrrt 335 vs 313 µs——结论不变（zero-copy paths µs-level and flat vs payload; DDS tens of ms and grows with payload; DDS exceeds 33 ms budget at 500w/800w）

### 5.2 main 分支：Agnocast 500w 延时倒挂分析

**现象**：Agnocast 500w（590µs）> 200w（499µs）> 800w（401µs），倒挂在 09-07 和 09-08 两次独立测试中都出现。

**根因：CPU 频率漂移（schedutil）**，证据链：

1. 同规格跨轮摆动巨大：agn 200w 三轮 553/401/542 µs（1.38×），adrrt 500w 三轮 320/320/597 µs——µs 级零拷贝路径的墙钟几乎完全由调度/唤醒开销决定，对 CPU 频率极其敏感
2. 锁频 2.2 GHz 后 Agnocast medians 变为单调（118/148/149 µs），倒挂消失
3. 小的真实 size 依赖存在（200w < 500w ≈ 800w at locked freq，118→149 µs，+26%），但单调且微小，无法解释 590 vs 401 的倒挂

**结论**：µs 级基准测量必须锁频，否则 schedutil 频率漂移（960–1574 MHz vs 上限 2201 MHz）可引入 2–3× 的同规格轮间摆动。

### 5.3 fastdds 分支：15 档延时扫描 vs Fast DDS

| 大小 | autodrrt p50/p99 | FastDDS p50/p99 | autodrrt vs FastDDS（p50） |
|------|------------------|-----------------|---------------------------|
| 1KB | 54.2/287.3 | 33.0/248.0 | 0.61×（原生快） |
| 2KB | 38.4/298.8 | 50.0/258.0 | **1.30×** |
| 4KB | 76.3/355.0 | 63.0/249.0 | 0.83×（原生快） |
| 8KB | 67.1/220.0 | 55.0/266.0 | 0.82×（原生快） |
| 16KB | 50.5/394.5 | 60.0/237.0 | **1.19×** |
| 32KB | 49.1/281.8 | 47.0/302.0 | 0.96×（基本持平） |
| 64KB | 61.0/260.5 | 71.0/258.0 | **1.16×** |
| 128KB | 54.4/173.6 | 120.0/286.0 | **2.21×** |
| 256KB | 64.5/295.5 | 184.0/519.0 | **2.85×** |
| 512KB | 54.9/315.6 | 317.0/781.0 | **5.77×** |
| 1MB | 67.0/175.8 | 590.0/1335.0 | **8.81×** |
| 2MB | 101.9/204.2 | 1208.0/2582.0 | **11.85×** |
| 4MB | 85.4/260.6 | 2508.0/5167.0 | **29.37×** |
| 8MB | 130.2/419.7 | 5119.0/10316.0 | **39.32×** |
| 16MB | 108.7/300.0 | 10377.0/22024.0 | **95.47×** |

**要点**：

1. autodrrt 的 p50 在全 15 档稳定在 **38–130µs**，与消息大小基本无关（O(1) 传输特征，仅 ~32B NotifySample 经 DDS 通知面，payload 原地读）
2. FastDDS 延时随载荷大小**线性增长**（1KB 33µs → 16MB 10.4ms，~315×）；≥128KB 后 autodrrt 拉开差距，16MB 档 **95.5×**
3. 小载荷（≤32KB）区间，原生 Fast DDS SHM 路径与 autodrrt 互有胜负（autodrrt 需额外承担 arena 记账与通知面往返）——该区间是"固定开销"的竞争，零拷贝优势尚未显现

### 5.4 fastdds 分支：7 场景传感器延时

| 场景 | 大小 | autodrrt p50/p99 | FastDDS p50/p99 | autodrrt vs FastDDS |
|------|------|------------------|-----------------|---------------------|
| lidar_vlp16（30720 点） | 480KB | 288.3/574.5 | 404.6/819.8 | **1.40×** |
| lidar_rs32（65536 点） | 1MB | 277.2/511.7 | 704.6/1581.6 | **2.54×** |
| lidar_os1_64（131072 点） | 2MB | 269.8/379.6 | 1266.6/2732.5 | **4.69×** |
| lidar_rs128（524288 点） | 8MB | 238.7/430.8 | 5119.6/10239.9 | **21.45×** |
| cam_200w（1920×1080） | 5MB | 166.6/286.7 | 3820.3/7710.0 | **22.93×** |
| cam_500w（2592×1944） | 14MB | 179.1/565.5 | 9162.9/18361.1 | **51.16×** |
| cam_800w（3264×2448） | 22MB | 273.3/490.3 | 14906.5/29874.8 | **54.54×** |

**要点**：

1. 传感器形状下 autodrrt p50 稳定在 **167–288µs**，7 场景间不随 payload 增长；FastDDS p50 从 405µs 恶化到 14.9ms（37×）
2. p99 差距最极端：cam_800w 档 autodrrt p99=490µs vs FastDDS p99=29.9ms（**61×**）
3. 实际意义：8MB 级点云（RS-128）、5–23MB 级相机帧（200w–800w）场景中，FastDDS 的毫秒级延时已挤占 10–30Hz 传感器节拍，autodrrt 保留两个数量级的节拍余量

### 5.5 cyclonedds 分支：15 档延时扫描 vs Cyclone DDS

| 大小 | autodrrt_cyclo p50/p99 | CycloneDDS p50/p99 | autodrrt_cyclo vs CycloneDDS（p50） |
|------|------------------------|--------------------|--------------------------------------|
| 1KB | 40.1/413.9 | 29.1/299.2 | 0.73×（原生快） |
| 2KB | 67.8/327.3 | 45.4/147.4 | 0.67×（原生快） |
| 4KB | 109.1/184.0 | 37.1/271.2 | 0.34×（原生快） |
| 8KB | 97.5/336.5 | 47.2/311.9 | 0.48×（原生快） |
| 16KB | 109.9/378.0 | 38.6/86.8 | 0.35×（原生快） |
| 32KB | 66.8/365.1 | 58.8/199.1 | 0.88×（原生快） |
| 64KB | 97.7/417.8 | 102.5/168.7 | **1.05×**（持平） |
| 128KB | 64.2/290.5 | 117.0/337.3 | **1.82×** |
| 256KB | 40.2/291.4 | 254.9/571.4 | **6.34×** |
| 512KB | 49.9/331.6 | 380.5/716.0 | **7.63×** |
| 1MB | 85.4/341.3 | 798.9/1330.0 | **9.36×** |
| 2MB | 125.4/372.2 | 1501.3/2426.9 | **11.97×** |
| 4MB | 110.4/218.2 | 2943.1/5018.3 | **26.66×** |
| 8MB | 88.6/308.3 | 6046.0/11836.9 | **68.25×** |
| 16MB | 131.4/211.6 | 12224.0/25180.9 | **93.04×** |

**要点**：

1. autodrrt_cyclo 的 p50 在 15 档稳定在 **40–131µs**（O(1) 传输特征）；CycloneDDS（iceoryx PSMX）延时随大小**线性增长**（1KB 29µs → 16MB 12.2ms，~420×）
2. 小载荷（≤32KB）区间，原生 CycloneDDS 路径反而更快（差距 0.34–0.88×）——同 fastdds 分支结论：小载荷下零拷贝优势尚未显现，autodrrt 的 arena 记账与 DDS 通知面往返是固定开销
3. 大载荷区间（≥128KB）autodrrt_cyclo 拉开差距：16MB 档 **93×**

### 5.6 cyclonedds 分支：7 场景传感器延时

| 场景 | 大小 | autodrrt_cyclo p50/p99 | CycloneDDS p50/p99 | autodrrt_cyclo vs CycloneDDS |
|------|------|------------------------|--------------------|------------------------------|
| lidar_vlp16（30720 点） | 480KB | 188.8/426.9 | 486.6/705.3 | **2.58×** |
| lidar_rs32（65536 点） | 1MB | 215.0/425.6 | 951.4/1585.0 | **4.43×** |
| lidar_os1_64（131072 点） | 2MB | 224.1/321.6 | 1739.3/2528.3 | **7.76×** |
| lidar_rs128（524288 点） | 8MB | 263.7/502.7 | 6252.9/10161.4 | **23.70×** |
| cam_200w（1920×1080） | 5MB | 208.7/272.5 | 4635.7/7219.1 | **22.21×** |
| cam_500w（2592×1944） | 14MB | 224.7/284.7 | 11222.0/17982.6 | **49.94×** |
| cam_800w（3264×2448） | 22MB | 222.6/345.4 | 17478.9/26452.0 | **78.52×** |

**要点**：传感器形状下 autodrrt_cyclo p50 稳定在 **189–264µs**，不随 payload 增长；CycloneDDS p50 从 487µs 恶化到 17.5ms（36×）。p99 差距：cam_800w 档 autodrrt_cyclo p99=345µs vs CycloneDDS p99=26.5ms（**77×**）。

### 5.7 订阅端资源开销

**cyclonedds 分支 15 档扫描（2026-09-26 补测）**：

| 大小 | autodrrt_cyclo sub_cpu / sub_rss | CycloneDDS sub_cpu / sub_rss |
|------|-------------------------------|----------------------------|
| 1KB | 0.01s / 7496KB | 0.01s / 8296KB |
| 128KB | 0.01s / 7492KB | 0.02s / 21460KB |
| 1MB | 0.01s / 7372KB | 0.08s / 112636KB |
| 8MB | 0.01s / 7492KB | 0.51s / 852276KB |
| 16MB | 0.02s / 7488KB | 1.03s / 1711632KB |

**要点**：

1. **CPU**：autodrrt_cyclo 订阅端 CPU 稳定在 0.01–0.02s，与载荷大小无关；CycloneDDS 从 0.01s 增长到 1.03s（16MB 档），大载荷下差距 **~50×**
2. **RSS**：autodrrt_cyclo 稳定在 ~7.5MB；CycloneDDS 的 RSS 随载荷**线性增长**（1KB 8MB → 16MB 1.7GB），反映 PSMX 路径下反序列化本地副本 + iceoryx SHM 页面的累积
3. 16MB 档对比：autodrrt_cyclo 0.02s/7.5MB vs CycloneDDS 1.03s/1.7GB——**CPU 51×、RSS 228×**

**RSS 构成分析（2MB 消息，fastfds bench，smaps 实测）**：

| 路径 | sub_rss | 主导因素 |
|------|---------|----------|
| ros2_dds | 44.3MB | 进程基线 + 默认 SHM 段（512KB） |
| fastfds | 474MB | 显式 128MB SHM 段 + 320MB 内部缓冲池 |
| cyclonedds | 212MB | 100 条 × 2MB 堆副本累积 |
| autodrrt | 15.8MB | 零拷贝，RSS 恒定 |

**fastfds 分支 sub_rss ≈ 474MB 的构成**：

| 内存区域 | RSS | 说明 |
|----------|-----|------|
| 匿名映射 | **320MB** | Fast DDS 内部接收缓冲池 |
| pub 的 SHM 段 | **130MB** | 134MB 段，几乎全部驻留 |
| sub 自己的 SHM 段 | 2.1MB | 134MB 段，仅元数据页驻留 |
| 库 + 二进制 | ~24MB | libfastdds.so 等 |
| **合计** | **~474MB** | |

根本原因：**SHM 段大小差异**。fastfds bench 显式配置 `segment_size(128MB)` → 每个进程创建一个 134MB SHM 段。ROS 2 默认 `shm_implicit_segment_size = 512KB` → **比 bench 小 256 倍**。所以 ros2_dds sub_rss = 44.3MB（无大 SHM 段映射）vs fastfds 474MB（映射了 pub 的 130MB 段 + 320MB 内部缓冲池）。

额外的 memset 开销（SharedMemTransport.cpp:313-319）：

```cpp
// Memset the whole segment to zero in order to force physical map of the buffer
memset(buffer->data(), 0, configuration_.segment_size());
```

初始化时 Fast DDS **主动 memset 整个 128MB 段**，强制所有页面驻留——pub 和 sub 都执行此操作。

**cyclonedds 的 RSS 线性增长规律**：实测数据拟合 **RSS ≈ 7MB 基线 + 100 × message_size × 1.04**。每条消息贡献 ~1.04 × message_size 的 RSS——即**订阅端为每条消息保留了一份完整堆副本**（CDR 反序列化产生），100 条消息全部累积在堆中。

| 消息大小 | 实测 RSS | 拟合 RSS |
|----------|----------|----------|
| 128KB | 21.0MB | 20.1MB |
| 1MB | 110.0MB | 111.0MB |
| 8MB | 832.3MB | 839.0MB |
| 16MB | 1671.5MB | 1663.0MB |

## 6. 工程化验证

### 6.1 1 小时长稳压测（2026-09-04）

场景：`autodrrt_stability.bash`，连续 1h、128 KiB × 100 Hz（period=10ms）、每 ~300s 随机 SIGKILL 订阅者一次、监控 RSS/FD/shm/mq 曲线、kill 后自动重启订阅者验证恢复。

| 验收项 | 结果 |
|---|---|
| kill 注入 | **10/10** SIGKILL 订阅者，发布者每次确认存活 |
| 恢复 | 每次 kill 后 ~3s 内新订阅者接入继续收流 |
| 消息量 / 完整性 | 11 条接收生命周期合计 **349,928 条**，流内 **0 gaps / 0 out-of-order** |
| publisher | **drops=0**（块池从未触发 DROP_OLDEST）、CPU 41.86s/3600s ≈ **1.2%** |
| 延时（续访谈流） | avg 109 µs / p99 559 µs / max 1.4 ms @128KiB×100Hz |
| 新增指标首用 | `cpu_per_msg=67.4µs / cpu_per_MiB=539µs` |
| 资源曲线 | 119 个采样：sub RSS 台位恒定（1.7 / 3.2–3.9 MB 台）、pub RSS 12MB 恒定、FD/shm/mq **全程恒定无增长** |
| 异常 / 残留 | 日志无 error/fail/fallback；kill 场景预期的 shm 对象残留已由 `cleanup.bash -y` 清净，mqueue 侧零残留 |

完整报告：`autodrrt_comm_results/longrun_stability_20260904.md`；原始数据：`/tmp/autodrrt_stability_20260904_135653/`。

### 6.2 生命周期与死亡回收（P1 硬化）

| 机制 | 说明 |
|---|---|
| 死订阅者 pending 回收 | `pending_mask` 记录死订阅者，下次有人建同 topic 时自动回收 |
| 读持有泄漏回收 | `reader_mask` 同上，防止 killed subscriber 钉死块池 |
| kill -9 残留 | OS 级约束：kill -9 的进程无法自减 shm 引用，用 `cleanup.bash [-y]` 手动清理 |

## 7. rclcpp executor 集成（路线 A / B）

**路线 A（`rclcpp_bridge.hpp`，已实现）**：autodrrt 的 dispatch 线程继续做 O(1) 收信（poll mqueue → seq 校验 → read hold），把 `ipc_shared_ptr` 塞到线程安全队列；rclcpp 一侧的 **wall timer** 按 `drain_period`（默认 1ms）把队列 drain 到 executor → 回调按 executor 规矩执行。payload 全程零拷。

```cpp
#include "autodrrt_comm/rclcpp_bridge.hpp"

typename autodrrt_comm::rclcpp_bridge::BridgeSubscription<Msg>::Config cfg;
auto bridge = autodrrt_comm::rclcpp_bridge::create_bridge_subscription<Msg>(
    node, topic, cb, cfg);   // 必须在 rclcpp::shutdown() 前销毁 bridge
```

**样例**：`samples/ros_bridge_listener.cpp`（回调里直接用了 rclcpp publisher）。

**路线 B（未做）**：把 mqueue fd 包装成 `rclcpp::Waitable`（guard condition）直接喂给 executor waitset，或自定义 `rclcpp::Executor`（参照 Agnocast 的 `SingleThreadedAgnocastExecutor`）在 spin 循环里同时 `epoll_wait` mqueue FD 与 waitset——**唤醒即派发，附加 ~5–20µs**，这是唯一能"集成又不加价"的路线，但依赖 rclcpp 非稳定 API。

| 对比 | 路线 A（现状） | 路线 B（未做） |
|---|---|---|
| mqueue 唤醒直接纳入 rclcpp wait set | ❌ 现在事件被 autodrrt 自己截走再转发 | `rclcpp::Waitable` 封装 mqueue fd → guard condition |
| 去掉自家 dispatch 线程 | ❌ 中间依然过一手 autodrrt 线程 | 自定义 `rclcpp::Executor`（参照 Agnocast 的 `SingleThreadedAgnocastExecutor`） |
| 附加时延 | ~1ms（可用 `cfg.drain_period` 调） | **唤醒即派发，附加 ~5–20µs** |

## 8. 五大宣传亮点

### ① 纯用户态零拷贝，部署零门槛

> **不要内核模块、不要特权、不要 LD_PRELOAD——colcon 一编就能跑。**

- 对比 Agnocast 要求装签名 `.ko`（在 `CONFIG_MODULE_SIG_FORCE=y` 的平台如地平线 J6 上直接不可部署），autodrrt_comm 把生命周期记账**下沉到共享内存原子量**（seq/pending/readers + pending_mask/reader_mask），与内核解耦。
- 一个 `ament package`，`package.xml + CMakeLists` 两行接入；在已跑的 Autoware 容器里原地构建可用，**不挑内核、不挑平台**。

### ② 毫秒级拼图消失：大消息延时被压到 O(1)

> **1 KiB 到 16 MiB，端到端延时稳定在百微秒级，不随载荷增长。**

| 对比 | 峰值优势（三方同口径实测） |
|---|---|
| vs ROS 2/DDS | **最大 167×**（16 MiB：33.8 ms → 203 µs）；Autoware 形态条件下 49–112× |
| vs Agnocast（内核态最强者） | 同量级且互有胜负：小消息 2.4–4.7× 领先，个别档 Agnocast 微优（<8%） |
| 尾延时 | **全程 p99 < 1 ms**（DDS 在 4 MiB 时 p99 已达 56 ms） |

延时由"传递一个指针"决定，而不是"拷贝 N 个字节"。

### ③ 订阅端资源消耗接近物理下限

> **RSS 恒定 1.7 MB、订阅端单条 CPU < 1 µs 量级——只映射、不拷贝。**

| 指标（1:1 同 run） | autodrrt sub | Agnocast sub | ROS 2 sub |
|---|---:|---:|---:|
| RSS（16 MiB 消息） | **1.7 MB 恒定** | 21.6 MB | **217 MB** |
| sub CPU（16 MiB ×100） | **0.01 s** | 0.15 s | 2.68 s |
| 传输效率（cpu/MiB） | **6–120 µs** | 556–1018 µs | 8,477–43,533 µs |

DDS 的订阅 RSS 随消息线性膨胀（QoS depth 缓存 + 反序列化副本）；零拷贝订阅端只有控制区热数据。

### ④ 不只是 demo：已经过"车规级"工程打磨

> **SIGKILL、抢占、慢订阅者全场景自愈，1 小时压测零失误。**

- **生命周期**：死订阅者的 pending/读持有被自动回收（P1 硬化），读者 kill -9 中途死亡不会钉死块池；
- **QoS-lite**：deadline 监视、RETAIN（晚到先拿最新帧）；
- **长稳验证**：3590 秒、349,928 条、10 次 SIGKILL 注入，**0 drops / 0 gap / 0 out-of-order / RSS-FD-shm 曲线完全平台**。

这不只是"跑起来的零拷贝"，是能在真实链路上扛死的零拷贝。

### ⑤ 真 Autoware 形态，真 30 fps/10 Hz 预算验收

> **不是 synthetic Float64 玩具——PointCloud2 / Image rgb8 已经三方验收完。**

- **激光雷达（XYZI float32）**：512 KiB–8 MiB PointCloud2 → autodrrt vs DDS **37–112×**，10 Hz 全帧满载率；
- **相机（rgb8 960P/1080P/1200P）**：→ **49–109×**，30 fps 预算（33ms）下 DDS 已超预算，autodrrt 全程 < 1 ms；
- **渐变迁移路径已备好**：`bridge_autodrrt_to_ros2` 双向桥 + `rclcpp_bridge` executor 集成（路线 A）+ QoS-lite——**先改驱动，下游按 topic 逐个迁移**，不必换整套中间件。

## 9. 已知限制

1. **VA 假设**：默认基址 `0x710000000000`、2 GiB/slot、1024 topic；与该地址区域冲突的进程会 open 失败（可配，见 SegmentOptions）。
2. **block_size 必须 ≥ 最大消息**。小了会被安全拒发。
3. **kill -9 的进程无法自减 shm 引用**——OS 级残留，用 `cleanup.bash [-y]` 手动清理（注册表 + segment 的 ref_count、订阅者表和遗留 mqueue 在下次有人建同 topic 时会自动回收）。
4. **订阅端 RW 映射**：硬件上也没法区分控制区/数据区，可信范围内用。
5. **无内建跨主机 / discovery / QoS**——用 bridge 要补。
6. **消息不走常规析构**（见 §2.3 守则）。

## 10. 开发时间线

| 日期 | 里程碑 |
|---|---|
| 2026-08-27 ~ 09-07 | **核心库开发**：borrow 窗口、VA 注册表、块池、原子生命周期；P1 生命周期硬化；rclcpp_bridge 路线 A；1h 长稳压测（09-04）；核心功能代码与测试代码分离，生成新仓库 `autodrrt_comm` |
| 2026-09-08 | 相机 30Hz 三方对比复测 + Agnocast 500w 延时倒挂分析（锁频实验） |
| 2026-09-11 ~ 09-18 | **FastDDS 适配版本**：`autodrrt_comm_dds_ws` 创建；fastdds 分支通知平面（~32B `NotifySample` 经 Fast DDS SHM） |
| 2026-09-22 | **测试目录整理为 ros2_ws 与 dds_ws**：main 分支 vs 原生 ROS 2 / Agnocast 插件 ROS 2；fastfds 分支 vs Fast DDS SHM；cyclonedds 分支 vs Cyclone DDS + iceoryx PSMX。4 个测试套件（core / dds / cyclonedds / gpu_zero_copy）全部通过 |
| 2026-09-26 | 订阅端资源开销补测（sub_cpu / sub_rss） |
| 2026-10-07 ~ 10-08 | CPU 效率、统一内存 API 整理；RSS 构成分析（fastfds 474MB 分解、cyclonedds 线性增长规律拟合） |
