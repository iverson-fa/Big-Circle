# Jetson AGX Xavier 安装 ROS2 和 Autoware.Auto

## 1 ROS2 Dashing 安装

### **1.1 参考网站**

[Github源码](https://github.com/ros2)

[navigation2 repository](https://index.ros.org/r/navigation2/)

[**ROS2 官方文档**](http://docs.ros.org/en/galactic/index.html)

[ROS Wiki](http://wiki.ros.org/)

[ROS2 官方教程](http://wiki.ros.org/ROS2/Tutorials)

[colcon文档](https://colcon.readthedocs.io/en/released/)



### **1.2 ROS2 安装 (dashing)**

**1.2.1 设置语言环境**

确保您有一个支持的语言环境 UTF-8. 如果您处于最小环境（例如 docker 容器）中，则语言环境可能是最小的，例如 POSIX. 我们使用以下设置进行测试。 但是，如果您使用不同的 UTF-8 支持的语言环境应该没问题。

```shell
locale  # check for UTF-8

sudo apt update && sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

locale  # verify settings
```



**1.2.2 添加 ROS2 apt 存储库**

```shell
sudo apt update && sudo apt install curl gnupg2 lsb-release

sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
```

认证 GPG 密钥可能需要梯子。

**1.2.3 安装开发工具**

```shell
sudo apt update && sudo apt install -y \
  build-essential \
  cmake \
  git \
  python3-colcon-common-extensions \
  python3-pip \
  python-rosdep \
  python3-vcstool \
  wget

# install some pip packages needed for testing
python3 -m pip install -U \
  argcomplete \
  flake8 \
  flake8-blind-except \
  flake8-builtins \
  flake8-class-newline \
  flake8-comprehensions \
  flake8-deprecated \
  flake8-docstrings \
  flake8-import-order \
  flake8-quotes \
  pytest-repeat \
  pytest-rerunfailures \
  pytest \
  pytest-cov \
  pytest-runner \
  setuptools

# install Fast-RTPS dependencies
sudo apt install --no-install-recommends -y \
  libasio-dev \
  libtinyxml2-dev
# install Cyclone DDS dependencies
sudo apt install --no-install-recommends -y \
  libcunit1-dev
```

```shell
# 编译 yaml-cpp-0.6 ，某些功能包可能会用到
# AGX 直接选 make -j8
git clone --branch yaml-cpp-0.6.0 https://github.com/jbeder/yaml-cpp yaml-cpp-0.6 && \
    cd yaml-cpp-0.6 && \
    mkdir build && \
    cd build && \
    cmake -DBUILD_SHARED_LIBS=ON .. && \
    make -j$(nproc) && \
    sudo cp libyaml-cpp.so.0.6.0 /usr/lib/aarch64-linux-gnu/ && \
    sudo ln -s /usr/lib/aarch64-linux-gnu/libyaml-cpp.so.0.6.0 /usr/lib/aarch64-linux-gnu/libyaml-cpp.so.0.6
```



**1.2.4 构建代码**

```shell
# 获取 ROS2 dashing
mkdir -p ~/ros2_dashing/src
cd ~/ros2_dashing
wget https://raw.githubusercontent.com/ros2/ros2/dashing/ros2.repos
vcs import src < ros2.repos

# rosdep 安装依赖项
sudo rosdep init
rosdep update
rosdep install --from-paths src --ignore-src --rosdistro dashing -y --skip-keys "console_bridge fastcdr fastrtps libopensplice67 libopensplice69 rti-connext-dds-5.3.1 urdfdom_headers"
```

在使用 vcs 拉取代码时，可能会失败，解决方法：

- 需要梯子
- 从其他下载好的地方拷贝至此文件夹
- 根据 `ros2.repos` 的内容自己从 `github` 上找对应的库版本下载



执行 `sudo rosdep init` 遇到连接超时的情况，可以在执行如下步骤：

```shell
# 方法一
$ sudo vim /etc/hosts

192.232.28.133 raw.githubusercontent.com
151.101.228.133 raw.github.com

# 方法二
$ sudo mkdir -p /etc/ros/rosdep/source.list.d
$ cd /etc/ros/rosdep/source.list.d
$ sudo vim 20-default.list

# os-specific listings first
yaml https://raw.githubusercontent.com/ros/rosdistro/master/rosdep/osx-homebrew.yaml osx

# generic
yaml https://raw.githubusercontent.com/ros/rosdistro/master/rosdep/base.yaml
yaml https://raw.githubusercontent.com/ros/rosdistro/master/rosdep/python.yaml
yaml https://raw.githubusercontent.com/ros/rosdistro/master/rosdep/ruby.yaml
gbpdistro https://raw.githubusercontent.com/ros/rosdistro/master/releases/fuerte.yaml fuerte

# newer distributions (Groovy, Hydro, ...) must not be listed anymore, they are being fetched from the rosdistro index.yaml instead
```

安装依赖项时，`rosdep update` 需要梯子，或者使用 `http://ghproxy.com` 代理修改配置文件，具体需要修改的地方如下（Ubuntu 18.04 和 Ubuntu 20.04 是不一样的）：

```shell
# /usr/lib/python2.7/dist-packages/rosdep2/sources_list.py
    72行
    308行 download_rosdep_data()函数的try后添加一行
          url="https://ghproxy.com/"+url

# /usr/lib/python2.7/dist-packages/rosdep2/gbpdistro_support.py
    36行
    204行添加 gbpdistro_url = 'https://ghproxy.com/' + gbpdistro_url

# /usr/lib/python2.7/dist-packages/rosdep2/rep3.py
     39行

# /usr/lib/python2.7/dist-packages/rosdistro/manifest_provider/github.py
     68/119行

# /usr/lib/python2.7/dist-packages/rosdistro/_ __init___.py
     68行
```

需要主要的是，使用 `rosdep` 安装依赖的时间会非常长，根据实际网速变化，个别依赖包体积较大，耐心等待即可。

```shell
# 编译,编译日志的写权限需要 sudo,可以不带
cd ~/ros2_dashing/
sudo colcon build --symlink-install
# 为了保证所有功能包完成编译，再编译一次
sudo colcon build --symlink-install

# environment setup
. ~/ros2_dashing/install/setup.bash
# 或者使用扩展环境变量的方法写入 .bash_aliases 文件
echo "source $ROS_ROOT/install/setup.bash" >> ~/.bash_aliases
echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bash_aliases
echo "export _colcon_cd_root=~/ros2_install" >> ~/.bash_aliases
```

Dashing 版本有 270 个功能包需要编译，虽然 colcon 是并行编译，但是花费时间依然较长，耐心等待即可。

```shell
# 简单示例
## 一个终端输入
. ~/ros2_dashing/install/local_setup.bash
ros2 run demo_nodes_cpp talker

## 另一个终端输入
. ~/ros2_dashing/install/local_setup.bash
ros2 run demo_nodes_py listener
```

至此，ROS2 Dashing 版本已经在 AGX 上成功构建（过程中有其他安装问题清查阅官方文档）。

## 2 安装 Autoware.Auto

### 2.1 参考资料

- [nvidia-docker](https://github.com/NVIDIA/nvidia-docker)
- 