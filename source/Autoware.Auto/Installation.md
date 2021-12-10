# Installation
- [Autoware Documentation](https://tier4.github.io/autoware.proj/tree/main/)

## Installation

安装vcstool
```shell
sudo apt update && sudo apt install curl gnupg lsb-release
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt-get update && sudo apt-get install python3-vcstool
```
设置Autoware仓库
```shell
mkdir -p ~/workspace
cd ~/workspace
git clone git@github.com:tier4/autoware.proj.git
cd autoware.proj
mkdir src
vcs import src < autoware.proj.repos
```
执行脚本，安装CUDA, cuDNN 8, OSQP, ROS 2, TensorRT 7
```shell
./setup_ubuntu20.04.sh
```
编译
```shell
source ~/.bashrc
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release
```
>  会有几个模块出现stderr，忽略即可。

更新
```shell
cd autoware.proj
git pull

# Usually you can ignore this step, but note that it sometimes causes errors.
rm -rf src
mkdir src
rm -rf build/ install/ log/

vcs import src < autoware.proj.repos
vcs pull src
rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release
```

## [Packages list](./Packages_List.md)








