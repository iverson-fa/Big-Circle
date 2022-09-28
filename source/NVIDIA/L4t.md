# Jetson 刷机

SDK Manager 不能满足定制化刷机，本文档以 Jetson AGX Orin 为例，L4t 版本为34.1，其余设备只需修改对应的环境变量即可。

## 1 环境准备

### 1.1 硬件

- USB-typec线，用于连接host主机到jetson-orin开发板，type-c插在pin口面
- 鼠标、键盘、显示器，用于jetson-orin开发板外设

### 1.2 软件

Host开发环境Ubuntu 18/Ubuntu 20，安装依赖

```shell
sudo apt install qemu-user-static build-essential bc flex bison libcurses-ocaml-dev graphviz dvipng python3-venv latexmk librsvg2-bin texlive-xetex
```

从[官网](https://developer.nvidia.com/embedded/jetson-linux-r341)下载以下文件并将放于同一个文件夹 `r34.1`，文件目录： 

```bash
r34.1/
├── aarch64--glibc--stable-final.tar.gz
├── Jetson_Linux_R34.1.0_aarch64.tbz2
├── kernel_out
├── l4t-gcc
├── public_sources.tbz2
└── Tegra_Linux_Sample-Root-Filesystem_R34.1.0_aarch64.tbz2
```

| File/Dir                                                     | Note                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| Jetson_Linux_R34.1.0_aarch64.tbz2/Tegra__Linux_R34.1.0_aarch64.tbz2 | DRIVERS > L4T Driver Package(BSP)，前者是SDK Manager下载，后者是官网下载，是相同的文件 |
| Tegra_Linux_Sample-Root-Filesystem_R34.1.0_aarch64.tbz2      | Drivers > Sample Root Filesystem                             |
| public_sources.tbz2                                          | SOURCES > L4T Driver Package(BSP) Sources                    |
| aarch64--glibc--stable-final.tar.gz                          | TOOLS > Bootlin Toolchain gcc 9.3                            |
| kernel_out                                                   | 内核编译目录                                                 |
| l4t-gcc                                                      | 工具链目录                                                   |

## 2 环境变量

```shell
# 此环境变量适用于L4T所有版本，注意各版本文件名，根据实际目录替换xxx
export WS=xxx/r34.1
export L4T_RELEASE_PACKAGE=$WS/Jetson_Linux_R34.1.0_aarch64.tbz2
export SAMPLE_FS_PACKAGE=$WS/Tegra_Linux_Sample-Root-Filesystem_R34.1.0_aarch64.tbz2
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
sudo tar -xpf $L4T_RELEASE_PACKAGE
cd Linux_for_Tegra/rootfs/
sudo tar -xpf $SAMPLE_FS_PACKAGE   # 将SAMPLE_FS_PACKAGE解压到Tegra/rootfs/目录下
cd ..
sudo ./apply_binaries.sh
```

### 3.2 解压内核源码

```bash
cd $WS
sudo tar -xjf  public_sources.tbz2 
cd Linux_for_Tegra/source/public/
sudo tar -xjf kernel_src.tbz2
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

NOTE：若不是 `/opt/l4t-gcc` ，需要修改 `$CROSS_COMPILE` 变量。

### 3.4 生成默认 `.config` 文件

```bash
cd $KERNEL_SOURCE
sudo make ARCH=arm64 O=$TEGRA_KERNEL_OUT tegra_defconfig
```

生成的 `.config` 文件位于 $TEGRA_KERNEL_OUT。

### 3.5 修改内核配置文件

```shell
cd $KERNEL_SOURCE # kernel-5.10
sudo make DEFCONFIG_PATH=arch/arm64/configs tegra_defconfig
sudo make menuconfig
# <<Update config options>> 功能剪切，可以直接选择 exit
sudo make savedefconfig
sudo cp -v defconfig arch/arm64/configs/tegra_defconfig
sudo make mrproper
```

### 3.6 编译内核

#### 3.6.1 EP 配置

若不需要配置为 EP 模式，跳过此节进入 3.6.2。

根据 `Orin-pcie-c5-ep-odmdata.patch`，修改 `Linux_for_Tegra/p3701.conf.common` 文件，在 ODMDATA 一行将 `nvhs-uphy-config-0` 修改为 `nvhs-uphy-config-1`。

#### 3.6.2 正常编译

执行以下命令构建内核

```bash
cd $KERNEL_SOURCE
sudo make ARCH=arm64 O=$TEGRA_KERNEL_OUT -j4
# 替换 Image
cp $TEGRA_KERNEL_OUT/arch/arm64/boot/Image $WS/Linux_for_Tegra/kernel/Image
# 替换 dtb，可以不执行
cp -r $TEGRA_KERNEL_OUT/arch/arm64/boot/dts/nvidia $WS/Linux_for_Tegra/kernel/dtb/
```

#### 3.6.3 编译后生成的内核模块安装到 L4T 包

在`${KERNEL_SOURCE} ` 中执行以下命令,

```bash
make ARCH=arm64 O=$TEGRA_KERNEL_OUT modules_install INSTALL_MOD_PATH=$WS/Linux_for_Tegra/rootfs/
```

#### 3.6.4 烧写

```bash
cd $WS/Linux_for_Tegra
sudo ./flash.sh $BOARD mmcblk0p1
```

安装过程完成后，Jetson 设备自动重启。

## 4 其他

### 4.1 常用命令

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
```

```bash
cp /opt/kernel_out/arch/arm64/boot/Image doc/InstallPackages/NVIDIA/r34.1/Linux_for_Tegra/kernel/Image
cp -r /opt/kernel_out/arch/arm64/boot/dts/nvidia doc/InstallPackages/NVIDIA/r34.1/Linux_for_Tegra/kernel/dtb
```

若出现 `gcc: unrecognized command line option “-milittle-endian”`，修改Makefile

```shell
sudo vim Linux_for_Tegra/source/public/kernel/kernel-5.10/Makefile
# 修改交叉编译工具
CROSS_COMPILE = /home/dafa/jetson_flash/r35.1/l4t-gcc/bin/aarch64-buildroot-linux-gnu-
```

### 4.2 安装 jetpack 软件包

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
deb https://repo.download.nvidia.com/jetson/common r34.1 main
deb https://repo.download.nvidia.com/jetson/t234 r34.1 main
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

### 4.3 深度学习环境配置

**（1）[miniforge](https://github.com/conda-forge/miniforge)**

`conda` 和 `miniconda` 都是无法在 `aarch64` 的架构上使用的，`miniforge` 是其替代品，使用方法和 `conda` 几乎一样。

```bash
# 下载源码后进入目录
$ bash Miniforge3-Linux-aarch64.sh
# 添加环境变量
$ sudo vim ~/.bashrc
export PATH="/home/aipt/miniforge3/bin:$PATH"
$ conda --version
# 添加镜像源
# 使用国科大镜像源
$ conda config --prepend channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/
$ conda config --prepend channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/
$ conda config --set show_channel_urls yes
```

**（2）Pytorch**

有了 `miniforge` 之后，可以创建一个虚拟环境，进行不同配置的隔离，然后就可以装 `pytorch` 了。

Jetson 的 pytorch 只能由[这种方式](https://forums.developer.nvidia.com/t/pytorch-for-jetson-version-1-11-now-available/72048)安装，不能像 `PC` 那样安装。不同的 `JetPack` 版本对应于不同的 `python` 和 `pytorch` 版本，可以根据 [Jetson Zoo](https://elinux.org/Jetson_Zoo) 进行选择。例如 `JetPack 5.0`，匹配 `python 3.8` + `pytorch 1.11.0`。

```bash
conda create -n dlTorch python=3.8
conda activate dlTorch
pip install Cython
pip install torch-1.11.0-cp38-cp38-linux_aarch64.whl
conda install numpy
```

NOTE：pytorch 安装成功，但仅仅是在 dlTorch 这个虚拟环境中安装成功。其他环境需要重复此步骤。

**（3）torchvision**

pytorch 对应的 torchvision 版本[查询](https://pypi.org/project/torchvision/)。`pytorch 1.11.0` 对应 `torchvision=0.12.0`，安装：

```bash
sudo apt-get install libjpeg-dev zlib1g-dev libpython3-dev libavcodec-dev libavformat-dev libswscale-dev
git clone --branch <version> https://github.com/pytorch/vision torchvision   # see below for version of torchvision to download
cd torchvision
export BUILD_VERSION=0.x.0  # where 0.x.0 is the torchvision version  
python3 setup.py install --user
cd ../  # attempting to load torchvision from build dir will result in import error
pip install 'pillow<7' # always needed for Python 2.7, not needed torchvision v0.5.0+ with Python 3.6
```

NOTE：这里的 `<version>` 和 `BUILD_VERSION=0.x.0` 用 `0.12.0` 替换掉，`pip install 'pillow<7'` 可以省略。

**（4）opencv链接到虚拟环境**

由于 JetPack 已经安装了 opencv 库，但是是在系统预装的 python 路径里面的，虚拟环境里无法 `import` ，于是需要我们将其软连接到当前的虚拟环境。首先查找 cv2 的位置：

```bash
sudo find / -iname "*cv2*"
```

根据 `python3.8` 的路径显示，cv2 的路径如下：`/usr/lib/python3.8/dist-packages/cv2/python-3.8/cv2.cpython-38-aarch64-linux-gnu.so`，而当前虚拟环境的路径如下 `/home/miniforge3/envs/dlTorch/lib/python3.8/site-packages`。建立软链接：

```bash
sudo ln -s /usr/lib/python3.8/dist-packages/cv2/python-3.8/cv2.cpython-38-aarch64-linux-gnu.so cv2.so
```

此时在虚拟环境 dlTorch 中启动 python 也可以 import cv2 了。

### 4.4 修改静态IP

适用于 `Jetson` 和 `X86` 平台 `Ubuntu 20.04`。

```bash
$ sudo apt install -y netplan.io
$ sudo vi /etc/netplan/01-network-manager-all.yaml 
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



