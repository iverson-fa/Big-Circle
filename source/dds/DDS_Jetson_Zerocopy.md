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

### 3.2 cyclonedds实现

├── CMakeLists.txt

├── consumer.cu

├── ipc_common.h

├── producer.cu

└── Throughput.idl

`Throughput.idl`

```shell
module ThroughputModule {
    struct DataDescriptor {
        string<64> shm_name;
        long n;
        long data_size;
    };

    struct ControlMsg {
        boolean ready;
        boolean ack;
    };
};

```

`ipc_common.h`

```c
#ifndef IPC_COMMON_H
#define IPC_COMMON_H

#include "Throughput.h"  // 包含生成的 DDS 类型

#define DATA_SIZE 16
#define DATA_SHM_NAME "/cuda_dds_data"
#define META_SHM_NAME "/cuda_dds_meta"

// 共享内存元数据结构（用于实际数据共享）
struct shm_meta {
    int ready;
    int ack;
    size_t n;
};

// DDS 主题名称
#define DATA_DESCRIPTOR_TOPIC "DataDescriptor"
#define CONTROL_TOPIC "ControlTopic"

#endif
```

`producer.cu`

```c
#include <iostream>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <cstring>
#include <cuda_runtime.h>
#include <dds/dds.h>
#include "ipc_common.h"

__global__ void init_kernel(int *data, size_t n) {
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if(i < n) data[i] = i + 1;
}

int main() {
    int N = DATA_SIZE;
    dds_entity_t participant, data_writer;
    dds_return_t rc;

    std::cout << "[Producer] Starting..." << std::endl;

    // 创建 POSIX 共享内存
    const char* shm_name = DATA_SHM_NAME;
    std::cout << "[Producer] Creating shared memory: " << shm_name << std::endl;

    int fd = shm_open(shm_name, O_CREAT | O_RDWR, 0666);
    if (fd < 0) {
        std::cerr << "[Producer] Failed to create shared memory: " << strerror(errno) << std::endl;
        return -1;
    }

    ftruncate(fd, N * sizeof(int));
    void* host_buf = mmap(nullptr, N * sizeof(int), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    close(fd);

    if (host_buf == MAP_FAILED) {
        std::cerr << "[Producer] Failed to mmap shared memory: " << strerror(errno) << std::endl;
        return -1;
    }

    // 注册 GPU 可访问
    cudaError_t cuda_err = cudaHostRegister(host_buf, N * sizeof(int), cudaHostRegisterMapped);
    if (cuda_err != cudaSuccess) {
        std::cerr << "[Producer] Failed to register host memory: " << cudaGetErrorString(cuda_err) << std::endl;
        return -1;
    }

    // 获取 GPU 可访问指针
    int* dev_ptr = nullptr;
    cuda_err = cudaHostGetDevicePointer(&dev_ptr, host_buf, 0);
    if (cuda_err != cudaSuccess) {
        std::cerr << "[Producer] Failed to get device pointer: " << cudaGetErrorString(cuda_err) << std::endl;
        return -1;
    }

    // GPU kernel 初始化数据
    init_kernel<<<1, 32>>>(dev_ptr, N);
    cudaDeviceSynchronize();

    // 打印数据
    std::cout << "[Producer] Data: ";
    int* cpu_buf = (int*)host_buf;
    for(int i = 0; i < N; i++) std::cout << cpu_buf[i] << " ";
    std::cout << std::endl;

    // 初始化 DDS
    participant = dds_create_participant(DDS_DOMAIN_DEFAULT, NULL, NULL);
    if (participant < 0) {
        std::cerr << "[Producer] Failed to create participant: " << dds_strretcode(-participant) << std::endl;
        return -1;
    }

    // 创建数据描述符主题 - 使用可靠的 QoS
    dds_qos_t *qos = dds_create_qos();
    dds_qset_reliability(qos, DDS_RELIABILITY_RELIABLE, DDS_SECS(10));
    dds_qset_durability(qos, DDS_DURABILITY_TRANSIENT_LOCAL);

    dds_entity_t data_topic = dds_create_topic(participant, &ThroughputModule_DataDescriptor_desc,
                                              DATA_DESCRIPTOR_TOPIC, qos, NULL);
    if (data_topic < 0) {
        std::cerr << "[Producer] Failed to create data topic: " << dds_strretcode(-data_topic) << std::endl;
        dds_delete_qos(qos);
        return -1;
    }

    data_writer = dds_create_writer(participant, data_topic, qos, NULL);
    if (data_writer < 0) {
        std::cerr << "[Producer] Failed to create data writer: " << dds_strretcode(-data_writer) << std::endl;
        dds_delete_qos(qos);
        return -1;
    }
    dds_delete_qos(qos);

    std::cout << "[Producer] Waiting for consumer to connect..." << std::endl;

    // 等待读者连接
    dds_publication_matched_status_t status;
    int wait_count = 0;
    do {
        rc = dds_get_publication_matched_status(data_writer, &status);
        if (rc < 0) {
            std::cerr << "[Producer] Failed to get publication matched status" << std::endl;
            return -1;
        }
        std::cout << "[Producer] Current matched readers: " << status.current_count << std::endl;
        if (status.current_count > 0) break;

        usleep(1000000); // 1秒
        wait_count++;
    } while (wait_count < 10); // 最多等待10秒

    if (status.current_count == 0) {
        std::cerr << "[Producer] Timeout waiting for consumer" << std::endl;
        return -1;
    }

    std::cout << "[Producer] Consumer connected, sending data descriptor..." << std::endl;

    // 发送数据描述符
    ThroughputModule_DataDescriptor data_desc;
    memset(&data_desc, 0, sizeof(data_desc));

    strncpy(data_desc.shm_name, shm_name, sizeof(data_desc.shm_name) - 1);
    data_desc.shm_name[sizeof(data_desc.shm_name) - 1] = '\0';
    data_desc.n = N;
    data_desc.data_size = N * sizeof(int);

    std::cout << "[Producer] Sending data descriptor..." << std::endl;
    rc = dds_write(data_writer, &data_desc);
    if (rc < 0) {
        std::cerr << "[Producer] Failed to write data descriptor: " << dds_strretcode(-rc) << std::endl;
        return -1;
    }

    std::cout << "[Producer] Data descriptor sent successfully" << std::endl;
    std::cout << "[Producer] Waiting 10 seconds for consumer to process..." << std::endl;

    sleep(10); // 给消费者足够的时间处理

    // 清理
    cudaHostUnregister(host_buf);
    munmap(host_buf, N * sizeof(int));
    shm_unlink(shm_name);

    dds_delete(participant);

    std::cout << "[Producer] Exiting." << std::endl;
    return 0;
}
```

