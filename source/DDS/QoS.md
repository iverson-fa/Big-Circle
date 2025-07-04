# QoS

NOTE：可以参考Fast DDS的文档了解DDS相关基础知识。

## 1. DDS标准定义的QoS

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

要实现 DDS 的确定性通信，**QoS（Quality of Service）策略是关键配置手段**。以下是你在设计 DDS 系统时需要特别关注的 **确定性通信相关 QoS 策略项**及推荐设置。

---

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

