

# 11 LGSVL_Simulator

## 1 概述

本文档介绍了在 SVL 模拟器中设置和使用 Autoware.Auto。由于 Autoware.Auto 仍处于开发阶段，完全自动驾驶尚不可能。本指南将重点关注运行已实现的各个模块。

## 2 设置

### 2.1 要求

- Linux操作系统
- 英伟达显卡

### 2.2 安装 Docker CE

要安装 Docker CE，请参考 [官方文档](https://docs.docker.com/install/linux/docker-ce/ubuntu/)。

建议按照 [安装后的步骤](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user)以非 root 用户身份运行 docker。

验证是否可以运行不带以下`docker`命令的命令`sudo`：

```bash
# In a desktop shell

docker run hello-world
```

此命令下载测试映像并在容器中运行它。当容器运行时，它会打印一条消息并退出。

## 3 安装 NVIDIA Container Toolkit

在安装 NVIDIA Container Toolkit 之前，请确保已安装适当的 NVIDIA 驱动程序。要测试是否正确安装了 NVIDIA 驱动程序，请输入`nvidia-smi`。如果驱动程序安装正确，应该会出现类似于以下内容的输出：

```console
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 440.59       Driver Version: 440.59       CUDA Version: 10.2     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  GeForce GTX 108...  Off  | 00000000:65:00.0  On |                  N/A |
|  0%   59C    P5    22W / 250W |   1490MiB / 11175MiB |      4%      Default |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|    0      1187      G   /usr/lib/xorg/Xorg                           863MiB |
|    0      3816      G   /usr/bin/gnome-shell                         305MiB |
|    0      4161      G   ...-token=7171B24E50C2F2C595566F55F1E4D257    68MiB |
|    0      4480      G   ...quest-channel-token=3330599186510203656   147MiB |
|    0     17936      G   ...-token=5299D28BAAD9F3087B25687A764851BB   103MiB |
+-----------------------------------------------------------------------------+
```

NVIDIA Container Toolkit 的安装步骤可从[官方文档](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)中获得。

`nvidia-smi`通过在基本 CUDA 容器中运行来验证 NVIDIA Container Toolkit 是否正常工作：

```bash
# In a desktop shell

docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```

这将验证 Docker CE 和 NVIDIA Container Toolkit 是否已安装并正常工作。

### 3.1 LGSVL 安装

- 下载并提取最新的[模拟器版本](https://github.com/lgsvl/simulator/releases/latest)。
- （可选）下载最新的[PythonAPI 版本](https://github.com/lgsvl/PythonAPI/releases/latest)（确保版本与模拟器匹配）并使用 pip 安装：

```bash
# In a desktop shell

cd PythonAPI
pip3 install --user .
```

### 3.2 安装 Autoware.Auto

**安装 ADE**

```bash
# In a desktop shell
# (from https://ade-cli.readthedocs.io/en/latest/install.html)

cd ~/.local/bin
wget https://gitlab.com/ApexAI/ade-cli/uploads/f6c47dc34cffbe90ca197e00098bdd3f/ade+x86_64
mv ade+x86_64 ade
chmod +x ade
./ade --version
# 4.0.0

./ade update-cli
./ade --version
# <latest-version>

PATH=$PATH:~/.local/bin
mkdir -p ~/adehome
cd ~/adehome
touch .adehome
```

**下载 Autoware.Auto**

在 ~/adehome 文件夹下下载 Autoware.Auto。

```bash
# In a desktop shell

cd ~/adehome
git clone https://gitlab.com/autowarefoundation/autoware.auto/AutowareAuto.git
```

安装和开发： Autoware.Auto 的[安装指南](https://autowarefoundation.gitlab.io/autoware.auto/AutowareAuto/installation.html)。

每个外部依赖库（ROS2 桥、消息等）都必须克隆到`external`源目录下的文件夹中：

```bash
mkdir -p ~/adehome/AutowareAuto/src/external/
cd ~/adehome/AutowareAuto/src/external/
```

**下载 AutowareAuto 的 msg**

该模块对于进一步的构建进度是必要的。

```bash
# in ~/adehome/AutowareAuto/src/external/
git clone https://gitlab.com/autowarefoundation/autoware.auto/autoware_auto_msgs.git
```

**运行 ADE 容器**

```bash
# in ~/adehome/AutowareAuto/
ade start --update
```

**停止 ADE 容器运行**

```bash
ade stop
```

**注意**所有接下来的构建步骤都假设 ADE 容器已经在运行。

### 3.3 安装 ROS 2 LGSVL Bridge

ros2-lgsvl-bridge有两种安装方式：

- 使用包管理器
- 构建源代码

#### 1.包管理器（推荐）

```bash
# In the ade container

sudo apt update
sudo apt install ros-foxy-lgsvl-bridge

# Test the bridge (then ctrl-c to stop the bridge):
lgsvl_bridge
```

- 注意：如果在 ADE 中`sudo apt update`返回`apt update: signatures were invalid`，请尝试按照[answers.ros.org](https://answers.ros.org/question/379190/apt-update-signatures-were-invalid-f42ed6fbab17c65)`curl http://repo.ros2.org/repos.key | sudo apt-key add -`中的说明更新 repo 密钥。

#### 2. 从源代码构建

外部模块文件夹

下载 ROS2 桥接器

```bash
# in ~/adehome/AutowareAuto/src/external/
git clone https://github.com/lgsvl/ros2-lgsvl-bridge.git
cd ros2-lgsvl-bridge
git checkout foxy-devel
```

构建 ROS2 桥

请参阅 repo 中的 README.md。

```bash
ade enter
# In the ade container

cd ~/AutowareAuto
colcon build --packages-select lgsvl_bridge --cmake-args '-DCMAKE_BUILD_TYPE=Release'
```

运行 ROS2 桥接器

请参阅 repo 中的 README.md。

```bash
ade enter
# In the ade container
source ~/AutowareAuto/install/setup.bash
lgsvl_bridge
```

### 3.4 安装 ROS 2 LGSVL 消息

下载

```bash
# in ~/adehome/AutowareAuto/src/external/
git clone https://github.com/lgsvl/lgsvl_msgs.git
```

编译

```bash
ade enter
# In the ade container

source ~/AutowareAuto/src/external/ros2-lgsvl-bridge/install/setup.bash
lgsvl_bridge

cd ~/AutowareAuto
colcon build --cmake-args '-DCMAKE_BUILD_TYPE=Release'
```

作为成功构建的示例，在控制台输出中观察如下内容：

```
...
Summary: 115 packages finished [8min 5s]
...
```

*注意：*只想使用以下命令构建 lgsvl_msgs 包：

```bash
colcon build --packages-select lgsvl_msgs --cmake-args '-DCMAKE_BUILD_TYPE=Release'
```

测试

注意：ROS2 Foxy 已弃用该`ros2 msg list`命令，请`ros2 interface list`改用。

```bash
ade enter
# In the ade container
cd ~/AutowareAuto
source install/setup.bash
ros2 interface list | grep lgsvl_msgs
# If you can see the list of lgsvl_msgs, they're ready to be used.
# Example:
...
lgsvl_msgs/CanBusData
lgsvl_msgs/VehicleControlData
lgsvl_msgs/VehicleStateData
...
```

## 4 Autoware.Auto && LGSVL 配置

ROS 2 网桥允许模拟器和 Autoware.auto 进行通信。为了测试这种连接，我们可以在 rviz2 中可视化来自模拟器的传感器数据（在 Autoware.auto 容器中运行）。

#### 4.1 在没有 NVIDIA 设置的情况下启动 ADE

如果 ADE 容器已经在运行，请停止它：`$ ade stop`

```bash
# In a desktop shell

cd ~/adehome/AutowareAuto
source .aderc-amd64-foxy-lgsvl
ade start
```

#### 4.2 使用 NVIDIA 设置启动 ADE

如果 ADE 容器已经在运行，请停止它：`$ ade stop`

创建一个具有 nvidia 设置的 adrc 文件：

```bash
# In a desktop shell

vim  ~/adehome/AutowareAuto/.aderc-amd64-foxy-lgsvl-nvidia
```

将下一个块粘贴到`.aderc-amd64-foxy-lgsvl-nvidia`文件中：

```bash
export ADE_DOCKER_RUN_ARGS="--cap-add=SYS_PTRACE --net=host --privileged --add-host ade:127.0.0.1 -e RMW_IMPLEMENTATION=rmw_cyclonedds_cpp --runtime=nvidia -ti --rm -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
-e NVIDIA_VISIBLE_DEVICES=all \
-e NVIDIA_DRIVER_CAPABILITIES=compute,utility,display"
export ADE_GITLAB=gitlab.com
export ADE_REGISTRY=registry.gitlab.com
export ADE_DISABLE_NVIDIA_DOCKER=false
export ADE_IMAGES="
  registry.gitlab.com/autowarefoundation/autoware.auto/autowareauto/amd64/ade-foxy:master
  registry.gitlab.com/autowarefoundation/autoware.auto/autowareauto/amd64/binary-foxy:master
  registry.gitlab.com/autowarefoundation/autoware.auto/ade-lgsvl/foxy:2020.06
  nvidia/cuda:11.0-base
"
```

（停止并重新）启动 ADE ：

```bash
# In a desktop shell, first stop ADE container if it was previously running
ade stop

cd ~/adehome/AutowareAuto
source .aderc-amd64-foxy-lgsvl-nvidia
ade start
ade enter
```

#### 4.3 在正在运行的 ADE 容器中构建并启动 RViz

```bash
ade enter
# In the ADE container
cd ~/AutowareAuto
colcon build --cmake-args '-DCMAKE_BUILD_TYPE=Release'
source ~/AutowareAuto/install/setup.bash
```

- 启动rviz2：

```bash
# In the ade container

rviz2 -d /home/"${USER}"/AutowareAuto/install/autoware_auto_examples/share/autoware_auto_examples/rviz2/autoware.rviz
```

#### 4.4 启动 SVL Simulator

- 在 ADE 容器之外启动可执行文件并单击`OPEN BROWSER`按钮以打开 Web UI。

```
bash  $ (path\to\downloaded\simulator)/svlsimulator-linux64-2021.3/simulator
```

- 在 Library 下的 Vehicles 选项卡中，查找`Lexus2016RXHybrid`. 如果不可用，请参阅[库](https://www.svlsimulator.com/docs/user-interface/web/library/#vehicles)页面以添加它。

  - 确保 Autoware.Auto 传感器配置具有`ROS2`桥接并添加了所有传感器。
  - 单击左侧库下的车辆，然后`Lexus2016RXHybrid`单击`Autoware.Auto`传感器配置。
  - 如果可以在传感器名称旁边看到标记，请单击`Add to Library button`以将传感器插件添加到库中。

- 切换到模拟选项卡并单击`Add new`按钮：

  - 输入模拟名称，然后单击下一步。
  - 在运行时模板中选择随机流量。
  - 从下拉菜单中选择地图。如果没有可用的，请按照[本指南](https://www.svlsimulator.com/docs/user-interface/web/library/#maps)获取地图。
  - `Lexus2016RXHybrid`从车辆的下拉菜单中选择。
  - `Autoware.Auto`在 Sensor Configuration 中选择，然后单击 Next。

- 在 Autopilot 中选择

  ```
  Autoware.Auto (Apex.AI)
  ```

  并在 Bridge IP 框中输入网桥地址（默认值：）

  ```
  localhost:9090
  ```

  然后单击 Next

  - 单击发布。
  - 按下`Run Simulation`按钮。

#### 4.5 启动 ROS 2 LGSVL Bridge

在新的终端窗口中

```bash
ade enter
# In the ADE container
source ~/AutowareAuto/install/setup.bash
lgsvl_bridge
```

#### 4.6 配置 RViz 查看 LIDAR 点云

在 RViz`Displays`面板中（下图左上角）：

- 将 Fixed Frame（在全局选项下）设置为`lidar_front`。
- 验证是否添加`PointCloud2`了一条`Transformed Points`消息。
- 将消息的`Topic`字段设置为`/lidar_front/points_raw`主题。

![img](https://www.svlsimulator.com/docs/images/system-under-test/autoware-auto-rviz.png)

## 5 ADE 中运行 LGSVL

以下是在在 ADE 中运行 SVL Simulator ，但建议改为在主机上运行 SVL Simulator。

#### 5.1 构建ADE

将以下内容复制`Dockerfile`到 ~/adehome/AutowareAuto/tools/ade_image 文件夹中。

```dockerfile
FROM ubuntu:20.04
CMD ["bash"]

ARG ROS_DISTRO=foxy

# https://docs.ros.org/en/foxy/Installation/Ubuntu-Development-Setup.html
RUN apt update && apt install locales
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
RUN export LANG=en_US.UTF-8

# tz America/Los_Angeles
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get install -y tzdata

RUN apt update && apt install -y curl gnupg2 lsb-release python3-pip gettext
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
# /https://docs.ros.org/en/foxy/Installation/Ubuntu-Development-Setup.html

RUN apt-get update && \
    apt-get install -y \
      python3-vcstool \
      ros-$ROS_DISTRO-cyclonedds \
      ros-$ROS_DISTRO-rmw-cyclonedds-cpp && \
    rm -rf /var/lib/apt/lists/* #/tmp/ros-deps

COPY apt-packages /tmp/
RUN apt-get update && \
    apt-get install -y \
        $(cat /tmp/apt-packages | cut -d# -f1 | envsubst) \
    && rm -rf /var/lib/apt/lists/* /tmp/apt-packages

RUN echo 'ALL ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN echo 'Defaults env_keep += "DEBUG ROS_DISTRO"' >> /etc/sudoers


COPY pip3-packages /tmp/
RUN pip3 install -U \
        $(cut -d# -f1 </tmp/pip3-packages) \
    && rm -rf /root/.cache /tmp/pip-* /tmp/pip3-packages


RUN git clone https://github.com/rigtorp/udpreplay && mkdir -p udpreplay/build \
      && cd udpreplay/build && cmake .. && make && make install \
      && cd - && rm -rf udpreplay/


COPY bashrc-git-prompt /
RUN cat /bashrc-git-prompt >> /etc/skel/.bashrc && \
    rm /bashrc-git-prompt
COPY gdbinit /etc/gdb/


# ===================== CLEAN UP ZONE ===================== #
# Commands in the cleanup zone will be cleaned up before every release
# and put into the correct place.
RUN apt-get update \
  && apt-get install -y \
    unzip \
    ca-certificates \
    libx11-6 \
    libxau6 \
    libxcb1 \
    libxdmcp6 \
    libxext6 \
    libvulkan1 \
    libgl1 \
    libgtk2.0-0 \
    vulkan-utils \
    docker.io \
    xdg-utils \
  && apt-get clean

ADD "https://gitlab.com/nvidia/container-images/vulkan/raw/master/nvidia_icd.json" /etc/vulkan/icd.d/nvidia_icd.json
RUN chmod 644 /etc/vulkan/icd.d/nvidia_icd.json

# ===================== END OF CLEAN UP ZONE ===================== #

# Add print url into tty part.
COPY print-tty.desktop /usr/share/applications/print-tty.desktop
COPY print-tty.sh /usr/bin/print-tty.sh
RUN chmod 755 /usr/bin/print-tty.sh
RUN apt-get update \
  && apt-get install -y \
    ros-$ROS_DISTRO-lgsvl-bridge \
  && apt-get clean
# /Add print url into tty part.

# Do full package upgrade as last step
# to avoid disrupting layer caching
RUN apt-get update && \
    apt-get -y dist-upgrade && \
    rm -rf /var/lib/apt/lists/*

COPY env.sh /etc/profile.d/ade_env.sh
COPY gitconfig /etc/gitconfig
COPY entrypoint /ade_entrypoint
COPY colcon-defaults.yaml /usr/local/etc/colcon-defaults.yaml
RUN echo "export COLCON_DEFAULTS_FILE=/usr/local/etc/colcon-defaults.yaml" >> \
    /etc/skel/.bashrc
ENTRYPOINT ["/ade_entrypoint"]
CMD ["/bin/sh", "-c", "trap 'exit 147' TERM; tail -f /dev/null & wait ${!}"]
```

将以下`print-tty.desktop`文件复制到 ~/adehome/AutowareAuto/tools/ade_image 文件夹中。

```
[Desktop Entry]
Name=PrintTty
GenericName=Print On Tty
Comment=Prints text on first tty
TryExec=echo
Exec=print-tty.sh %F
Terminal=true
Type=Application
MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/ftp;x-scheme-handler/http;x-scheme-handler/https;
```

将以下`print-tty.sh`文件复制到 ~/adehome/AutowareAuto/tools/ade_image 文件夹中。

```bash
#!/bin/sh

echo "$@" >/dev/tty
```

构建 docker 容器并标记它：

```bash
cd ~/adehome/AutowareAuto/tools/ade_image
docker build -t registry.gitlab.com/autowarefoundation/autoware.auto/autowareauto/amd64/ade-foxy:local .
```

#### 5.2 构建并启动ADE

将以下 .aderc-amd64-foxy-lgsvl-nvidia 复制到 ~/adehome/AutowareAuto 文件夹中：

```bash
export ADE_DOCKER_RUN_ARGS="--cap-add=SYS_PTRACE --net=host --privileged --add-host ade:127.0.0.1 -e RMW_IMPLEMENTATION=rmw_cyclonedds_cpp --runtime=nvidia -ti --rm -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
-e NVIDIA_VISIBLE_DEVICES=all \
-e NVIDIA_DRIVER_CAPABILITIES=compute,utility,display"
export ADE_GITLAB=gitlab.com
export ADE_REGISTRY=registry.gitlab.com
export ADE_DISABLE_NVIDIA_DOCKER=false
export ADE_IMAGES="
  registry.gitlab.com/autowarefoundation/autoware.auto/autowareauto/amd64/ade-foxy:local
  registry.gitlab.com/autowarefoundation/autoware.auto/autowareauto/amd64/binary-foxy:master
  registry.gitlab.com/apexai/ade-lgsvl:2021.2.1
  nvidia/cuda:11.0-base
"
```

*注意：*如果有`registry.gitlab.com/apexai/ade-lgsvl:2021.2.1` 容器，您可以将其包含在 .aderc-amd64-foxy-lgsvl-nvidia 文件中（如上例所示）；如果不这样做，可以在启动 ade 容器时将本地模拟器安装到 ade docker 容器中的 /opt/lgsvl 中。

source  .aderc-amd64-foxy-lgsvl-nvidia：

```bash
source .aderc-amd64-foxy-lgsvl-nvidia
```

解压缩：

```bash
unzip svlsimulator-linux64-2021.2.1.zip -d ~
```

启动 ADE

```bash
ade start -- -e DISPLAY -e XAUTHORITY=/tmp/.Xauthority \
-v ${XAUTHORITY}:/tmp/.Xauthority -v /tmp/.X11-unix:/tmp/.X11-unix \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /tmp/LGElectronics/:/tmp/LGElectronics/ \
-v ~/svlsimulator-linux64-2021.2.1:/opt/lgsvl
```

#### 5.3 在 ADE中启动 Simulator

```bash
ade enter
lgsvl_bridge &
/opt/lgsvl/simulator
```

点击集群链接，终端打印URL。

将 URL 复制并粘贴到 Web 浏览器以打开 SVL Simulator 用户界面。

## 6 在 Autoware.Auto 中运行 AVP

这解释了从 ADE docker 容器运行预构建的 Autoware.Auto。如果要运行从源代码[构建的 Autoware.Auto，请参阅如何构建代码](https://autowarefoundation.gitlab.io/autoware.auto/AutowareAuto/building.html#installation-and-development-how-to-build)。

### 6.1 运行 ROS 2 LGSVL Bridge

检查是否安装了 ROS 2 LGSVL Bridge。如果没有，[安装 ROS 2 LGSVL Bridge](https://www.svlsimulator.com/docs/system-under-test/autoware-auto-instructions/#install-ros2-lgsvl-bridge data-toc-label)。

```bash
# In the ade container
source /opt/AutowareAuto/setup.bash
lgsvl_bridge
```

### 6.2 运行 AVP 

```bash
# In the ade container
source /opt/AutowareAuto/setup.bash
ros2 launch /opt/AutowareAuto/src/launch/autoware_demos/launch/avp_sim.launch.py
```

### 6.3 运行 RViz2

```bash
# In the ade container
source /opt/AutowareAuto/setup.bash
rviz2 -d /opt/AutowareAuto/share/autoware_auto_launch/config/avp.rviz
```

**rviz2**将为停车演示加载 AutonomouStuff 地图。

### 6.4 运行 Simulator

```bash
# In a desktop shell, launch SVL Simulator
(path\to\downloaded\simulator)/svlsimulator-linux64-2021.3/simulator
```

模拟设置应如下所示：

- Runtime Template: **Random Traffic**
- Maps: **AutonomouStuff**
- Vehicle Asset: **Lexus2016RXHybrid**
- Sensor configuration: **Autoware.Auto**
- Bridge: **ROS2**
- Autopilot: **Autoware.Auto (Apex.AI)**
- Connection: **localhost:9090** (In the case of the Simulator and Autoware.Auto running on the same machine.)

### 6.5 设置姿势估计和目标姿势

- 单击**2D Pose Estimate** 单击初始位置并向下拖动以设置当前车辆的方向。
- 单击**2D Goal Pose** 单击所需的停车位并垂直于车道拖动。

根据停车位的位置，Planner 可能会也可能不会成功找到路线。

![img](https://www.svlsimulator.com/docs/images/autoware-pose-estimate-goal-pose.png)
