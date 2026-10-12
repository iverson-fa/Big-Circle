# 英文缩写

## 1 车载以太网

| 简称     | 含义               | 全称                                          |
| ------ | ---------------- | ------------------------------------------- |
| OSI    | 开放式系统互联通信参考模型    | Open System Interconnection Reference Model |
| PHY    | 端口物理层 OSI最底层     | Physical                                    |
| SOA    | 面向服务架构           | Service Oriented Architecture               |
| DMIPS  | 每秒处理的百万级的机器语言指令数 | Dhrystone Million Instructions Per Second   |
| GFLOPS | 每秒10亿次的浮点运算数     | Giga Floating-point Operations Per Second   |
| NPU    | 嵌入式神经网络处理器       | Neural-network Processing Units             |
| IC     | 集成电路             | Integrated Circuit                          |
| TSN    | 时间敏感网络，时效性网络     | Time-Sensitive Network                      |
| ASIC   | 专用集成电路           | Application Specific Integrated Circuit     |
| FPGA   | 现场可编程逻辑门阵列       | Field Programmable Gate Array               |
|        |                  |                                             |

## 2 Orin

| 简称     | 含义               | 全称                                          |
| ------ | ---------------- | ------------------------------------------- |
| HSM    | 硬件安全管理    | Hardware Safety Manager |
| SCE | 安全集群引擎，：确保传感器、控制系统和执行器之间的协作，即使某些组件失效，也能安全停车或降低风险 | Safety Cluster Engine |
| CBB | 连接传感器、控制器和执行器的核心总线，例如以太网AVB/TSN或CAN总线，确保实时数据流动和控制信号传输 | Control Backbone |
| DBB | 整个车辆系统中用于集中管理和高效传输数据的核心通信和处理平台 | Data Backbone |
| PA | 物理地址 | Physical Address |
| IPA | 一个内存管理机制，用于高效管理设备与内存之间的数据交换所需的内存页 | I/O Page Allocator |
| VA | 虚拟地址 | Virtual Address |
| FSI | 功能安全岛，为满足功能安全要求而设计的独立、安全域（或硬件模块）。它专门用于确保在关键任务或系统失效情况下，车辆依然能够执行安全相关的基本功能，防止事故发生 | Functional Safety Island |
| NVCSI | 高速串行接口，专门用于将摄像头模块的数据传输到嵌入式系统中，用于图像处理和计算机视觉任务 | NVIDIA Camera Serial Interface |
| MMU | 内存管理单元。它是计算机硬件的一个组成部分，负责将虚拟内存地址转换为物理内存地址，以及管理内存访问权限等 | Memory Management Unit  |
| SMMU | 系统内存管理单元。它通常用于更复杂的系统中，比如大型服务器或嵌入式系统中，提供高级的内存管理功能，比如虚拟化支持、内存保护等。SMMU 可以提供比传统 MMU 更强大的内存管理能力 | System MMU |
| ISP | 专用硬件处理器，用于对摄像头传感器捕获的原始图像数据进行预处理 | Image Signal Processor |
| Hypervisor | 支持安全与非安全域隔离、实时任务支持，以及与 GPU 协作处理感知任务。 |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |

## 2.1 CBB和DBB

在**自动驾驶场景**中，**Data Backbone**（数据骨干）是指整个车辆系统中用于集中管理和高效传输数据的核心通信和处理平台。它连接车辆的传感器、处理单元、控制器以及执行器，确保数据能够快速、安全且可靠地流动，以支持自动驾驶功能的实现。

---
| **方面**             | **Data Backbone**                         | **Control Backbone**                      |
|----------------------|------------------------------------------|------------------------------------------|
| **主要功能**         | 数据传输和管理，支持感知与计算任务       | 控制信号的传输与执行                     |
| **数据类型**         | 高带宽数据流（如传感器数据）             | 低带宽控制信号（如转向、制动命令）       |
| **实时性要求**       | 高但非极端（实时环境感知处理）            | 极高（例如紧急制动响应）                 |
| **传输协议**         | Ethernet AVB/TSN，PCIe                   | CAN、FlexRay                             |
| **适用范围**         | 感知、计算、地图更新等复杂任务            | 驱动系统和执行器的控制任务               |

---

在自动驾驶系统中，**Data Backbone** 是感知和计算的中枢神经，用于传输和处理大量的传感器数据和计算结果；而 **Control Backbone** 则是执行和反馈的核心，用于确保车辆能够按照预期安全运行。两者相辅相成，共同支持自动驾驶的高效运行。