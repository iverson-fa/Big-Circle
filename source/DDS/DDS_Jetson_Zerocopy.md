# Jetson 实现GPU跨进程通信

> * 根据社区 / 开发者论坛的反馈，许多 Tegra / Jetson 平台对 **CUDA IPC 的 device-memory 共享（`cudaIpcGetMemHandle` / `cudaIpcOpenMemHandle`）** 支持得不完整或不被支持，只能使用 event IPC 等。也就是说 **在 Jetpack6 / CUDA12 的某些 Jetson 镜像上，cudaIpc memory 共享可能不可用**。([NVIDIA Developer Forums][1])
> * 因此推荐的可靠实现方式（跨进程共享大缓冲区）是：**用 POSIX 共享内存 / mmap 创建一个共享 host buffer，然后在每个进程里用 `cudaHostRegister` 将该 host 缓冲页锁定为 pinned（可被 GPU 直接访问 / DMA）**；或者在能接受拷贝的场景下，producer 在自己的进程把数据放到该 shm，然后各进程用 `cudaMemcpyAsync` 拷入 device。这个方法在 Jetson 上更兼容。针对低延迟需求也可以把 host buffer 注册后直接用 kernel 访问 (zero-copy/pinned host memory)。相关讨论见社区。([NVIDIA Developer Forums][2])

## 1 相关参考


[1]: https://forums.developer.nvidia.com/t/cuda-ipc-memory-sharing-support-on-jetson-agx-orin-64gb-with-jetpack-6-0/334460?utm_source=chatgpt.com "CUDA IPC Memory Sharing Support on Jetson AGX Orin ..."
[2]: https://forums.developer.nvidia.com/t/cudamallocmanaged-on-jetson-devices/244942?utm_source=chatgpt.com "cudaMallocManaged on jetson devices"


## 2 技术路线（推荐·兼容 Jetson）：POSIX shm + cudaHostRegister（跨进程共享 host pinned buffer）

思路：用 `shm_open` + `mmap` 创建一个共享内存区（文件映射），两个进程都 `mmap` 到相同物理内存区域；每个进程在使用前调用 `cudaHostRegister(ptr, size, cudaHostRegisterPortable)`（或 `cudaHostRegisterMapped` / 视需求），把该 host buffer 注册为 pinned，使得 GPU 可以直接 DMA 访问（可在 kernel 中以 host pointer 访问或进行异步拷贝）。这种方式不依赖 `cudaIpcGetMemHandle`，在 Jetson 上更稳健。


**注意点 / 性能说明：**

* `cudaHostRegister` 可以把映射页锁定为 pinned：GPU 可直接对 pinned host memory 做 DMA，但在 Jetson 上直接在 kernel 中访问 host 指针（所谓 zero-copy）可能比把数据拷到 device memory 慢（取决于架构）。常见做法：把 shared host buffer 注册后使用 `cudaMemcpyAsync` 拷贝到 device，然后启动 kernel 在 device memory 上运行（这避免在 kernel 中产生大量 page faults/PCIe stall）。
* 使用 `cudaHostRegisterPortable` 有利于跨 CUDA contexts /进程的可移植性。
* 要注意缓存一致性、同步与内存屏障——producer 在写完 shared area 并 `msync`/`munmap`/写信号量之前，consumer 不要启动 GPU 访问。示例用 sem 做简化同步。

## 3 程序

### 3.1 基础功能实现测试

代码结构

├── CMakeLists.txt
├── include
│   └── ipc_common.h
├── readme
├── run.sh
├── src
│   ├── consumer.cpp
│   └── producer.cu

`ipc_common.h`

```c
#pragma once
#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <cstdint>

constexpr size_t FRAME_COUNT = 100;
constexpr size_t SAMPLE_COUNT = 1024*1024; // 每帧 1M
constexpr size_t BUFFER_SIZE = FRAME_COUNT * SAMPLE_COUNT * sizeof(uint32_t);

inline void checkCuda(cudaError_t err, const char* msg) {
    if (err != cudaSuccess) {
        fprintf(stderr, "CUDA error %s: %s\n", msg, cudaGetErrorString(err));
        std::exit(EXIT_FAILURE);
    }
}
```

`consumer.cpp`

```c
#include "ipc_common.h"
#include <cstdio>
#include <thread>
#include <chrono>

int main() {
    uint32_t* host_buffer = nullptr;
    checkCuda(cudaMallocHost((void**)&host_buffer, BUFFER_SIZE), "cudaMallocHost failed");

    uint32_t* device_ptr = nullptr;
    checkCuda(cudaHostGetDevicePointer((void**)&device_ptr, host_buffer, 0), "Get host pointer");

    // 模拟读取每帧数据
    for (size_t f = 0; f < FRAME_COUNT; ++f) {
        uint64_t sum = 0;
        for (size_t i = 0; i < SAMPLE_COUNT; ++i) {
            sum += host_buffer[f*SAMPLE_COUNT + i];
        }
        printf("[Consumer] Frame %zu sum = %lu\n", f, sum);
        std::this_thread::sleep_for(std::chrono::microseconds(1000)); // 模拟处理延迟
    }

    checkCuda(cudaFreeHost(host_buffer), "cudaFreeHost failed");
    printf("[Consumer] Finished.\n");
    return 0;
}
```

`producer.cu`

```c
#include "ipc_common.h"
#include <unistd.h> // sleep

int main() {
    uint32_t* host_buffer = nullptr;
    checkCuda(cudaMallocHost((void**)&host_buffer, BUFFER_SIZE), "cudaMallocHost failed");

    uint32_t* device_ptr = nullptr;
    checkCuda(cudaHostGetDevicePointer((void**)&device_ptr, host_buffer, 0), "Get host pointer");

    // 模拟每帧数据写入
    for (size_t f = 0; f < FRAME_COUNT; ++f) {
        for (size_t i = 0; i < SAMPLE_COUNT; ++i) {
            host_buffer[f*SAMPLE_COUNT + i] = f * SAMPLE_COUNT + i;
        }
        printf("[Producer] Frame %zu written\n", f);
        usleep(1000); // 模拟发布间隔 1ms
    }

    checkCuda(cudaFreeHost(host_buffer), "cudaFreeHost failed");
    printf("[Producer] Finished.\n");
    return 0;
}
```

`CMakeLists.txt`

```cmake
cmake_minimum_required(VERSION 3.18)
project(cuda_ipc_demo LANGUAGES CXX CUDA)

# C++ 17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 找到 CUDA
find_package(CUDA REQUIRED)

# include
include_directories(${PROJECT_SOURCE_DIR}/include)
include_directories(${CUDA_INCLUDE_DIRS})   # <-- 关键，consumer 找 cuda_runtime.h

# producer 可执行文件
add_executable(producer src/producer.cu)
set_target_properties(producer PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON
)

# consumer 可执行文件
add_executable(consumer src/consumer.cpp)
target_link_libraries(consumer PRIVATE ${CUDA_LIBRARIES})  # 链接 cuda runtime
```

`run.sh`

```sh
#!/bin/bash
set -e

./build/producer &   # 启动 producer
sleep 1
./build/consumer     # 启动 consumer
```