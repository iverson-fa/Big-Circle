# Jetson 刷机

SDK Manager 不能满足定制化刷机，本文档以 Jetson AGX Orin 为例，L4t 版本为35.1，其余设备只需修改对应的环境变量即可。

[Jetson Linux Archive](https://developer.nvidia.com/embedded/jetson-linux-archive)

| JETSON LINUX  Version                                        | Jetson AGX Orin | Jetson Orin NX | Jetson AGX Xavier | Jetson AGX Xavier Industrial | Jetson Xavier NX |
| ------------------------------------------------------------ | --------------- | -------------- | ----------------- | ---------------------------- | ---------------- |
| [35.2.1](https://developer.nvidia.com/embedded/jetson-linux-r3521) | ✔*              | ✔**            | ✔                 | ✔                            | ✔                |
| [35.1](https://developer.nvidia.com/embedded/jetson-linux-r351) | ✔*              |                | ✔                 | ✔                            | ✔                |
| [34.1.1](https://developer.nvidia.com/embedded/jetson-linux-r3411) | ✔               |                | ✔                 |                              | ✔                |
| [34.1](https://developer.nvidia.com/embedded/jetson-linux-r341) | ✔               |                | ✔                 |                              | ✔                |
| [36.3](https://developer.nvidia.com/embedded/jetson-linux-r363) | ✔ | ✔ |  |  |  |

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

```
# 也可以修改如下文件
source/public/kernel/kernel-5.10/arch/arm64/configs/defconfig
```

### 3.5 修改内核配置文件

```shell
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

JP5.x 烧录AGX Orin
```bash
cd $WS/Linux_for_Tegra
sudo ./flash.sh $BOARD mmcblk0p1
```

JP6.x 烧录
```shell
# Jetson Orin Nano Developer Kit (NVMe):
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 \
  -c tools/kernel_flash/flash_l4t_t234_nvme.xml -p "-c bootloader/generic/cfg/flash_t234_qspi.xml" \
  --showlogs --network usb0 jetson-orin-nano-devkit internal

# Jetson Orin Nano Developer Kit (USB):
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device sda1 \
  -c tools/kernel_flash/flash_l4t_t234_nvme.xml -p "-c bootloader/generic/cfg/flash_t234_qspi.xml" \
  --showlogs --network usb0 jetson-orin-nano-devkit internal

# Jetson Orin Nano Developer Kit (SD card):
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device mmcblk0p1 \
  -c tools/kernel_flash/flash_l4t_t234_nvme.xml -p "-c bootloader/generic/cfg/flash_t234_qspi.xml" \
  --showlogs --network usb0 jetson-orin-nano-devkit internal

# Jetson AGX Orin Developer Kit (eMMC):
sudo ./flash.sh jetson-agx-orin-devkit internal

# Jetson AGX Orin Developer Kit (NVMe):
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 \
  -c tools/kernel_flash/flash_l4t_t234_nvme.xml \
  --showlogs --network usb0 jetson-agx-orin-devkit external

# Jetson AGX Orin Developer Kit (USB):
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device sda1 \
  -c tools/kernel_flash/flash_l4t_t234_nvme.xml \
  --showlogs --network usb0 jetson-agx-orin-devkit external

# Jetson AGX Orin Developer Kit (SD card):
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device mmcblk0p1 \
  -c tools/kernel_flash/flash_l4t_t234_nvme.xml \
  --showlogs --network usb0 jetson-agx-orin-devkit external
```

安装过程完成后，Jetson 设备自动重启。

#### 3.6.4 生成批量刷机包

详细说明参阅：`Linux_for_Tegra/tools/kernel_flash/README_initrd_flash.txt`。offline模式查看所需4个参数。

```shell
# 暂时禁用自动挂载新的外部存储设备
systemctl stop udisks2.service
# online模式：jetson置于刷机模式，生成文件名为 mfi_jetson-agx-orin-devkit.tar.gz
cd $WS/Linux_for_Tegra
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash --network usb0 --massflash 5 jetson-agx-orin-devkit mmcblk0p1
# offline模式, AGX Orin 32G模组，
cd $WS/Linux_for_Tegra
sudo BOARDID=3701 FAB=500 BOARDSKU=0004 BOARDREV=J.0 ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash --network usb0 --massflash 5 jetson-agx-orin-devkit mmcblk0p1
# 使用，x为批量的设备数
tar xpfv  mfi_jetson-agx-orin-devkit.tar.gz
cd mfi_jetson-agx-orin-devkit
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --flash-only --network usb0 --massflash <x>
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

生成批量刷机包后使用方法跟 3.6.4 相同。更详细说明参阅 `README_backup_restore.txt`。

## 4 其他

### 4.1 some orders

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

### 4.2 flash.sh 使用方法

```shell
Usage: sudo ./flash.sh [options] <target_board> <rootdev>
  Where,
	target board: Valid target board name.
	rootdev: Proper root device.
    options:
        -c <cfgfile> ---------- Flash partition table config file.
        -d <dtbfile> ---------- device tree file.
        -f <flashapp> --------- Path to flash application (tegraflash.py)
        -h -------------------- print this message.
        -i <enc rfs key file>-- key for disk encryption support.
        -k <partition id> ----- partition name or number specified in flash.cfg.
        -m <mts preboot> ------ MTS preboot such as mts_preboot_si.
        -n <nfs args> --------- Static nfs network assignments
                                <Client IP>:<Server IP>:<Gateway IP>:<Netmask>
        -o <odmdata> ---------- ODM data.
        -r -------------------- skip building and reuse existing system.img.
        -t <tegraboot> -------- tegraboot binary such as nvtboot.bin
        -u <PKC key file>------ PKC key used for odm fused board.
        -v <SBK key file>------ Secure Boot Key (SBK) key used for ODM fused board.
        -w <wb0boot> ---------- warm boot binary such as nvtbootwb0.bin
        -x <tegraid> ---------- Tegra CHIPID.
        -B <boardid> ---------- BoardId.
        -C <cmdline> ---------- Kernel commandline arguments.
                                WARNING:
                                Each option in this kernel commandline gets
                                higher preference over the values set by
                                flash.sh. In case of NFS booting, this script
                                adds NFS booting related arguments, if -i option
                                is omitted.
        -F <flasher> ---------- Flash server such as cboot.bin.
        -G <file name> -------- Read partition and save image to file.
        -I <initrd> ----------- initrd file. Null initrd is default.
        -K <kernel> ----------- Kernel image file such as zImage or Image.
        -L <bootloader> ------- Bootloader such as cboot.bin or u-boot-dtb.bin.
        -M <mts boot> --------- MTS boot file such as mts_si.
        -N <nfsroot> ---------- i.e. <my IP addr>:/my/exported/nfs/rootfs.
        -R <rootfs dir> ------- Sample rootfs directory.
        -S <size> ------------- Rootfs size in bytes. Valid only for internal
                                rootdev. KiB, MiB, GiB short hands are allowed,
                                for example, 1GiB means 1024 * 1024 * 1024 bytes.
        -Z -------------------- Print configurations and then exit.
        --no-flash ------------ perform all steps except physically flashing the board.
                                This will create a system.img.
        --external-device------ Generate flash images for external devices
        --sparseupdate--------- only flash partitions that have changed. Currently only support SPI flash memory
        --no-systemimg -------- Do not create or re-create system.img.
        --bup ----------------- Generate bootloader update payload(BUP).
        --single-image-bup <part name> Generate specified single image BUP, this must work with --bup.
        --bup-type <type> ----- Generate specific type bootloader update payload(BUP), such as bl or kernel.
        --multi-spec----------- Enable support for building multi-spec BUP.
        --clean-up------------- Clean up BUP buffer when multi-spec is enabled.
        --usb-instance <id> --- Specify the USB instance to connect to;
                                <id> = USB port path (e.g. 3-14).
        --no-root-check ------- Typical usage of this script require root permissions.
                                Pass this option to allow running the script as a
                                regular user, in which case only specific combinations
                                of command-line options will be functional.
        --user_key <key_file>   User provided key file (16-byte) to encrypt user images,
                                like kernel, kernel-dtb and initrd.
                                If user_key is specified, SBK key (-v) has to be specified.
                                For now, user_key file must contain all 0's.
        --uefi-keys <keys_conf> Specify UEFI keys configuration file.
        --rcm-boot ------------ Do RCM boot instead of physically flashing the board.
        --sign ---------------- Sign images and store them under "bootloader/signed"
                                directory. The board will not be physically flashed.
        --image --------------- Specify the image to be written into board.
        --boot-chain-flash <c>  Flash only a specific boot chain (ex. "A, "B", "all").
                                Defaults to "all", inputs are case insensitive.
                                Not suitable for production.
        --boot-chain-select <c> Specify booting chain (ex. "A" or "B") after the board is flashed.
                                Defaults to "A", inputs are case insensitive.
        --pv-crt -------------- The certificate for the key that is used to sign cpu_bootloader
```

### 4.3 l4t_initrd_flash.sh 使用方法

```shell
Usage: ./tools/kernel_flash/l4t_initrd_flash.sh <options> <board-name> <rootdev>
Where,
    -u <PKC key file>            PKC key used for odm fused board.
    -v <SBK key file>            SBK key used for encryptions
    -p <option>                  Pass options to flash.sh when generating the image for internal storage
    -k <target_partition>        Only flash parition specified with the label <target_partition>
    <board-name>                 Indicate which board to use.
    <rootdev>                    Indicate what root device to use
    --no-flash                   Generate the flash images
    --flash-only                 Flash using existing images
    --external-device <dev>      Generate and/or flash images for the indicated external storage
                                 device. If this is used, -c option must be specified.
    --external-only              Skip generating internal storage images
    --usb-instance               Specify the usb port where the flashing cable is plugged (i.e 1-3)
    --sparse                     Use sparse image to flash instead of tar image.
    -c <config file>             The partition layout for the external storage device.
    -S <size>                    External APP partition size in bytes. KiB, MiB, GiB short hands are allowed,
                                 for example, 1GiB means 1024 * 1024 * 1024 bytes. (optional)
    --massflash [<max_devices>]  Flash multiple device. Receive an option <count> argument to indicate the
                                 maximum number of devices supported. Default is 10 if not specified in board config file
    --showlogs                   Spawn gnome-terminal to show individual flash process logs. Applicable
                                 for --massflash only.
    --reuse                      Reuse existing working environment kept by --keep option.
    --keep                       Keep working environment instead of cleaning up after flashing
    --erase-all                  Delete all storage device before flashing
    --initrd                     Stop after device boot into initrd.
    --network <netargs>          Flash through Ethernet protocal using initrd flash. <netargs> can be "usb0" to flash through the USB Flashing cable
                                 or "eth0:<target-ip>/<subnet>:<host-ip>[:<gateway>]" to flash through the LAN cable
                                 For examples:
                                 --network usb0
                                 --network eth0:192.168.0.17/24:192.168.0.21
                                 --network eth0:192.168.0.17/24:192.168.1.2:192.168.0.1

    --append                     Only applicable when using with --no-flash --external-only option. This option is parts of
                                 the three steps flashing process to generate images for internal device and external device seperately
                                 and flash them together.
                                 For examples:
                                1. sudo ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash jetson-xavier internal
                                2. sudo ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash --external-device nvme0n1p1 -S 5120000000 -c flash_enc.xml --external-only --append jetson-xavier internal
                                3. sudo ./tools/kernel_flash/l4t_initrd_flash.sh --flash-only jetson-xavier internal

    --direct <dev>               Flash the device directly connected to host with the <dev> name
                                 For examples,
                                 sudo ./tools/kernel_flash/l4t_initrd_flash.sh --direct sdb --external-device sda -c flash_external.xml concord sda1

    --user_key <key_file>        User provided key file (16-byte) to encrypt user images, like kernel, kernel-dtb and initrd.
                                 If user_key is specified, SBK key (-v) has to be specified.
                                 For now, user_key file must contain all 0's.

    --pv-crt <crt file>          The certificate for the key that is used to sign cpu_bootloader




With --external-device options specified, the supported values for <dev> are
    nvme0n1
    sda

Examples:
	Both external and internal flash
	sudo <BSP_TOOLS_DIR>/./tools/kernel_flash/l4t_initrd_flash.sh  -c ~/Downloads/flash_l4t_nvme.xml -S 10240000000 --external-device nvme0n1 jetson-xavier-nx-devkit-emmc external

	Internal only
	sudo <BSP_TOOLS_DIR>/./tools/kernel_flash/l4t_initrd_flash.sh  jetson-xavier-nx-devkit-emmc mmcblk0p1


	External only:
	sudo <BSP_TOOLS_DIR>/./tools/kernel_flash/l4t_initrd_flash.sh  --external-only -c ~/Downloads/flash_l4t_nvme.xml -S 10240000000 --external-device nvme0n1 jetson-xavier-nx-devkit-emmc external
```

### 4.4 chroot 跨平台编译

**1 获取根文件系统**

- 通过[Ubuntu官网](http://cdimage.ubuntu.com/ubuntu-base/releases/)下载
- 使用NVIDIA的BSP包

**2 修改根文件目录**

```shell
#拷贝host系统的文件到rootfs里面
sudo cp -b /etc/resolv.conf rootfs/etc/resolv.conf
#如果没有qemu-aarch64-static 就执行命令安装 sudo apt install -y qemu-system-arm
sudo cp /usr/bin/qemu-aarch64-static rootfs/usr/bin/
```

**3 使用 chroot 启动**

```shell
sudo chroot rootfs/
mknod -m 644 /dev/random c 1 8
mknod -m 644 /dev/urandom c 1 9
chown root:root /dev/random /dev/urandom
```

**4 可用脚本**

使用方法：`sudo ./chroot.sh rootfs`

```shell
#!/bin/bash

# qemu binary location:
ARCH="aarch64"
BIN=$(which qemu-${ARCH}-static)

# parse arguments
if [[ $# -ne 1 ]] || [[ $1 == "--help" ]]; then
    echo "usage: $0 rootfs_path"
    exit 1
fi

# make sure we have the requisite permissions
if [[ $(id -u) -ne "0" ]]; then
    echo "this script must be run as root"
    exit 1
fi

# make sure qemu is installed
if [[ ! -f ${BIN} ]]; then
    echo "${BIN} not found. Please run: sudo apt install qemu-user-static"
fi

# be verbose, print every line in script from here on
set -x

# copy qemu to the rootfs
cp ${BIN} $1/usr/bin

# mount special filesystems
mount -t sysfs -o ro none $1/sys
mount -t proc -o ro none $1/proc
mount -t tmpfs none $1/tmp
mount -o bind,ro /dev $1/dev
mount -t devpts none $1/dev/pts
mount -o bind,ro /etc/resolv.conf $1/run/resolvconf/resolv.conf

# enter chroot
chroot $1 /bin/bash

# unmount special filesystems
umount $1/sys
umount $1/proc
umount $1/tmp
umount $1/dev/pts
umount $1/dev
umount $1/run/resolvconf/resolv.conf

# remove qemu from the rootfs
rm $1${BIN}
```

### 4.5 使用BSP根文件系统制作docker镜像

官方的根文件系统为 `Tegra_Linux_Sample-Root-Filesystem_<version>_aarch64.tbz2`，可以根据实际使用版本下载。

```shell
#导入docker镜像
sudo docker import Tegra_Linux_Sample-Root-Filesystem_R35.3.1_aarch64.tbz2 jetson/orin:r35.3.1
#查看已经导入的镜像
sudo docker images
#运行docker镜像
sudo docker run -it -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static jetson/orin:r35.3.1 /bin/bash
#按需修改后，导出docker镜像文件
#查看所有容器
sudo docker ps -a
#导出docker镜像文件
sudo docker export -o nvidia_orin.tar <CONTAINER ID>
```

### 4.6 基于空镜像构建

```shell
# 获取scratch基础镜像
$ tar cv --files-from /dev/null | sudo docker import - scratch
# 新建目录，将根文件系统（参考4.4）copy到该目录
$ mkdir docker_orin
$ touch dockerfile
# 编辑 dockerfile
FROM scratch
LABEL maintainer="nvidia_orin"
ADD Tegra_Linux_Sample-Root-Filesystem_<version>_aarch64.tbz2 /
RUN apt-get update
WORKDIR /home/nvidia
CMD /bin/bash
# 开始构建
$ sudo docker build -t nvidia_orin .
# 运行
$ sudo docker run -it -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static nvidia_orin /bin/bash

```

### 4.7 dtc反编译

```shell
# dtb -> dts
dtc -I dtb -O dts xxx.dtb -o xxx.dts
# dts -> dtb
dtc -I dts -O dtb xxx.dts -o xxx.dtb
```

