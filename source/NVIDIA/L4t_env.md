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

参考[官方文档](https://docs.nvidia.com/jetson/archives/r35.1/DeveloperGuide/text/HR/JetsonModuleAdaptationAndBringUp/JetsonAgxOrinSeries.html#for-rgmii)及NVBUG，禁用 MGBE，配置前兆PHY，将下列 patch 打到刷机包中

```shell
From 21c884060ce62c8b5bc3b39ea8bc767ad934187c Mon Sep 17 00:00:00 2001
From: Jason Mei <jianjunm@nvidia.com>
Date: Fri, 10 Jun 2022 11:30:04 +0800
Subject: [PATCH] Set eqos mad and phy pinmux in kernel dts

Usually, it's much better to set pinmux in MB1 BCT

Signed-off-by: Jason Mei <jianjunm@nvidia.com>
---
 .../tegra234-p3711-ethernet.dtsi              |  19 ++-
 .../tegra234-p3737-eqos-pinmux.dtsi           | 142 ++++++++++++++++++
 .../cvb/tegra234-ethernet-3737-0000.dtsi      |   2 +-
 .../tegra234-soc/tegra234-soc-eqos.dtsi       |   5 +-
 4 files changed, 159 insertions(+), 9 deletions(-)
 create mode 100644 hardware/nvidia/platform/t23x/common/kernel-dts/t234-common-cvb/tegra234-p3737-eqos-pinmux.dtsi

diff --git a/hardware/nvidia/platform/t23x/common/kernel-dts/t234-common-cvb/tegra234-p3711-ethernet.dtsi b/hardware/nvidia/platform/t23x/common/kernel-dts/t234-common-cvb/tegra234-p3711-ethernet.dtsi
index 953fd2939..03ccfb59f 100644
--- a/hardware/nvidia/platform/t23x/common/kernel-dts/t234-common-cvb/tegra234-p3711-ethernet.dtsi
+++ b/hardware/nvidia/platform/t23x/common/kernel-dts/t234-common-cvb/tegra234-p3711-ethernet.dtsi
@@ -19,19 +19,24 @@
 		nvidia,phy-reset-gpio = <&tegra_main_gpio TEGRA234_MAIN_GPIO(G, 5) 0>;
 		phy-mode = "rgmii-id";
 		phy-handle = <&phy>;
-		/delete-node/ fixed-link;
+		nvidia,max-platform-mtu = <16383>;
 
 		mdio {
 			compatible = "nvidia,eqos-mdio";
 			#address-cells = <1>;
 			#size-cells = <0>;
 
-			phy: phy@1 {
-				reg = <1>;
-				nvidia,phy-rst-pdelay-msec = <224>; /* msec */
-				nvidia,phy-rst-duration-usec = <10000>; /* usec */
-				interrupt-parent = <&tegra_main_gpio>;
-				interrupts = <TEGRA234_MAIN_GPIO(G, 4) IRQ_TYPE_LEVEL_LOW>;
+			phy: phy@0 {
+				reg = <0>;
+#if TEGRA_ETHERNETPHY_DT_VERSION >= DT_VERSION_2
+                                /* use phy in poll mode */
+#else
+                                interrupt-parent = <&tegra_main_gpio>;
+                                interrupts = <TEGRA234_MAIN_GPIO(G, 4) IRQ_TYPE_LEVEL_LOW>;
+#endif
+                                marvell,copper-mode;
+                                /* Setup LED[2] as interrupt pin (active low) */
+                                marvell,reg-init = <0x03 0x12 0x7fff 0x880>;
 			};
 		};
 	};
diff --git a/hardware/nvidia/platform/t23x/common/kernel-dts/t234-common-cvb/tegra234-p3737-eqos-pinmux.dtsi b/hardware/nvidia/platform/t23x/common/kernel-dts/t234-common-cvb/tegra234-p3737-eqos-pinmux.dtsi
new file mode 100644
index 000000000..12b748b2e
--- /dev/null
+++ b/hardware/nvidia/platform/t23x/common/kernel-dts/t234-common-cvb/tegra234-p3737-eqos-pinmux.dtsi
@@ -0,0 +1,142 @@
+/ {
+	pinmux@2430000 {
+		pinctrl-names = "default", "drive", "unused";
+		pinctrl-0 = <&pinmux_default>;
+		pinctrl-1 = <&drive_default>;
+		pinctrl-2 = <&pinmux_unused_lowpower>;
+		pinmux_default: common {
+			eqos_txc_pe0 {
+				nvidia,pins = "eqos_txc_pe0";
+				nvidia,function = "eqos";
+				nvidia,pull = <TEGRA_PIN_PULL_NONE>;
+				nvidia,tristate = <TEGRA_PIN_DISABLE>;
+				nvidia,enable-input = <TEGRA_PIN_DISABLE>;
+			};
+
+			eqos_td0_pe1 {
+				nvidia,pins = "eqos_td0_pe1";
+				nvidia,function = "eqos";
+				nvidia,pull = <TEGRA_PIN_PULL_NONE>;
+				nvidia,tristate = <TEGRA_PIN_DISABLE>;
+				nvidia,enable-input = <TEGRA_PIN_DISABLE>;
+			};
+
+			eqos_td1_pe2 {
+				nvidia,pins = "eqos_td1_pe2";
+				nvidia,function = "eqos";
+				nvidia,pull = <TEGRA_PIN_PULL_NONE>;
+				nvidia,tristate = <TEGRA_PIN_DISABLE>;
+				nvidia,enable-input = <TEGRA_PIN_DISABLE>;
+			};
+
+			eqos_td2_pe3 {
+				nvidia,pins = "eqos_td2_pe3";
+				nvidia,function = "eqos";
+				nvidia,pull = <TEGRA_PIN_PULL_NONE>;
+				nvidia,tristate = <TEGRA_PIN_DISABLE>;
+				nvidia,enable-input = <TEGRA_PIN_DISABLE>;
+			};
+
+			eqos_td3_pe4 {
+				nvidia,pins = "eqos_td3_pe4";
+				nvidia,function = "eqos";
+				nvidia,pull = <TEGRA_PIN_PULL_NONE>;
+				nvidia,tristate = <TEGRA_PIN_DISABLE>;
+				nvidia,enable-input = <TEGRA_PIN_DISABLE>;
+			};
+
+			eqos_tx_ctl_pe5 {
+				nvidia,pins = "eqos_tx_ctl_pe5";
+				nvidia,function = "eqos";
+				nvidia,pull = <TEGRA_PIN_PULL_NONE>;
+				nvidia,tristate = <TEGRA_PIN_DISABLE>;
+				nvidia,enable-input = <TEGRA_PIN_DISABLE>;
+			};
+
+			eqos_rd0_pe6 {
+				nvidia,pins = "eqos_rd0_pe6";
+				nvidia,function = "eqos";
+				nvidia,pull = <TEGRA_PIN_PULL_NONE>;
+				nvidia,tristate = <TEGRA_PIN_ENABLE>;
+				nvidia,enable-input = <TEGRA_PIN_ENABLE>;
+			};
+
+			eqos_rd1_pe7 {
+				nvidia,pins = "eqos_rd1_pe7";
+				nvidia,function = "eqos";
+				nvidia,pull = <TEGRA_PIN_PULL_NONE>;
+				nvidia,tristate = <TEGRA_PIN_ENABLE>;
+				nvidia,enable-input = <TEGRA_PIN_ENABLE>;
+			};
+			eqos_rd2_pf0 {
+				nvidia,pins = "eqos_rd2_pf0";
+				nvidia,function = "eqos";
+				nvidia,pull = <TEGRA_PIN_PULL_NONE>;
+				nvidia,tristate = <TEGRA_PIN_ENABLE>;
+				nvidia,enable-input = <TEGRA_PIN_ENABLE>;
+			};
+
+			eqos_rd3_pf1 {
+				nvidia,pins = "eqos_rd3_pf1";
+				nvidia,function = "eqos";
+				nvidia,pull = <TEGRA_PIN_PULL_NONE>;
+				nvidia,tristate = <TEGRA_PIN_ENABLE>;
+				nvidia,enable-input = <TEGRA_PIN_ENABLE>;
+			};
+
+			eqos_rx_ctl_pf2 {
+				nvidia,pins = "eqos_rx_ctl_pf2";
+				nvidia,function = "eqos";
+				nvidia,pull = <TEGRA_PIN_PULL_NONE>;
+				nvidia,tristate = <TEGRA_PIN_ENABLE>;
+				nvidia,enable-input = <TEGRA_PIN_ENABLE>;
+			};
+
+			eqos_rxc_pf3 {
+				nvidia,pins = "eqos_rxc_pf3";
+				nvidia,function = "eqos";
+				nvidia,pull = <TEGRA_PIN_PULL_NONE>;
+				nvidia,tristate = <TEGRA_PIN_ENABLE>;
+				nvidia,enable-input = <TEGRA_PIN_ENABLE>;
+			};
+
+			eqos_sma_mdio_pf4 {
+				nvidia,pins = "eqos_sma_mdio_pf4";
+				nvidia,function = "eqos";
+				nvidia,pull = <TEGRA_PIN_PULL_NONE>;
+				nvidia,tristate = <TEGRA_PIN_DISABLE>;
+				nvidia,enable-input = <TEGRA_PIN_ENABLE>;
+			};
+
+			eqos_sma_mdc_pf5 {
+				nvidia,pins = "eqos_sma_mdc_pf5";
+				nvidia,function = "eqos";
+				nvidia,pull = <TEGRA_PIN_PULL_NONE>;
+				nvidia,tristate = <TEGRA_PIN_DISABLE>;
+				nvidia,enable-input = <TEGRA_PIN_DISABLE>;
+			};
+			soc_gpio17_pg4 {
+				nvidia,pins = "soc_gpio17_pg4";
+				nvidia,function = "rsvd0";
+				nvidia,pull = <TEGRA_PIN_PULL_UP>;
+				nvidia,tristate = <TEGRA_PIN_ENABLE>;
+				nvidia,enable-input = <TEGRA_PIN_ENABLE>;
+				nvidia,lpdr = <TEGRA_PIN_DISABLE>;
+			};
+
+			soc_gpio18_pg5 {
+				nvidia,pins = "soc_gpio18_pg5";
+				nvidia,function = "rsvd0";
+				nvidia,pull = <TEGRA_PIN_PULL_NONE>;
+				nvidia,tristate = <TEGRA_PIN_DISABLE>;
+				nvidia,enable-input = <TEGRA_PIN_DISABLE>;
+				nvidia,lpdr = <TEGRA_PIN_DISABLE>;
+			};
+		};
+		pinmux_unused_lowpower: unused_lowpower {
+		};
+		drive_default: drive {
+		};
+	};
+
+};
diff --git a/hardware/nvidia/platform/t23x/concord/kernel-dts/cvb/tegra234-ethernet-3737-0000.dtsi b/hardware/nvidia/platform/t23x/concord/kernel-dts/cvb/tegra234-ethernet-3737-0000.dtsi
index 05c2ba700..ce4411a35 100644
--- a/hardware/nvidia/platform/t23x/concord/kernel-dts/cvb/tegra234-ethernet-3737-0000.dtsi
+++ b/hardware/nvidia/platform/t23x/concord/kernel-dts/cvb/tegra234-ethernet-3737-0000.dtsi
@@ -19,7 +19,7 @@
 / {
 	/* MGBE - A */
 	ethernet@6810000 {
-		status = "okay";
+		status = "disabled";
 		nvidia,mac-addr-idx = <0>;
 		nvidia,max-platform-mtu = <16383>;
 		/* 0=enable, 1=disable */
diff --git a/hardware/nvidia/soc/t23x/kernel-dts/tegra234-soc/tegra234-soc-eqos.dtsi b/hardware/nvidia/soc/t23x/kernel-dts/tegra234-soc/tegra234-soc-eqos.dtsi
index e8ce274ec..baced39f0 100644
--- a/hardware/nvidia/soc/t23x/kernel-dts/tegra234-soc/tegra234-soc-eqos.dtsi
+++ b/hardware/nvidia/soc/t23x/kernel-dts/tegra234-soc/tegra234-soc-eqos.dtsi
@@ -18,6 +18,9 @@
  * tegra234-soc-eqos.dtsi: Ethernet QOS DTSI file.
  */
 
+#include <t234-common-cvb/tegra234-p3711-ethernet.dtsi>
+#include <t234-common-cvb/tegra234-p3737-eqos-pinmux.dtsi>
+
 / {
 	pinmux@2430000 {
 		eqos_mii_rx_input_state_disable: eqos_rx_disable {
@@ -108,7 +111,7 @@
 		nvidia,tx-queue-prio = <0x0 0x7 0x2 0x3 0x0 0x0 0x0 0x0>;
 		nvidia,rxq_enable_ctrl = <2 2 2 2 2 2 2 2>;
 		nvidia,vm-irq-config = <&eqos_vm_irq_config>;
-		status = "disabled";
+		status = "okay";
 		nvidia,dcs-enable = <0x1>;
 		nvidia,pad_calibration = <0x1>;
 		nvidia,rx_riwt = <512>;
-- 
2.25.1

```

### 1.4 安装 Jtop

```bash
sudo pip3 install -U jetson-stats
```

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

## 3 深度学习环境配置

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

## 4 可用脚本

### 4.1 修改静态IP

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
