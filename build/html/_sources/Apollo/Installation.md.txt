# Apollo6.0安装

## 1.安装显卡驱动
注意： 如果是在虚拟机中安装的 Ubuntu 或物理机没有配置 NVIDIA 显卡，此步务必跳过，否则将导致后续步骤中启动 Apollo 开发容器时失败。虚拟机情况下这样做的根本原因是，虚拟机中无法虚拟 NVIDIA 显卡。
```shell
sudo apt-get update
sudo apt-add-repository multiverse
sudo apt-get update
sudo apt-get install nvidia-driver-455
```
## 2.安装Docker Engine
```shell
curl https://get.docker.com | sh
sudo systemctl start docker && sudo systemctl enable docker
sudo systemctl restart docker
sudo groupadd docker
sudo usermod -aG docker your_username
```
## 3.安装NVIDIA容器工作包
如果是在物理机中安装的 Ubuntu，且机器配有 NVIDIA 显卡，在安装了驱动的前提下，还需要安装 NVIDIA 容器工具包以运行 Apollo Docker 镜像中的 CUDA（虚拟机跳过）。
```shell
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get -y update
sudo apt-get install -y nvidia-docker2
```
## 4.下载源码
```shell
# 使用github
git clone git@github.com:ApolloAuto/apollo.git # 使用 SSH 的方式
git clone https://github.com/ApolloAuto/apollo.git # 使用 HTTPS 的方式
# 使用gitee
git clone git@gitee.com:ApolloAuto/apollo.git
git clone https://gitee.com/ApolloAuto/apollo.git
```
## 5.运行 Apollo Docker 开发容器
```shell
./docker/scripts/dev_start.sh
```
如果是在虚拟机中安装的 Ubuntu 或物理机没有配置 NVIDIA 显卡，但却又安装了 NVIDIA 驱动，则在执行上述启动容器的操作时将报错，解决方法是下载NVIDIA相关安装项：`sudo apt purge nvidia*`
```shell
./docker/scripts/dev_into.sh # 进入容器
./apollo.sh build # 开始构建
./scripts/bootstrap.sh start # 启动
```
上述命令会启动 DreamView 并使能模块监控机制，在浏览器中访问 http://localhost:8888 来显示 DreamView 界面。












