# Jetson AGX Orin 启动过程的串口输出日志

日志记录了从 **上电开始（BootROM → MB1 → MB2 → UEFI/TOS/Kernel）** 的所有初始化步骤。下面分层解析。

---

## 1 启动阶段分解

### **阶段 1：MB1 (Bootloader Stage 1)**

```
[0000.063] I> MB1 (version: 1.4.0.4-t234-54845784-e89ea9bc)
[0000.073] I> Boot-mode : Coldboot
...
[0000.308] I> Boot_device: QSPI_FLASH instance: 0
[0000.312] I> QSPI Flash: Macronix 64MB
```

**说明：**

* 这是 Jetson Orin 平台的第一级引导加载程序（BootROM之后的第一级可更新组件）。
* 它负责初始化安全引擎 (SE)、时钟、PLL、电压监控、UPHY、内存控制器（EMC）等底层硬件。
* 从日志可知：

  * 启动源是 **QSPI Flash**（正常情况）。
  * 设备温度检测、Fuse校验、内存BCT加载都成功。
  * 没有检测到错误或重启原因（`last_boot_error: 0x0`、`rst_source: 0x0`）。

✅ **状态：一切正常。**

---

### **阶段 2：内存配置 (BCT / MEM-BCT)**

```
[0000.326] I> RAM_CODE 0x4000401
[0000.329] I> Loading MEMBCT
[0000.395] I> Binary MEM-BCT-0 loaded successfully ...
```

**说明：**

* MB1 从 QSPI 读取并验证 **Memory Boot Configuration Table (MEM-BCT)**。
* 该表定义了 DRAM 初始化参数（时序、通道配置、Carveout 分区等）。
* “integrity check success” 表示签名校验成功。

✅ **状态：内存初始化成功，ECC/Non-ECC 分区划分完成。**

---

### **阶段 3：Carveout 内存分配**

```
[0000.487] I> allocated(CO:44) base:0x849800000 size:0x36800000 ...
...
[0000.745] I> NSDRAM base: 0x80000000, end: 0x82cdf0000, size: 0x7acdf0000
```

**说明：**

* 各个 Carveout（系统保留内存区）被划分给：

  * BPMP、RCE、DCE、TZDRAM、MB2、MCE、VPR、Video 等模块。
* 地址区间和对齐都成功，表示内存映射正确。

✅ **状态：DRAM 分区正常。**

---

### **阶段 4：MB1 → MB2 切换**

```
[0001.741] I> Binary magic in BCH component 0 is MB2R
...
[0001.925] I> Binary MB2 loaded successfully at 0x80000000 (0x69a70)
[0001.974] I> MB1: MSS reconfig completed
```

**说明：**

* MB1 加载第二阶段引导程序 **MB2 (Mini Bootloader 2)**。
* MB2 是可更新的 bootloader，用于加载 TOS、UEFI、内核等。
* 校验通过，地址对齐正确。

✅ **状态：从 MB1 切换到 MB2 成功。**

---

### **阶段 5：MB2 初始化**

```
I> MB2 (version: 0.0.0.0-t234-54845784-0fbce5b9)
I> Boot-mode : Coldboot
I> DMA heap: [base:0x82e000000, size:0x800000]
...
I> Task: Load HV/CPUBL
I> Task: Load TOS
```

**说明：**

* MB2 启动后重新配置 watchdog、安全环境、IOMMU、power domain。
* 然后开始加载：

  * **TOS (Trusted OS)** → TrustZone安全环境
  * **A_cpu-bootloader** → 实际引导CPU核心的U-Boot或UEFI
* 日志显示“integrity check success”与“Binary loaded successfully”，表示镜像有效。

✅ **状态：MB2 阶段正常进入。**

---

### **阶段 6：子系统上电与外设初始化**

```
I> Unhalting RCE
I> RCE unhalt successful
I> Unhalting DCE
I> DCE unhalt successful
[     2.574661] Camera-FW on t234-rce-safe started
```

**说明：**

* MB2 解除视频、相机、显示等子系统（RCE/DCE）的复位。
* Camera Firmware 成功启动。

✅ **状态：SoC 各模块上电成功。**

---

### **阶段 7：Bootloader / Kernel 加载（未显示完全）**

```
I> Partition name: A_cpu-bootloader
I> Size of partition: 3670016
...
```

**说明：**

* MB2 正在从 QSPI 或 NVMe/eMMC 读取 **A_cpu-bootloader** 分区（即 UEFI 或 U-Boot）。
* 后续会加载 Kernel、DTB、initrd。
* 当前日志截断在这一步，尚未进入内核输出（`Linux version ...`）。

---

## 2 整体诊断总结

| 启动阶段              | 组件                                 | 状态     | 说明              |
| ----------------- | ---------------------------------- | ------ | --------------- |
| BootROM → MB1     | SoC BootROM, Fuses, Clock, Voltage | ✅ 正常   | 无复位/错误          |
| MEM-BCT 加载        | DRAM 初始化                           | ✅ 正常   | ECC/Carveout 成功 |
| Carveout 分配       | 各功能区内存映射                           | ✅ 正常   | 分配表完整           |
| MB1 → MB2 切换      | 二级引导加载                             | ✅ 正常   | 校验成功            |
| MB2 初始化           | Watchdog、IOMMU、安全模块                | ✅ 正常   | 执行完毕            |
| 子系统上电             | DCE/RCE、Camera                     | ✅ 正常   | 摄像头固件加载         |
| CPU Bootloader 加载 | UEFI/U-Boot                        | 🔄 进行中 | 尚未进入内核          |

---

## 3 结论

这份日志显示：

* **启动链条（BootROM → MB1 → MB2）完整且无错误；**
* **内存配置和 carveout 分配均正常；**
* **启动源为 QSPI Flash（Macronix 64MB），系统正在继续加载 CPU Bootloader。**

🚀 **说明系统硬件与早期引导阶段完全正常**，若后续卡住或黑屏，则问题大概率出在：

1. **A_cpu-bootloader 分区损坏**；
2. **内核镜像或 DTB 文件异常**；
3. **rootfs 没有正确挂载或 fstab 错误**；
4. **设备树中某些外设配置不匹配（尤其是 display/power rail）**。

---

## 4 原始日志