`consumer.cu`

```c
#include <iostream>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <cstring>
#include <cuda_runtime.h>
#include <dds/dds.h>
#include "ipc_common.h"

__global__ void sum_kernel(int *data, size_t n, unsigned long long *out) {
    unsigned long long s = 0;
    for(int i = threadIdx.x + blockIdx.x * blockDim.x; i < n; i += blockDim.x * gridDim.x)
        s += (unsigned int)data[i];
    atomicAdd(out, s);
}

int main() {
    dds_entity_t participant, data_reader;
    dds_return_t rc;

    std::cout << "[Consumer] Starting..." << std::endl;

    // 初始化 DDS
    participant = dds_create_participant(DDS_DOMAIN_DEFAULT, NULL, NULL);
    if (participant < 0) {
        std::cerr << "[Consumer] Failed to create participant: " << dds_strretcode(-participant) << std::endl;
        return -1;
    }

    // 创建数据描述符读取器 - 使用可靠的 QoS
    dds_qos_t *qos = dds_create_qos();
    dds_qset_reliability(qos, DDS_RELIABILITY_RELIABLE, DDS_SECS(10));
    dds_qset_durability(qos, DDS_DURABILITY_TRANSIENT_LOCAL);

    dds_entity_t data_topic = dds_create_topic(participant, &ThroughputModule_DataDescriptor_desc,
                                              DATA_DESCRIPTOR_TOPIC, qos, NULL);
    if (data_topic < 0) {
        std::cerr << "[Consumer] Failed to create data topic: " << dds_strretcode(-data_topic) << std::endl;
        dds_delete_qos(qos);
        return -1;
    }

    data_reader = dds_create_reader(participant, data_topic, qos, NULL);
    if (data_reader < 0) {
        std::cerr << "[Consumer] Failed to create data reader: " << dds_strretcode(-data_reader) << std::endl;
        dds_delete_qos(qos);
        return -1;
    }
    dds_delete_qos(qos);

    std::cout << "[Consumer] Waiting for data descriptor..." << std::endl;

    // 等待数据描述符 - 使用更长的超时时间
    ThroughputModule_DataDescriptor data_desc;
    bool received_data = false;

    for (int i = 0; i < 30; i++) { // 最多等待30秒
        ThroughputModule_DataDescriptor *received_sample = NULL;
        dds_sample_info_t info;

        rc = dds_take(data_reader, (void**)&received_sample, &info, 1, 1);
        if (rc > 0 && info.valid_data) {
            // 复制数据到本地变量
            memcpy(&data_desc, received_sample, sizeof(data_desc));
            dds_free(received_sample);
            received_data = true;
            break;
        }

        if (received_sample) {
            dds_free(received_sample);
        }

        std::cout << "[Consumer] Waiting... (" << (i+1) << "/30)" << std::endl;
        sleep(1); // 1秒
    }

    if (!received_data) {
        std::cerr << "[Consumer] Timeout waiting for data descriptor" << std::endl;

        // 检查订阅状态
        dds_subscription_matched_status_t status;
        rc = dds_get_subscription_matched_status(data_reader, &status);
        if (rc >= 0) {
            std::cout << "[Consumer] Current matched writers: " << status.current_count << std::endl;
        }

        return -1;
    }

    std::cout << "[Consumer] Received data descriptor!" << std::endl;
    std::cout << "[Consumer] SHM name: " << data_desc.shm_name << std::endl;
    std::cout << "[Consumer] Data size: " << data_desc.data_size << std::endl;
    std::cout << "[Consumer] Element count: " << data_desc.n << std::endl;

    // 打开共享内存
    int fd = shm_open(data_desc.shm_name, O_RDWR, 0666);
    if (fd < 0) {
        std::cerr << "[Consumer] Failed to open shared memory: " << data_desc.shm_name
                  << ", error: " << strerror(errno) << std::endl;
        return -1;
    }

    void* host_buf = mmap(nullptr, data_desc.data_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    close(fd);

    if (host_buf == MAP_FAILED) {
        std::cerr << "[Consumer] Failed to mmap shared memory: " << strerror(errno) << std::endl;
        return -1;
    }

    // 注册 GPU 可访问
    cudaError_t cuda_err = cudaHostRegister(host_buf, data_desc.data_size, cudaHostRegisterMapped);
    if (cuda_err != cudaSuccess) {
        std::cerr << "[Consumer] Failed to register host memory: " << cudaGetErrorString(cuda_err) << std::endl;
        return -1;
    }

    // 获取 GPU 可访问指针
    int* dev_ptr = nullptr;
    cuda_err = cudaHostGetDevicePointer(&dev_ptr, host_buf, 0);
    if (cuda_err != cudaSuccess) {
        std::cerr << "[Consumer] Failed to get device pointer: " << cudaGetErrorString(cuda_err) << std::endl;
        return -1;
    }

    // 打印数据
    int* cpu_buf = (int*)host_buf;
    std::cout << "[Consumer] Data: ";
    for(int i = 0; i < data_desc.n; i++)
        std::cout << cpu_buf[i] << " ";
    std::cout << std::endl;

    // GPU 求和计算
    unsigned long long *d_out, h_out = 0;
    cudaMalloc(&d_out, sizeof(unsigned long long));
    cudaMemcpy(d_out, &h_out, sizeof(unsigned long long), cudaMemcpyHostToDevice);

    sum_kernel<<<1, 32>>>(dev_ptr, data_desc.n, d_out);
    cudaDeviceSynchronize();
    cudaMemcpy(&h_out, d_out, sizeof(unsigned long long), cudaMemcpyDeviceToHost);

    std::cout << "[Consumer] Sum = " << h_out << std::endl;

    // 清理
    cudaHostUnregister(host_buf);
    munmap(host_buf, data_desc.data_size);
    cudaFree(d_out);

    dds_delete(participant);

    std::cout << "[Consumer] Exiting successfully." << std::endl;
    return 0;
}
```

