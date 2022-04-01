# Foxy 常用命令

## 1 参考资料

- [ROS2 官方文档](https://docs.ros.org/en/foxy/Tutorials/Colcon-Tutorial.html)
- [ROS2 命令行工具源码](https://github.com/ros2/ros2cli)
- [colcon 官方文档](https://colcon.readthedocs.io/en/released/index.html)
  - user documentation
  - reference
  - developer documentation
  - migrate from other build tools
- [API : rclpy](https://docs.ros2.org/foxy/api/rclpy/index.html)

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

测试

```bash
mkdir colcon_test && cd colcon_test
git clone https://github.com/ros2/examples src/examples -b foxy
colcon build
# 打开一个终端
source install/setup.bash
ros2 run examples_rclcpp_minimal_subscriber subscriber_member_function
# 打开另一个终端
source install/setup.bash
ros2 run examples_rclcpp_minimal_publisher publisher_member_function
```

常用指令

```bash
# 只编译一个包
colcon build --packages-select YOUR_PKG_NAME 
# 不编译某个包
colcon build --packages-select YOUR_PKG_NAME  --cmake-args -DBUILD_TESTING=0
# 编译
colcon build
# 允许通过更改 src 的部分文件来改变 install
# 每次调整 python 脚本时都不必重新build
colcon build --symlink-install
```

### 2.3 Python Node

```bash
mkdir -p town_ws/src
cd town_ws/src
ros2 pkg create village_li --build-type ament_python --dependencies rclpy
```



### 2.4 话题与服务

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
# 查看消息类型
ros2 interface show std_msgs/msg/String
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
```