```shell

[0000.063] I> MB1 (version: 1.4.0.4-t234-54845784-e89ea9bc)
[0000.069] I> t234-A01-0-Silicon (0x12347) Prod
[0000.073] I> Boot-mode : Coldboot
[0000.076] I> Entry timestamp: 0x00000000
[0000.080] I> last_boot_error: 0x0
[0000.083] I> BR-BCT: preprod_dev_sign: 0
[0000.087] I> rst_source: 0x0, rst_level: 0x0
[0000.091] I> Task: SE error check
[0000.094] I> Task: Bootchain select WAR set
[0000.098] I> Task: Enable SLCG
[0000.101] I> Task: CRC check
[0000.104] I> Skip FUSE records CRC check as records_integrity fuse is not burned
[0000.111] I> Task: Initialize MB2 params
[0000.115] I> MB2-params @ 0x40060000
[0000.119] I> Task: Crypto init
[0000.122] I> Task: Perform MB1 KAT tests
[0000.125] I> Task: NVRNG health check
[0000.129] I> NVRNG: Health check success
[0000.133] I> Task: MSS Bandwidth limiter settings for iGPU clients
[0000.139] I> Task: Enabling and initialization of Bandwidth limiter
[0000.145] I> No request to configure MBWT settings for any PC!
[0000.151] I> Task: Secure debug controls
[0000.154] I> Task: strap war set
[0000.157] I> Task: Initialize SOC Therm
[0000.161] I> Task: Program NV master stream id
[0000.165] I> Task: Verify boot mode
[0000.171] I> Task: Alias fuses
[0000.175] W> FUSE_ALIAS: Fuse alias on production fused part is not supported.
[0000.182] I> Task: Print SKU type
[0000.185] I> FUSE_OPT_CCPLEX_CLUSTER_DISABLE = 0x000001c0
[0000.190] I> FUSE_OPT_GPC_DISABLE = 0x00000000
[0000.194] I> FUSE_OPT_TPC_DISABLE = 0x00000008
[0000.199] I> FUSE_OPT_DLA_DISABLE = 0x00000000
[0000.203] I> FUSE_OPT_PVA_DISABLE = 0x00000000
[0000.207] I> FUSE_OPT_NVENC_DISABLE = 0x00000000
[0000.212] I> FUSE_OPT_NVDEC_DISABLE = 0x00000000
[0000.216] I> FUSE_OPT_FSI_DISABLE = 0x00000000
[0000.220] I> FUSE_OPT_EMC_DISABLE = 0x00000000
[0000.225] I> FUSE_BOOTROM_PATCH_VERSION = 0x7
[0000.229] I> FUSE_PSCROM_PATCH_VERSION = 0x7
[0000.233] I> FUSE_OPT_ADC_CAL_FUSE_REV = 0x2
[0000.237] I> FUSE_SKU_INFO_0 = 0xd2
[0000.240] I> FUSE_OPT_SAMPLE_TYPE_0 = 0x3 PS
[0000.245] I> FUSE_PACKAGE_INFO_0 = 0x2
[0000.248] I> SKU: Prod
[0000.250] I> Task: Boost clocks
[0000.253] I> Initializing NAFLL for BPMP_CPU_NIC.
[0000.258] I> BPMP NAFLL: fll_lock = 1, dvco_min_reached = 0
[0000.264] I> BPMP NAFLL lock success.
[0000.267] I> BPMP_CPU_NIC : src = 42, divisor = 0
[0000.272] I> Initializing PLLC2 for AXI_CBB.
[0000.276] I> AXI_CBB : src = 35, divisor = 0
[0000.280] I> Task: Voltage monitor
[0000.283] I> VMON: Vmon re-calibration and fine tuning done
[0000.289] I> Task: UPHY init
[0000.294] I> HSIO UPHY init done
[0000.297] W> Skipping GBE UPHY config
[0000.300] I> Task: Boot device init
[0000.304] I> Boot_device: QSPI_FLASH instance: 0
[0000.308] I> Qspi clock source : pllc_out0
[0000.312] I> QSPI Flash: Macronix 64MB
[0000.316] I> QSPI-0l initialized successfully
[0000.320] I> Task: TSC init
[0000.323] I> Task: Load membct
[0000.326] I> RAM_CODE 0x4000401
[0000.329] I> Loading MEMBCT
[0000.332] I> Slot: 0
[0000.334] I> Binary[0] block-3840 (partition size: 0x40000)
[0000.339] I> Binary name: MEM-BCT-0
[0000.343] I> Size of crypto header is 8192
[0000.347] I> Size of crypto header is 8192
[0000.350] I> strt_pg_num(3840) num_of_pgs(16) read_buf(0x40050000)
[0000.357] I> BCH of MEM-BCT-0 read from storage
[0000.361] I> BCH address is : 0x40050000
[0000.365] I> MEM-BCT-0 header integrity check is success
[0000.370] I> Binary magic in BCH component 0 is MEM0
[0000.375] I> component binary type is 0
[0000.379] I> strt_pg_num(3856) num_of_pgs(115) read_buf(0x40040000)
[0000.385] I> MEM-BCT-0 binary is read from storage
[0000.390] I> MEM-BCT-0 binary integrity check is success
[0000.395] I> Binary MEM-BCT-0 loaded successfully at 0x40040000 (0xe580)
[0000.402] I> RAM_CODE 0x4000401
[0000.407] I> RAM_CODE 0x4000401
[0000.411] I> Task: Load Page retirement list
[0000.415] I> Task: SDRAM params override
[0000.419] I> Task: Save mem-bct info
[0000.423] I> Task: Carveout allocate
[0000.426] I> RCM blob carveout will not be allocated
[0000.431] I> Update CCPLEX IST carveout from MB1-BCT
[0000.436] I> ECC region[0]: Start:0x0, End:0x0
[0000.440] I> ECC region[1]: Start:0x0, End:0x0
[0000.444] I> ECC region[2]: Start:0x0, End:0x0
[0000.448] I> ECC region[3]: Start:0x0, End:0x0
[0000.453] I> ECC region[4]: Start:0x0, End:0x0
[0000.457] I> Non-ECC region[0]: Start:0x80000000, End:0x880000000
[0000.463] I> Non-ECC region[1]: Start:0x0, End:0x0
[0000.468] I> Non-ECC region[2]: Start:0x0, End:0x0
[0000.472] I> Non-ECC region[3]: Start:0x0, End:0x0
[0000.477] I> Non-ECC region[4]: Start:0x0, End:0x0
[0000.487] I> allocated(CO:44) base:0x849800000 size:0x36800000 align: 0x100000
[0000.495] I> allocated(CO:31) base:0x840000000 size:0x8000000 align: 0x8000000
[0000.502] I> allocated(CO:43) base:0x83c000000 size:0x4000000 align: 0x200000
[0000.509] I> allocated(CO:39) base:0x839e00000 size:0x2200000 align: 0x10000
[0000.516] I> allocated(CO:20) base:0x836000000 size:0x2000000 align: 0x2000000
[0000.523] I> allocated(CO:24) base:0x834000000 size:0x2000000 align: 0x2000000
[0000.530] I> allocated(CO:28) base:0x832000000 size:0x2000000 align: 0x2000000
[0000.537] I> allocated(CO:29) base:0x830000000 size:0x2000000 align: 0x2000000
[0000.544] I> allocated(CO:22) base:0x848000000 size:0x1000000 align: 0x1000000
[0000.551] I> allocated(CO:35) base:0x838e00000 size:0x1000000 align: 0x100000
[0000.558] I> allocated(CO:41) base:0x82f000000 size:0x1000000 align: 0x100000
[0000.565] I> allocated(CO:02) base:0x849000000 size:0x800000 align: 0x800000
[0000.572] I> allocated(CO:03) base:0x838000000 size:0x800000 align: 0x800000
[0000.579] I> allocated(CO:06) base:0x82e800000 size:0x800000 align: 0x800000
[0000.586] I> allocated(CO:56) base:0x82e000000 size:0x800000 align: 0x200000
[0000.593] I> allocated(CO:07) base:0x838800000 size:0x400000 align: 0x400000
[0000.600] I> allocated(CO:33) base:0x82dc00000 size:0x400000 align: 0x200000
[0000.607] I> allocated(CO:19) base:0x82d980000 size:0x280000 align: 0x10000
[0000.614] I> allocated(CO:23) base:0x838c00000 size:0x200000 align: 0x200000
[0000.621] I> allocated(CO:01) base:0x82d800000 size:0x100000 align: 0x100000
[0000.628] I> allocated(CO:05) base:0x82d700000 size:0x100000 align: 0x100000
[0000.635] I> allocated(CO:08) base:0x82d600000 size:0x100000 align: 0x100000
[0000.642] I> allocated(CO:09) base:0x82d500000 size:0x100000 align: 0x100000
[0000.649] I> allocated(CO:12) base:0x82d400000 size:0x100000 align: 0x100000
[0000.656] I> allocated(CO:15) base:0x82d300000 size:0x100000 align: 0x100000
[0000.663] I> allocated(CO:17) base:0x82d200000 size:0x100000 align: 0x100000
[0000.670] I> allocated(CO:27) base:0x82d100000 size:0x100000 align: 0x100000
[0000.676] I> allocated(CO:42) base:0x82d000000 size:0x100000 align: 0x100000
[0000.683] I> allocated(CO:54) base:0x82d900000 size:0x80000 align: 0x80000
[0000.690] I> allocated(CO:34) base:0x82cff0000 size:0x10000 align: 0x10000
[0000.697] I> allocated(CO:72) base:0x82cdf0000 size:0x200000 align: 0x10000
[0000.704] I> allocated(CO:47) base:0x82c800000 size:0x400000 align: 0x200000
[0000.711] I> allocated(CO:50) base:0x82c600000 size:0x200000 align: 0x100000
[0000.718] I> allocated(CO:52) base:0x82cdc0000 size:0x30000 align: 0x10000
[0000.724] I> allocated(CO:48) base:0x82cda0000 size:0x20000 align: 0x10000
[0000.731] I> allocated(CO:69) base:0x82cd80000 size:0x20000 align: 0x10000
[0000.738] I> allocated(CO:49) base:0x82cd70000 size:0x10000 align: 0x10000
[0000.745] I> NSDRAM base: 0x80000000, end: 0x82cdf0000, size: 0x7acdf0000
[0000.751] I> Task: Thermal check
[0000.754] I> Using min_chip_limit as min_tmon_limit
[0000.759] I> Using max_chip_limit as max_tmon_limit
[0000.764] I> BCT max_tmon_limit = 105
[0000.767] I> BCT min_tmon_limit = -28
[0000.771] I> BCT max_tmon_limit = 105
[0000.774] I> BCT min_tmon_limit = -28
[0000.778] I> SKU specific max_chip_limit = 105
[0000.782] I> SKU specific min_chip_limit = -28
[0000.786] I> BCT max_chip_limit = 105
[0000.790] I> BCT min_chip_limit = -28
[0000.793] I> enable_soctherm_polling = 0
[0000.797] I> max temp read = 33
[0000.800] I> min temp read = 33
[0000.803] I> Enabling thermtrip
[0000.806] I> Task: Update FSI SCR with thermal fuse data
[0000.811] I> Task: Enable WDT 5th expiry
[0000.815] I> Task: I2C register
[0000.818] I> Task: Set I2C bus freq
[0000.821] I> Task: Resetis success
[0001.741] I> Binary magic in BCH component 0 is MB2R
[0001.746] I> component binary type is 14
[0001.749] I> Size of crypto header is 8192
[0001.753] I> strt_pg_num(24592) num_of_pgs(224) read_buf(0xa00d7d10)
[0001.761] I> MB2_RF binary is read from storage
[0001.765] I> MB2_RF binary integrity check is success
[0001.770] I> Binary MB2_RF loaded successfully at 0xa00d7d10 (0x1bf60)
[0001.777] I> Task: Save fuse alias data to SC7 ctx
[0001.781] I> Task: Save PMIC data to SC7 ctx
[0001.785] I> Task: Save Pinmux data to SC7 ctx
[0001.790] I> Task: Save Pad Voltage data to SC7 ctx
[0001.794] I> Task: Save controller prod data to SC7 ctx
[0001.799] I> Task: Save prod cfg data to SC7 ctx
[0001.804] I> Task: Save I2C bus freq data to SC7 ctx
[0001.809] I> Task: Save SOCTherm data to SC7 ctx
[0001.813] I> Task: Save FMON data to SC7 ctx
[0001.817] I> Task: Save VMON data to SC7 ctx
[0001.821] I> Task: Save TZDRAM data to SC7 ctx
[0001.826] I> Task: Save GPIO int data to SC7 ctx
[0001.830] I> Task: Save clock data to SC7 ctx
[0001.834] I> Task: Save debug data to SC7 ctx
[0001.839] I> Task: Save MBWT data to SC7 ctx
[0001.847] I> SC7 context save done
[0001.850] I> Task: Load MB2/Applet/FSKP
[0001.854] I> Loading MB2
[0001.856] I> Slot: 0
[0001.858] I> Binary[6] block-8448 (partition size: 0x80000)
[0001.863] I> Binary name: MB2
[0001.866] I> Size of crypto header is 8192
[0001.870] I> Size of crypto header is 8192
[0001.874] I> strt_pg_num(8448) num_of_pgs(16) read_buf(0x8007e000)
[0001.880] I> BCH of MB2 read from storage
[0001.884] I> BCH address is : 0x8007e000
[0001.888] I> MB2 header integrity check is success
[0001.893] I> Binary magic in BCH component 0 is MB2B
[0001.897] I> component binary type is 6
[0001.901] I> Size of crypto header is 8192
[0001.905] I> strt_pg_num(8464) num_of_pgs(846) read_buf(0x80000000)
[0001.916] I> MB2 binary is read from storage
[0001.921] I> MB2 binary integrity check is success
[0001.925] I> Binary MB2 loaded successfully at 0x80000000 (0x69a70)
[0001.932] I> Task: Map CCPLEX SHARED carveout
[0001.936] I> Task: Prepare MB2 params
[0001.940] I> Task: Dram ecc test
[0001.943] I> Task: Misc NV security settings
[0001.947] I> NVDEC sticky bits programming done
[0001.951] I> Successfully powergated NVDEC
[0001.955] I> Task: Disable/Reload WDT
[0001.959] I> Task: Program misc carveouts
[0001.963] I> Program IPC carveouts
[0001.966] I> Task: Disable SCPM/POD reset
[0001.970] I> SLCG Global override status := 0x0
[0001.974] I> MB1: MSS reconfig completed
I> MB2 (version: 0.0.0.0-t234-54845784-0fbce5b9)
I> t234-A01-0-Silicon (0x12347)
I> Boot-mode : Coldboot
I> Emulation:
I> Entry timestamp: 0x001e9b76
I> Regular heap: [base:0x40040000, size:0x10000]
I> DMA heap: [base:0x82e000000, size:0x800000]
I> Task: SE error check
I> Task: Crypto init
I> Task: MB2 Params integrity check
I> Task: Enable CCPLEX WDT 5th expiry
I> Task: ARI update carveout TZDRAM
I> Task: Configure OEM set LA/PTSA values
I> Task: Check MC errors
I> Task: SMMU external bypass disable
I> Tas
      initialized reset
initialized uphy_early
initialized emc_early
initialized pm
465 clocks registered
initialized clk_mach
initialized clk_cal_early
initialized clk_mach_early_config
initialized io_dpd
initialized soctherm
initialized regime
initialized i2c
vrmon_dt_init: vrmon node not found
vrmon_chk_boot_state: found 0 rail monitors
initialized vrmon
initialized regulator
??sc
I> Received ACK from psc
I> Task: Unhalt FSI
I> FSI unhalt skipped
I> Task: Unhalt AUXPs
I> Unhalting RCE
I> RCE unhalt successful
I> Unhalting DCE
I> DCE unhalt successful
I> APE unhalt skipped
I> Task: Load HV/CPUBL
I> Task: Load TOS
I> Task: Trigger l??initialized avfs_clk_platform
initialized powergate
??[     2.574661] Camera-FW on t234-rce-safe started
TCU early console enabled.
??oad??initialized dvs
initialized clk_mach_config
initialized suspend
initialized strap
initialized mce_dbell
?? TSEC leyblob
I> Sending opcode 0x53535452 to psc
??
  ??I> Sent opcode to psc
I> Task: Load and authenticate registered FWs
I> Partition name: A_cpu-bootloader
I> Size of partition: 3670016
I> Binary@ device:3/0 block-24832 (partition size: 0x380000), name: A_cpu-bootloader
??DCE Started
??I> strt_pg_num(24832) num_of_pgs(16) read_buf(0x40067ab0)
I> cpubl : oem authentication of header done
I> strt_pg_num(24848) num_of_pgs(1) read_buf(0x82e143f98)
I> strt_pg_num(24848) num_of_pgs(8) read_buf(0x82e143f98)
??DCE_R5_Init
??I> cpubl : meta-blob integrity check is success.
I> str??initialized emc
initialized emc_mrq
??t_pg_num(24856) num_of_pgs(512) read_buf(0x82??initialized clk_cal
initialized uphy_dt
initialized uphy_mrq
HSIO UPHY reset has been de-asserted 0x0
??e00??initialized uphy
??3f80)
??MPU enabled
DCE_SW??initialized pg_late
initialized pg_mrq_init
swdtimer_init: reg polling start w period 47 ms
initialized swdtimer
initialized hwwdt_late
initialized bwmgr
initialized thermal_host_trip
initialized thermal_mrq
initialized oc_mrq
initialized reset_mrq
initialized mail_mrq
initialized fmon_mrq
initialized clk_mrq
initialized avfs_mrq
initialized i2c_mrq
initialized tag_mrq
initialized bwmgr_mrq
initialized console_mrq
missing prod DT calibration data for 199 fmons
initialized clk_sync_fmon_post
??_Init
??I> strt_pg_num(25368) num_of_pgs(512) read_buf(0x82e043f8??initialized clk_cal_late
initialized noc_late
initialized cvc
??0)
I> cpubl : will be decompre??initialized avfs_clk_mach_post
initialized avfs_clk_platform_post
initialized cvc_late
initialized rm
initialized console_late
handling unreferenced clks
enable can1_core
enable can1_host
enable can2_core
enable can2_host
enable pwm3
enable mss_encrypt
enable maud
enable pllg_ref
enable dsi_core
enable aza_2xbit
enable pllc4_muxed
enable sdmmc4_axicif
enable xusb_ss
enable xusb_fs
enable xusb_falcon
enable xusb_core_mux
enable dsi_lp
enable sdmmc_legacy_tm
initialized clk_mach_post
??[     2.772026] Camer??initialized pg_post
initialized regulator_post
initialized profile
initialized mrq
initialized patrol_scrubber
initialized cactmon
initialized extras_post
bpmp: init complete
??a-FW on t234-rce-safe ready SHA1=e2238c99 (crt 12.422 ms, total boot 210.860 ms)
??ssed at 0x82c800000
I> version 1 Bin 1 BCheckSum 0 content_size 0 Content ChkSum 1 reserved_00  0
I> Reserved10 0 BlockMaxSize 5 Reserved11 0
I> strt_pg_num(25880) num_of_pgs(512) read_buf(0x82e083f80)
I> strt_pg_num(26392) num_of_pgs(512) read_buf(0x82e0c3f80)
I> strt_pg_num(26904) num_of_pgs(512) read_buf(0x82e103f80)
I> strt_pg_num(27416) num_of_pgs(512) read_buf(0x82e003f80)
I> strt_pg_num(27928) num_of_pgs(512) read_buf(0x82e043f80)
I> strt_pg_num(28440) num_of_pgs(512) read_buf(0x82e083f80)
I> strt_pg_num(28952) num_of_pgs(512) read_buf(0x82e0c3f80)
I> strt_pg_num(29464) num_of_pgs(512) read_buf(0x82e103f80)
I> strt_pg_num(29976) num_of_pgs(512) read_buf(0x82e003f80)
??Admin Task Ini



                ??I/TC: Reserved shared memory is disabled
I/TC: Dynamic shared memory is enabled
I/TC: Normal World virtualization support is disabled
I/TC: Asynchronous notifications are disabled
I/TC: WARNING: Test UEFI variable auth key is being used !
I/TC: WARNING: UEFI variable protection is not fully enabled !
??



L4TLauncher: Attempting Direct Boot
EFI stub: Booting Linux Kernel...
EFI stub: Using DTB from configuration table
EFI stub: Loaded initrd from LINUX_EFI_INITRD_MEDIA_GUID device path
EFI stub: Exiting boot services...
??debugfs initialized
??I/TC: Reserved shared memory is disabled
I/TC: Dynamic shared memory is enabled
I/TC: Normal World virtualization support is disabled
I/TC: Asynchronous notifications are disabled
??[    0.000000] Booting Linux on physical CPU 0x0000000000 [0x410fd421]
[    0.000000] Linux version 5.15.148-tegra (root@ieit) (aarch64-buildroot-linux-gnu-gcc.br_real (Buildroot 2022.08) 11.3.0, GNU ld (GNU Binutils) 2.38) #2 SMP PREEMPT Thu Sep 4 10:18:49 CST 2025 ()
[    0.000000] Machine model: NVIDIA Jetson AGX Orin Developer Kit
[    0.000000] efi: EFI v2.70 by EDK II
[    0.000000] efi: RTPROP=0x829a1e698 TPMFinalLog=0x825e10000 SMBIOS=0xffff0000 SMBIOS 3.0=0x829620000 MEMATTR=0x825329018 ESRT=0x824f37f98 TPMEventLog=0x824c9a018 RNG=0x824c95018 MEMRESERVE=0x824c9cc18
[    0.000000] random: crng init done
[    0.000000] secureboot: Secure boot disabled
[    0.000000] esrt: Reserving ESRT space from 0x0000000824f37f98 to 0x0000000824f37fd0.
[    0.000000] Reserved memory: created CMA memory pool at 0x0000000810000000, size 256 MiB
[    0.000000] OF: reserved mem: initialized node linux,cma, compatible id shared-dma-pool
[    0.000000] NUMA: No NUMA configuration found
[    0.000000] NUMA: Faking a node at [mem 0x0000000080000000-0x0000000833ffffff]
[    0.000000] NUMA: NODE_DATA [mem 0x826d4a800-0x826d4cfff]
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000080000000-0x00000000ffffffff]
[    0.000000]   DMA32    empty
[    0.000000]   Normal   [mem 0x0000000100000000-0x0000000833ffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000080000000-0x00000000fffdffff]
[    0.000000]   node   0: [mem 0x00000000fffe0000-0x00000000ffffffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000082283ffff]
[    0.000000]   node   0: [mem 0x0000000822840000-0x000000082496ffff]
[    0.000000]   node   0: [mem 0x0000000824970000-0x00000008250fffff]
[    0.000000]   node   0: [mem 0x0000000825100000-0x000000082510ffff]
[    0.000000]   node   0: [mem 0x0000000825110000-0x0000000825e0ffff]
[    0.000000]   node   0: [mem 0x0000000825e10000-0x0000000825e1ffff]
[    0.000000]   node   0: [mem 0x0000000825e20000-0x0000000827adffff]
[    0.000000] ??WARNING: clock_disable: clk_power_ungate on gated domain 35 for gpusysclk
??  node   0: [mem 0x0000000827ae0000-0x0000000829a1ffff]
[    0.000000]   node   0: [mem 0x0000000829a20000-0x000000082c5fffff]
[    0.000000]   node   0: [mem 0x000000082c600000-0x000000082c7fffff]
[    0.000000]   node   0: [mem 0x000000082c800000-0x000000082cd6ffff]
[    0.000000]   node   0: [mem 0x0000000832000000-0x0000000833ffffff]
??WARNING: clock_disable: clk_power_ungate on gated domain 35 for gpc1clk
??[    0.000000] Initmem setup node 0 [mem 0x0000000080000000-0x0000000833ffffff]
[    0.000000] On node 0, zone Normal: 21136 pages in unavailable ranges
[    0.000000] On node 0, zone Normal: 16384 pages in unavailable ranges
[    0.000000] psci: probing for conduit method from DT.
[    0.000000] psci: PSCIv1.1 detected in firmware.
??WARNING: clock_disable: clk_power_ungate on gated domain 35 for gpc0clk
??[    0.000000] psci: Using standard PSCI v0.2 function IDs
[    0.000000] psci: Trusted OS migration not required
[    0.000000] psci: SMC Calling Convention v1.2
[    0.000000] percpu: Embedded 29 pages/cpu s80408 r8192 d30184 u118784
[    0.000000] Detected PIPT I-cache on CPU0
[    0.000000] CPU features: detected: Address authentication (architected algorithm)
[    0.000000] CPU features: detected: GIC system register CPU interface??WARNING: clock_disable: clk_power_ungate on gated domain 34 for dla1_core
??
[    0.000000] CPU features: detected: Virtualization Host Extensions
[    0.000000] CPU features: detected: Hardware dirty bit management
[    0.000000] CPU features: detected: Spectre-v4
[    0.000000] CPU features: detected: Spectre-BHB
[    0.000000] CPU features: kernel page table isolation forced ON by KASLR
??WARNING: clock_disable: clk_power_ungate on gated domain 34 for nafll_dla1_core
??[    0.000000] CPU features: detected: Kernel page table isolation (KPTI)
[    0.000000] alternatives: patching kernel code
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 7929968
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: usbcore.autosuspend=-1 root=/dev/mmcblk0p1 rw rootwait rootfstype=ext4 mminit_loglevel=4 cons??WARNING: clock_disable: clk_power_ungate on gated domain 34 for dla1_falcon
??ole=ttyTCU0,115200 console=ttyAMA0,115200 firmware_class.path=/etc/firmware fbcon=map:0 video=efifb:off console=tty0 bl_prof_dataptr=2031616@0x82C610000 bl_prof_ro_ptr=65536@0x82C600000
[    0.000000] Unknown kernel command line parameters "bl_prof_dataptr=2031616@0x82C610000 bl_pr??WARNING: clock_disable: clk_power_ungate on gated domain 34 for nafll_dla1_falcon
??of_ro_ptr=65536@0x82C600000", will be passed to user space.
[    0.000000] Dentry cache hash table entries: 4194304 (order: 13, 33554432 bytes, linear)
[    0.000000] Inode-cache hash table entries: 2097152 (order: 12, 16777216 bytes, linear)
[    0.000000] mem au??WARNING: clock_disable: clk_power_ungate on gated domain 34 for dla0_core
??to-init: stack:off, heap alloc:off, heap free:off
[    0.000000] software IO TLB: mapped [mem 0x00000000fbfe0000-0x00000000fffe0000] (64MB)
[    0.000000] Memory: 31117164K/32224704K available (19328K kernel code, 4062K rwdata, 10048K rodata, 7680K init, 532K bss, 845396K reserved, 2621??WARNING: clock_disable: clk_power_ungate on gated domain 34 for nafll_dla0_core
??44K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
[    0.000000] trace event string verifier disabled
[    0.000000] rcu: Preemptible hierarchical RCU implementation.
[    0.000000] rcu:     RCU event tracing is enabled.
[  ??WARNING: clock_disable: clk_power_ungate on gated domain 34 for dla0_falcon
??  0.000000] rcu:      RCU restricting CPUs from NR_CPUS=256 to nr_cpu_ids=8.
[    0.000000]  Trampoline variant of Tasks RCU enabled.
[    0.000000]  Rude variant of Tasks RCU enabled.
[    0.000000]  Tracing variant of Tasks RCU enabled.
[    0.000000] rcu: RCU calculate??WARNING: clock_disable: clk_power_ungate on gated domain 34 for nafll_dla0_falcon
??d value of scheduler-enlistment delay is 25 jiffies.
[    0.000000] rcu: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=8
[    0.000000] NR_IRQS: 64, nr_irqs: 64, preallocated irqs: 0
[    0.000000] GICv3: GIC: Using split EOI/Deactivate mode
[    0.000000] GICv3: 960 SPIs implemented
[    0.000000] GICv3: 0 Extended SPIs implemented
[    0.000000] GICv3: Distributor has no Range Selector support
[    0.000000] Root IRQ handler: gic_handle_irq
[    0.000000] GICv3: 16 PPIs implemented
[    0.000000] GICv3: CPU0: found redistributor 0 region 0:0x000000000f440000
[    0.000000] arch_timer: cp15 timer(s) running at 31.25MHz (phys).
[    0.000000] clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0xe6a171046, max_idle_ns: 881590405314 ns
[    0.000001] sched_clock: 56 bits at 31MHz, resolution 32ns, wraps every 4398046511088ns
[    0.000381] Console: colour dummy device 80x25
[    0.000389] printk: console [tty0] enabled
[    0.000454] Calibrating delay loop (skipped), value calculated using timer frequency.. 62.50 BogoMIPS (lpj=125000)
[    0.000462] pid_max: default: 32768 minimum: 301
[    0.000495] LSM: Security Framework initializing
[    0.000518] Yama: becoming mindful.
[    0.000534] SELinux:  Initializing.
[    0.000652] Mount-cache hash table entries: 65536 (order: 7, 524288 bytes, linear)
[    0.000698] Mountpoint-cache hash table entries: 65536 (order: 7, 524288 bytes, linear)
[    0.001993] rcu: Hierarchical SRCU implementation.
[    0.004873] Tegra Revision: A01 SKU: 210 CPU Process: 0 SoC Process: 0
[    0.005183] Remapping and enabling EFI services.
[    0.005977] smp: Bringing up secondary CPUs ...
[    0.006476] Detected PIPT I-cache on CPU1
[    0.006522] GICv3: CPU1: found redistributor 100 region 0:0x000000000f460000
[    0.006561] CPU1: Booted secondary processor 0x0000000100 [0x410fd421]
[    0.007018] Detected PIPT I-cache on CPU2
[    0.007030] GICv3: CPU2: found redistributor 200 region 0:0x000000000f480000
[    0.007043] CPU2: Booted secondary processor 0x0000000200 [0x410fd421]
[    0.007436] Detected PIPT I-cache on CPU3
[    0.007446] GICv3: CPU3: found redistributor 300 region 0:0x000000000f4a0000
[    0.007458] CPU3: Booted secondary pro 0.248010] arm-smmu 8000000.iommu:     stream matching with 128 register groups
[    0.248016] arm-smmu 8000000.iommu:  128 context banks (0 stage-2 only)
[    0.248042] arm-smmu 8000000.iommu:  Supported page sizes: 0x61311000
[    0.248048] arm-smmu 8000000.iommu:  Stage-1: 48-bit VA -> 48-bit IPA
[    0.248052] arm-smmu 8000000.iommu:  Stage-2: 48-bit IPA -> 48-bit PA
[    0.249020] arm-smmu 10000000.iommu: probing hardware configuration...
[    0.249024] arm-smmu 10000000.iommu: SMMUv2 with:
[    0.249027] arm-smmu 10000000.iommu:         stage 1 translation
[    0.249027] arm-smmu 10000000.iommu:         stage 2 translation
[    0.249028] arm-smmu 10000000.iommu:         nested translation
[    0.249030] arm-smmu 10000000.iommu:         stream matching with 128 register groups
[    0.249032] arm-smmu 10000000.iommu:         128 context banks (0 stage-2 only)
[    0.249038] arm-smmu 10000000.iommu:         Supported page sizes: 0x61311000
[    0.249039] arm-smmu 10000000.iommu:         Stage-1: 48-bit VA -> 48-bit IPA
[    0.249040] arm-smmu 10000000.iommu:         Stage-2: 48-bit IPA -> 48-bit PA
[    0.249369] arm-smmu 12000000.iommu: probing hardware configuration...
[    0.249373] arm-smmu 12000000.iommu: SMMUv2 with:
[    0.249375] arm-smmu 12000000.iommu:         stage 1 translation
[    0.249376] arm-smmu 12000000.iommu:         stage 2 translation
[    0.249376] arm-smmu 12000000.iommu:         nested translation
[    0.249379] arm-smmu 12000000.iommu:         stream matching with 128 register groups
[    0.249380] arm-smmu 12000000.iommu:         128 context banks (0 stage-2 only)
[    0.249386] arm-smmu 12000000.iommu:         Supported page sizes: 0x61311000
[    0.249387] arm-smmu 12000000.iommu:         Stage-1: 48-bit VA -> 48-bit IPA
[    0.249387] arm-smmu 12000000.iommu:         Stage-2: 48-bit IPA -> 48-bit PA
[    0.257803] loop: module loaded
[    0.258925] megasas: 07.717.02.00-rc1
[    0.263170] tun: Universal TUN/TAP device driver, 1.6
[    0.263749] thunder_xcv, ver 1.0
[    0.263776] thunder_bgx, ver 1.0
[    0.263795] nicpf, ver 1.0
[    0.264691] hclge is initializing
[    0.264718] hns3: Hisilicon Ethernet Network Driver for Hip08 Family - version
[    0.264726] hns3: Copyright (c) 2017 Huawei Corporation.
[    0.264763] e1000: Intel(R) PRO/1000 Network Driver
[    0.264769] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    0.264788] e1000e: Intel(R) PRO/1000 Network Driver
[    0.264791] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
[    0.264818] igbvf: Intel(R) Gigabit Virtual Function Network Driver
[    0.264823] igbvf: Copyright (c) 2009 - 2012 Intel Corporation.
[    0.265029] sky2: driver version 1.30
[    0.265625] hso: drivers/net/usb/hso.c: Option Wireless
[    0.265712] usbcore: registered new interface driver hso
[    0.265805] VFIO - User Level meta-driver version: 0.3
[    0.267363] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    0.267371] ehci-pci: EHCI PCI platform driver
[    0.267399] ehci-platform: EHCI generic platform driver
[    0.267480] ehci-orion: EHCI orion driver
[    0.267552] ehci-exynos: EHCI Exynos driver
[    0.267611] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    0.267632] ohci-pci: OHCI PCI platform driver
[    0.267655] ohci-platform: OHCI generic platform driver
[    0.267726] ohci-exynos: OHCI Exynos driver
[    0.268114] usbcore: registered new interface driver cdc_wdm
[    0.268145] usbcore: registered new interface driver usb-storage
[    0.269974] i2c_dev: i2c /dev entries driver
[    0.271301] pps pps0: new PPS source ktimer
[    0.271310] pps pps0: ktimer PPS source registered
[    0.271320] pps_ldisc: PPS line discipline registered
[    0.273440] device-mapper: ioctl: 4.45.0-ioctl (2021-03-22) initialised: dm-devel@redhat.com
[    0.275545] sdhci: Secure Digital Host Controller Interface driver
[    0.275549] sdhci: Copyright(c) Pierre Ossman
[    0.276015] Synopsys Designware Multimedia Card Interface Driver
[    0.276644] sdhci-
                     [    7.152534] tegra_bpmp_thermal: module verification failed: signature and/or required key missing - tainting kernel
[    7.178816] Found dev node: /dev/mmcblk0p1
[   11.182596] EXT4-fs (mmcblk0p1): 2 orphan inodes deleted
[   11.182608] EXT4-fs (mmcblk0p1): recovery complete
[   11.272273] EXT4-fs (mmcblk0p1): mounted filesystem with ordered data mode. Opts: (null). Quota mode: none.
[   11.278391] Rootfs mounted over mmcblk0p1
[   11.289618] Switching from initrd to actual rootfs
[   11.401339] systemd[1]: System time before build time, advancing clock.
[   11.463119] NET: Registered PF_INET6 protocol family
[   11.464309] Segment Routing with IPv6
[   11.464314] In-situ OAM (IOAM) with IPv6
[   11.487980] systemd[1]: systemd 249.11-0ubuntu3.16 running in system mode (+PAM +AUDIT +SELINUX +APPARMOR +IMA +SMACK +SECCOMP +GCRYPT +GNUTLS +OPENSSL +ACL +BLKID +CURL +ELFUTILS +FIDO2 +IDN2 -IDN +IPTC +KMOD +LIBCRYPTSETUP +LIBFDISK +PCRE2 -PWQUALITY -P11KIT -QRENCODE +BZIP2 +LZ4 +XZ +ZLIB +ZSTD -XKBCOMMON +UTMP +SYSVINIT default-hierarchy=unified)
[   11.488310] systemd[1]: Detected architecture arm64.
[   11.531767] systemd[1]: Hostname set to <eis860>.
[   11.543843] systemd[1]: Using hardware watchdog 'NVIDIA Tegra186 WDT', version 0, device /dev/watchdog
[   11.543860] systemd[1]: Set hardware watchdog to 2min.
[   11.753793] systemd[1]: Configuration file /run/systemd/system/netplan-ovs-cleanup.service is marked world-inaccessible. This has no effect as configuration data is accessible via APIs without restrictions. Proceeding anyway.
[   11.778576] systemd[1]: /lib/systemd/system/snapd.service:23: Unknown key name 'RestartMode' in section 'Service', ignoring.
[   11.789991] systemd[1]: /etc/systemd/system/nvs-service.service:41: Standard output type syslog is obsolete, automatically updating to journal. Please update your unit file, and consider removing the setting altogether.
[   11.797404] systemd[1]: /etc/systemd/system/nvargus-daemon.service:42: Standard output type syslog is obsolete, automatically updating to journal. Please update your unit file, and consider removing the setting altogether.
[   11.849013] systemd[1]: Queued start job for default target Graphical Interface.
[   11.850340] systemd[1]: Created slice Slice /system/modprobe.
[   11.851864] systemd[1]: Created slice Slice /system/serial-getty.
[   11.875804] systemd[1]: Created slice Slice /system/systemd-fsck.
[   11.884313] systemd[1]: Created slice User and Session Slice.
[   11.892240] systemd[1]: Started ntp-systemd-netif.path.
[   11.899647] systemd[1]: Started Forward Password Requests to Wall Directory Watch.
[   11.909677] systemd[1]: Set up automount Arbitrary Executable File Formats File System Automount Point.
[   11.910775] systemd[1]: Reached target User and Group Name Lookups.
[   11.911754] systemd[1]: Reached target Slice Units.
[   11.937360] systemd[1]: Reached target Mounting snaps.
[   11.938423] systemd[1]: Reached target Mounted snaps.
[   11.939415] systemd[1]: Reached target Swaps.
[   11.958446] systemd[1]: Reached target System Time Set.
[   11.959932] systemd[1]: Reached target Local Verity Protected Volumes.
[   11.975224] systemd[1]: Listening on Device-mapper event daemon FIFOs.
[   11.976389] systemd[1]: Listening on LVM2 poll daemon socket.
[   11.998317] systemd[1]: Listening on RPCbind Server Activation Socket.
[   11.999499] systemd[1]: Listening on Syslog Socket.
[   12.014134] systemd[1]: Listening on fsck to fsckd communication Socket.
[   12.015169] systemd[1]: Listening on initctl Compatibility Named Pipe.
[   12.016326] systemd[1]: Listening on Journal Audit Socket.
[   12.039595] systemd[1]: Listening on Journal Socket (/dev/log).
[   12.047730] systemd[1]: Listening on Journal Socket.
[   12.054910] systemd[1]: Listening on udev Control Socket.
[   12.055960] systemd[1]: Listening on udev Kernel Socket.
[   12.070513] systemd[1]: Mounting Huge Pages File System...
[   12.072451] systemd[1]: Mounting POSIX Message Queue File System...
[   12.088930] systemd[1]: Mounting Kernel Debug File System...
[   12.090873] systemd[1]: Mounting Kernel Trace File System...
[   12.098970] systemd[1]: Starting Journal Service...
[   12.112477] systemd[1]: Finished Availability of block devices.
[   12.114611] systemd[1]: Starting Set the console keyboard layout...
[   12.116451] systemd[1]: Starting Create List of Static Device Nodes...
[   12.139843] systemd[1]: Starting Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling...
[   12.153322] systemd[1]: Starting Load Kernel Module configfs...
[   12.155206] systemd[1]: Starting Load Kernel Module drm...
[   12.157088] systemd[1]: Starting Load Kernel Module efi_pstore...
[   12.178939] systemd[1]: Starting Load Kernel Module fuse...
[   12.180760] systemd[1]: Starting NVIDIA specific first-boot udev script...
[   12.196986] systemd[1]: Started Nameserver information manager.
[   12.197844] systemd[1]: Reached target Preparation for Network.
[   12.198661] systemd[1]: Condition check resulted in File System Check on Root Device being skipped.
[   12.212161] systemd[1]: Starting Load Kernel Modules...
[   12.214859] fuse: init (API version 7.34)
[   12.221719] nvsciipc: loading out-of-tree module taints kernel.
[   12.225664] nvsciipc: loaded module
[   12.243407] nvmap_heap_init: nvmap_heap_init: created heap block cache
[   12.243952] nvmap_co_device_init: vpr :dma coherent mem declare 0x0000000849800000,914358272
[   12.243959] tegra-carveouts tegra-carveouts: assigned reserved memory node vpr-carveout
[   12.243969] nvmap_page_pool_init: Total RAM pages: 7850619
[   12.243970] nvmap_page_pool_init: nvmap page pool size: 981327 pages (3833 MB)
[   12.244036] nvmap_background_zero_thread: PP zeroing thread starting.
[   12.244051] nvmap_heap_create: created heap vpr base 0x0000000849800000 size (892928KiB)
[   12.244080] nvmap_heap_create: fsi :dma coherent mem declare 0x000000082f000000,16777216
[   12.244083] nvmap_heap_create: created heap fsi base 0x000000082f000000 size (16384KiB)
[   12.248521] systemd[1]: Starting Remount Root and Kernel File Systems...
[   12.255574] EXT4-fs (mmcblk0p1): re-mounted. Opts: (null). Quota mode: none.
[   12.273315] tegra-host1x 13e00000.host1x: Adding to iommu group 5
[   12.274460] host1x-context host1x-ctx.0: Adding to iommu group 6
[   12.274581] host1x-context host1x-ctx.1: Adding to iommu group 7
[   12.274682] host1x-context host1x-ctx.2: Adding to iommu group 8
[   12.274785] host1x-context host1x-ctx.3: Adding to iommu group 9
[   12.274886] host1x-context host1x-ctx.4: Adding to iommu group 10
[   12.274983] host1x-context host1x-ctx.5: Adding to iommu group 11
[   12.275076] host1x-context host1x-ctx.6: Adding to iommu group 12
[   12.275170] host1x-context host1x-ctx.7: Adding to iommu group 13
[   12.275269] host1x-context host1x-ctx.8: Adding to iommu group 14
[   12.275365] host1x-context host1x-ctx.9: Adding to iommu group 15
[   12.275459] host1x-context host1x-ctx.10: Adding to iommu group 16
[   12.275556] host1x-context host1x-ctx.11: Adding to iommu group 17
[   12.275652] host1x-context host1x-ctx.12: Adding to iommu group 18
[   12.275745] host1x-context host1x-ctx.13: Adding to iommu group 19
[   12.275842] host1x-context host1x-ctx.14: Adding to iommu group 20
[   12.275941] host1x-context host1x-ctx.15: Adding to iommu group 21
[   12.323935] systemd[1]: Starting Coldplug All udev Devices...
[   12.384779] systemd[1]: Started Journal Service.
[   12.483891] nvgpu: 17000000.gpu          nvgpu_nvhost_syncpt_init:122  [INFO]  syncpt_unit_base 60000000 syncpt_unit_size 4000000 size 10000
[   12.483891]
[   12.530779] systemd-journald[252]: Received client request to flush runtime journal.
??I/TC: WARNING (insecure configuration): Failed to get monotonic counter for REE FS, using 0
I/TC: WARNING (insecure configuration): Failed to commit dirh counter 5282
??TCU debug prints will be routed to traces.
??[   13.244012] tegra-ivc-bus bc00000.rtcpu:ivc-bus:echo@0: ivc channel driver missing
[   13.244013] tegra-ivc-bus bc00000.rtcpu:ivc-bus:dbg@1: ivc channel driver missing
[   13.244014] tegra-ivc-bus bc00000.rtcpu:ivc-bus:dbg@2: ivc channel driver missing
[   13.244016] tegra-ivc-bus bc00000.rtcpu:ivc-bus:ivccontrol@3: ivc channel driver missing
[   13.244017] tegra-ivc-bus bc00000.rtcpu:ivc-bus:ivccapture@4: ivc channel driver missing
[   13.244018] tegra-ivc-bus bc00000.rtcpu:ivc-bus:diag@5: ivc channel driver missing
[   13.244028] tegra-hsp b950000.tegra-hsp: Try increasing MBOX_TX_QUEUE_LEN
[   13.244035] tegra-hsp b950000.tegra-hsp: Try increasing MBOX_TX_QUEUE_LEN
[   13.244038] tegra-hsp b950000.tegra-hsp: Try increasing MBOX_TX_QUEUE_LEN
[   13.244041] tegra-hsp b950000.tegra-hsp: Try increasing MBOX_TX_QUEUE_LEN
[   13.244049] tegra-hsp b950000.tegra-hsp: Try increasing MBOX_TX_QUEUE_LEN
[   13.244051] tegra-hsp b950000.tegra-hsp: Try increasing MBOX_TX_QUEUE_LEN
[   13.244052] tegra-hsp b950000.tegra-hsp: Try increasing MBOX_TX_QUEUE_LEN
[   13.244054] tegra-hsp b950000.tegra-hsp: Try increasing MBOX_TX_QUEUE_LEN
[   13.460910] (NULL device *): fops function table already registered
??Starting RmBootstrap
Registered event_type:[0] for dce_core_ipc_type:[1]
Registered event_type:[1] for dce_core_ipc_type:[3]
dce_ipc State Initialized
RmBootstrap completed successfully
??[   13.597035] tegra194-pcie 14180000.pcie: supply vddio-pex-ctl not found, using dummy regulator
[   14.010097] usb 2-3: Enable of device-initiated U1 failed.
[   14.011460] usb 2-3: Enable of device-initiated U2 failed.
[   16.719746] using random self ethernet address
[   16.719753] using random host ethernet address
[   17.470854] using random self ethernet address
[   17.470862] using random host ethernet address
[   18.039540] tegra194-pcie 141e0000.pcie: supply vddio-pex-ctl not found, using dummy regulator
[   20.599043] rt5640 8-001c: Device with ID register 0xffff0000 is not rt5640/39
[   20.600828] nvme nvme0: missing or invalid SUBNQN field.

****************** [   ȫ  ½ (Security Login) ] *****************
Authorized only. All activity will be monitored and reported.
eis860 login: [   27.620287] [drm:nv_drm_atomic_commit [nvidia_drm]] *ERROR* [nvidia-drm] [GPU ID 0x00020000] Flip event timeout on head 0
root
Password:
Welcome to EIS860 V5.0 (GNU/Linux 5.15.148-tegra aarch64)
################## Welcome to use EIS860 ! ####################
Login success. Please execute the commands and operation data carefully.

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.
Last login: Thu Oct  9 15:26:40 CST 2025 on ttyTCU0
root@eis860:~#
```