编译测试
```shell
mkdir build && cd build
cmake .. -DCMAKE_PREFIX_PATH=/home/orin/cyclonedds/install
make
# 启动consumer
[Consumer] Starting...
1761726831.435866 [0]   consumer: determined docker0 (udp/172.17.0.1) as highest quality interface, selected for automatic interface.
[Consumer] Waiting for data descriptor...
[Consumer] Waiting... (1/30)
[Consumer] Waiting... (2/30)
[Consumer] Waiting... (3/30)
[Consumer] Waiting... (4/30)
[Consumer] Waiting... (5/30)
[Consumer] Waiting... (6/30)
[Consumer] Received data descriptor!
[Consumer] SHM name: /cuda_dds_data
[Consumer] Data size: 64
[Consumer] Element count: 16
[Consumer] Data: 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
[Consumer] Sum = 136
[Consumer] Exiting successfully.
# 启动producer
[Producer] Starting...
[Producer] Creating shared memory: /cuda_dds_data
[Producer] Data: 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
[Producer] Waiting for consumer to connect...
[Producer] Current matched readers: 1
[Producer] Consumer connected, sending data descriptor...
[Producer] Sending data descriptor...
[Producer] Data descriptor sent successfully
[Producer] Waiting 10 seconds for consumer to process...
[Producer] Exiting.
```
### 3.3 fastdds实现

