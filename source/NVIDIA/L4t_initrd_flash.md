# 使用 initrd 烧录

## 1. 简介

NVIDIA Jetson Linux 软件包提供了使用目标上运行的 recovery kernel initrd 从 host 烧录 Jetson 设备的工具。

Requirements:

- 这个工具在烧录过程中会使用USB大容量存储，所以需要禁掉自动挂载外部存储设备服务：

  ```bash
  systemctl stop udisks2.service
  ```

- 安装依赖:

  ```bash
  sudo tools/l4t_flash_prerequisites.sh
  ```

How to use:
- 此工具不支持内部 emmc/sdcard 的 size discovery，在`bootloader/t186ref/cfg`中有一个变量`num_sectors`，如果缺省值不兼容的话，必须修改这个值，使得`num_sectors * sector_size`小于等于Jetson设备的 emmc/sdcard 的大小
- 此工具支持 T194/T234 设备，可以使用 `-h` 参数确定支持的选项

## 2. 烧录单个设备

确认只有一个recovery模式的Jetson设备与host连接

```shell
# 在Linux_for_Tegra中执行
sudo ./tools/kernel_flash/l4t_initrd_flash.sh <board-name> <rootdev>
```

其中 <board-name> 和<rootdev>与 `flash.sh`命令中使用的相关参数类似，具体可参考官方文档的 board name 表格

## 3. 先生成镜像再烧录

### 3.1 生成镜像

**在线模式（设备连接）**

确认只有一个recovery模式的Jetson设备与host连接

```shell
# 在Linux_for_Tegra中执行
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash <board-name> <rootdev>
```

其中 <board-name> 和<rootdev>与 `flash.sh`命令中使用的相关参数类似，具体可参考官方文档的 board name 表格

**离线模式（没有设备连接）**

```shell
# 在Linux_for_Tegra中执行，生成烧录镜像
sudo BOARDID=<BOARDID> FAB=<FAB> BOARDSKU=<BOARDSKU> BOARDREV=<BOARDREV> \
./tools/kernel_flash/l4t_initrd_flash.sh --no-flash <board-name> <rootdev>
```

### 3.2 烧录

将设备置于recovery模式

```shell
# 在Linux_for_Tegra中执行
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --flash-only <board-name> <rootdev>
```

这些参数可以参考底部的表格。

## 4 烧录外部存储

