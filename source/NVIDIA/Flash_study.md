# 烧录过程研究

## 1 Jetson启动链

MB1、MB2、BPMP、MCE、DCE等这些模块是 Jetson AGX Orin 启动过程中各阶段的核心组件，它们被烧录到 **QSPI NOR Flash** 中，在设备加电后按照启动链依次执行。下面是它们的详细解释：

---

### UEFI_CPU_BL（UEFI Bootloader）

**全称**：UEFI CPU Boot Loader
**作用**：是 Jetson AGX Orin 平台的主启动加载器，负责引导 Linux 内核。

特点：

* 替代了 JetPack 4.x 中的 `cboot`（传统 NVIDIA bootloader）
* 支持 UEFI 规范，可引导多个系统（GRUB、EFI Shell 等）
* 可在 Secure Boot 模式下验证 kernel、DTB、initrd 的签名
* 加载 `kernel`, `initrd`, `extlinux.conf` 并启动系统

类似于 PC 上的 BIOS/UEFI 固件。

---

### OP-TEE（secure-os）

**全称**：Open Portable Trusted Execution Environment
**作用**：安全执行环境（TEE），为 Jetson 提供安全功能，如：

* Secure Boot 的 RSA 校验
* 密钥加解密处理
* 加密存储（fuse、SBK、PKC）
* TZDRAM 管理

特点：

* 与 UEFI 协同工作进行签名校验
* 运行在 Cortex-A78 的 secure world（TrustZone）

---

### MB1（Bootloader stage 1）

**全称**：Micro Bootloader Stage 1
**作用**：系统启动的第一阶段，从 BootROM 跳转进入，初始化以下内容：

* DDR/LPDDR 内存初始化（基于 BCT 配置）
* CPU 初始化、PLL 设置
* Secure Boot hash 校验启动项
* 加载 MB2

由 BootROM 调用，必须成功运行，系统才继续启动。

---

### MB2（Bootloader stage 2）

**全称**：Micro Bootloader Stage 2
**作用**：第二阶段 bootloader，加载 BPMP 固件、DCE、UEFI。

* 设置 CPU/内存时钟
* 加载 OP-TEE、UEFI
* 设置 DDR training，进入恢复模式判断

---

### BPMP（Boot and Power Management Processor）

**全称**：Boot and Power Management Processor
**作用**：Jetson 中的协处理器（ARM Cortex-R 系列）负责：

* 电源调节、电压域控制
* 启动过程的温控、时钟控制
* 动态负载调节（DVFS）
* 外设如 I2C, GPIO 的初始化

是设备启动和运行过程中持续运行的 MCU。

---

### DCE、APE、MCE 等（部分板子）

这些是可选模块，依模组和配置而异：

| 模块      | 全称                      | 作用                 |
| ------- | ----------------------- | ------------------ |
| **DCE** | Display Control Engine  | 控制 HDMI、DP 输出显示初始化 |
| **APE** | Audio Processing Engine | 处理音频编解码和音频硬件资源管理   |
| **MCE** | Memory Control Engine   | 负责安全内存隔离、IOMMU 配置等 |

---

### Jetson 启动链完整流程（简化）

```text
[1] BootROM
  └──▶ [2] MB1 (init DRAM, clocks)
         └──▶ [3] MB2 (load BPMP, UEFI, OP-TEE)
                └──▶ [4] OP-TEE (secure checks)
                └──▶ [5] BPMP (power/peripherals)
                       └──▶ [6] UEFI_CPU_BL (load Linux kernel)
```

---

### 总结

| 模块                  | 类型             | 功能核心                          |
| ------------------- | -------------- | ----------------------------- |
| **UEFI_CPU_BL**   | Bootloader     | 加载 kernel/initrd，支持 UEFI 启动配置 |
| **OP-TEE**          | 安全 OS          | 签名校验、安全存储、TrustZone 支持        |
| **MB1 / MB2**       | 多阶段 Bootloader | 初始化硬件，加载后续启动组件                |
| **BPMP**            | 协处理器固件         | 控制电源、时钟、外设等                   |
| **DCE / APE / MCE** | 子模块固件          | 显示、音频、内存安全等板级功能支持             |

---