## 5 报错分析：nv_drm_atomic_commit

这条日志是 **NVIDIA 显示驱动（nvidia-drm 内核模块）** 在 **JetPack 6（基于 L4T r36.x / 内核 5.15+）** 上常见的显示路径超时错误，代表 **GPU 向显示控制器提交帧缓冲翻转（flip）事件时超时**。下面是详细解释与分析。

---

### 5.1 日志结构拆解

* `[drm:nv_drm_atomic_commit [nvidia_drm]]`
  → 日志来源是 Linux DRM（Direct Rendering Manager）子系统的 `nv_drm` 驱动，也就是 NVIDIA 自家的 KMS/DRM 实现。
* `*ERROR* [nvidia-drm]`
  → 表示在提交 display flip（翻转帧缓冲）时发生错误。
* `[GPU ID 0x00020000]`
  → GPU 标识符（通常对应 `/dev/dri/card0` 或 `/dev/dri/card1`）。
* `Flip event timeout on head 0`
  → **head 0** 是显示输出管线（一般对应 HDMI、DP 的第一个显示头）。
  “flip event timeout” 意味着：

  > GPU 提交一帧到显示控制器后等待硬件信号“帧刷新完成”超时。

---

### 5.2 技术背景

在 NVIDIA 驱动（nvidia-drm）中，**Flip event** 是一次显示更新过程（framebuffer flip）：

