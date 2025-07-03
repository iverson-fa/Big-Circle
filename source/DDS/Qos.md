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

