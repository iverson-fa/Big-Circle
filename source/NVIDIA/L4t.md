# Jetson AGX Orin 刷机

## 1 环境准备

- Host开发环境Ubuntu 18/Ubuntu 20

- USB-typec线，用于连接host主机到jetson-orin开发板，type-c插在pin口面

- 鼠标、键盘、显示器，用于jetson-orin开发板外设

## 2 环境变量

安装依赖包

```bash 
sudo apt install qemu-user-static build-essential bc flex bison libcurses-ocaml-dev graphviz dvipng python3-venv latexmk librsvg2-bin texlive-xetex
```

从[官网](https://developer.nvidia.com/embedded/jetson-linux-r341)下载以下文件并将放于同一个文件夹 `orin_flash`，文件目录：

- Jetson_Linux_R34.1.0_aarch64.tbz2，位置：DRIVERS > L4T Driver Package(BSP)
- Tegra_Linux_Sample-Root-Filesystem_R34.1.0_aarch64.tbz2，位置：Drivers > Sample Root Filesystem
- public_sources.tbz2，位置：SOURCES > L4T Driver Package(BSP) Sources
- aarch64--glibc--stable-final.tar.gz，位置：TOOLS > Bootlin Toolchain gcc 9.3

```shell
export L4T_RELEASE_PACKAGE=Jetson_Linux_R34.1.0_aarch64.tbz2
export SAMPLE_FS_PACKAGE=Tegra_Linux_Sample-Root-Filesystem_R34.1.0_aarch64.tbz2
export BOARD=jetson-agx-orin-devkit
export FILE_ENV=xxx/orin_flash/ # 根据实际目录替换xxx
# 交叉编译环境
export TEGRA_KERNEL_OUT=/opt/kernel_out
export CROSS_COMPILE=/opt/l4t-gcc/bin/aarch64-buildroot-linux-gnu
export LOCALVERSION=-tegra

export KERNEL_SOURCE=Linux_for_Tegra/source/public/kernel/kernel-5.10
export TEGRA_TOP=Linux_for_Tegra/source/public
export ARCH=arm64
```

- Jetson_Linux_R34.1.0_aarch64.tbz2 包含 Jetson Linux 发行包名称的文件的路径名
- Tegra_Linux_Sample-Root-Filesystem_R34.1.0_aarch64.tbz2 包含示例文件系统包的文件名
- aarch64--glibc--stable-final.tar.gz 包含 ARM 64 工具链，用于配置交叉编译环境变量
- BOARD 包含支持的 Jetson 模块和载板配置的名称
- TEGRA_KERNEL_OUT 代表编译输出目录

## 3 配置

### 3.1 组装 `rootfs`

```bash
cd ${FILE_ENV}
sudo tar xpf ${L4T_RELEASE_PACKAGE}
cd Linux_for_Tegra/rootfs/
sudo tar xpf ../../${SAMPLE_FS_PACKAGE}     # 将SAMPLE_FS_PACKAGE解压到Tegra/rootfs/目录下
cd ..
sudo ./apply_binaries.sh
```

至此，根文件系统组装完成。

### 3.2 内核源码

在 `${FILE_ENV}` 中解压内核源码

```bash
tar -xjf  public_sources.tbz2 
cd Linux_for_Tegra/source/public/
tar -xjf kernel_src.tbz2
```

### 3.3 安装交叉编译工具

工具链组件

- GCC 版本：9.3.0

- Binutils 版本：2.33.1

- Glibc 版本：2.31

提取工具链

```bash
mkdir /opt/l4t-gcc
cd /opt/l4t-gcc
tar xf aarch64--glibc--stable-final.tar.gz
```

NOTE：若不是 `/opt/l4t-gcc` ，需要修改 `$CROSS_COMPILE` 变量。

### 3.4 生成默认 `.config` 文件

在 `${FILE_ENV}` 中执行以下命令

```bash
mkdir ${TEGRA_KERNEL_OUT}
cd ${KERNEL_SOURCE}
make ARCH=arm64 O=$TEGRA_KERNEL_OUT tegra_defconfig
```

### 3.5 修改内核配置文件

在 `${FILE_ENV}` 中执行以下命令

```shell
cd ${KERNEL_SOURCE} # kernel-5.10
make DEFCONFIG_PATH=arch/arm64/configs tegra_defconfig
make menuconfig
# <<Update config options>> 功能剪切，可以直接 exit
make savedefconfig
cp -v defconfig arch/arm64/configs/tegra_defconfig
make mrproper
```

### 3.6 编译内核

#### 3.6.1 EP 配置

若不需要配置为 EP 模式，跳过此节进入 3.6.2。

根据 `Orin-pcie-c5-ep-odmdata.patch`，修改 `Linux_for_Tegra/p3701.conf.common` 文件，在 ODMDATA 一行将 `nvhs-uphy-config-0` 修改为 `nvhs-uphy-config-1`。

根据 `pcie-regulator.patch`，修改 `Linux_for_Tegra/source/public/hardware/nvidia/platform/t23x/concord/kernel-dts/tegra234-p3737-overlay-pcie.dts` 文件，添加头文件

```c
#include <dt-bindings/gpio/tegra234-gpio.h>
```

添加`fragment@2` 函数，注意函数排版

```c
/* PCIe changes for >= P3737-A04 revision. */
fragment@2 {
	target-path = "/";
	board_config {
		ids = ">=3737-0000-TS4";
	};
	__overlay__ {
		pcie_ep@141a0000 {
			nvidia,refclk-select-gpios = <&tegra_main_gpio
						      TEGRA234_MAIN_GPIO(Q, 4)
						      GPIO_ACTIVE_HIGH>;
		};
		fixed-regulators {
			regulator@105 {
				gpio = <&tegra_main_gpio TEGRA234_MAIN_GPIO(H, 4) 0>;
			};
		};
	};
};
```

#### 3.6.2 正常编译

在`${KERNEL_SOURCE} ` 中执行以下命令构建内核

```bash
make ARCH=arm64 O=$TEGRA_KERNEL_OUT -j4
# 替换 Image
cp $TEGRA_KERNEL_OUT/arch/arm64/boot/Image ${FILE_ENV}/Linux_for_Tegra/kernel/Image
# 替换 dtb，可以不执行
cp $TEGRA_KERNEL_OUT/arch/arm64/boot/dts/nvidia $TEGRA_KERNEL_OUT/Linux_for_Tegra/kernel/dtb/
```

#### 3.6.3 编译后生成的内核模块安装到 L4T 包

在`${KERNEL_SOURCE} ` 中执行以下命令,

```bash
make ARCH=arm64 O=$TEGRA_KERNEL_OUT modules_install INSTALL_MOD_PATH=${FILE_ENV}/Linux_for_Tegra/rootfs/
```

#### 3.6.4 烧写

```bash
sudo ./flash.sh ${BOARD} mmcblk0p1
```

安装过程完成后，Jetson 开发者工具包会自动重启。











```bash
# 串口连接
minicom -D /dev/ttyACM0
# device-tree
dts -I fs -O dts -o extracted.dts /proc/device-tree
# EP 相关的寄存器
sudo busybox devmem 0x2444008 0x170
sudo busybox devmem 0x2444000 0x560
# 查看设备模式
cat /proc/device-tree/pcie@141a0000/status;echo
cat /proc/device-tree/pcie_ep@141a0000/status;echo
```

```bash
cp /opt/kernel_out/arch/arm64/boot/Image doc/InstallPackages/NVIDIA/orin_flash/Linux_for_Tegra/kernel/Image
cp -r /opt/kernel_out/arch/arm64/boot/dts/nvidia doc/InstallPackages/NVIDIA/orin_flash/Linux_for_Tegra/kernel/dtb
```

## 4 bug

若出现 `gcc: unrecognized command line option “-milittle-endian”`，修改Makefile

```shell
vim Linux_for_Tegra/source/public/kernel/kernel-5.10/Makefile
# 修改交叉编译工具
CROSS_COMPILE = /opt/l4t-gcc/bin/aarch64-buildroot-linux-gnu-
```

