# ROS2

## ROS2安装(galactic)
官方要求是需要确认支持UTF-8，虽然说起来似乎不一定需要，不过确认一下即可。
特别是在docker容器内使用时，由于locale经常会被最小化地设置为POSIX。

```shell
locale  # check for UTF-8

sudo apt update && sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

locale  # verify settings
```

设置Ubuntu Universe仓库
```shell
sudo apt install software-properties-common
sudo add-apt-repository universe
```
```shell
sudo apt update && sudo apt install curl gnupg lsb-release
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg # 验证GPG key
sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list' # 将仓库加入软件源
sudo apt update
sudo apt install ros-galactic-desktop
# sudo aptitude install ros-galactic-desktop
# sudo apt install ros-galactic-ros-base # 没有GUI工具
```
在.bashrc文件中添加`source /opt/ros/galactic/setup.bash`。

测试
```shell
ros2 run demo_nodes_cpp talker
ros2 run demo_nodes_cpp listener
```

## ROS2学习

1. [Github源码](https://github.com/ros2)
2. [navigation2 repository](https://index.ros.org/r/navigation2/)