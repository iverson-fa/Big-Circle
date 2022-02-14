# AGX 刷机
## SDK Manager 的使用
### 1 下载
[官方下载](https://developer.nvidia.cn/nvidia-sdk-manager)
```shell
sudo apt install ./sdkmanager_[version]-[build#]_amd64.deb
# docker 安装123456a?

docker load -i ./sdkmanager_[version].[build#]_docker.tar.gz
docker tag sdkmanager:[version].[build#] sdkmanager:latest
```
**Docker 启动**

- Docker 镜像旨在直接从主机执行，无需在 Docker 本身内部打开终端。 这 sdkmanager可执行文件是入口点。 运行新容器时应直接使用 SDK Manager CLI 参数：
- 示例命令：带有 Docker 的 SDK Manager CLI： `docker run -it --rm sdkmanager --help`