要烧录到外部连接的存储设备，需要为外部设备创建自己的分区配置 xml 文件，具体信息参考官方文档的[External Storage Device Partition](https://docs.nvidia.com/jetson/archives/r35.3.1/DeveloperGuide/text/AR/BootArchitecture/PartitionConfiguration.html#external-storage-device-partition)。**NOTE：**需要修改 xml 文件里的`num_sectors`，使得`num_sectors * sector_size `的结果小于等于外部存储。对于所有类型的外部存储设备，参数`type`的值都是`nvme`。

在`tools/kernel_flash`目录中有三个 xml 文件：

- `flash_l4t_external.xml` contains both the rootfs, kernel and kernel-dtb on the
  external storage device.
- `flash_l4t_nvme_rootfs_enc.xml` is a sample partition configuration that is used for
  disk encryption feature on external storage.
- `lash_l4t_nvme_rootfs_ab.xml` is a sample partition configuration that is used for the
  rootfs ab feature on external storage.

示例程序假设外部存储空间大于等于64G。

To flash, run this command from the Linux_for_Tegra folder:
$ sudo ADDITIONAL_DTB_OVERLAY_OPT=<opt> ./tools/kernel_flash/l4t_initrd_flash.sh --external-device <external-device> \
      -c <external-partition-layout> \
      [ --external-only ] \
      [ -S <APP-size> ] \
      [ --network <netargs> ] <board-name> <rootdev>
Where:
- <board-name> and <rootdev> variables are similar to those that are used for
  flash.sh. (See more details in the official documentation's board name
  table).
- <root-dev> can be set to "mmcblk0p1" or "internal" for booting from internal
  device or "external", "sda1" or "nvme0n1p1" for booting from external device.
  If your external device's external partition layout has "APP" partition,
  specifying here "nvme0n1p1" will generate the rootfs boot commandline:
  root=/dev/nvme0n1p1. If <rootdev> is internal or external, the tool will
  generate rootfs commandline: root=PARTUUID=...
- <external-partition-layout> is the partition layout for the external storage
  device in XML format.
- <external-device> is the name of the external storage device you want to flash
  as it appears in the '/dev/' folder (i.e nvme0n1, sda).
- <APP-size> is the size of the partition that contains the operating system in bytes.
  KiB, MiB, GiB shorthand are allowed, for example, 1GiB means 1024 * 1024 *
  1024 bytes. This size cannot be bigger than "num_sectors" * "sector_size"
  specified in the <external-partition-layout> and must be small enough to fit
  other partitions in the partition layout.
- Use --external-only to flash only the external storage device.
  If you do not provide the "--external-only" option, the command will flash both internal and
  external storage devices.
- Use --network <netargs> if you want the flash process to happen through Ethernet protocol
  instead of USB protocol. Ethernet protocol is more reliable than USB protocol
  for external devices like USB.
  <netargs> can be "usb0" when flashing using ethernet protocol through the usb
  flashing cable or "eth0:<target-ip>/<subnet>:<host-ip>" when flashing using
  ethernet protocol through the RJ45 cable.
- (Optional) Declare ADDITIONAL_DTB_OVERLAY_OPT=<opt> where <opt> can be BootOrderNvme.dtbo.
  This allows UEFI to prioritize booting from NVMe SSD. <opt> can also be BootOrderUsb.dtbo, which
  allows UEFI to prioritize booting from the USB storage drive


Example usage:
Flash an NVMe SSD and use APP partition on it as root filesystem:
sudo ADDITIONAL_DTB_OVERLAY_OPT="BootOrderNvme.dtbo" ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 -c ./tools/kernel_flash/flash_l4t_external.xml  --showlogs  jetson-xavier nvme0n1p1

Flash USB-connected storage use APP partition on it as root filesystem:
sudo ADDITIONAL_DTB_OVERLAY_OPT="BootOrderUsb.dtbo" ./tools/kernel_flash/l4t_initrd_flash.sh --external-device sda1 -c ./tools/kernel_flash/flash_l4t_external.xml  --showlogs  jetson-xavier mmcblk0p1

Flash an NVMe SSD and use the partition UUID (that is specified in l4t-rootfs-uuid.txt_ext) as the root filesystem:
sudo ADDITIONAL_DTB_OVERLAY_OPT="BootOrderNvme.dtbo" ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 -c ./tools/kernel_flash/flash_l4t_external.xml  --showlogs  jetson-xavier external



Initrd flash depends on --external-device options and the last parameter <rootdev>
to generate the correct images. The following combinations are supported:
+-------------------+-----------------+-------------------------------------------------------+
| --external-device |       <rootdev> | Results                                               |
+-------------------+-----------------+-------------------------------------------------------+
| nvme*n*p* / sda*  |        internal | External device contains full root filesystem with    |
|                   |                 | kernel commandline: rootfs=PARTUUID=<external-uuid>   |
|                   |                 |                                                       |
|                   |                 | Internal device contains full root filesystem with    |
|                   |                 | kernel commandline: rootfs=PARTUUID=<internal-uuid>   |
+-------------------+-----------------+-------------------------------------------------------+
| nvme*n*p* / sda*  | nvme0n*p* / sd* | External device  contains full root filesystem with   |
|                   |                 | with kernel commandline rootfs=/dev/nvme0n1p1         |
|                   |                 |                                                       |
|                   |                 | Internal device contains minimal filesystem with     |
|                   |                 | kernel command line rootfs=/dev/nvme0n1p1             |
+-------------------+-----------------+-------------------------------------------------------+
| nvme*n*p* / sda*  |       mmcblk0p1 | External device  contains full root filesystem with   |
|                   |                 | with kernel commandline rootfs=/dev/nvme0n1p1         |
|                   |                 |                                                       |
|                   |                 | Internal device contains full filesystem with     |
|                   |                 | kernel command line rootfs=/dev/mmcblk0p1             |
+-------------------+-----------------+-------------------------------------------------------+
| nvme*n*p* / sda*  |        external | External device contains full root filesystem with    |
|                   |                 | kernel commandline: rootfs=PARTUUID=<external-uuid>   |
|                   |                 |                                                       |
|                   |                 | Internal device contains minimal root filesystem with |
|                   |                 | kernel commandline: rootfs=PARTUUID=<external-uuid>   |
+-------------------+-----------------+-------------------------------------------------------+





Workflow 4: How to flash to device with internal qspi and an external storage device:
Some Jetson devices like Jetson Orin NX and Jetson Xavier NX have an internal QSPI and an external
storage device, which flash.sh may not have support flashing yet. In this case you can use the
following commands:

For a device with internal QSPI and external NVMe:
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 \
      -c tools/kernel_flash/flash_l4t_external.xml \
      -p "-c bootloader/t186ref/cfg/flash_t234_qspi.xml --no-systemimg" --network usb0 \
      <board> external


For a device with internal QSPI and external USB storage:
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device sda1 \
      -c tools/kernel_flash/flash_l4t_external.xml \
      -p "-c bootloader/t186ref/cfg/flash_t234_qspi.xml --no-systemimg" --network usb0 \
      <board> external




Workflow 5: ROOTFS_AB support and boot from external device:
ROOTFS_AB is supported by setting the ROOTFS_AB environment variable to 1. For
example:
sudo ROOTFS_AB=1 ./tools/kernel_flash/l4t_initrd_flash.sh \
      --external-device nvme0n1 \
      -S 8GiB \
      -c ./tools/kernel_flash/flash_l4t_nvme_rootfs_ab.xml \
      jetson-xavier \
      external





Workflow 6: Secureboot
With Secureboot package installed, you can flash PKC fused or SBKPKC fused
Jetson. For example:
$ sudo ./tools/kernel_flash/l4t_initrd_flash.sh \
      -u pkckey.pem \
      -v sbk.key \
      [-p "--user_key user.key" ] \
      --external-device nvme0n1 \
      -S 8GiB \
      -c ./tools/kernel_flash/flash_l4t_external.xml \
      jetson-xavier \
      external





Workflow 7: Initrd Massflash
Initrd Massflash works with workflow 3,4,5. Initrd massflash also requires you to do the massflash
in two steps.

First, generate massflash package using options --no-flash and --massflash <x> and --network usb0
Where <x> is the highest possible number of devices to be flashed concurrently.

Both online mode and offline mode are supported (Details can be seen in workflow 2).
In the example below, we use online mode to create a flashing environment that is
capable of flashing 5 devices concurrently.

$ sudo BOARDID=<BOARDID> FAB=<FAB> BOARDSKU=<BOARDSKU> BOARDREV=<BOARDREV>
./tools/kernel_flash/l4t_initrd_flash.sh --no-flash --massflash 5 --network usb0 jetson-xavier-nx-devkit-emmc mmcblk0p1

(For the value of BOARDID, FAB, BOARDSKU and BOARDREV, please refer to the table at the bottom of this file.)


Second,
- Connect all 5 Jetson devices to the flashing hosts.
(Make sure all devices are in exactly the same hardware revision similar to the requirement in
README_Massflash.txt )
- Put all of connected Jetsons into RCM mode.
- Run:
$ sudo ./tools/kernel_flash/l4t_initrd_flash.sh --flash-only --massflash 5 --network usb0
(Optionally add --showlogs to show all of the log)

Note:
the actual number of connected devices can be less than the maximum number
of devices the package can support.


Tips:
- The tool also provides the --keep option to keep the flash
  environment, and the --reuse options to reuse the flash environment to make
  massflash run faster:

  Massflash the first time.
  $ sudo ./tools/kernel_flash/l4t_initrd_flash.sh --flash-only --massflash 5 --network usb0 --keep

  Massflash the second time.
  $ sudo ./tools/kernel_flash/l4t_initrd_flash.sh --flash-only --massflash 5 --network usb0 --reuse

- Use ionice to make the flash process the highest I/O priority in the system.
  $ sudo ionice -c 1 -n 0 ./tools/kernel_flash/l4t_initrd_flash.sh --flash-only --network usb0 --massflash 5






Workflow 8: Secure initrd Massflash

Here are the steps to flash in unsecure factory floor.

First, generate a massflash package using the --no-flash and --massflash <x>
options, and specify the neccessary keys using the -u and -v options, where <x>
is the highest possible number of devices to be flashed concurrently. In the
example below, we create a flashing environment in online mode that is
capable of flashing 5 devices concurrently.

$ sudo ./tools/kernel_flash/l4t_initrd_flash.sh -u <pkckey> [-v <sbkkey>] --no-flash --massflash 5 jetson-xavier-nx-devkit-emmc mmcblk0p1

The tool generates a tarball called mfi_<target-board>.tar.gz that contains all
the minimal binaries needed to flash in an unsecure environment. Download this
tarball to the unsafe environment, and untar the tarball to create a flashing
environment. For examples,
$ scp mfi_<target-board>.tar.gz <factory-host-ip>:<factory-host-dir>
...
Untar on a factory host machine:
$ sudo tar xpfv mfi_<target-board>.tar.gz

Second, perform this procedure:
- Connect the Jetson devices to the flashing hosts.
  (Make sure all devices are in exactly the same hardware revision similar to
  the requirement in README_Massflash.txt )
- Put all of connected Jetsons into RCM mode.
- Run:
  $ cd mfi_<target-board>
  $ sudo ./tools/kernel_flash/l4t_initrd_flash.sh --flash-only --massflash 5
  (Optionally add --showlogs to show all of the log)






Workflow 9: Flash inidividual partition

Initrd flash has an option to flash individual partitions based on the index file.
When running initrd flash, index files are generated under tools/kernel_flash/images
based on the partition configuration layout xml (images/internal/flash.idx for internal storage,
images/external/flash.idx for external storage). Using "-k" option, initrd flash can flash one
partition based on the partition label specified in the index file.

Examples:
For flashing eks partition on internal device:
$ sudo ./tools/kernel_flash/l4t_initrd_flash.sh -k eks jetson-xavier mmcblk0p1


For flashing kernel-dtb partition on external device:
$ sudo ./tools/kernel_flash/l4t_initrd_flash.sh \
  --external-device nvme0n1p1 \
  -c ./tools/kernel_flash/flash_l4t_external.xml \
  -k kernel-dtb --external-only jetson-xavier mmcblk0p1


Workflow 10: Disk encryption support on external device

For disk encryption for external device on Jetson Xavier, you can flash the external
device with the below command:

- Run this command from the Linux_for_Tegra folder:
  $ sudo ROOTFS_ENC=1 ./tools/kernel_flash/l4t_initrd_flash.sh --external-device <external-device> \
      -c <external-partition-layout> \
      [-p "-i encryption.key" ] --external-only \
      -S <APP-size> jetson-xavier external

Where:
- all the parameters are the same as above.
- <external-partition-layout> is the external storage partition layout containing
APP, APP_ENC and UDA encrypted partition. In this folder, flash_l4t_nvme_rootfs_enc.xml
is provided as an example.





Workflow 11: Generate images for internal device and external device seperately
then flash

The flashing tool supports a three-step process: "to generate images for an
internal device, then generate them for an external device, then flash.
This is enabled by using the "append" option. Four examples below show how it
works.

Example 1: Generate a normal root filesystem configuration for the internal device
, then generate an encrypted root filesystem for the external device, then flash

1. Put the device into recovery mode, then generate a normal root
filesystem for the internal device:
$ sudo ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash jetson-xavier internal
(Or if you want to generate the image offline, then you can use:
$ sudo BOARDID=2888 BOARDSKU=004 FAB=400 ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash jetson-xavier internal
)

2. Put the device into recovery mode, then generate an encrypted
filesystem for the external device:
$ sudo ROOTFS_ENC=1 ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash \
            --external-device nvme0n1p1 \
            -S 8GiB -c ./tools/kernel_flash/flash_l4t_nvme_rootfs_enc.xml \
            --external-only --append jetson-xavier external
(Or if you want to generate the image offline, then you can use:
$ sudo BOARDID=2888 BOARDSKU=0004 FAB=400 ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash \
            --external-device nvme0n1p1 \
            -S 8GiB -c ./tools/kernel_flash/flash_l4t_nvme_rootfs_enc.xml \
            --external-only --append jetson-xavier external
)


3. Put the device into recovery mode, then flash both images:
$ sudo ./tools/kernel_flash/l4t_initrd_flash.sh --flash-only


Example 2: In this example, you want to boot Jetson Xavier NX SD from an
attached NVMe SSD. The SD card does not need to be plugged in. You can also
apply this if you don't want to use the emmc on the Jetson Xavier NX emmc.

1. Put the device into recovery mode, then generate qspi only images
for the internal device:
$ sudo ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash jetson-xavier-nx-devkit-qspi internal

Note: The board name given here is not jetson-xavier-nx-devkit or
jetson-xavier-nx-devkit-emmc so that no SD card or eMMC images are generated.


2. Put the device into recovery mode, then generate a normal
filesystem for the external device:
$ sudo ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash \
            --external-device nvme0n1p1 \
            -c ./tools/kernel_flash/flash_l4t_external.xml \
            --external-only --append jetson-xavier-nx-devkit external

3. Put the device into recovery mode, then flash both images:
$ sudo ./tools/kernel_flash/l4t_initrd_flash.sh --flash-only


Example 3: we create a massflash package with encrypted internal image and
normal external image with the --append option

1. Put the device into recovery mode, then generate encrypted rootfs
images for the internal device:
$ sudo ROOTFS_ENC=1 ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash jetson-xavier internal

2. Put the device into recovery mode, then generate a normal
filesystem for the external device, and create a massflash package capable of
flashing two devices simultaneously:

$ sudo ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash \
            --external-device nvme0n1p1 \
            -S 8GiB -c ./tools/kernel_flash/flash_l4t_external.xml \
            --external-only --massflash 2 --append jetson-xavier external

3. Put two devices into recovery mode, then flash two devices:
$ sudo ./tools/kernel_flash/l4t_initrd_flash.sh --flash-only --massflash 2


Example 4: Generate an encrypted root filesystem configuration for the internal device
, then generate an encrypted root filesystem for the external device, then flash

1. Put the device into recovery mode, then generate an encrypted root
filesystem for the internal device:
$ sudo ROOTFS_ENC=1 ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash jetson-xavier internal

Second step: Put the device into recovery mode, then generate an encrypted
filesystem for the external device:
$ sudo ROOTFS_ENC=1 ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash \
            --external-device nvme0n1p1 \
            -S 8GiB -c ./tools/kernel_flash/flash_l4t_nvme_rootfs_enc.xml \
            --external-only --append jetson-xavier external

Third step: Put the device into recovery mode, then flash both images:
$ sudo ./tools/kernel_flash/l4t_initrd_flash.sh --flash-only

Workflow 12: Manually generate a bootable external storage device:

You can manually generate a bootable external storage such as NVMe SSD, SD card or USB using this tool.
When a Jetson in recovery mode is connected, use the following command:

$ sudo ./tools/kernel_flash/l4t_initrd_flash.sh --direct <extdev_on_host> \
      -c <external-partition-layout> \
      --external-device <extdev_on_target> \
      [ -p <options> ] \
      [ -S <rootfssize> ] \
      <boardname> external

where
     <extdev_on_host> is the external device /dev node name as it appears on the host. For examples,
     if you plug in a USB on your PC, and it appears as /dev/sdb, then <exdev_on_host> will be sdb

     <extdev_on_target> is "nvme0n1p1" for NVMe SSD, "sda1" for USB or mmcblk1p1 for SD card
    
     <external-partition-layout> is the partition layout for the external storage device in XML format.
     You can use ./tools/kernel_flash/flash_l4t_external.xml as an example.
    
     <rootfssize> (optional) is the size of APP partition on the external storage device. Note that this is different
     from the total size of the external storage device, which is defined by num_sectors field in
     <external-partition-layout>
    
     <options> (optional) is any other option you use when generating the external storage device.
     For examples, specify -p "-C kmemleak" if you want to add kernel option "kmemleak"

If no Jetson in recovery mode is connected, please specify these env variables when running the flash command:
sudo BOARDID=<BOARDID> FAB=<FAB> BOARDSKU=<BOARDSKU> BOARDREV=<BOARDREV>
 ./tools/kernel_flash/l4t_initrd_flash.sh ...

For the value of these, please refer to the table at the bottom of this file.



Appendix:

Environment variables value table:

#

|                                 | BOARDID | BOARDSKU | FAB  | BOARDREV |
| ------------------------------- | ------- | -------- | ---- | -------- |
| jetson-agx-xavier-industrial    | 2888    | 0008     | 600  | A.0      |
| clara-agx-xavier-devkit"        | 3900    | 0000     | 001  | C.0      |
| jetson-xavier-nx-devkit         | 3668    | 0000     | 100  | N/A      |
| jetson-xavier-nx-devkit-emmc    | 3668    | 0001     | 100  | N/A      |
| jetson-xavier-nx-devkit-emmc    | 3668    | 0003     | N/A  | N/A      |
| jetson-agx-xavier-devkit (16GB) | 2888    | 0001     | 400  | H.0      |
| jetson-agx-xavier-devkit (32GB) | 2888    | 0004     | 400  | K.0      |
| jetson-agx-orin-devkit          | 3701    | 0001     | TS1  | C.2      |
| jetson-agx-orin-devkit          | 3701    | 0000     | TS4  | A.0      |
| jetson-agx-xavier-devkit (64GB) | 2888    | 0005     | 402  | B.0      |
| holoscan-devkit                 | 3701    | 0002     | TS1  | A.0      |
| jetson-agx-orin-devkit          | 3701    | 0004     | TS4  | A.0      |



Other environment variables:
EXTOPTIONS: flash option when generating flash image for external devices
ADDITIONAL_DTB_OVERLAY_OPT: Add additional overlay dtbs for UEFI when generating flash image
