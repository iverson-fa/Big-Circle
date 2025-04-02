# JP 6适配

## 1 配置脚本
```shell
#!/bin/bash

# Author: dafa
# Date: 2023-04-25

set -e

if [[ $(id -u) -ne "0" ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Function to initialize the script and get user input
init() {
    read -r -t 30 -p "Please choose:
    [1] src
    [2] build
    [3] create massflash package
    [4] massflash
    [5] devkit_flash
    [6] default_user
    [7] nvbuild
    [8] clean
    [9] Image
    [10] DTS
    [11] modules
    [12] build with no menuconfig
    [13] setup_driver
    " NUM
}

# Function to set up the environment variables
setup_env() {
    export TOP_DIR=$(pwd)
    export WS=$(pwd)/BSP
    export L4T_RELEASE_PACKAGE="$WS"/Jetson_Linux_R36.4.3_aarch64.tbz2
    export SAMPLE_FS_PACKAGE="$WS"/Tegra_Linux_Sample-Root-Filesystem_R36.4.3_aarch64.tbz2
    export BOARD=jetson-agx-orin-devkit
    export CROSS_COMPILE="$TOP_DIR"/l4t-gcc/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-
    export LOCALVERSION=-tegra
    export KERNEL_SOURCE="$WS"/Linux_for_Tegra/source
    export KERNEL_HEADERS="$KERNEL_SOURCE"/kernel/kernel-jammy-src
    export ARCH=arm64
    export INSTALL_MOD_PATH="$WS"/Linux_for_Tegra/rootfs
    # export KERNEL_OUTPUT="$WS"/kernel_out
}

# Function to extract BSP and kernel source
src() {
    echo "开始解压"
    cd "$WS" || exit
    tar -xpf $L4T_RELEASE_PACKAGE
    tar -xpf $SAMPLE_FS_PACKAGE -C Linux_for_Tegra/rootfs/
    cd "$WS"/Linux_for_Tegra
    ./apply_binaries.sh
    echo "根文件目录系统组装完成"
    cd "$WS" || exit
    tar xf public_sources.tbz2
    cd Linux_for_Tegra/source/ || exit
    tar xf kernel_src.tbz2
    tar xf kernel_oot_modules_src.tbz2
    tar xf nvidia_kernel_display_driver_source.tbz2
    cd "$TOP_DIR" || exit
    echo "环境准备完毕!"
}

# Function to compile the kernel
linux() {
    # echo "开始编译"
    cd "$KERNEL_SOURCE" || exit
    make -C kernel
    make install -C kernel
    # # make tegra_defconfig
    make dtbs
    make modules
    make modules_install
    cp kernel/kernel-jammy-src/arch/arm64/boot/Image "$WS"/Linux_for_Tegra/kernel/Image
    cp nvidia-oot/device-tree/platform/generic-dts/dtbs/* "$WS"/Linux_for_Tegra/kernel/dtb/
}

# Function to configure and build the kernel
build() {
    cd "$KERNEL_SOURCE" || exit
    make menuconfig ARCH=arm64 O=$KERNEL_OUT
    echo "开始编译"
    make ARCH=arm64 O=$KERNEL_OUT -j12
    cp "$KERNEL_OUT"/arch/arm64/boot/Image "$WS"/Linux_for_Tegra/kernel/Image
    cp "$KERNEL_OUT"/arch/arm64/boot/dts/nvidia/* "$WS"/Linux_for_Tegra/kernel/dtb/
    make ARCH=arm64 O=$KERNEL_OUT modules_install INSTALL_MOD_PATH="$WS"/Linux_for_Tegra/rootfs/
}

# Function to use nvbuild script
nvbuild() {
    cd "$KERNEL_SOURCE" || exit
    ./nvbuild.sh -o $KERNEL_OUT
    ./nvbuild.sh -i $INSTALL_MOD_PATH
    # cp "$KERNEL_OUT"/arch/arm64/boot/Image "$WS"/Linux_for_Tegra/kernel/Image
    # cp "$KERNEL_OUT"/arch/arm64/boot/dts/nvidia/tegra234-p3701-0000-p3737-0000.dtb "$WS"/Linux_for_Tegra/kernel/dtb/
}

# Function to build kernel image
Image() {
    echo "开始编译Image"
    cd "$KERNEL_SOURCE" || exit
    make -C kernel
    make install -C kernel
    cp kernel/kernel-jammy-src/arch/arm64/boot/Image "$WS"/Linux_for_Tegra/kernel/Image
}

# Function to build device tree
dts() {
    echo "开始编译设备树"
    cd "$KERNEL_SOURCE" || exit
    make dtbs
    cp nvidia-oot/device-tree/platform/generic-dts/dtbs/* "$WS"/Linux_for_Tegra/kernel/dtb/
}

# Function to build kernel modules
modules() {
    echo "开始编译modules"
    cd "$KERNEL_SOURCE" || exit
    make modules
    make modules_install
    cd "$WS"/Linux_for_Tegra
    sudo ./tools/l4t_update_initrd.sh
}

# Function to clean the build
clean() {
    cd "$KERNEL_SOURCE" || exit
    make -C kernel clean
    make clean
    make O=$KERNEL_OUT clean
}

# Function to create massflash package
mfi() {
    systemctl stop udisks2.service
    cd "$WS"/Linux_for_Tegra || exit
    read -r -t 10 -p "开始制作批量刷机包,请选择机型：
    [1] EIS860  Offline
    [2] EIS860  Online
    " TYPE
    if [ "$TYPE" -eq "1" ]; then
        sudo BOARDID=3701 FAB=500 BOARDSKU=0004 BOARDREV=F.0 ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash --network usb0 --massflash 5 $BOARD mmcblk0p1
    else
        sudo ./tools/kernel_flash/l4t_initrd_flash.sh --network usb0 --no-flash --massflash 4 $BOARD mmcblk0p1
    fi
    echo "批量刷机包制作完成!"
}

# Function to massflash the devices
massflash() {
    cd "$WS"/Linux_for_Tegra/mfi_jetson-agx-orin-devkit || exit
    sudo ./tools/kernel_flash/l4t_initrd_flash.sh --network usb0 --flash-only --massflash 1
}

# Function to flash devkit
devkit_flash() {
    cd "$WS"/Linux_for_Tegra || exit
    sudo ./flash.sh $BOARD mmcblk0p1
}

# Function to create default user
default_user() {
    cd "$WS"/Linux_for_Tegra/tools || exit
    ./l4t_create_default_user.sh -u orin -p 1 -n jp6 -a
}

setup_driver() {
        "$TOP_DIR"/patch/cfg.sh
}

# Initialize the script and get user input
init
setup_env
# Execute the selected option
case $NUM in
    1) src ;;
    2) build ;;
    3) mfi ;;
    4) massflash ;;
    5) devkit_flash ;;
    6) default_user ;;
    7) nvbuild ;;
    8) clean ;;
    9) Image ;;
    10) dts ;;
    11) modules ;;
    12) linux ;;
    13) setup_driver ;;
    *) echo "Wrong parameter! Please choose again." ;;
esac
```


