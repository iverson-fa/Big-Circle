# Orin 环境搭建
## 1 适配 32G module 载板

### 1.1 EP 配置

修改 `Linux_for_Tegra/p3701.conf.common` 文件，在 ODMDATA 一行将 `nvhs-uphy-config-0` 修改为 `nvhs-uphy-config-1`。

### 1.1 关闭 EEPROM

在`Linux_for_Tegra/bootloader/tegra234-mb2-bct-common.dtsi` 的第38行将`cvb_eeprom_read_size` 设为0：

```c
cvb_eeprom_read_size = <0>;
```

### 1.2 支持 HDMI

在[官网下载](https://developer.nvidia.com/embedded/jetson-linux-r3411)文件`tegra234-dcb-p3701-0000-a02-p3737-0000-a01_hdmi.dtsi`，放置于`Linux_for_Tegra/source/public/hardware/nvidia/platform/t23x/concord/kernel-dts/`目录，修改此目录 `tegra234-p3701-0000-p3737-0000.dts`

```bash
--- a/tegra234-p3701-0000-p3737-0000.dts
+++ b/tegra234-p3701-0000-p3737-0000.dts
@@ -17,7 +17,7 @@
#include "cvm/tegra234-p3701-0000.dtsi"
#include "cvb/tegra234-p3737-0000-a00.dtsi"
#include "tegra234-power-tree-p3701-0000-p3737-0000.dtsi"
-#include "tegra234-dcb-p3701-0000-a02-p3737-0000-a01.dtsi"
+#include "tegra234-dcb-p3701-0000-a02-p3737-0000-a01_hdmi.dtsi"
#include <tegra234-soc/mods-simple-bus.dtsi>
#include "cvb/tegra234-p3737-camera-modules.dtsi"
```

### 1.3 配置 RGMII

参考[官方文档](https://docs.nvidia.com/jetson/archives/r35.1/DeveloperGuide/text/HR/JetsonModuleAdaptationAndBringUp/JetsonAgxOrinSeries.html#for-rgmii)及论坛，禁用 MGBE，配置千兆PHY，配置GPIO和pinmux，详见《BUG整理》。

### 1.4 安装 Jtop

```bash
sudo pip3 install -U jetson-stats
```

### 1.5 I2C总线

NVIDIA 使用的总线2，控制器为 `3180000`，Hermes 使用的总线1，控制器为 `c240000`，需要修改的文件：

- Linux_for_Tegra/source/public/hardware/nvidia/platform/t23x/concord/kernel-dts/cvb/tegra234-p3737-0000-camera-ar0233-a00.dtsi
- Linux_for_Tegra/source/public/hardware/nvidia/platform/t23x/common/kernel-dts/t234-common-modules/tegra234-camera-ar0233-a00.dtsi

## 2 安装 jetpack 软件包

**（1）安装**

参考[官方文档](https://docs.nvidia.com/jetson/archives/jetpack-archived/jetpack-50dp/install-jetpack/index.html#how-to-install-jetpack)，有 4 种安装方法：

- SDK Manager
- SD Card Image
- Package Management Tool
- Jetpack Debian Packages on Host

下面基于第三种 `apt` 的方式安装：

```bash
sudo vim /etc/apt/sources.list.d/nvidia-l4t-apt-source.list 
# 添加地址
deb https://repo.download.nvidia.com/jetson/common r35.1 main
deb https://repo.download.nvidia.com/jetson/t234 r35.1 main
```

```bash
sudo apt update
sudo apt install nvidia-jetpack
sudo apt show nvidia-jetpack -a
```

主要组件版本：

| Jetpack component      | Sample locations on reference filesystem |
| ---------------------- | ---------------------------------------- |
| CUDA 11.4              | /usr/local/cuda-11.4/samples/            |
| cuDNN 8.3.2            | /usr/src/cudnn_samples_v8/               |
| TensorRT 8.4.0         | /usr/src/tensorrt/samples/               |
| MM API                 | /usr/src/jetson_multimedia_api/          |
| VPI 2.0                | /opt/nvidia/vpi2/samples/                |
| OpenCV 4.5.4           |                                          |
| Vulkan 1.3             |                                          |
| Nsight Systems 2021.5  |                                          |
| Nsight Graphics 2021.5 |                                          |

**（2）CUDA 配置**：

```bash
# 在 .bash_aliases 中添加
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
```

或者修改 `/etc/profile`

```bash
export PATH=/usr/local/cuda-11/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-11/lib64$LD_LIBRARY_PATH
export CUDA_HOME=/usr/local/cuda-11
```

source 环境后使用 `nvcc -V` 可以查看 `CUDA` 版本信息。

**（3）cuDNN 配置**：

默认安装路径：

- 头文件：`/usr/include/cudnn.h`
- 库文件：/usr/lib/aarch64-linux-gnu/libcudnn*

复制到 `CUDA` 路径并修改权限：

```bash
sudo cp /usr/include/cudnn.h /usr/local/cuda-11/include
sudo cp /usr/lib/aarch64-linux-gnu/libcudnn* /usr/local/cuda-11/lib64/
sudo chmod 777 /usr/local/cuda-11/include/cudnn.h /usr/local/cuda-11/lib64/libcudnn*
# 更新动态链接库
sudo ldconfig
```

`ldconfig`命令的用途主要是在默认搜寻目录 `/lib` 和`usr/lib` 以及动态库配置文件` /etc/ld.so.conf` 内所列的目录下，搜索出可共享的动态链接库（格式如`lib*.so*`）,进而创建出动态装入程序（`ld.so`）所需的连接和缓存文件。`ldconfig` 通常在系统启动时运行，而当用户安装了一个新的动态链接库时，就需要手工运行这个命令。由于已经添加过了环境变量，所以重启后就不用再更新动态链接库了。

测试：

```bash
sudo cp -r /usr/src/cudnn_samples_v8/ ~/
cd ~/cudnn_samples_v8/conv_sample
sudo make clean
sudo make
./conv_sample
```

软件版本查看：

- JetPack: sudo apt show nvidia-jetpack
- CUDA: nvcc -V
- cuDNN cat /usr/include/cudnn_version.h | grep CUDNN_MAJOR -A 2
- openCV: pkg-config --modversion opencv4
- TensorRT: dpkg -l | grep TensorRT
- cmake: cmake --version

其他软件的安装可以参考 [Github 仓库](https://github.com/yqlbu/jetson-packages-family)。

## 3 可用脚本

### 3.1 修改静态IP

适用于 `Jetson` 和 `X86` 平台 `Ubuntu 20.04`。

```bash
$ sudo apt install -y netplan.io
$ sudo vim /etc/netplan/01-network-manager-all.yaml 
network:
    version: 2
    renderer: networkd
    ethernets:
        eth0:
            addresses:
                - 192.168.3.3/24
            gateway4: 192.168.3.1
            nameservers:
                addresses: [114.114.114.114, 8.8.8.8]
$ sudo netplan generate
$ sudo service network-manager restart
$ sudo netplan apply
```

### 3.2 内核编译

```shell
#!/bin/bash
# author:dafa 2023-5-15


init()
{
	read -t 30 -p "Please choose:
	[1] src
	[2] build
	[3] linux
	[4] nvbuild
	[5] Image
	[6] dts
	[7] modules
	[8] clean
	[9] mfi
	[10] massflash
	[11] devkit_flash
	[12] default_user
	[13] test
	" NUM
}

env()
{
	export WS=/home/dafa/jetson_flash/r35.2
	export BSP=$WS/Linux_for_Tegra/source/public
	export L4T_RELEASE_PACKAGE=$WS/Jetson_Linux_R35.2.1_aarch64.tbz2
	export SAMPLE_FS_PACKAGE=$WS/Tegra_Linux_Sample-Root-Filesystem_R35.2.1_aarch64.tbz2
	export BOARD=jetson-agx-orin-devkit
	# 交叉编译环境
	export TEGRA_KERNEL_OUT=$WS/kernel_out
	export CROSS_COMPILE=/opt/l4t-gcc/bin/aarch64-buildroot-linux-gnu-
	export LOCALVERSION=-tegra
	# 内核目录
	export KERNEL_SOURCE=$WS/Linux_for_Tegra/source/public/kernel/kernel-5.10
	export ARCH=arm64
	# .nvbuild 
	export CROSS_COMPILE_AARCH64_PATH=/opt/l4t-gcc
	export CROSS_COMPILE_AARCH64=/opt/l4t-gcc/bin/aarch64-buildroot-linux-gnu-
}

src()
{
	env
	echo "开始解压BSP"
	cd $WS
	tar -xpf $L4T_RELEASE_PACKAGE
	cd Linux_for_Tegra/rootfs/
	tar -xpf $SAMPLE_FS_PACKAGE   
	cd ..
	./apply_binaries.sh
	echo "BSP解压完成 开始解压内核源码"
	cd $WS
	tar -xjf  public_sources.tbz2
	cd Linux_for_Tegra/source/public/
	tar -xjf kernel_src.tbz2
	cd $WS
	echo "环境准备完毕!"
}

linux()
{
	env
	echo "开始编译"
	cd $KERNEL_SOURCE
	make tegra_defconfig O=$TEGRA_KERNEL_OUT
	make dtbs O=$TEGRA_KERNEL_OUT
	make modules -j12 O=$TEGRA_KERNEL_OUT
	cp $TEGRA_KERNEL_OUT/arch/arm64/boot/Image $WS/Linux_for_Tegra/kernel/Image
	cp $TEGRA_KERNEL_OUT/arch/arm64/boot/dts/nvidia/tegra234-p3701-0000-p3737-0000.dtb $WS/Linux_for_Tegra/kernel/dtb/
	# cp $TEGRA_KERNEL_OUT/drivers/gpu/nvgpu/nvgpu.ko $WS/Linux_for_Tegra/rootfs/usr/lib/modules/5.10.104-tegra/kernel/drivers/gpu/nvgpu/nvgpu.ko
	cd -
}

build()
{
	env
	cd $KERNEL_SOURCE
	make menuconfig ARCH=arm64 O=$TEGRA_KERNEL_OUT
	echo "开始编译"
	make ARCH=arm64 O=$TEGRA_KERNEL_OUT -j12
	cp $TEGRA_KERNEL_OUT/arch/arm64/boot/Image $WS/Linux_for_Tegra/kernel/Image
	cp $TEGRA_KERNEL_OUT/arch/arm64/boot/dts/nvidia/* $WS/Linux_for_Tegra/kernel/dtb/
	make ARCH=arm64 O=$TEGRA_KERNEL_OUT modules_install INSTALL_MOD_PATH=$WS/Linux_for_Tegra/rootfs/
}

nvbuild()
{
	env
	cd $BSP
	./nvbuild.sh O=$TEGRA_KERNEL_OUT 
	cp $TEGRA_KERNEL_OUT/arch/arm64/boot/Image $WS/Linux_for_Tegra/kernel/Image
	cp $TEGRA_KERNEL_OUT/arch/arm64/boot/dts/nvidia/tegra234-p3701-0000-p3737-0000.dtb $WS/Linux_for_Tegra/kernel/dtb/
}

Image()
{
	env
	echo "开始编译Image"
	cd $KERNEL_SOURCE
	make O=$TEGRA_KERNEL_OUT tegra_defconfig
	make Image -j12
	cp $TEGRA_KERNEL_OUT/arch/arm64/boot/Image $WS/Linux_for_Tegra/kernel/Image
	cd -
}

dts()
{
	env
	echo "开始编译设备树"
	cd $KERNEL_SOURCE
	make tegra_defconfig
	make dtbs
	cp $TEGRA_KERNEL_OUT/arch/arm64/boot/dts/nvidia/tegra234-p3701-0000-p3737-0000.dtb $WS/Linux_for_Tegra/kernel/dtb/
	cd -
}

modules()
{
	env
	echo "开始编译modules"
	cd $KERNEL_SOURCE
	make tegra_defconfig
	make modules -j8
	cd -
}

clean()
{
	env
	cd $KERNEL_SOURCE
	make clean
	cd -
}

mfi()
{
	env
	systemctl stop udisks2.service
	echo "开始制作批量刷机包"
	cd $WS/Linux_for_Tegra
	./tools/kernel_flash/l4t_initrd_flash.sh --no-flash –massflash 4 $BOARD mmcblk0p1
	cd -
	echo "批量刷机包制作完成!"
}

massflash()
{
	env
	cd $WS/Linux_for_Tegra/mfi_jetson-agx-orin-devkit
	# 1 可以替换为实际设备数量
	./tools/kernel_flash/l4t_initrd_flash.sh --flash-only --massflash 1 
	cd -
}

devkit_flash()
{
	env
	cd $WS/Linux_for_Tegra
	sudo ./flash.sh $BOARD mmcblk0p1
}

default_user()
{
	env
	cd Linux_for_Tegra/tools
	./l4t_create_default_user.sh -u orin -p 1 -n eis860 -a
}

test()
{
	echo "TEST"
}

init

if [ $NUM == "1" ]; then
	src
elif [ $NUM == "2" ]; then
	build
elif [ $NUM == "4" ]; then
	nvbuild
elif [ $NUM == "3" ]; then
	linux
elif [ $NUM == "5" ]; then
	Image
elif [ $NUM == "6" ]; then
	dts
elif [ $NUM == "7" ]; then
	modules
elif [ $NUM == "8" ]; then
	clean
elif [ $NUM == "9" ]; then
	mfi
elif [ $NUM == "10" ]; then
	massflash
elif [ $NUM == "11" ]; then
	devkit_flash
elif [ $NUM == "12" ]; then
	default_user
elif [ $NUM == "13" ]; then
	test
else
	useage
fi

```

