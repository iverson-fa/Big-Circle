# Foxy 常用命令

## 0 参考资料

- [ROS2 官方文档](https://docs.ros.org/en/foxy/Tutorials/Colcon-Tutorial.html)

- [ROS2 命令行工具源码](https://github.com/ros2/ros2cli)
- [colcon 官方文档](https://colcon.readthedocs.io/en/released/index.html)
  - user documentation
  - reference
  - developer documentation
  - migrate from other build tools

## 1 基础

### 1.1 节点

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

### 1.2 工作空间和功能包

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

