1. 用户空间（如 Xorg、Wayland、Weston）请求更新屏幕内容；
2. 内核 DRM 驱动（nvidia-drm）调用 **atomic commit**；
3. 硬件（display controller）收到 flip 命令并在下一个 vsync 同步后完成；
4. 驱动等待完成事件（event）；
5. 如果在一定时间（默认 10s）内没等到 → 触发超时。

---

### 5.3 常见触发原因与分析

| 原因类别                               | 说明                                                                | 常见场景                                         |
| ---------------------------------- | ----------------------------------------------------------------- | -------------------------------------------- |
|  **显示输出未连接或异常**                  | 如果 head 0 对应的 HDMI/DP 输出无信号、未初始化或 EDID 读取失败，flip 等待的 vsync 永远不会到。 | HDMI 显示器未连接、热插拔后未刷新 EDID。                    |
|  **用户态显示栈（Xorg / Weston）死锁或卡死** | 如果 compositor 停止响应（例如 GPU 占用 100%），atomic commit 无法完成。            | 图形应用 crash 或 EGLSurface 被释放后仍在渲染。            |
|  **显示时钟或电源域未开启**                  | 当 display pipeline 被 power-gated，硬件无法触发事件。                        | suspend/resume 过程或启动早期。                      |
|  **GPU 通信问题 / 固件异常**             | 特别是在 Jetson 平台，BPMP / NVDisplay 之间的通信异常会导致事件丢失。                   | BSP 未完全加载 firmware（`/lib/firmware/nvidia/`）。 |
|  **内核 / 驱动 bug**                 | JetPack 6 仍有部分未修复的 atomic commit 同步 bug（见 NVIDIA Dev Forum）。      | 特别是在 headless 模式或多显示 pipeline 下。             |

