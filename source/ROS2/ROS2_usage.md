# ROS2 常用命令

## 0 .bash_aliases配置

```shell
alias cb='colcon build --symlink-install
```

## 1 参考资料

- [ROS2 官方文档](https://docs.ros.org/en/foxy/Tutorials/Colcon-Tutorial.html)
- [ROS2 命令行工具源码](https://github.com/ros2/ros2cli)
- [colcon 官方文档](https://colcon.readthedocs.io/en/released/index.html)
  - user documentation
  - reference
  - developer documentation
  - migrate from other build tools
- [API : rclpy](https://docs.ros2.org/foxy/api/rclpy/index.html)
- [Gezebo官方文档](https://gazebosim.org/docs/harmonic/getstarted)

```bash
usage: ros2 [-h] Call `ros2 <command> -h` for more detailed usage. ...

ros2 is an extensible command-line tool for ROS 2.

optional arguments:
  -h, --help            show this help message and exit

Commands:
  action     Various action related sub-commands
  bag        Various rosbag related sub-commands
  component  Various component related sub-commands
  daemon     Various daemon related sub-commands
  doctor     Check ROS setup and other potential issues
  interface  Show information about ROS interfaces
  launch     Run a launch file
  lifecycle  Various lifecycle related sub-commands
  multicast  Various multicast related sub-commands
  node       Various node related sub-commands
  param      Various param related sub-commands
  pkg        Various package related sub-commands
  run        Run a package specific executable
  security   Various security related sub-commands
  service    Various service related sub-commands
  topic      Various topic related sub-commands
  wtf        Use `wtf` as alias to `doctor`

  Call `ros2 <command> -h` for more detailed usage.
```

## 2 基础

### 2.1 节点

编写ROS2节点的一般步骤

1. 导入库文件
2. 初始化客户端库
3. 新建节点
4. spin循环节点
5. 关闭客户端库

启动节点

```bash
ros2 run <package_name> <executable_name>
```

- GUI（Graphical User Interface）图形用户界面
- CLI（Command-Line Interface）命令行界面

查看节点列表(常用)：

```bash
ros2 node list
```

查看节点信息(常用)：

```bash
ros2 node info <node_name>
```

重映射节点名称

```bash
ros2 run turtlesim turtlesim_node --ros-args --remap __node:=my_turtle
```

### 2.2 工作空间和功能包

工作空间是包含若干个功能包的目录，一个工作空间下可以有多个功能包，一个功能包可以有多个节点存在。

ROS2 中功能包根据编译方式的不同分为三种类型。

- ament_python，适用于python程序
- cmake，适用于 C++
- ament_cmake，适用于 C++ 程序,是 cmake 的增强版

**两种获取方式**

第一种是安装获取，安装获取会自动放置到系统目录，不用再次手动source。

```bash
sudo apt install ros-<version>-package_name
```

第二种是手动编译获取，需要下载源码然后进行编译生成相关文件，手动编译之后，需要手动source工作空间的install目录。

与功能包相关的指令为 `ros2 pkg`

```bash
create       Create a new ROS2 package
executables  Output a list of package specific executables
list         Output a list of available packages
prefix       Output the prefix path of a package
xml          Output the XML of the package manifest or a specific tag
```

**1.创建功能包**

```bash
ros2 pkg create <package-name>  --build-type  {cmake,ament_cmake,ament_python}  --dependencies <依赖名字>
# example
ros2 pkg create village_li --build-type ament_python --dependencies rclpy
```

**2.列出可执行文件**

 列出所有

```bash
ros2 pkg executables
```

列出某个功能包的

```bash
ros2 pkg executables turtlesim
```

**3.列出所有的包**

```bash
ros2 pkg list
```

**4.输出某个包所在路径的前缀**

```bash
ros2 pkg prefix  <package-name>
```

比如小乌龟

```bash
ros2 pkg prefix turtlesim
```

**5.列出包的清单描述文件**

每一个功能包都有一个标配的 manifest.xml 文件，用于记录这个包的名字，构建工具，编译信息，拥有者，功能等信息。通过这个信息，就可以自动为该功能包安装依赖，构建时确定编译顺序等。

查看小乌龟模拟器功能包的信息。

```bash
ros2 pkg xml turtlesim
```

### 2.2 ROS2 构建工具 — colcon

colcon 是功能包构建工具，相当于 ROS1 的 catkin。

安装

```bash
sudo apt-get install python3-colcon-common-extensions
```

若显示无法定位软件包，先使用如下 apt 存储库

```bash
sudo sh -c 'echo "deb [arch=amd64,arm64] http://repo.ros2.org/ubuntu/main `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
```

`colcon build` 是用于构建 ROS 2 工作空间的命令，它支持多种参数来控制构建行为。以下是常用的参数及其用途：

---

**1. 通用参数**
`--parallel-workers N`
指定并行构建的线程数（默认为 CPU 核心数）。

```bash
colcon build --parallel-workers 4
```

`--packages-select <package1> <package2> ...`
仅构建指定的包。

```bash
colcon build --packages-select my_package
```

`--packages-skip <package1> <package2> ...`
跳过构建指定的包。

```bash
colcon build --packages-skip my_package
```

`--packages-up-to <package1> <package2> ...`
构建指定包及其所有依赖项。

```bash
colcon build --packages-up-to my_package
```

`--packages-ignore-regex <regex>`
使用正则表达式匹配的包将被忽略。

```bash
colcon build --packages-ignore-regex "test_.*"
```

`--cmake-args <arg1> <arg2> ...`
为 CMake 提供额外的参数。

```bash
colcon build --cmake-args -DCMAKE_BUILD_TYPE=Debug
```

`--merge-install`
将所有包安装到同一安装目录（`install/`），而不是分离的包安装。

```bash
colcon build --merge-install
```

---

**2. 清理相关参数**

`--clean`
在构建之前清理目标目录。

```bash
colcon build --clean
```

`--clean-build`
删除构建目录和安装目录后再进行构建。

```bash
colcon build --clean-build
```

---

**3. 输出相关参数**

`--log-base <path>`
指定日志文件的存储位置（默认是 `log/`）。

```bash
colcon build --log-base /path/to/log
```

`--event-handlers <handlers>`
控制输出日志的格式：
- `console_cohesion+`：更详细的日志。
- `status+`：显示状态信息。
- `log+`：写入日志文件。

```bash
colcon build --event-handlers console_cohesion+ log+
```

---

**4. 环境相关参数**

`--base-paths <path1> <path2> ...`
指定工作空间的路径（默认为当前目录）。

```bash
colcon build --base-paths /path/to/ws
```

`--build-base <path>`
指定构建目录（默认是 `build/`）。

```bash
colcon build --build-base /path/to/build
```

`--install-base <path>`
指定安装目录（默认是 `install/`）。

```bash
colcon build --install-base /path/to/install
```

`--test-result-base <path>`
指定测试结果存储目录（默认是 `build/`）。

```bash
colcon build --test-result-base /path/to/test_results
```

---

**5. 其他选项**
`--continue-on-error`
遇到构建错误时继续构建其他包。

```bash
colcon build --continue-on-error
```

`--build-only`
仅执行构建步骤，不安装。

```bash
colcon build --build-only
```

`--install-only`
仅执行安装步骤，跳过构建。

```bash
colcon build --install-only
```

`--test`
在构建完成后运行测试。

```bash
colcon build --test
```

---

**常用组合示例**

1. **构建单个包（包括依赖）并设置 Debug 模式：**

   ```bash
   colcon build --packages-up-to my_package --cmake-args -DCMAKE_BUILD_TYPE=Debug
   ```

2. **跳过某些包并使用多线程构建：**

   ```bash
   colcon build --packages-skip test_package1 test_package2 --parallel-workers 8
   ```

3. **清理后重新构建并将日志输出到指定目录：**

   ```bash
   colcon build --clean-build --log-base /tmp/colcon_logs
   ```

---

**获取完整参数列表**

使用以下命令查看所有支持的参数：

```bash
colcon build --help
```

### 2.3 Python Node

```bash
mkdir -p town_ws/src
cd town_ws/src
ros2 pkg create village_li --build-type ament_python --dependencies rclpy
```



### 2.4 话题与服务
接口命令
```bash
# 查看指令
ros2 topic -h
# 返回系统中当前活动的所有主题的列表
ros2 topic list
# 增加消息类型
ros2 topic list -t
# 打印实时话题内容
ros2 topic echo /chatter
# 查看话题信息
ros2 topic info  /chatter
# 手动发布命令
ros2 topic pub /chatter std_msgs/msg/String 'data: "123"'

# 查看当前环境下的接口列表
ros2 interface list
# 查看所有接口包
ros2 interface packages
# 查看某一个包下的所有接口
ros2 interface package std_msgs
# 查看某一个接口的详细内容
ros2 interface show std_msgs/msg/String
# 输出某一个接口的所有属性
ros2 interface proto sensor_msgs/msg/Image

# 查看服务列表
ros2 service list
# 手动调用服务
ros2 service call /add_two_ints example_interfaces/srv/AddTwoInts "{a: 5,b: 10}"
# 查看服务接口类型
ros2 service type /add_two_ints
# 查找使用某一接口的服务
ros2 service find example_interfaces/srv/AddTwoInts
```

创建服务接口的步骤：

- 新建`srv`文件夹，并在文件夹下新建`xxx.srv`
- 在`xxx.srv`下编写服务接口内容并保存
- 在`CmakeLists.txt`添加依赖和srv文件目录
- 在`package.xml`中添加`xxx.srv`所需的依赖
- 编译功能包即可生成`python`与`c++`头文件

除此之外，还要确定好请求的数据结构和返回的数据结构。

ROS2 创建服务端的基本步骤：
- 导入服务接口
- 创建客户端回调函数
- 声明并创建服务端
- 编写回调函数逻辑处理请求

ROS2 创建客户端的基本步骤：
- 导入服务接口
- 创建请求结果接收回调函数
- 声明并创建客户端
- 编写结果接收逻辑
- 调用客户端发送请求

### 2.5 参数

**A parameter is a configuration value of a node. You can think of parameters as node settings.**

ROS2支持的参数值的类型如下：

- bool 和bool[]，布尔类型用来表示开关，比如我们可以控制雷达控制节点，开始扫描和停止扫描。
- int64 和int64[]，整形表示一个数字，含义可以自己来定义，这里我们可以用来表示李四节点写小说的周期值
- float64 和float64[]，浮点型，可以表示小数类型的参数值
- string 和string[]，字符串，可以用来表示雷达控制节点中真实雷达的ip地址
- byte[]，字节数组，这个可以用来表示图片，点云数据等信息

```bash
# 查看节点的参数
ros2 param list
# 查看参数详细信息
ros2 param describe <node_name> <param_name>
# 查看参数值
ros2 param get /turtlesim background_b
# 设置参数值
ros2 param set <node_name> <parameter_name> <value>
# 保存当前参数
ros2 param dump <node_name>
# 举例
ros2 param dump /turtlesim
cat ./turtlesim.yaml
# 恢复参数
ros2 run turtlesim turtlesim_node
ros2 param load  /turtlesim ./turtlesim.yaml
# 启动时加载参数
ros2 run <package_name> <executable_name> --ros-args --params-file <file_name>
# 举例
ros2 run turtlesim turtlesim_node --ros-args --params-file ./turtlesim.yaml
```

### 2.6 Action

**原因**

通过服务服务发送一个目标点给机器人，让机器人移动到该点：

- 你不知道机器人有没有处理移动到目标点的请求（不能确认服务端接收并处理目标）
- 假设机器人收到了请求，你不知道机器人此时的位置和距离目标点的距离（没有反馈）
- 假设机器人移动一半，你想让机器人停下来，也没有办法通知机器人

上面的场景在机器人控制当中经常出现，比如控制导航程序，控制机械臂运动，控制小乌龟旋转等，很显然单个话题和服务不能满足我们的使用，因此ROS2针对控制这一场景，基于原有的话题和服务，设计了动作（Action）这一通信方式来解决这一问题。

Action的三大组成部分目标、反馈和结果。

- 目标：即Action客户端告诉服务端要做什么，服务端针对该目标要有响应。解决了不能确认服务端接收并处理目标问题
- 反馈：即Action服务端告诉客户端此时做的进度如何（类似与工作汇报）。解决执行过程中没有反馈问题
- 结果：即Action服务端最终告诉客户端其执行结果，结果最后返回，用于表示任务最终执行情况。

> 参数是由服务构建出来了，而Action是由话题和服务共同构建出来的（一个Action = 三个服务+两个话题） 三个服务分别是：1.目标传递服务    2.结果传递服务    3.取消执行服务 两个话题：1.反馈话题（服务发布，客户端订阅）   2.状态话题（服务端发布，客户端订阅）

![](img/Action-SingleActionClient.gif)

```bash
# 列表
ros2 action list
# 查看类型
ros2 action list -t
# 查看接口的详细信息
ros2 interface show turtlesim/action/RotateAbsolute
# 查看 action 信息
ros2 action info /turtle1/rotate_absolute
# 发送请求
ros2 action send_goal /turtle1/rotate_absolute turtlesim/action/RotateAbsolute "{theta: 1.5}" --feedback
```

### 2.7 通信机制总结

**话题**

话题是单向的，而且不需要等待服务端上线，直接发就行，数据的实时性比较高。

频率高，实时性强的传感器数据的传递一般使用话题实现。

**服务**

服务是双向的，客户端发送请求后，服务端有响应，可以得知服务端的处理结果。

频率较低，强调服务特性和反馈的场景一般使用服务实现。

**参数**

参数是节点的设置，用于配置节点，原理基于服务。

**动作**

动作适用于需要实时反馈的场景，原理基于话题和服务。

## 3 ROS2 常用工具

### 3.1 launch 文件

### 3.2 rosbag2

```bash
# 记录一个话题
ros2 bag record /topic_name
# 记录多个话题
ros2 bag record topic-name1  topic-name2
# 记录所有话题
ros2 bag record -a
# 自定义输出文件名字
ros2 bag record -o file-name topic-name
# -s 目前仅支持sqllite3
# 查看 bag 包信息
ros2 bag info bag-file
# 播放
ros2 bag play xxx.db3
# 倍速播放
ros2 bag play xxx.db3 -r 10
# 循环播放
ros2 bag play xxx.db3  -l
# 播放制定话题
ros2 bag play rxxx.db3 --topics /topic-name
```

### 3.3 RQT

### 3.4 RVIZ2

- 数据：各种调试机器人时常用的数据，比如：图像数据、三维点云数据、地图数据、TF数据，机器人模型数据等等
- 可视化：可视化就是直观的看到数据，比如说一个三维的点(100,100,100)，通过RVIZ可以将其显示在空间中
- 如何做到不同数据的可视化：强大的插件，如果没有数据，可以自己写一个插件，即插即用，方便快捷

**全局配置**

- Fixed Frame：所有帧参考的帧的名称，坐标都是相对的，这个就是告诉RVIZ你是相对谁的，一般是设置成map或者odom
- Frame Rate：用于设置更新 3D 视图的最大频率。

**网格**

- Reference frame：帧用作网格坐标参考（通常：）
- Plane cell count: 单元格中网格的大小
- Normal cell count：在沿垂直于叶栅平面的网格数（正常：0）
- Cell size：每个网格单元的尺寸（以米为单位）
- Plane：标识网格平面的两个轴

**机器人模型**

- Visual enabled: 启用/禁用模型的 3D 可视化
- Description Source：机器人模型文件的来源，可以在File和Topic之间进行选择
- Description Topic: 机器人模型文件所在的话题

- Visual enabled: 启用/禁用模型的 3D 可视化
- Description Source：机器人模型文件的来源，可以在File和Topic之间进行选择
- Description Topic: 机器人模型文件所在的话题

**TF**

- Marker Scale: 将字和坐标系标识调整的小一些，使其更加可见且不那么混乱
- Update interval：以秒为单位的TF广播更新时间

### 3.5 Gazebo

**Gazebo 是一个独立的应用程序，可以独立于 ROS 或 ROS 2 使用。**

Gazebo与ROS 版本的集成是通过一组叫做`gazebo_ros_pkgs`的包 完成的，`gazebo_ros_pkgs`将Gazebo和ROS2连接起来。

gazebo_ros_pkgs不是一个包，是一堆包如下：

- gazebo_dev：开发Gazebo插件可以用的API
- gazebo_msgs：定义的ROS2和Gazebo之间的接口（Topic/Service/Action）
- gazebo_ros：提供方便的 C++ 类和函数，可供其他插件使用，例如转换和测试实用程序。它还提供了一些通常有用的插件。gazebo_ros::Node
- gazebo_plugins：一系列 Gazebo 插件，将传感器和其他功能暴露给 ROS2  例如:
  1. `gazebo_ros_camera` 发布ROS2图像
  2. `gazebo_ros_diff_drive` 通过ROS2控制和获取两轮驱动机器人的接口

```shell
# 运行差速小车 demo
sudo apt install gazebo11
sudo apt install ros-foxy-gazebo-*
gazebo /opt/ros/foxy/share/gazebo_plugins/worlds/gazebo_ros_diff_drive_demo.world
ros2 topic pub /demo/cmd_demo geometry_msgs/msg/Twist "{linear: {x: 0.2,y: 0,z: 0},angular: {x: 0,y: 0,z: 0}}"
```
