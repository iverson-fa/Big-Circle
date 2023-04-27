# Jetson 刷机

SDK Manager 不能满足定制化刷机，本文档以 Jetson AGX Orin 为例，L4t 版本为35.1，其余设备只需修改对应的环境变量即可。

[Jetson Linux Archive](https://developer.nvidia.com/embedded/jetson-linux-archive)

| JETSON LINUX  Version                                        | Jetson AGX Orin | Jetson Orin NX | Jetson AGX Xavier | Jetson AGX Xavier Industrial | Jetson Xavier NX |
| ------------------------------------------------------------ | --------------- | -------------- | ----------------- | ---------------------------- | ---------------- |
| [35.2.1](https://developer.nvidia.com/embedded/jetson-linux-r3521) | ✔*              | ✔**            | ✔                 | ✔                            | ✔                |
| [35.1](https://developer.nvidia.com/embedded/jetson-linux-r351) | ✔*              |                | ✔                 | ✔                            | ✔                |
| [34.1.1](https://developer.nvidia.com/embedded/jetson-linux-r3411) | ✔               |                | ✔                 |                              | ✔                |
| [34.1](https://developer.nvidia.com/embedded/jetson-linux-r341) | ✔               |                | ✔                 |                              | ✔                |

其中，* 代表 Jetson AGX Orin 32GB Module，** 代表 Jetson Orin NX 16GB Module。

## 1 环境准备

### 1.1 硬件

- USB-typec线，用于连接host主机到jetson-orin开发板，type-c插在pin口面
- 鼠标、键盘、显示器，用于jetson-orin开发板外设

### 1.2 软件

Host开发环境Ubuntu 18/Ubuntu 20，**建议在 `sudo` 权限下运行**，安装依赖

```shell
apt install qemu-user-static build-essential bc flex bison libcurses-ocaml-dev graphviz dvipng python3-venv latexmk librsvg2-bin texlive-xetex libssl-dev python3-sphinx libxml2-utils simg2img abootimg sshpass device-tree-compiler
```

文件下载：

- [34.1 JP5.0](https://developer.nvidia.com/embedded/jetson-linux-34.1)
- [L4t 35.1 JP5.0.2](https://developer.nvidia.com/embedded/jetson-linux-r351)
- [L4t 35.2 JP5.1](https://developer.nvidia.com/embedded/jetson-linux)

需要的文件：

- [Driver Package(BSP)](https://developer.nvidia.com/embedded/l4t/r35_release_v1.0/release/jetson_linux_r35.1.0_aarch64.tbz2)
- [Sample Root Filesystem](https://developer.nvidia.com/embedded/l4t/r35_release_v1.0/release/tegra_linux_sample-root-filesystem_r35.1.0_aarch64.tbz2)
- [Driver Pacakge(BSP) Sources](https://developer.nvidia.com/embedded/l4t/r35_release_v1.0/sources/public_sources.tbz2)
- [Bootlin Toolchain gcc 9.3](https://developer.nvidia.com/embedded/jetson-linux/bootlin-toolchain-gcc-93)

文件目录：

```bash
r35.1
├── aarch64--glibc--stable-final.tar.gz
├── Jetson_Linux_R35.1.0_aarch64.tbz2
├── public_sources.tbz2
├── kernel_out
├── l4t-gcc
└── Tegra_Linux_Sample-Root-Filesystem_R35.1.0_aarch64.tbz2
```

## 2 环境变量

```shell
# 此环境变量适用于L4T所有版本，注意各版本文件名，根据实际目录替换xxx
export WS=xxx/r35.1
export L4T_RELEASE_PACKAGE=$WS/Jetson_Linux_R35.1.0_aarch64.tbz2
export SAMPLE_FS_PACKAGE=$WS/Tegra_Linux_Sample-Root-Filesystem_R35.1.0_aarch64.tbz2
export BOARD=jetson-agx-orin-devkit
# 交叉编译环境
export TEGRA_KERNEL_OUT=$WS/kernel_out
export CROSS_COMPILE=$WS/l4t-gcc/bin/aarch64-buildroot-linux-gnu-
export LOCALVERSION=-tegra
# 内核目录
export KERNEL_SOURCE=$WS/Linux_for_Tegra/source/public/kernel/kernel-5.10
export ARCH=arm64
```

`$BOARD` 的值根据设备的不同而设置：

| Module                                                       | BOARD                        |
| ------------------------------------------------------------ | ---------------------------- |
| Jetson AGX Orin                                              | jetson-agx-orin-devkit       |
| Jetson AGX Xavier                                            | jetson-xavier                |
| Jetson Xavier NX with production SOM (without micro-SD card) | jetson-xavier-nx-devkit-emmc |
| Jetson Xavier NX with Devkit SOM (with micro-SD card)        | jetson-xavier-nx-devkit      |
| Jetson TX2                                                   | jetson-tx2                   |

## 3 配置

### 3.1 组装 `rootfs`

```bash
cd $WS
tar -xpf $L4T_RELEASE_PACKAGE
cd Linux_for_Tegra/rootfs/
tar -xpf $SAMPLE_FS_PACKAGE   # 将SAMPLE_FS_PACKAGE解压到Tegra/rootfs/目录下
cd ..
sudo ./apply_binaries.sh
```

### 3.2 解压内核源码

```bash
cd $WS
tar -xjf  public_sources.tbz2 
cd Linux_for_Tegra/source/public/
tar -xjf kernel_src.tbz2
```

若有编译好的二进制文件，替换到相关目录，直接跳转到 `3.6.4`  进行刷机即可，例如：

```bash
cp tegra234-p3701-0000-p3737-0000.dtb /home/dafa/jetson_flash/r35.1/Linux_for_Tegra/kernel/dtb
cp Image /home/dafa/jetson_flash/r35.1/Linux_for_Tegra/kernel/
cp nvgpu.ko /home/dafa/jetson_flash/r35.1/Linux_for_Tegra/rootfs/usr/lib/modules/5.10.104-tegra/kernel/drivers/gpu/nvgpu
```

### 3.3 安装交叉编译工具

工具链组件

- GCC 版本：9.3.0

- Binutils 版本：2.33.1

- Glibc 版本：2.31

提取工具链

```bash
cd $WS
tar xf aarch64--glibc--stable-final.tar.gz -C l4t-gcc/
```

### 3.4 生成默认 `.config` 文件

```bash
cd $KERNEL_SOURCE
make ARCH=arm64 O=$TEGRA_KERNEL_OUT tegra_defconfig
```

生成的 `.config` 文件位于 $TEGRA_KERNEL_OUT。

### 3.5 修改内核配置文件

```shell
cd $KERNEL_SOURCE # kernel-5.10
make DEFCONFIG_PATH=arch/arm64/configs tegra_defconfig
make menuconfig
# <<Update config options>> 功能剪切，可以直接选择 exit
make savedefconfig
cp -v defconfig arch/arm64/configs/tegra_defconfig
make mrproper
```

### 3.6 编译内核

#### 3.6.1 正常编译

执行以下命令构建内核

```bash
cd $KERNEL_SOURCE
make ARCH=arm64 O=$TEGRA_KERNEL_OUT -j12
```
也可以参考[官方文档](https://docs.nvidia.com/jetson/archives/r35.1/DeveloperGuide/text/SD/Kernel/KernelCustomization.html#kernel-customization)使用 `nvbuild.sh` 脚本进行编译，与上述 `make` 命令编译结果相同，命令为 `./nvbuild.sh -o $TEGRA_KERNEL_OUT`。
```bash
# 替换 Image
cp $TEGRA_KERNEL_OUT/arch/arm64/boot/Image $WS/Linux_for_Tegra/kernel/Image
# 替换所有 dtb
cp -r $TEGRA_KERNEL_OUT/arch/arm64/boot/dts/nvidia $WS/Linux_for_Tegra/kernel/dtb/
# 也可以只替换 tegra234-p3701-0000-p3737-0000.dtb
cp $TEGRA_KERNEL_OUT/arch/arm64/boot/dts/nvidia/tegra234-p3701-0000-p3737-0000.dtb $WS/Linux_for_Tegra/kernel/dtb/
# 替换 nvgpu.ko
cp $TEGRA_KERNEL_OUT/drivers/gpu/nvgpu/nvgpu.ko $WS/Linux_for_Tegra/rootfs/usr/lib/modules/5.10.104-tegra/kernel/drivers/gpu/nvgpu/nvgpu.ko
```

Note：

- 编译源码生成的设备树文件为 `tegra234-p3701-0000-p3737-0000.dtb`，在 devkit 中的路径为 `/boot/dtb/kernel_tegra234-p3701-0000-p3737-0000.dtb`，可以直接将新的设备树文件拷贝到 devkit 对应的目录进行更新，也可以按上述步骤替换
- Image 在 devkit 中的路径为 /boot/Image
- 替换 `nvgpu.ko` 也可以采用设备树更新的方法，在 `devkit` 的路径为`/lib/modules/5.10.104-tegra/kernel/drivers/gpu/nvgpu/nvgpu.ko`

#### 3.6.2 编译后生成的内核模块安装到 L4T 包

在`${KERNEL_SOURCE} ` 中执行以下命令,

```bash
make ARCH=arm64 O=$TEGRA_KERNEL_OUT modules_install INSTALL_MOD_PATH=$WS/Linux_for_Tegra/rootfs/
```

#### 3.6.3 烧写

```bash
cd $WS/Linux_for_Tegra
sudo ./flash.sh $BOARD mmcblk0p1
```

安装过程完成后，Jetson 设备自动重启。

#### 3.6.4 镜像克隆生成批量刷机包

详细说明参阅：`Linux_for_Tegra/tools/kernel_flash/README_initrd_flash.txt`。

```shell
# 暂时禁用自动挂载新的外部存储设备
systemctl stop udisks2.service
# jetson置于刷机模式，生成文件名为 mfi_jetson-agx-orin-devkit.tar.gz
cd $WS/Linux_for_Tegra
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash --massflash 5 jetson-agx-orin-devkit mmcblk0p1
# 使用，x为批量的设备数
tar xpfv  mfi_jetson-agx-orin-devkit.tar.gz
cd mfi_jetson-agx-orin-devkit
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --flash-only --massflash <x>
```

#### 3.6.5 备份镜像

创建一个备份镜像，可以用于恢复一个Jetson设备

```bash
cd Linux_for_Tegra
sudo ./tools/backup_restore/l4t_backup_restore.sh -b -c  <board-name>
```

其中`<board-name>`类似于`flash.sh`命令中使用的相应变量。如果此命令成功完成，则生成的 image 将存储在`Linux_for_Tegra/tools/kernel_flash/images `中。

使用备份镜像生成批量刷机包

```bash
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --use-backup-image --no-flash --massflash <x> <board-name> mmcblk0p1
```

生成批量刷机包后使用方法跟 3.6.4 相同。更详细说明参阅 `README_backup_restore.txt`

## 4 其他

```bash
# 串口连接
minicom -D /dev/ttyACM0
# device-tree
dtc -I fs -O dts -o extracted.dts /proc/device-tree
# EP 相关的寄存器
sudo busybox devmem 0x2444008 0x170
sudo busybox devmem 0x2444000 0x560
# 查看设备模式
cat /proc/device-tree/pcie@141a0000/status;echo
cat /proc/device-tree/pcie_ep@141a0000/status;echo
# 查看系统配置
zcat /proc/config.gz
# 刷机添加用户名等
cd Linux_for_Tegra/tools
./l4t_create_default_user.sh -u orin-a -p 1 -n hermes -a
```



| BOARDID                         | BOARDSKU | FAB  | BOARDREV |
| ------------------------------- | -------- | ---- | -------- |
| jetson-agx-xavier-industrial    | 2888     | 600  | A.0      |
| clara-agx-xavier-devkit"        | 3900     | 001  | C.0      |
| jetson-xavier-nx-devkit         | 3668     | 100  | N/A      |
| jetson-xavier-nx-devkit-emmc    | 3668     | 100  | N/A      |
| jetson-xavier-nx-devkit-emmc    | 3668     | N/A  | N/A      |
| jetson-agx-xavier-devkit (16GB) | 2888     | 400  | H.0      |
| jetson-agx-xavier-devkit (32GB) | 2888     | 400  | K.0      |
| jetson-agx-orin-devkit          | 0001     | TS1  | C.2      |
| jetson-agx-orin-devkit          | 0000     | TS1  | A.0      |
| jetson-agx-xavier-devkit (64GB) | 0005     | 402  | B.0      |
| holoscan-devkit                 | 0002     | TS1  | A.0      |
| jetson-agx-orin-devkit          | 0004     | TS4  | A.0      |

