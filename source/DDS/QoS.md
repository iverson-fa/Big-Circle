# QoS

- [Fast DDS关于QoS的解释](https://fast-dds.docs.eprosima.com/en/stable/fastdds/dds_layer/core/policy/policy.html)


## 1. 简介

### 1.1 优点

- 增加系统灵活度
- 便于独立的配置实体的QoS策略
- 可支持以不同速率接收数据
- 支持数据包的自定义顺序接收

### 1.2 DDS标准定义的QoS


| Qos                   | 解释                     |
| --------------------- | ------------------------ |
| User_Data             | 用户自定义数据           |
| Topic_Data            | 主题之外附加信息         |
| Group_Data            | 约束组订阅分发等         |
| **Durability**        | 数据是否需要存储         |
| Durability_Service    | 对存储数据的属性定义     |
| Presentation          | 定义一些变化             |
| Deadline              | 数据更新的最大时间       |
| Latency_Budget        | 性能消耗                 |
| Ownership             | 多个写者写同个数据       |
| Ownership_Strength    | 数据处理优先级           |
| **Liveness**          | 确定实体是否存在         |
| **Time_Based_Filter** | 数据获取的最小间隔       |
| Partition             | Domain的逻辑分区         |
| **Reliability**       | 服务的可靠性             |
| Transport_Priority    | 输出层优先级             |
| **Lifespan**          | 数据的超时时间           |
| Destination_Order     | 数据交付的顺序           |
| **History**           | 历史数据的数量           |
| Resource_limits       | 服务可使用的资源限制     |
| Entity_Factory        | 实体在创建时自动激活     |
| Writer_Data_Lifecycle | 写者数据实例生命周期管理 |
| Reader_Data_lifecycle | 读者数据实例生命周期管理 |

在 DDS（Data Distribution Service）中，“**确定性通信（Deterministic Communication）**”意味着在**规定时间内稳定、可预期地传输消息**，这是自动驾驶、工业控制、机器人等实时系统的核心要求。

要实现 DDS 的确定性通信，**QoS（Quality of Service）策略是关键配置手段**。以下是在设计 DDS 系统时需要特别关注的 **确定性通信相关 QoS 策略项**及推荐设置。

---

In-line QoS : 通信数据包中携带的QoS策略

| Qos    | 对RTPS的影响       | 是否存在内联的QoS |
| --------------------- | ------------------------ |------|
| User_Data | None|No   |
| Topic_Data  | None | No  |
| Group_Data|None |No|
| Durability|Yes |Yes|
| Durability_Service | None | No |
| Presentation |Yes |Yes|
| Deadline| None |Yes|
| Latency_Budget |None |Yes|
| Ownership|None |Yes|
| Ownership_Strength|None |Yes|
| Liveness| Yes |Yes|
| Ownership|None |Yes|
| Time_Based_Filter |Yes |No|
| Partion|None |Yes|


## 2. 确定性通信的 QoS 策略核心配置

| QoS 策略                 | 作用       | 推荐设置（确定性场景）                     |
| ---------------------- | -------- | ------------------------------- |
| **Reliability**        | 是否保证消息送达 | `RELIABLE`                     |
| **History**            | 消息缓冲策略   | `KEEP_LAST` （可控）               |
| **History Depth**      | 缓冲消息数量   | 小值（如 `1-10`）过大会带来不确定性         |
| **Deadline**           | 最大发送周期   | 设置如 `10ms`，结合检查                 |
| **Latency Budget**     | 通信预算时间   | 设置最大可接受通信延迟，如 `5ms`             |
| **Transport Priority** | 网络优先级    | 配合 RT OS 使用（如 VxWorks）          |
| **Durability**         | 是否保留历史数据 | 一般设为 `VOLATILE` （实时性优先）        |
| **Liveliness**         | 检测发布者存活  | `AUTOMATIC` 或 `MANUAL_BY_TOPIC` |
| **Time-Based Filter**  | 接收侧最小间隔  | 通常设为 `0`（即全部接收）                |
| **Ownership**          | 控制数据源    | `SHARED`（默认）或 `EXCLUSIVE` 视场景而定 |

---

## 3. 推荐的 QoS 组合（适合确定性场景）

### 自动驾驶 / 工业实时控制

```xml
<qos>
  <reliability>
    <kind>RELIABLE</kind>
  </reliability>
  <history>
    <kind>KEEP_LAST</kind>
    <depth>5</depth>
  </history>
  <deadline>
    <period>10ms</period>
  </deadline>
  <latency_budget>
    <duration>5ms</duration>
  </latency_budget>
  <liveliness>
    <kind>AUTOMATIC</kind>
    <lease_duration>20ms</lease_duration>
  </liveliness>
  <durability>
    <kind>VOLATILE</kind>
  </durability>
</qos>
```

---

### 补充说明：各 QoS 策略的确定性影响

🔹 1. `RELIABLE` vs `BEST_EFFORT`

* `RELIABLE`：确保每条消息最终被接收（带 ACK 与重传）

  * 延迟略高，但具备可靠性保障
* `BEST_EFFORT`：可能丢消息，延迟低但不确定

🔹 2. `KEEP_LAST` vs `KEEP_ALL`

* `KEEP_LAST`：只保留最新 `depth` 条消息，内存与处理可控
* `KEEP_ALL`：保留所有历史，可能引起内存/延迟抖动

🔹 3. `DEADLINE` 与 `LATENCY_BUDGET`

* `DEADLINE`：设置最大发送周期，订阅端可检测是否超时
* `LATENCY_BUDGET`：传输延迟的期望预算，通知中间件优化路径

🔹 4. `TIME_BASED_FILTER`

* 控制接收频率，过滤过多数据
* 若要所有数据都处理，应设为 0

---

## 4. ROS 2 中设置 QoS 配置

### 4.1 编码示例

C++

```cpp
rclcpp::QoS qos_profile(rclcpp::KeepLast(5));
qos_profile.reliability(RMW_QOS_POLICY_RELIABILITY_RELIABLE);
qos_profile.durability(RMW_QOS_POLICY_DURABILITY_VOLATILE);
qos_profile.deadline(rclcpp::Duration::from_seconds(0.01));
qos_profile.latency_budget(rclcpp::Duration::from_seconds(0.005));
```

Python

```python
QoSProfile(
  reliability=ReliabilityPolicy.RELIABLE,
  durability=DurabilityPolicy.VOLATILE,
  history=HistoryPolicy.KEEP_LAST,
  depth=5,
  deadline=Duration(seconds=0.01),
  latency_budget=Duration(seconds=0.005)
)
```

### 4.2 配合测试工具验证设置生效

* 使用 `ddsperf` 或自定义 `pub/sub` 打时间戳，记录消息延迟
* 用 `Wireshark` 抓包确认 QoS flag 和通信行为
* 配合 `cyclictest` 验证线程调度抖动（系统实时性）
* 利用 `stress-ng` + `iperf3` 模拟负载，验证 QoS 在干扰下是否仍然满足设定

---

### 4.3 确定性通信 QoS 设置 Checklist

| 要素    | 建议设置                          |
| ----- | ----------------------------- |
| 可靠性   | `RELIABLE`                    |
| 缓冲策略  | `KEEP_LAST` + depth ≤ 10      |
| 延迟控制  | `LATENCY_BUDGET` + `DEADLINE` |
| 数据新鲜度 | `VOLATILE` durability         |
| 优先级控制 | `Transport Priority`（配合系统）    |
| 接收端控制 | `TIME_BASED_FILTER = 0`       |

## 5. 基于 CycloneDDS 实现确定性通信测试的方案

### 5.1 测试目标

通过 CycloneDDS 进行如下测试：

| 指标              | 描述                       |
| --------------- | ------------------------ |
| 延迟 (Latency)    | 单条消息从发送到接收的时间（单位：μs/ms）  |
| 抖动 (Jitter)     | 连续延迟值的波动范围               |
| 丢包率 (Loss Rate) | 丢失消息的百分比                 |
| 延迟上限            | 所有延迟是否都落在要求范围内（例如 <10ms） |

---

### 5.2 环境准备

#### 5.2.1 安装 CycloneDDS

基于ROS2安装：

```bash
sudo apt install ros-humble-rmw-cyclonedds-cpp
```

或手动编译：

```bash
git clone https://github.com/eclipse-cyclonedds/cyclonedds.git
cd cyclonedds && mkdir build && cd build
cmake .. && make -j$(nproc)
sudo make install
```

---

#### 5.2.2 设置 QoS 策略（确保确定性）

 CycloneDDS 的 XML 配置文件设置 QoS（或直接在代码中设置）：

`cyclonedds.xml` 示例（放在当前目录或 `/etc/cyclonedds/cyclonedds.xml`）：

```xml
<CycloneDDS>
  <Domain id="any">
    <Topic>
      <Reliability>Reliable</Reliability>
      <Durability>Volatile</Durability>
      <History>KeepLast</History>
      <Depth>5</Depth>
      <Deadline>0.01</Deadline> <!-- 10ms deadline -->
      <LatencyBudget>0.005</LatencyBudget> <!-- 5ms latency budget -->
    </Topic>
  </Domain>
</CycloneDDS>
```

---

#### 5.2.3 测试代码（发布 + 订阅 + 延迟记录）

发布者（`pub.c`）

```c
#include <dds/dds.h>
#include <stdio.h>
#include <time.h>

typedef struct {
  int64_t send_time_ns;
} Msg;

int64_t now_ns() {
  struct timespec ts;
  clock_gettime(CLOCK_REALTIME, &ts);
  return (int64_t)ts.tv_sec * 1e9 + ts.tv_nsec;
}

int main() {
  dds_entity_t participant = dds_create_participant(DDS_DOMAIN_DEFAULT, NULL, NULL);
  dds_entity_t topic = dds_create_topic(participant, &Msg_desc, "LatencyTest", NULL);
  dds_qos_t *qos = dds_create_qos();
  dds_qset_reliability(qos, DDS_RELIABILITY_RELIABLE, DDS_INFINITY);
  dds_qset_history(qos, DDS_HISTORY_KEEP_LAST, 5);
  dds_entity_t writer = dds_create_writer(participant, topic, qos, NULL);

  Msg msg;
  while (1) {
    msg.send_time_ns = now_ns();
    dds_write(writer, &msg);
    usleep(10000); // 10ms
  }

  dds_delete(participant);
  return 0;
}
```

订阅者（`sub.c`）

```c
#include <dds/dds.h>
#include <stdio.h>
#include <time.h>
#include <math.h>

typedef struct {
  int64_t send_time_ns;
} Msg;

int64_t now_ns() {
  struct timespec ts;
  clock_gettime(CLOCK_REALTIME, &ts);
  return (int64_t)ts.tv_sec * 1e9 + ts.tv_nsec;
}

int main() {
  dds_entity_t participant = dds_create_participant(DDS_DOMAIN_DEFAULT, NULL, NULL);
  dds_entity_t topic = dds_create_topic(participant, &Msg_desc, "LatencyTest", NULL);
  dds_qos_t *qos = dds_create_qos();
  dds_qset_reliability(qos, DDS_RELIABILITY_RELIABLE, DDS_INFINITY);
  dds_qset_history(qos, DDS_HISTORY_KEEP_LAST, 5);
  dds_entity_t reader = dds_create_reader(participant, topic, qos, NULL);

  Msg msg;
  while (1) {
    dds_take(reader, &msg, 1, NULL, NULL);
    int64_t now = now_ns();
    double latency_ms = (now - msg.send_time_ns) / 1e6;
    printf("Latency: %.3f ms\n", latency_ms);
  }

  dds_delete(participant);
  return 0;
}
```

#### 5.2.4 验证与分析

数据记录与可视化

将输出重定向为 CSV 文件：

```bash
./sub > latency.csv
```

使用 Python 分析延迟数据：

```python
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('latency.csv', names=['Latency'])
plt.plot(df['Latency'])
plt.title('Latency over Time')
plt.xlabel('Sample')
plt.ylabel('Latency (ms)')
plt.grid()
plt.show()
```

---

#### 5.2.5 在负载下测试确定性

使用 `stress-ng` 增加负载：

```bash
stress-ng --cpu 4 --vm 2 --io 2 --timeout 30s
```

使用 `cyclictest` 监测系统 jitter：

```bash
cyclictest -p95 -m -n -i1000 -d0 -l10000
```

使用 `chrt` 提高优先级运行 CycloneDDS 测试程序：

```bash
sudo chrt -f 80 ./pub
sudo chrt -f 80 ./sub
```

---

#### 5.2.6 确定性通信测试要点

| 测试项    | 关键配置 / 工具                      |
| ------ | ------------------------------ |
| 延迟稳定性  | QoS + 高精时间戳                    |
| 系统实时性  | PREEMPT-RT + cyclictest        |
| 干扰下鲁棒性 | stress-ng + chrt               |
| 通信QoS  | Reliable + KeepLast + Deadline |

## 6. 经纬恒润用得的到的 QoS


### **1. `user_data`**

**作用**：

* 在实体（比如 `DataWriter` 或 `DataReader`）中附加自定义的二进制或文本数据。
* 这些数据并不随普通 topic 数据传输，而是在发现（Discovery）阶段就能被对方获取。

**用途**：

* 用于身份标识（如“我是车辆 A”）。
* 在发现时就能根据这些数据过滤或做权限判断。

---

### **2. `partition`**

**作用**：

* 把同一个 Topic 的数据按照“逻辑分区”隔离。
* 只有分区名匹配的 `DataWriter` 和 `DataReader` 才能通信。

**用途**：

* 让多个系统共享相同的 Topic 名字但互不干扰（如不同测试车使用相同的 `position` Topic，但分区为 `car1`、`car2`）。

---

### **3. `durability`**

**作用**：

* 决定 **历史数据是否在订阅者加入后依然可见**。
* 常见值：

  * `VOLATILE`：只发送实时数据，不保存历史。
  * `TRANSIENT_LOCAL`：保存最近的历史数据，直到 DataWriter 销毁。
  * `TRANSIENT` / `PERSISTENT`：使用持久存储（磁盘等）保存数据。

**用途**：

* 让新加入的订阅者立刻收到最新状态（例如配置参数、地图数据）。

---

### **4. `lifespan`**

**作用**：

* 限制数据的“生存时间”。
* 超过时间的数据即使没被消费也会被丢弃。

**用途**：

* 避免过期数据被使用（如传感器帧的有效期 100ms）。

---

### **5. `deadline`**

**作用**：

* 约束 **两次数据更新的最大间隔**。
* 如果超时未更新，就会触发监听器或回调。

**用途**：

* 检测数据源是否延迟或掉线（如 IMU 应该每 5ms 更新一次）。

---

### **6. `liveliness`**

**作用**：

* 确认一个 DataWriter 是否仍然“存活”。
* 可选模式：

  * `AUTOMATIC`：由 DDS 中间件自动声明。
  * `MANUAL_BY_PARTICIPANT`：应用需手动声明存活。
  * `MANUAL_BY_TOPIC`：对单个 DataWriter 手动声明。

**用途**：

* 检测节点是否崩溃或失去连接。

---

### **7. `ownership`**

**作用**：

* 决定当多个 DataWriter 写同一个实例时，谁的值生效。
* 常见值：

  * `SHARED`：所有 Writer 的值都广播，订阅者接收全部。
  * `EXCLUSIVE`：只有拥有最高优先级的 Writer 数据有效。

**用途**：

* 冗余控制系统（如主控失效时备控接管）。

---

### **8. `ownership_strength`**

**作用**：

* 配合 `EXCLUSIVE` 模式使用，数值越大优先级越高。

**用途**：

* 在多源写入时设定主从关系。

---

### **9. `history`**

**作用**：

* 决定缓存多少历史数据。
* 模式：

  * `KEEP_LAST(N)`：保留最近 N 条数据。
  * `KEEP_ALL`：保留全部（受 `resource_limits` 约束）。

**用途**：

* 保证订阅者即使处理慢，也能拿到最近的 N 条消息。

---

### **10. `reliability`**

**作用**：

* 决定数据传输可靠性：

  * `BEST_EFFORT`：丢包不重传（快，适合视频流）。
  * `RELIABLE`：丢包会重传，确保送达（慢，但可靠）。

**用途**：

* 根据应用场景权衡延迟与可靠性。

---

### **11. `destination_order`**

**作用**：

* 决定按什么顺序交付数据：

  * `BY_RECEPTION_TIMESTAMP`：按接收时间。
  * `BY_SOURCE_TIMESTAMP`：按发送方时间戳。

**用途**：

* 在需要事件时序一致性时很重要（如控制指令流）。

---

### **12. `resource_limits`**

**作用**：

* 限制缓存的最大数据量（数量、字节数、实例数）。

**用途**：

* 避免低性能节点被高频数据压垮。

---

### **13. `entity_factory`**

**作用**：

* 控制创建 DDS 实体时是否立即启用（`autoenable_created_entities`）。
* 如果设为 `false`，创建后需手动 enable。

**用途**：

* 在批量创建实体时延迟启用，以便统一配置后再启动。


好，那我给你画一个 **DDS QoS 关系图**，把刚才那些策略按功能分类，方便你调参时一眼定位。

---

## 7. DDS QoS 分类关系图

```
┌──────────────────────────┐
│       数据可见性 QoS      │
├──────────────────────────┤
│ user_data       → 发现阶段传递自定义信息     │
│ partition       → 按逻辑分区隔离 Topic 流    │
│ durability      → 控制历史数据可见性         │
│ history         → 控制缓存历史条数           │
│ resource_limits → 限制缓存大小/数量          │
└──────────────────────────┘

┌──────────────────────────┐
│       数据有效性 QoS      │
├──────────────────────────┤
│ lifespan        → 数据有效期限制              │
│ deadline        → 最大更新间隔约束            │
│ reliability     → BEST_EFFORT / RELIABLE      │
│ destination_order → 按发送或接收时间排序      │
└──────────────────────────┘

┌──────────────────────────┐
│       系统可靠性 QoS      │
├──────────────────────────┤
│ liveliness      → 检测 Writer 是否存活        │
│ ownership       → 数据源优先级策略            │
│ ownership_strength → EXCLUSIVE 模式优先级值   │
│ entity_factory  → 控制实体创建时是否立即启用  │
└──────────────────────────┘
```

---

### **使用思路**

* **调数据可见性**：

  * 想让新加入的订阅者看到历史数据 → 调 `durability` / `history`
  * 想隔离测试环境 → 调 `partition`
* **调数据有效性**：

  * 要丢旧帧 → 设置 `lifespan`
  * 要检测数据延迟 → 设置 `deadline`
  * 要可靠性优先还是延迟优先 → 调 `reliability`
* **调系统可靠性**：

  * 多主备写同一实例 → `ownership` + `ownership_strength`
  * 检测节点是否死机 → `liveliness`

