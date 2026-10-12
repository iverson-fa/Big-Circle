# UEFI

## 1 常用命令

```bash
# 确认模组型号
cat /etc/nv_boot_control.conf
# 系统版本信息
cat /etc/*release
```

## 2 使用EDK2编译UEFI

### 2.1 不使用容器

在[Build without docker](https://github.com/NVIDIA/edk2-nvidia/wiki/Build-without-docker)中，mono-devel 不需要添加新的源。创建工作空间时，可以选择具体的版本。

参考文档：[Combos](https://github.com/NVIDIA/edk2-nvidia/wiki/Combos)

```bash
# 文档中的命令
edkrepo clone nvidia-uefi NVIDIA-Platforms main
# L4T 35.3
edkrepo clone nvidia-uefi-r35.3 NVIDIA-Platforms r35.3.1
```

成功后的打印信息：

```shell
Syncing the global manifest repository: /home/dafa/.edkrepo/edk2-edkrepo-manifest-main
Syncing the global manifest repository: /home/dafa/.edkrepo/nvidia
Verifying the global manifest repository entry for project: NVIDIA-Jetson

Cloning from: https://github.com/NVIDIA/edk2.git
Cloning from: https://github.com/NVIDIA/edk2-non-osi.git
Cloning from: https://github.com/NVIDIA/edk2-platforms.git
Cloning from: https://github.com/NVIDIA/edk2-nvidia.git
Cloning from: https://github.com/NVIDIA/edk2-nvidia-non-osi.git
Initializing/Updating submodulesdone.
Submodule path 'ArmPkg/Library/ArmSoftFloatLib/berkeley-softfloat-3': checked out 'b64af41c3276f97f0e181920400ee056b9c88037'
Submodule path 'BaseTools/Source/C/BrotliCompress/brotli': checked out 'f4153a09f87cbb9c826d8fc12c74642bb2d879ea'
Submodule path 'CryptoPkg/Library/OpensslLib/openssl': checked out 'd82e959e621a3d597f1e0d50ff8c2d8b96915fd7'
Submodule path 'MdeModulePkg/Library/BrotliCustomDecompressLib/brotli': checked out 'f4153a09f87cbb9c826d8fc12c74642bb2d879ea'
Submodule path 'MdeModulePkg/Universal/RegularExpressionDxe/oniguruma': checked out 'abfc8ff81df4067f309032467785e06975678f0d'
Submodule path 'RedfishPkg/Library/JsonLib/jansson': checked out 'e9ebfa7e77a6bee77df44e096b100e7131044059'
Submodule path 'UnitTestFrameworkPkg/Library/CmockaLib/cmocka': checked out '1cc9cde3448cdd2e000886a26acf1caac2db7cf1'
Performing sparse checkout...
- /home/dafa/nvidia-uefi-r35.3/edk2-platforms
```

[**修改LOGO**](https://forums.developer.nvidia.com/t/customized-logo-for-xavier-nx/231993/8)

- 将 bmp 文件放在 `edk2-nvidia/Silicon/NVIDIA/Assets`，
- 在`Platform/NVIDIA/NVIDIA.fvmain.fdf.inc`中修改文件名，重新编译UEFI，编译命令：

```bash
edk2-nvidia/Platform/NVIDIA/Jetson/build.sh
```

- 在`images`目录下会有两个文件：uefi_Jetson_DEBUG.bin，uefi_Jetson_RELEASE.bin，选择一个重命名为`uefi_Jetson.bin`，放到刷机目录`Linux_for_Tegra/bootloader`下

### 2.2 使用容器

**[推荐使用Docker方式](https://github.com/NVIDIA/edk2-nvidia/wiki/Build-with-docker)**

编辑`.bashrc` or `.zshrc`，

```shell
# Point to the Ubuntu-20 dev image
export EDK2_DEV_IMAGE="ghcr.io/tianocore/containers/ubuntu-20-dev:latest"

# Required
export EDK2_USER_ARGS="-v \"${HOME}\":\"${HOME}\" -e EDK2_DOCKER_USER_HOME=\"${HOME}\""

# Required, unless you want to build in your home directory.
# Change "/build" to be a suitable build root on your system.
export EDK2_BUILD_ROOT="/build"
export EDK2_BUILDROOT_ARGS="-v \"${EDK2_BUILD_ROOT}\":\"${EDK2_BUILD_ROOT}\""

# Create the alias
alias edk2_docker="docker run -it --rm -w \"\$(pwd)\" ${EDK2_BUILDROOT_ARGS} ${EDK2_USER_ARGS} \"${EDK2_DEV_IMAGE}\""
```

```shell
# pull image
edk2_docker echo hello
# configurature edkrepo
edk2_docker init_edkrepo_conf
# NVIDIA's manifest repository
edk2_docker edkrepo manifest-repos add nvidia https://github.com/NVIDIA/edk2-edkrepo-manifest.git main nvidia
# create
edk2_docker edkrepo clone <workspace> NVIDIA-Platforms <combo>
cd /build # .bashrc对应的地址
edk2_docker edkrepo clone nvidia-uefi NVIDIA-Platforms main
# build
cd nvidia-uefi
edk2_docker edk2-nvidia/Platform/NVIDIA/Jetson/build.sh
```

## 3 删除UEFI菜单

测试版本：R35.3\R35.4

[参考论坛](https://forums.developer.nvidia.com/t/close-or-hide-uefi-menu/263382/3?u=fa1053)，使用如下patch，可以使菜单不显示：

```shell
--- a/Silicon/NVIDIA/Library/PlatformBootManagerLib/PlatformBm.c
+++ b/Silicon/NVIDIA/Library/PlatformBootManagerLib/PlatformBm.c
@@ -1193,7 +1193,7 @@ PlatformBootManagerBeforeConsole (
     //
     // Register platform-specific boot options and keyboard shortcuts.
     //
-    PlatformRegisterOptionsAndKeys ();
+    //PlatformRegisterOptionsAndKeys ();

     //
     // Register EnrollDefaultKeysApp as a SysPrep Option.
@@ -1546,7 +1546,7 @@ PlatformBootManagerAfterConsole (
   //
   // Display system and hotkey information after console is ready.
   //
-  DisplaySystemAndHotkeyInformation ();
+  //DisplaySystemAndHotkeyInformation ();
```

## 4 删除UEFI菜单等待时间
[参考论坛](https://forums.developer.nvidia.com/t/jetson-agx-orin-faq/237459#q-there-is-a-wait-in-uefi-stage-how-to-disable-it-to-accelerate-system-booting-10)
```shell
# File name: NVIDIA.common.dsc.inc
# 将5改成0
gEfiMdePkgTokenSpaceGuid.PcdPlatformBootTimeOut|L"Timeout"|gEfiGlobalVariableGuid|0x0|5
```


