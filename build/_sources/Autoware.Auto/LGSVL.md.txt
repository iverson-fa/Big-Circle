# LGSVL

## 1 参考资料

### 1.1  安装之前的环境检查

文档地址

- [CUDA Toolkit Documentation v11.6.0](https://docs.nvidia.com/cuda/index.html)

- [NVIDIA Driver Installation Quickstart Guide](https://docs.nvidia.com/datacenter/tesla/index.html)
- [NVIDIA Driver Documentation](https://docs.nvidia.com/datacenter/tesla/index.html#nvidia-driver-documentation)
- [NVIDIA Cloud Native Documentation](https://docs.nvidia.com/datacenter/cloud-native/contents.html)
- [SVL Similator](https://www.svlsimulator.com/docs/)



cuda 安装

```shell
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pinsudo
mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.6.0/local_installers/cuda-repo-ubuntu1804-11-6-local_11.6.0-510.39.01-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1804-11-6-local_11.6.0-510.39.01-1_amd64.deb
sudo apt-key add /var/cuda-repo-ubuntu1804-11-6-local/7fa2af80.pub
sudo apt-get update
sudo apt-get -y install cuda
```



+-----------------------------------------------------------------------------+
| NVIDIA-SMI 510.39.01    Driver Version: 510.39.01    CUDA Version: 11.6     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  Tesla T4            On   | 00000000:D8:00.0 Off |                    0 |
| N/A   36C    P8    15W /  70W |     29MiB / 15360MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|    0   N/A  N/A      1443      G   /usr/lib/xorg/Xorg                 14MiB |
|    0   N/A  N/A      3636      G   /usr/lib/xorg/Xorg                 14MiB |
+-----------------------------------------------------------------------------+

sudo apt-get install dkms

sudo dkms install -m nvidia -v 450.57



 
