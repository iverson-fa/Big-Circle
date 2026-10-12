# Packages

## 1 源码安装

### 1.1 开发环境设置

```bash
# 默认 galactic
git clone https://github.com/autowarefoundation/autoware.git
# humble
git clone https://github.com/autowarefoundation/autoware.git -b humble
```

### 1.2 安装依赖

#### 1.2.1 ROS 2

```bash
$ sudo apt install software-properties-common
$ sudo add-apt-repository universe
$ apt-cache policy | grep universe
 500 http://us.archive.ubuntu.com/ubuntu focal/universe amd64 Packages
     release v=20.04,o=Ubuntu,a=focal,n=focal,l=Ubuntu,c=universe,b=amd64   
```

```bash
# Taken from: https://docs.ros.org/en/galactic/Installation/Ubuntu-Install-Debians.html

# You will need to add the ROS 2 apt repository to your system. First, make sure that the Ubuntu Universe repository is enabled by checking the output of this command.
apt-cache policy | grep universe

# The output of the above command should contain following:

# 500 http://us.archive.ubuntu.com/ubuntu focal/universe amd64 Packages
#     release v=20.04,o=Ubuntu,a=focal,n=focal,l=Ubuntu,c=universe,b=amd64

# If you don’t see an output line like the one above, then enable the Universe repository with these instructions.
sudo apt install software-properties-common
sudo add-apt-repository universe

# Now add the ROS 2 apt repository to your system. First authorize our GPG key with apt.
sudo apt update && sudo apt install curl gnupg lsb-release
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

# Then add the repository to your sources list.
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Update your apt repository caches after setting up the repositories.
sudo apt update

# Desktop Install
rosdistro=galactic
installation_type=desktop
sudo apt install ros-${rosdistro}-${installation_type}

# Environment setup
# (Optional) You can source ros2 in the ~/.bashrc file.
echo '' >> ~/.bashrc && echo "source /opt/ros/${rosdistro}/setup.bash" >> ~/.bashrc
```

#### 1.2.2 ROS 2 development tools

```bash
# Taken from https://docs.ros.org/en/galactic/Installation/Ubuntu-Development-Setup.html
sudo apt update && sudo apt install -y \
  build-essential \
  cmake \
  git \
  python3-colcon-common-extensions \
  python3-flake8 \
  python3-pip \
  python3-pytest-cov \
  python3-rosdep \
  python3-setuptools \
  python3-vcstool \
  wget

# Install some pip packages needed for testing
python3 -m pip install -U \
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
  setuptools \
  -i http://pypi.douban.com/simple --trusted-host pypi.douban.com

# Initialize rosdep
sudo rosdep init
rosdep update
```

#### 1.2.3 ROS 2 RMW implementation

```bash
# For details: https://docs.ros.org/en/galactic/How-To-Guides/Working-with-multiple-RMW-implementations.html
sudo apt update
rosdistro=galactic
rmw_implementation=rmw_cyclonedds_cpp
rmw_implementation_dashed=$(eval sed -e "s/_/-/g" <<< "${rmw_implementation}")
sudo apt install ros-${rosdistro}-${rmw_implementation_dashed}

# (Optional) You set the default RMW implementation in the ~/.bashrc file.
echo '' >> ~/.bashrc && echo "export RMW_IMPLEMENTATION=${rmw_implementation}" >> ~/.bashrc
```

#### 1.2.4 pacmod

```bash
# Taken from https://github.com/astuff/pacmod3#installation
sudo apt install apt-transport-https
sudo sh -c 'echo "deb [trusted=yes] https://s3.amazonaws.com/autonomoustuff-repo/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/autonomoustuff-public.list'
sudo apt update
rosdistro=galactic
sudo apt install ros-${rosdistro}-pacmod3
```

#### 1.2.5 Autoware Core Dependencies

```bash
# Install gdown to download files from CMakeLists.txt
pip3 install gdown
```

#### 1.2.6 Autoware Universe Dependencies

```bash
sudo apt install geographiclib-tools
# Add EGM2008 geoid grid to geographiclib
sudo geographiclib-get-geoids egm2008-1
```

#### 1.2.7 pre_commit

```bash
clang_format_version=14.0.6
pip3 install pre-commit clang-format==${clang_format_version}

# Install Golang (Add Go PPA for shfmt)
sudo add-apt-repository ppa:longsleep/golang-backports
sudo apt install golang
```

#### 1.2.8 CUDA & cuDNN & TensorRT

```bash
# Modified from:
# https://developer.nvidia.com/cuda-11-4-4-download-archive?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=deb_network
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
sudo apt-get update
cuda_version=11-4
sudo apt install cuda-${cuda_version} --no-install-recommends
```

```bash
# Taken from: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#post-installation-actions
echo 'export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> ~/.bashrc
```

```bash
# Taken from: https://docs.nvidia.com/deeplearning/tensorrt/install-guide/index.html#installing

cudnn_version=8.4.1.50-1+cuda11.6
sudo apt-get install libcudnn8=${cudnn_version} libcudnn8-dev=${cudnn_version}
sudo apt-mark hold libcudnn8 libcudnn8-dev

tensorrt_version=8.4.2-1+cuda11.6
sudo apt-get install libnvinfer8=${tensorrt_version} libnvonnxparsers8=${tensorrt_version} libnvparsers8=${tensorrt_version} libnvinfer-plugin8=${tensorrt_version} libnvinfer-dev=${tensorrt_version} libnvonnxparsers-dev=${tensorrt_version} libnvparsers-dev=${tensorrt_version} libnvinfer-plugin-dev=${tensorrt_version}
sudo apt-mark hold libnvinfer8 libnvonnxparsers8 libnvparsers8 libnvinfer-plugin8 libnvinfer-dev libnvonnxparsers-dev libnvparsers-dev libnvinfer-plugin-dev
```

### 1.3 Workspace 设置

```bash
cd autoware
mkdir src
vcs import src < autoware.repos
# rosdep
source /opt/ros/galactic/setup.bash
rosdepc install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO
# build
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release
```

更新

```bash
cd autoware
git pull
vcs import src < autoware.repos
vcs pull src
source /opt/ros/galactic/setup.bash
rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release
```

