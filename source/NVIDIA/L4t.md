# Jetson AGX Orin 刷机

## 1 环境准备

- host开发环境Ubuntu 18/Ubuntu 20

- USB-typec线，用于连接host主机到jetson-orin开发板，type-c插在pin口面

- 鼠标、键盘、显示器，用于jetson-orin开发板外设

## 2 环境变量

安装依赖包

```bash 
sudo apt install qemu-user-static build-essential bc flex bison libcurses-ocaml-dev graphviz dvipng python3-venv latexmk librsvg2-bin texlive-xetex
```

将所有安装文件放于同一个文件夹 `orin_flash`，[文件目录](https://developer.nvidia.com/embedded/jetson-linux-r341)：

- Jetson_Linux_R34.1.0_aarch64.tbz2，位置：DRIVERS > L4T Driver Package(BSP)
- Tegra_Linux_Sample-Root-Filesystem_R34.1.0_aarch64.tbz2，位置：Drivers > Sample Root Filesystem
- public_sources.tbz2，位置：SOURCES > L4T Driver Package(BSP) Sources

```shell
export L4T_RELEASE_PACKAGE=Jetson_Linux_R34.1.0_aarch64.tbz2
export SAMPLE_FS_PACKAGE=Tegra_Linux_Sample-Root-Filesystem_R34.1.0_aarch64.tbz2
export BOARD=jetson-agx-orin-devkit
export FILE_ENV=xxx/orin_flash/ # 根据实际目录替换xxx
# 交叉编译环境
export TEGRA_KERNEL_OUT=/opt/kernel_out
export CROSS_COMPILE=/opt/l4t-gcc/bin/aarch64-buildroot-linux-gnu-
export LOCALVERSION=-tegra

export kernel_source=Linux_for_Tegra/source/public/kernel/kernel-5.10
export TEGRA_TOP=/opt/Linux_for_Tegra/source/public
```

- Jetson_Linux_R34.1.0_aarch64.tbz2 包含 Jetson Linux 发行包名称的文件的路径名
- Tegra_Linux_Sample-Root-Filesystem_R34.1.0_aarch64.tbz2 包含示例文件系统包的文件名
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









```bash
tar -xjf  public_sources.tbz2 
cd Linux_for_Tegra/source/public/
tar -xjf kernel_src.tbz2
```



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

