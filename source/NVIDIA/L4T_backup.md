# 系统备份

- 参考：`Linux_for_Tegra/tools/backup_restore/README_backup_restore.txt`
- 基于 Jetson AGX Orin，其他模组需要修改`jetson-agx-orin-devkit`

## 0 Requirements

在 backing up 和 restore 过程中要禁用外部存储设备的自动挂载功能

```bash
systemctl stop udisks2.service
```

安装依赖

```bash
sudo tools/l4t_flash_prerequisites.sh
```

运行 nfs-kernel-server 服务

```bash
sudo service nfs-kernel-server start
```

## 1 在host存储中创建备份镜像

- 确认只有一个recovery模式的Jetson设备与host连接

```bash
# 在Linux_for_Tegra目录中执行
sudo ./tools/backup_restore/l4t_backup_restore.sh -b jetson-agx-orin-devkit
```

执行成功后，镜像存储目录为：`Linux_for_Tegra/tools/backup_restore/images`

## 2 使用备份镜像restore一个Jetson设备

- 确认只有一个recovery模式的Jetson设备与host连接
- 确认一个备份镜像在此目录：`Linux_for_Tegra/tools/backup_restore/images`

```bash
# 在Linux_for_Tegra目录中执行
sudo ./tools/backup_restore/l4t_backup_restore.sh -r jetson-agx-orin-devkit
```

## 3 使用备份镜像批量烧录

### 3.1 orin

- 确认只有一个recovery模式的Jetson设备与host连接

```bash
# 在Linux_for_Tegra目录中执行
sudo ./tools/backup_restore/l4t_backup_restore.sh -b -c jetson-agx-orin-devkit
```

执行成功后，镜像存储目录为：`Linux_for_Tegra/tools/kernel_flash/images`。

将设备置于recovery模式，使用备份镜像生成批量刷机包：

```bash
 sudo ./tools/kernel_flash/l4t_initrd_flash.sh --use-backup-image --no-flash --network usb0 --massflash 4 jetson-agx-orin-devkit mmcblk0p1
```

使用生成的批量刷机包进行刷机：

```bash
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --flash-only --massflash 1 --network usb0
```

### 3.2 orin nano

- 确认只有一个recovery模式的Jetson设备与host连接
- 修改nvbackup_partitions.sh和nvrestore_partitions.sh，使其适用于 NVMe SSD。l4t_backup_restore.sh的工作原理是将设备恢复引导到初始虚拟硬盘，该虚拟硬盘可以通过 SSH  与主机通信。主机基本上运行nvbackup_partitions.sh来备份映像，nvrestore_partitions.sh通过SSH和NFS恢复这些映像。将这两个脚本中的mmcblk0 引用替换为 nvme0n1（[参考](https://forums.developer.nvidia.com/t/how-to-clone-orin-nx-app-partition-to-host-pc/241629/3)）

```bash
# 在Linux_for_Tegra目录中执行
sudo ./tools/backup_restore/l4t_backup_restore.sh -b -c p3509-a02+p3767-0000
```

执行成功后，镜像存储目录为：`Linux_for_Tegra/tools/kernel_flash/images`。

将设备置于recovery模式，使用备份镜像生成批量刷机包：

```bash
# orin nano + eis200 载板
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 \
  -c tools/kernel_flash/flash_l4t_external.xml -p "-c bootloader/t186ref/cfg/flash_t234_qspi.xml" \
  --showlogs --network usb0 p3509-a02+p3767-0000 internal
```

使用生成的批量刷机包进行刷机：

```bash
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --flash-only --massflash 1 --network usb0 --showlogs
```







## 4 在emmc中安装raw disk image

- 确认只有一个recovery模式的Jetson设备与host连接
- 确认有一个使用`dd`命令直接从disk获得的raw disk image，例如 `sudo dd if=/dev/mmcblk0 of=raw_disk.img`

```bash
# 在Linux_for_Tegra目录中执行
sudo ./tools/backup_restore/l4t_backup_restore.sh -r --raw-image <path to your raw disk image> <board-name>
# 举例，安装在Jetson Xavier NX eMMC
sudo ./tools/backup_restore/l4t_backup_restore.sh -r --raw-image raw_disk.img jetson-xavier-nx-devkit-emmc
```



