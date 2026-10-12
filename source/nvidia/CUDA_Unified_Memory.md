# CUDA 统一内存与零拷贝

整理自 autodrrt_comm 项目的 GPU 零拷贝测试（`gpu_zero_copy_kernel.cu`）。autodrrt_comm 的订阅端 CPU 稳定在 0.01–0.02s、RSS 稳定在 ~7.5MB——**O(1) 传输特征**，7 场景几乎无差异。

## 1. 统一内存核心 API

### 1.1 分配类

| API | 作用 | 使用场景 |
|-----|------|----------|
| `cudaMallocManaged(&ptr, size)` | 分配统一内存（CPU/GPU 均可直接访问） | 需要驱动自动管理页迁移 |
| `cudaHostAlloc(&ptr, size, cudaHostAllocMapped)` | 分配 pinned host memory | 零拷贝路径 |
| `cudaMalloc(&d_ptr, size)` | 分配 device memory | 传统 H2D/D2H 拷贝路径 |

### 1.2 注册类（autodrrt_comm 使用）

| API | 作用 |
|-----|------|
| `cudaHostRegister(ptr, size, cudaHostRegisterMapped)` | 将**已存在的 host 内存**（如 shm arena）注册为 GPU 可映射 |
| `cudaHostGetDevicePointer(&d_ptr, h_ptr, 0)` | 获取注册内存对应的 device 指针 |

### 1.3 迁移控制类

| API | 作用 |
|-----|------|
| `cudaMemPrefetchAsync(ptr, size, device, stream)` | 主动预取数据到指定设备 |
| `cudaMemAdvise(ptr, size, advice, device)` | 告知驱动数据访问模式（如 `cudaMemAdviseSetReadMostly`） |

### 1.4 同步类

| API | 作用 |
|-----|------|
| `cudaDeviceSynchronize()` | 等待所有 GPU kernel 完成 |
| `cudaStreamSynchronize(stream)` | 等待指定 stream 完成 |

## 2. GPU 零拷贝方案

```cpp
// 注册已存在的 host 内存（如 shm arena）为 GPU 可映射
cudaHostRegister(ptr, size, cudaHostRegisterMapped);
// 获取注册内存对应的 device 指针
cudaHostGetDevicePointer(&d_ptr, h_ptr, 0);
```

**零拷贝映射内存 vs 统一内存**：

- 零拷贝映射内存：GPU 直接通过 PCIe 总线（离散 GPU）或共享物理内存（集成 GPU/Jetson）访问 host 内存，**无页迁移、无拷贝——直接访问**
- 统一内存（`cudaMallocManaged`）：页迁移由驱动自动管理，离散 GPU 上通过 PCIe/NVLink 迁移
- **在 Jetson（集成 GPU）上两者性能等价**：CPU 和 GPU 共享同一块物理 LPDDR5 内存，无 PCIe 总线穿越，无页迁移需求
