# Nvidia Docker

- [github jetson-containers](https://github.com/dusty-nv/jetson-containers)
- [NGC](https://catalog.ngc.nvidia.com/)

## 1 NVIDIA NGC

这些容器镜像托管在 NVIDIA 的 NGC（NVIDIA GPU Cloud）。首次拉取需要注册过 NGC 账户（可免费注册），并使用 nvcr.io 镜像地址。

但在 Jetson 上，NVIDIA 已经默认将 nvcr.io 纳入可信镜像源，无需登录。

## 2 Installation

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

## 3 测试

```shell
# 新建并进入 截至20250711最新镜像为R36.2
docker run --rm -it --runtime nvidia nvcr.io/nvidia/l4t-base:r36.2.0
# 执行命令查看
nvidia-smi
```

下面是一个适用于 **Jetson AGX Orin + JetPack 6.0 (L4T R36.2.0)** 的 **完整 Docker 启动脚本**，它支持：

* GPU 加速（通过 `--runtime=nvidia`）
* X11 GUI 支持（如运行 PyQt、Matplotlib 可视化、RViz 等）
* 挂载主目录供开发调试
* 使用 PyTorch 官方 Jetson 镜像（可换成 base / TensorFlow）

---

脚本内容：`run_l4t_container.sh`

```bash
#!/bin/bash

# ==== 配置部分（可根据需要自定义） ====
CONTAINER_NAME="jetson_dev"
IMAGE_NAME="nvcr.io/nvidia/l4t-pytorch:r36.2.0-pth2.1-py3"
HOST_HOME="$HOME"
CONTAINER_HOME="/home/developer"
DISPLAY_VAR=${DISPLAY:-:0}
XSOCK="/tmp/.X11-unix"
SHM_SIZE="2g"

# ==== 授权 X11 显示 ====
xhost +local:root

# ==== 启动容器 ====
docker run -it --rm \
  --name $CONTAINER_NAME \
  --runtime nvidia \
  --network host \
  --privileged \
  --shm-size=$SHM_SIZE \
  -e DISPLAY=$DISPLAY_VAR \
  -e QT_X11_NO_MITSHM=1 \
  -v $XSOCK:$XSOCK \
  -v $HOST_HOME:$CONTAINER_HOME \
  -w $CONTAINER_HOME \
  $IMAGE_NAME \
  /bin/bash

# ==== 恢复权限 ====
xhost -local:root
```

---

用法

1. 将上述内容保存为 `run_l4t_container.sh`
2. 赋予执行权限：

```bash
chmod +x run_l4t_container.sh
```

3. 执行脚本：

```bash
./run_l4t_container.sh
```

进入一个已加载 GPU 和图形界面支持的 L4T 容器，适合跑 deep learning、视觉、RViz、GUI 工具等。

---

可选修改

| 场景            | 说明                                                                |
| ------------- | ----------------------------------------------------------------- |
| 使用 TensorFlow | 改 `IMAGE_NAME="nvcr.io/nvidia/l4t-tensorflow:r36.2.0-tf2.12-py3"` |
| 不需要 GUI       | 删除 `-e DISPLAY` 和 `-v /tmp/.X11-unix:/tmp/.X11-unix`              |
| 长期使用不删容器      | 去掉 `--rm`，改用 `docker start`、`docker exec` 操作                      |

---

**总结一句话：**

> 使用该脚本可一键启动 JetPack 6.0 容器开发环境，集成 GPU 加速、X11 图形界面、主目录挂载，非常适合在 Jetson AGX Orin 上进行深度学习、ROS、CV 应用开发。