## 2 设备树

设备树文件的位置： `Linux_for_Tegra/source/hardware/nvidia/t23x/nv-public`

AGX Orin 64GB模组的设备树名称：`kernel_tegra234-p3737-0000+p3701-0005-nv.dtb`

### **设备树的层级结构**

1. **底层（Upstream Linux Kernel）**:
   - 来源：**Linux 内核社区的上游代码**。
   - 作用：保持 NVIDIA 平台的设备树配置与上游内核的基础设备树文件对齐。
   - 存放位置：`nv-public` 文件夹的根目录。
   - 示例文件：`nv-public/tegra234-p3737-0000+p3701-0000.dts`。
     - 此文件定义了设备的基本硬件配置。

2. **顶层（NV-Platform Layer）**:
   - 来源：**NVIDIA 的平台目录 (nv-platform)**。
   - 作用：在上游设备树文件的基础上，添加特定于 NVIDIA 平台的内容或对其进行更新。
   - 文件命名：
     - 文件名与上游设备树文件的名称保持一致，但在文件名末尾添加 `-nv`。
     - 示例文件：`nv-platform/tegra234-p3737-0000+p3701-0000-nv.dts`。
   - 工作方式：
     - **继承与扩展**：通过包含（`#include`）底层设备树文件，并在此基础上添加内容或更新配置。

---

### **总结**
NVIDIA 的设备树组织结构分为底层（与上游内核对齐）和顶层（平台扩展）。通过这种分层设计，设备树既保持了与内核的兼容性，也允许 NVIDIA 针对其特定硬件进行自定义优化。这种设计适用于支持多 SKU 和模块的复杂硬件平台，如 AGX Orin。
