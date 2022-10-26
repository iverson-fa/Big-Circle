# CUDA 

## 1. 安装

**显卡驱动安装**

```bash
# 禁用 nouveau
$ sudo vim /etc/modprobe.d/blacklist.conf
blacklist nouveau
options nouveau modeset=0
$ sudo update-initramfs -u
## 重启检查
$ lsmod | grep nouveau
```

```bash
# 查看系统推荐的驱动版本
ubuntu-drivers devices
# 自动安装
sudo ubuntu-drivers autoinstall
# apt 安装，举例
sudo apt install nvidia-driver-470
reboot
```

[CUDA 1.4 命令行安装](https://big-circle.readthedocs.io/en/latest/Autoware.Universe/Packages.html#cuda-cudnn-tensorrt)

[CUDA 安装](https://developer.nvidia.com/cuda-toolkit)

[CUDA 文档](https://docs.nvidia.com/cuda/index.html)

[cuDNN 安装](https://developer.nvidia.com/cudnn)

[docker hub中不同 CUDA 版本](https://github.com/NVIDIA/nvidia-docker/wiki/CUDA)

- base: starting from CUDA 9.0, contains the bare minimum (libcudart) to deploy a pre-built CUDA application. Use this image if you want to manually select which CUDA packages you want to install.
- runtime: extends the base image by adding all the shared libraries from the CUDA toolkit. Use this image if you have a pre-built application using multiple CUDA libraries.
- devel: extends the runtime image by adding the compiler toolchain, the debugging tools, the headers and the static libraries. Use this image to compile a CUDA application from sources.

