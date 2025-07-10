# JP 6.2适配

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


## 2 T23x 设备树

配置设备树之前，要完成[内核自定义](https://docs.nvidia.com/jetson/archives/r36.4.3/DeveloperGuide/SD/Kernel/KernelCustomization.html#sd-kernel-kernelcustomization)。

设备树dts文件的位置： `Linux_for_Tegra/source/hardware/nvidia/t23x/nv-public`

设备树编译生成文件dtb的位置： `Linux_for_Tegra/source/kernel-devicetree/generic-dts/dtbs`

AGX Orin 64GB模组的设备树名称：`kernel_tegra234-p3737-0000+p3701-0005-nv.dtb`

AGX Orin 32GB模组的设备树名称：`kernel_tegra234-p3737-0000+p3701-0004-nv.dtb`

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

## 3 内核文档编译

```shell
# 在 .venv 下创建虚拟环境
python3 -m venv sphinx-docs-env
source sphinx-docs-env/bin/activate
# 查看环境依赖，如果不生成PDF，建议加参数 --no-pdf
./scripts/sphinx-pre-install
# 根据上步输出安装指定版本组件
pip install "sphinx>=6.2.1,<7" "docutils>=0.18.1,<0.20" "sphinx-rtd-theme"
# 构建
make htmldocs
# 退出虚拟环境
deactivate
```
[虚拟环境管理参考](https://big-circle.readthedocs.io/en/latest/Linux/Linux.html#python-venv)。

## 4 使用 OTA 更新实时内核

```shell
# file name : /etc/apt/sources.list.d/nvidia-l4t-apt-source.list
# 添加RT内核存储库
deb https://repo.download.nvidia.com/jetson/rt-kernel r36.4 main
# 更新
$ sudo apt update
$ sudo apt install nvidia-l4t-rt-kernel nvidia-l4t-rt-kernel-headers nvidia-l4t-rt-kernel-oot-modules nvidia-l4t-display-rt-kernel
$ reboot
# 删除RT
$ sudo apt remove nvidia-l4t-rt-kernel nvidia-l4t-rt-kernel-headers nvidia-l4t-rt-kernel-oot-modules nvidia-l4t-display-rt-kernel
$ reboot
```
## 5 软件安装

### 5.1 firefox

- [firefox浏览器版本选择，下载安装包](https://www.mozilla.org/zh-CN/firefox/all/desktop-release/)
- [在GNU/Linux中使用APT安装](https://support.mozilla.org/zh-CN/kb/install-firefox-linux?_gl=1*1k69eja*_ga*MTU3MDUwODIxMi4xNzQ5MDAyOTI2*_ga_MQ7767QQQW*czE3NDkwMDI5MjUkbzEkZzEkdDE3NDkwMDI5NjQkajIxJGwwJGgw#w_install-firefox-deb-package-for-debian-based-distributions)
- [Ubuntu 22.04 ARM64 安装包下载链接](https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64-aarch64&lang=zh-CN&_gl=1*1eng209*_ga*MTU3MDUwODIxMi4xNzQ5MDAyOTI2*_ga_MQ7767QQQW*czE3NDkwMDY3NDYkbzIkZzEkdDE3NDkwMDY4MzAkajQ1JGwwJGgw)

```shell
# 基于tar.bz2安装包
# 从第一个链接下载安装包
tar xjf firefox-*.tar.bz2
mv firefox /opt
ln -s /opt/firefox/firefox /usr/local/bin/firefox
wget https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop -P /usr/local/share/applications
```

```shell
# 基于APT库密钥安装deb包
# 创建保存APT库密钥的目录
install -d -m 0755 /etc/apt/keyrings
# 导入Mozilla APT密钥环
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
# 把Mozilla APT库添加到源列表
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
# 配置 APT 优先使用 Mozilla 库中的包
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | tee /etc/apt/preferences.d/mozilla
# 更新软件列表并安装 firefox（或 firefox-esr、-beta、-nightly、-devedition 之一）：
apt-get update && apt-get install firefox
# 设置语言
apt-get install firefox-l10n-zh-cn
```
脚本版，使用`sudo`权限执行：
```shell
#!/bin/bash
# file_name : install_firefox_mozilla.sh

set -e

echo "安装 Mozilla 官方提供的 Firefox (非 Snap)"
echo
echo "请选择要安装的版本："
echo "1. firefox          - 正式版（推荐）"
echo "2. firefox-esr      - 扩展支持版（适合企业/长期稳定）"
echo "3. firefox-beta     - 测试版"
echo "4. firefox-nightly  - 每日构建开发版"
read -p "请输入选项 [1-4]，默认安装正式版（1）: " choice

case "$choice" in
    2)
        pkg_name="firefox-esr"
        ;;
    3)
        pkg_name="firefox-beta"
        ;;
    4)
        pkg_name="firefox-nightly"
        ;;
    *)
        pkg_name="firefox"
        ;;
esac

echo "选择安装：$pkg_name"

# 检查是否已通过 APT 安装该版本
if dpkg -l | grep -q "^ii  $pkg_name "; then
    echo "已通过 APT 安装了 $pkg_name，无需重复安装。"
    echo "如果需要重新安装，请先执行：sudo apt remove $pkg_name"
    exit 0
fi

# 1. 创建密钥环目录
sudo install -d -m 0755 /etc/apt/keyrings

# 2. 导入 Mozilla APT 密钥
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

# 3. 添加 Mozilla APT 仓库
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null

# 4. 设置高优先级
sudo tee /etc/apt/preferences.d/mozilla > /dev/null <<EOF
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF

# 5. 卸载 Snap 版 Firefox（如有）
if command -v snap &> /dev/null && snap list | grep -q "^firefox"; then
    echo "检测到 Snap 版 Firefox，正在卸载..."
    sudo snap remove firefox
fi

# 6. 更新软件源并安装所选版本
sudo apt-get update
sudo apt-get install -y "$pkg_name"

# 7. 安装中文语言包（仅适用于正式版）
if [[ "$pkg_name" == "firefox" ]]; then
    sudo apt-get install -y firefox-l10n-zh-cn
    echo "已安装中文语言包。"
fi

echo
echo "已成功安装 $pkg_name。你可以通过命令行运行：$pkg_name"
```