代码文件

```shell
./
├── CMakeLists.txt
├── include
│   └── ipc_common.h
└── src
    ├── publisher.cu
    └── subscriber.cu
```

ipc_common.h

```c
#ifndef IPC_COMMON_H
#define IPC_COMMON_H

#define META_SHM_NAME "/cuda_ipc_meta"
#define DATA_SIZE 1024  // 示例元素数量

struct shm_meta {
    volatile int ready;       // 1=publisher 写完
    volatile int ack;         // subscriber 处理完
    char shm_name[64];        // 共享内存名称
    size_t n;                 // 元素数量
};

#endif
```

publisher.cu

```c
#include <iostream>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <cstring>
#include <cuda_runtime.h>
#include "ipc_common.h"

__global__ void init_kernel(int* data, size_t n) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    if(idx < (int)n) data[idx] = idx + 1;
}

int main() {
    const char* shm_name = "/cuda_ipc_buffer";
    int N = DATA_SIZE;

    // 1. 创建 buffer shm
    int fd = shm_open(shm_name, O_CREAT | O_RDWR, 0666);
    ftruncate(fd, N * sizeof(int));
    void* host_buf = mmap(nullptr, N*sizeof(int), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    close(fd);

    // 2. 注册 GPU 可访问
    cudaHostRegister(host_buf, N*sizeof(int), cudaHostRegisterMapped);
    int* dev_ptr = nullptr;
    cudaHostGetDevicePointer(&dev_ptr, host_buf, 0);

    // 3. GPU 初始化
    int threads = 256;
    int blocks = (N + threads - 1) / threads;
    init_kernel<<<blocks, threads>>>(dev_ptr, N);
    cudaDeviceSynchronize();

    // 4. CPU 检查
    int* cpu_buf = (int*)host_buf;
    std::cout << "[Publisher] Data sample: " << cpu_buf[0] << " " << cpu_buf[1]
              << " ... " << cpu_buf[N-1] << std::endl;

    // 5. 创建 meta shm
    int meta_fd = shm_open(META_SHM_NAME, O_CREAT|O_RDWR, 0666);
    ftruncate(meta_fd, sizeof(shm_meta));
    shm_meta* meta = (shm_meta*)mmap(nullptr, sizeof(shm_meta),
                                     PROT_READ | PROT_WRITE, MAP_SHARED, meta_fd, 0);
    close(meta_fd);

    strncpy(meta->shm_name, shm_name, sizeof(meta->shm_name));
    meta->n = N;
    meta->ready = 1;
    meta->ack = 0;

    std::cout << "[Publisher] Waiting for subscriber..." << std::endl;
    while(meta->ack == 0) usleep(1000);
    std::cout << "[Publisher] Subscriber finished." << std::endl;

    // cleanup
    cudaHostUnregister(host_buf);
    munmap(host_buf, N*sizeof(int));
    shm_unlink(shm_name);
    munmap(meta, sizeof(shm_meta));
    shm_unlink(META_SHM_NAME);

    return 0;
}
```