---

### 5.4 确认方式与调试思路

1. **检查连接状态**

   ```bash
   sudo cat /sys/class/drm/*/status
   ```

   应该看到：

   ```
   connected
   ```

   若为 `disconnected`，则 flip 超时属正常。

2. **查看 dmesg 详细日志**

   ```bash
   dmesg | grep nvidia-drm
   dmesg | grep nvdisplay
   ```

   看是否有 “timeout”、“link training failed”、“edid read error”等前置错误。

3. **检查显示固件加载**

   ```bash
   ls /lib/firmware/nvidia/*display*
   ```

   缺失 firmware 会导致 flip event 永远不返回。

4. **Wayland / Xorg 日志**

   ```bash
   cat ~/.local/share/xorg/Xorg.0.log
   journalctl -u weston.service
   ```

   若 compositor 异常退出，也会造成 flip 超时。

5. **headless 模式下忽略**
   若运行在无显示（headless）模式，可安全忽略该错误，只需：

   ```bash
   sudo modprobe nvidia-drm modeset=0
   ```

   或在 `/boot/extlinux/extlinux.conf` 的内核参数中加入：

   ```
   nvidia-drm.modeset=0
   ```

   来禁用 DRM KMS。

---

### 5.5 修复或规避建议

| 场景               | 解决方案                                                                                               |
| ---------------- | -------------------------------------------------------------------------------------------------- |
| HDMI/DP 没插显示器    | 在 Jetson headless 模式禁用 KMS：`nvidia-drm.modeset=0`                                                  |
| HDMI 插入但黑屏或超时    | 检查 `/boot/firmware/extlinux.conf` 是否设置 `quiet splash`，改为 `nvidia-drm.modeset=1` 并更新 display config |
| 启动阶段频繁报错         | 将 `/etc/systemd/system/display-manager.service` 设置延迟启动（After=nvfb.service）                         |
| Weston / Xorg 卡死 | 重启 compositor 或 kill 掉僵死进程                                                                         |
| BSP 定制           | 确保 `nvdisplay` 节点正确配置（设备树中 clock/power domain）                                                     |

---

### 5.6 总结一句话

> 该日志表示 **GPU 在等待显示刷新事件时超时**。
> 通常由于 **无连接显示、显示栈异常、或驱动时序问题** 引起。
> 在 headless 系统中可 **安全忽略或禁用 KMS**，在图形系统中则需检查 **EDID、compositor、驱动加载时序**。

