# Installation

1. 更新 ROS源地址
```shell
# # 更换阿里源, 网速快; 缺点, 当碰巧,阿里源正在和官方源同步的时段，会无法安装
# sed -i 's/cn.archive.ubuntu.com/mirrors.aliyun.com/' /etc/apt/sources.list # X86 中文
# sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/' /etc/apt/sources.list    # X86 英文
# sed -i 's/ports.ubuntu.com/mirrors.aliyun.com/' /etc/apt/sources.list      # arm

#  添加 科大ROS源
sudo sh -c '. /etc/lsb-release && echo "deb http://mirrors.ustc.edu.cn/ros/ubuntu/ $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/ros-latest.list'

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F42ED6FBAB17C654
sudo apt-get update
```

2. 安装 ROS
- 执行安装脚本
```shell
# 按照提示输入,当前用户密码
# x86_64
wget -qO - https://raw.githubusercontent.com/my-rds-store/my_space/master/source/autoware/src/ros_instal.sh | bash
wget -qO - https://raw.fastgit.org/my-rds-store/my_space/master/source/autoware/src/ros_instal.sh | bash

# Arm - Nvidia Jetson AGX
wget -qO - https://github.com/my-rds-store/my_space/raw/master/source/autoware/src/ros_install_agx.sh | bash
wget -qO - https://raw.fastgit.org/my-rds-store/my_space/master/source/autoware/src/ros_install_agx.sh
```
- x86_64安装脚本的源码如下:
```shell
##############################
# Install ROS  melodic
##############################

sudo tee /etc/resolv.conf <<-'EOF'
nameserver 114.114.114.114
nameserver 8.8.8.8
EOF

sudo apt install libc6:i386 --yes --allow-unauthenticated
#sudo apt-get install cuda-10-0

sudo apt-get install openssh-server vim --yes --allow-unauthenticated
sudo apt-get install python3-pip --yes --allow-unauthenticated
sudo apt-get install ros-melodic-desktop-full --yes --allow-unauthenticated
sudo apt-get install ros-melodic-desktop-full --yes --allow-unauthenticated --fix-missing

sudo apt-get install ros-melodic-rosbash ros-melodic-rosbash-params --yes --allow-unauthenticated

tee ${HOME}/.bash_aliases <<-'EOF'
##################################
#  CUDA
##################################
export CUDA_HOME=/usr/local/cuda-10.0
export PATH=$PATH:$CUDA_HOME/bin
export LD_LIBRARY_PATH=${CUDA_HOME}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

export CPLUS_INCLUDE_PATH=/usr/local/include/eigen3:${CPLUS_INCLUDE_PATH}  # autoware : --- stderr: glviewer

source /opt/ros/melodic/setup.bash
EOF
source /opt/ros/melodic/setup.bash


sudo apt-get install python-rosinstall \
                     python-rosinstall-generator \
                     python-wstool \
                     build-essential --yes --allow-unauthenticated


sudo apt install -y python-catkin-pkg python-rosdep ros-$ROS_DISTRO-catkin
sudo apt install -y python3-pip python3-colcon-common-extensions python3-setuptools python3-vcstool

##############
sudo tee /etc/resolv.conf <<-'EOF'
nameserver 8.8.8.8
nameserver 114.114.114.114
EOF

sudo rosdep init
rosdep update

##############
sudo tee /etc/resolv.conf <<-'EOF'
nameserver 114.114.114.114
nameserver 8.8.8.8
EOF



sudo apt-get install libarmadillo-dev libglew-dev libssh2-1-dev python-flask python-requests wget --yes --allow-unauthenticated

######## pip
mkdir ${HOME}/.pip
sudo tee ${HOME}/.pip/pip.conf <<-'EOF'
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/

#(legacy|columns)
format = columns

[install]
trusted-host=mirrors.aliyun.com
EOF

#######
sudo apt-get install vim openssh-server --yes --allow-unauthenticated


# #sudo apt-get install nvidia-docker2
# sudo apt-get install curl --yes --allow-unauthenticated
# sudo apt-get install chromium-browser --yes --allow-unauthenticated

sudo apt-get install libsdl1.2-dev --yes --allow-unauthenticated

#
# #sudo apt-get install aptitude
# #sudo aptitude install  ros-melodic-desktop-full --yes --allow-unauthenticated
```