subscriber.cu

```c
#include <iostream>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <cuda_runtime.h>
#include "ipc_common.h"

__global__ void sum_kernel(int* data, size_t n, unsigned long long* out) {
    unsigned long long s = 0;
    for(int i = threadIdx.x + blockIdx.x * blockDim.x; i < (int)n; i += blockDim.x * gridDim.x)
        s += (unsigned int)data[i];
    atomicAdd(out, s);
}

int main() {
    // 1. 打开 meta shm
    int meta_fd = shm_open(META_SHM_NAME, O_RDWR, 0666);
    shm_meta* meta = (shm_meta*)mmap(nullptr, sizeof(shm_meta),
                                     PROT_READ | PROT_WRITE, MAP_SHARED, meta_fd, 0);
    close(meta_fd);

    // 等待 publisher ready
    while(meta->ready == 0) usleep(1000);

    // 2. 打开 buffer shm
    int fd = shm_open(meta->shm_name, O_RDWR, 0666);
    void* host_buf = mmap(nullptr, meta->n*sizeof(int),
                          PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    close(fd);

    // 3. 注册 CUDA
    cudaHostRegister(host_buf, meta->n*sizeof(int), cudaHostRegisterMapped);
    int* dev_ptr = nullptr;
    cudaHostGetDevicePointer(&dev_ptr, host_buf, 0);

    // 4. GPU 计算 sum
    unsigned long long h_out = 0;
    unsigned long long* d_out;
    cudaMalloc(&d_out, sizeof(unsigned long long));
    cudaMemcpy(d_out, &h_out, sizeof(unsigned long long), cudaMemcpyHostToDevice);

    int threads = 256;
    int blocks = (meta->n + threads - 1) / threads;
    sum_kernel<<<blocks, threads>>>(dev_ptr, meta->n, d_out);
    cudaDeviceSynchronize();
    cudaMemcpy(&h_out, d_out, sizeof(unsigned long long), cudaMemcpyDeviceToHost);
    cudaFree(d_out);

    std::cout << "[Subscriber] Sum = " << h_out << std::endl;

    // ack
    meta->ack = 1;

    // cleanup
    cudaHostUnregister(host_buf);
    munmap(host_buf, meta->n*sizeof(int));
    munmap(meta, sizeof(shm_meta));

    return 0;
}
```

CMakeLists.txt

```shell
cmake_minimum_required(VERSION 3.18)
project(latency_ipc_cuda LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 14)
enable_language(CUDA)
set(CMAKE_CUDA_STANDARD 14)
set(CMAKE_CUDA_ARCHITECTURES 72)  # 适配 GPU

include_directories(${PROJECT_SOURCE_DIR}/include)
set(SRC_DIR ${PROJECT_SOURCE_DIR}/src)

add_executable(publisher ${SRC_DIR}/publisher.cu)
add_executable(subscriber ${SRC_DIR}/subscriber.cu)

target_link_libraries(publisher PRIVATE rt cuda pthread)
target_link_libraries(subscriber PRIVATE rt cuda pthread)

set_target_properties(publisher PROPERTIES CUDA_SEPARABLE_COMPILATION ON)
set_target_properties(subscriber PROPERTIES CUDA_SEPARABLE_COMPILATION ON)
```
