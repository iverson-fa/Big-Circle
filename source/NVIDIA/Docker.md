# Nvidia Docker

## 1 Installation

安装完 Docker 之后安装 Nvidia Docker

```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

测试

```bash 
docker run --runtime=nvidia --rm nvidia/cuda:9.0-base nvidia-smi
```
