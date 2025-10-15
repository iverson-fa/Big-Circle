# Jetson 实现GPU跨进程通信

> * 根据社区 / 开发者论坛的反馈，许多 Tegra / Jetson 平台对 **CUDA IPC 的 device-memory 共享（`cudaIpcGetMemHandle` / `cudaIpcOpenMemHandle`）** 支持得不完整或不被支持，只能使用 event IPC 等。也就是说 **在 Jetpack6 / CUDA12 的某些 Jetson 镜像上，cudaIpc memory 共享不可用**。([NVIDIA Developer Forums][1])
> * 因此推荐的可靠实现方式（跨进程共享大缓冲区）是：**用 POSIX 共享内存 / mmap 创建一个共享 host buffer，然后在每个进程里用 `cudaHostRegister` 将该 host 缓冲页锁定为 pinned（可被 GPU 直接访问 / DMA）**；或者在能接受拷贝的场景下，producer 在自己的进程把数据放到该 shm，然后各进程用 `cudaMemcpyAsync` 拷入 device。这个方法在 Jetson 上更兼容。针对低延迟需求也可以把 host buffer 注册后直接用 kernel 访问 (zero-copy/pinned host memory)。相关讨论见社区。([NVIDIA Developer Forums][2])

## 1 相关参考


[1]: https://forums.developer.nvidia.com/t/cuda-ipc-memory-sharing-support-on-jetson-agx-orin-64gb-with-jetpack-6-0/334460?utm_source=chatgpt.com "CUDA IPC Memory Sharing Support on Jetson AGX Orin ..."
[2]: https://forums.developer.nvidia.com/t/cudamallocmanaged-on-jetson-devices/244942?utm_source=chatgpt.com "cudaMallocManaged on jetson devices"
- [CUDA编程中的内存介绍](https://docs.nvidia.com/cuda/cuda-for-tegra-appnote/index.html#porting-considerations)


## 2 技术路线（推荐·兼容 Jetson）：POSIX shm + cudaHostRegister（跨进程共享 host pinned buffer）

思路：用 `shm_open` + `mmap` 创建一个共享内存区（文件映射），两个进程都 `mmap` 到相同物理内存区域；每个进程在使用前调用 `cudaHostRegister(ptr, size, cudaHostRegisterPortable)`（或 `cudaHostRegisterMapped` / 视需求），把该 host buffer 注册为 pinned，使得 GPU 可以直接 DMA 访问（可在 kernel 中以 host pointer 访问或进行异步拷贝）。这种方式不依赖 `cudaIpcGetMemHandle`，在 Jetson 上更稳健。


**注意点 / 性能说明：**

* `cudaHostRegister` 可以把映射页锁定为 pinned：GPU 可直接对 pinned host memory 做 DMA，但在 Jetson 上直接在 kernel 中访问 host 指针（所谓 zero-copy）可能比把数据拷到 device memory 慢（取决于架构）。常见做法：把 shared host buffer 注册后使用 `cudaMemcpyAsync` 拷贝到 device，然后启动 kernel 在 device memory 上运行（这避免在 kernel 中产生大量 page faults/PCIe stall）。
* 使用 `cudaHostRegisterPortable` 有利于跨 CUDA contexts /进程的可移植性。
* 要注意缓存一致性、同步与内存屏障——producer 在写完 shared area 并 `msync`/`munmap`/写信号量之前，consumer 不要启动 GPU 访问。示例用 sem 做简化同步。

## 3 程序

### 3.1 基础功能实现测试

代码结构

```shell
├── CMakeLists.txt
├── include
│   └── ipc_common.h
├── readme
├── run.sh
├── src
│   ├── consumer.cu
│   └── producer.cu
```

`ipc_common.h`

```c
#ifndef IPC_COMMON_H
#define IPC_COMMON_H

#define META_SHM_NAME "/cuda_ipc_meta"
#define DATA_SIZE 16   // 示例大小
struct shm_meta {
    int ready;       // 1=producer写完
    int ack;         // consumer处理完
    char shm_name[64]; // 共享内存名称
    size_t n;        // 元素数量
};

#endif
```

`consumer.cu`

```c
#include <iostream>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <cstring>
#include <cuda_runtime.h>
#include "ipc_common.h"

__global__ void sum_kernel(int *data, size_t n, unsigned long long *out) {
    unsigned long long s = 0;
    for(int i=threadIdx.x+blockIdx.x*blockDim.x; i<n; i+=blockDim.x*gridDim.x)
        s += (unsigned int)data[i];
    atomicAdd(out, s);
}

int main() {
    // 打开 meta shm
    int meta_fd = shm_open(META_SHM_NAME, O_RDWR, 0666);
    shm_meta* meta = (shm_meta*)mmap(nullptr, sizeof(shm_meta), PROT_READ|PROT_WRITE, MAP_SHARED, meta_fd, 0);
    close(meta_fd);

    // 等待 producer ready
    while(meta->ready==0) usleep(1000);

    // 打开 buffer shm
    int fd = shm_open(meta->shm_name, O_RDWR, 0666);
    void* host_buf = mmap(nullptr, meta->n*sizeof(int), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    close(fd);

    // 注册 GPU 可访问
    cudaHostRegister(host_buf, meta->n*sizeof(int), cudaHostRegisterMapped);

    // 获取 GPU 可访问指针
    int* dev_ptr = nullptr;
    cudaHostGetDevicePointer(&dev_ptr, host_buf, 0);

    int* cpu_buf = (int*)host_buf;
    std::cout << "[Consumer] Data: ";
    for(int i=0;i<meta->n;i++) std::cout << cpu_buf[i] << " ";
    std::cout << std::endl;

    // GPU sum
    unsigned long long *d_out, h_out=0;
    cudaMalloc(&d_out, sizeof(unsigned long long));
    cudaMemcpy(d_out, &h_out, sizeof(unsigned long long), cudaMemcpyHostToDevice);

    sum_kernel<<<1,32>>>(dev_ptr, meta->n, d_out);
    cudaDeviceSynchronize();
    cudaMemcpy(&h_out, d_out, sizeof(unsigned long long), cudaMemcpyDeviceToHost);
    cudaFree(d_out);

    std::cout << "[Consumer] Sum = " << h_out << std::endl;

    // ack
    meta->ack = 1;

    // 清理
    munmap(host_buf, meta->n*sizeof(int));
    munmap(meta, sizeof(shm_meta));

    return 0;
}
```

`producer.cu`

```c
#include <iostream>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <cstring>
#include <cuda_runtime.h>
#include "ipc_common.h"

__global__ void init_kernel(int *data, size_t n) {
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if(i < n) data[i] = i+1;
}

int main() {
    int N = DATA_SIZE;

    // 创建 POSIX 共享内存
    const char* shm_name = "/cuda_ipc_buffer";
    int fd = shm_open(shm_name, O_CREAT | O_RDWR, 0666);
    ftruncate(fd, N * sizeof(int));
    void* host_buf = mmap(nullptr, N*sizeof(int), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    close(fd);

    // 注册 GPU 可访问
    cudaHostRegister(host_buf, N*sizeof(int), cudaHostRegisterMapped);

    // 获取 GPU 可访问指针
    int* dev_ptr = nullptr;
    cudaHostGetDevicePointer(&dev_ptr, host_buf, 0);

    // GPU kernel 初始化
    init_kernel<<<1, 32>>>(dev_ptr, N);
    cudaDeviceSynchronize();

    // CPU 检查数据
    std::cout << "[Producer] Data: ";
    int* cpu_buf = (int*)host_buf;
    for(int i=0;i<N;i++) std::cout << cpu_buf[i] << " ";
    std::cout << std::endl;

    // meta shm
    int meta_fd = shm_open(META_SHM_NAME, O_CREAT|O_RDWR, 0666);
    ftruncate(meta_fd, sizeof(shm_meta));
    shm_meta* meta = (shm_meta*)mmap(nullptr, sizeof(shm_meta), PROT_READ|PROT_WRITE, MAP_SHARED, meta_fd, 0);
    close(meta_fd);

    meta->n = N;
    strncpy(meta->shm_name, shm_name, sizeof(meta->shm_name));
    meta->ready = 1;
    meta->ack = 0;

    std::cout << "[Producer] Ready for consumer..." << std::endl;
    while(meta->ack == 0) usleep(1000);

    std::cout << "[Producer] Consumer finished." << std::endl;

    // 清理
    munmap(host_buf, N*sizeof(int));
    shm_unlink(shm_name);
    munmap(meta, sizeof(shm_meta));
    shm_unlink(META_SHM_NAME);

    return 0;
}
```

`CMakeLists.txt`

```cmake
cmake_minimum_required(VERSION 3.18)
project(cuda_host_ipc LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
enable_language(CUDA)
set(CMAKE_CUDA_STANDARD 14)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

set(CMAKE_CUDA_ARCHITECTURES 72)

include_directories(${PROJECT_SOURCE_DIR}/include)
set(SRC_DIR ${PROJECT_SOURCE_DIR}/src)

add_executable(producer ${SRC_DIR}/producer.cu)
add_executable(consumer ${SRC_DIR}/consumer.cu)

target_link_libraries(producer PRIVATE rt cuda pthread)
target_link_libraries(consumer PRIVATE rt cuda pthread)

set_target_properties(producer PROPERTIES CUDA_SEPARABLE_COMPILATION ON POSITION_INDEPENDENT_CODE ON)
set_target_properties(consumer PROPERTIES CUDA_SEPARABLE_COMPILATION ON POSITION_INDEPENDENT_CODE ON)
```

`run.sh`

```sh
#!/bin/bash
set -e

./build/producer &   # 启动 producer
sleep 1
./build/consumer     # 启动 consumer
```