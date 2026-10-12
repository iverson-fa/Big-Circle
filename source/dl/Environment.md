# 环境搭建
## 1 软件版本
- Ubuntu 18.04
- CUDA 11.4
- Cudnn 8_8.2.4.15-1
- miniconda

- Pytorch 1.9

## 2 安装

### 2.1 预备工作

1 检查 GPU 型号，在[官网](https://developer.nvidia.com/cuda-gpus)列表确认是否支持 CUDA:

```bash
lspci | grep -i nvidia
# 没有lspci就安装
sudo apt install pciutils
```

2 禁用 nouveau 并重启：

```bash
sudo vim /etc/modprobe.d/blacklist.conf
```

添加

```shell
blacklist nouveau
options nouveau modeset=0
```

3 更新后重启：

```bash
sudo update-initramfs -u
sudo reboot
```

执行 `lsmod | grep nouveau`后没有任何输出证明禁用成功

4 删除旧的NVIDIA驱动：无旧的驱动可忽略

```bash
sudo apt remove nvidia-*
sudo apt autoremove
sudo apt update
```

5 使用`ubuntu-drivers devices` 查看系统推荐的驱动版本，我用的公司电脑，显卡型号 GT730，驱动推荐的是 `470-server` 版本，安装驱动可以使用如下命令或安装 CUDA 时一起安装

```bash
sudo ubuntu-drivers autoinstall
```

6 重启，`nvidia-smi`测试是否安装成功，查看需要的 CUDA 版本，我的是 11.4

### 2.2 安装 CUDA

[下载列表](https://developer.nvidia.com/cuda-toolkit-archive)

在下载列表中选择合适的版本，不推荐使用最新的 11.6 版本，因为目前还没有适配的 Cudnn

```bash
wget https://developer.download.nvidia.com/compute/cuda/11.4.0/local_installers/cuda_11.4.0_470.42.01_linux.run
sudo sh cuda_11.4.0_470.42.01_linux.run
```

如果在预备工作中已经安装过驱动，此处就不选驱动安装了。

在 `.bashrc` 文件中添加

```shell
export PATH="/usr/local/cuda-11.4/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda-11.4/lib64:$LD_LIBRARY_PATH"
```

使用 `nvcc -V` 查看是否安装成功。

### 2.3 安装 Cudnn

[下载列表](https://developer.nvidia.com/rdp/cudnn-archive)

在下载列表中选择合适版本，将两个库和代码示例都下载下来然后安装。

验证

```bash
cd /usr/local/cuda/samples/1_Utilities/deviceQuery
sudo make
./deviceQuery
```

出现 `Result = PASS` 成功

### 2.4 安装 Pytorch

```bash
pip3 install torch==1.9.0+cu111 torchvision==0.10.0+cu111 torchaudio==0.9.0 -f https://download.pytorch.org/whl/torch_stable.html
```

验证

```bash
python3
import torch
import torchvision
print(torch.cuda.is_available())
```

显示 `True` 则成功。
### 2.5 安装 Miniconda
```bash
wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py38_4.8.3-Linux-x86_64.sh --no-check-certificate
bash Miniconda3-py38_4.8.3-Linux-x86_64.sh
# 重启终端
conda -v
```
换源，`touch .condarc`
```bash
channels:
  - defaults
show_channel_urls: true
channel_alias: https://mirrors.tuna.tsinghua.edu.cn/anaconda
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/pro
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
```
```bash
conda clean -i # 清除缓存
conda config --show 
```
