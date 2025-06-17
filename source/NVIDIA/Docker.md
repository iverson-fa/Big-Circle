# Nvidia Docker

- [github jetson-containers](https://github.com/dusty-nv/jetson-containers)

## 1 Installation

安装完 Docker 之后安装 Nvidia Docker，在Orin上不需要配置。

```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

测试（arm架构拉取对应image）

```bash
docker run --runtime=nvidia --rm nvidia/cuda:9.0-base nvidia-smi
```
/etc/docker/daemon.json
```shell
{
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
```