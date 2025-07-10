# Nvidia Docker

- [github jetson-containers](https://github.com/dusty-nv/jetson-containers)

## 1 Installation

安装完 Docker 之后安装 Nvidia Docker，在Orin上不需要配置。

```bash
sudo apt install docker.io
sudo apt install -y nvidia-container-toolkit
sudo systemctl restart docker
```

测试（arm架构拉取对应image）

```bash
docker run --rm -it --runtime=nvidia nvcr.io/nvidia/l4t-base:r36.2.0
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
跟加速源合并的版本：
```shell
{
  "registry-mirrors": [
    "https://docker.211678.top",
    "https://docker.1panel.live",
    "https://hub.rat.dev",
    "https://docker.m.daocloud.io",
    "https://do.nark.eu.org",
    "https://dockerpull.com",
    "https://dockerproxy.cn",
    "https://docker.awsl9527.cn"
  ],
  "default-runtime": "nvidia",
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
}
```

## 2 测试

```shell
# 新建并进入
docker run --rm -it --runtime nvidia nvcr.io/nvidia/l4t-base:r36.2.0
# 执行命令查看
nvidia-smi
```