# Geek-car 分析

- [geek-car 源码](https://github.com/for-geeks/geek-car)

## 1 代码架构

![source architecture](./img/source_architecture.png)

```shell
.
├── cyber # Cyber通讯框架主目录，包含通讯，服务发现，协程调度，Python封装工具链
│   ├── base
│   ├── blocker
│   ├── class_loader
│   ├── common
│   ├── component
│   ├── conf
│   ├── croutine
│   ├── data
│   ├── doxy-docs
│   ├── event
│   ├── examples
│   ├── io
│   ├── logger
│   ├── mainboard
│   ├── message
│   ├── node
│   ├── parameter
│   ├── proto
│   ├── python
│   ├── py_wrapper
│   ├── record
│   ├── scheduler
│   ├── service
│   ├── service_discovery
│   ├── sysmo
│   ├── task
│   ├── time
│   ├── timer
│   ├── tools
│   └── transport
├── docker # 运行环境虚拟化的所有原料，包含Dockerfile 拉取镜像 创建容器与交互
│   ├── build
│   ├── scripts
│   └── setup_host
├── images
├── modules
│   ├── common		 # 共有模块，配置、数据结构信息
│   ├── control		 # 车辆底盘驱动、控制下发信息等
│   ├── data 		 # 测试数据
│   ├── examples 	 # 部分样例代码
│   ├── exercises	 # 练习代码
│   ├── localization # 定位实现，包含基于Apriltag UWB等
│   ├── monitor		 # 车端状态监控
│   ├── perception	 # 点云感知
│   ├── planning   	 # 规划
│   ├── sensors		 # 传感器驱动，包含Realsense uwb设备的原始数据播发
│   └── tools		 # 图形化调试工具链
├── scripts
├── third_party
│   └── tf2
└── tools
    └── platforms
```

## 2 基础服务与驱动层接口

### 2.1 获取图像、压缩图像

#### 2.1.1 RealSense驱动基本功能简述

Geekcar系统使用 Intel RealSense 系列，型号为D435的摄像头作为主传感器。RealSense为Geekcar系统提供了基本的图像数据。本节向开发者介绍了用户应用层使用的图像数据是如何从设备驱动流转到系统中的。

#### **2.1.2 服务启停方法**

简单来说，使用bash脚本控制这些服务的启动或者停止。脚本的控制方式为我们提供了便捷且平滑的衔接，一方面开发者可以在开发的过程中随时控制，方便调试；另一方面也供上位机在启动或关闭实验的过程中，使用按钮事件响应来调用。

比如可以使用以下命令来启动或停止RealSense原始图像的发送服务：

```bash
bash /apollo/scripts/realsense.sh {start | stop}
```

同时，为了提高传输效率，也提供了压缩图的传输服务，你可以通过以下脚本启动或者停止该服务：

```bash
bash /apollo/scripts/realsense_exercise1.sh {start | stop}
```

如果想深究一下，你可以发现这些脚本中核心调用的还是以 **cyber_launch** 命令的控制逻辑，所以进阶地，你可以使用一下方式控制服务的启停：

```bash
cyber_launch {start| stop} /apollo/modules/sensors/launch/realsense_exercise1.launch
```

作为延展内容，如果想了解更多cyber_launch的内容，可以查看代码[https://github.com/ApolloAuto/apollo/tree/master/cyber/tools/cyber_launch](https://github.com/ApolloAuto/apollo/tree/master/cyber/tools/cyber_launch?accessToken=eyJhbGciOiJIUzI1NiIsImtpZCI6ImRlZmF1bHQiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE2NzUxMzg3MDUsImZpbGVHVUlEIjoiNkRreFF5eHZieWlsRjlBdiIsImlhdCI6MTY3NTEzODQwNSwiaXNzIjoidXBsb2FkZXJfYWNjZXNzX3Jlc291cmNlIiwidXNlcklkIjozNTYzNTUxOH0.Op8iz083rov4uR1xiRgPdw8r1m4xmkePs1cT51K9vA0) 了解该命令是如何工作的。

#### **2.1.3 原始、压缩图像数据结构**

a.通讯通道

数据通道(Channel)，是整个系统中数据流通的名称，比如原始图像的数据通道为

```bash
/realsense/color_image
```

而压缩图的通道名称为

```bash
/realsense/color_image/compressed
```

b.数据结构

以上不同通道对应的传输图像数据对应了不同类型的数据结构：

- 原始图像：**apollo.sensors.Image**

- 压缩图像：**apollo.sensors.CompressedImage**

这是基于[Protobuf](https://github.com/protocolbuffers/protobuf?accessToken=eyJhbGciOiJIUzI1NiIsImtpZCI6ImRlZmF1bHQiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE2NzUxMzg3MDUsImZpbGVHVUlEIjoiNkRreFF5eHZieWlsRjlBdiIsImlhdCI6MTY3NTEzODQwNSwiaXNzIjoidXBsb2FkZXJfYWNjZXNzX3Jlc291cmNlIiwidXNlcklkIjozNTYzNTUxOH0.Op8iz083rov4uR1xiRgPdw8r1m4xmkePs1cT51K9vA0)的数据结构描述方式，轻便高效的结构化数据存储格式，可以用于结构化数据串行化，或者说序列化。它很适合做数据存储或 RPC 数据交换格式。可用于通讯协议、数据存储等领域的语言无关、平台无关、可扩展的序列化结构数据格式。

图像数据结构文件相对地址为 `modules/sensors/proto/sensor_image.proto`，以下是对该数据结构的描述。

图像数据结构字段描述

| 字段名称         | 字段类型             | 是否有默认值 | 解释                                |
| ---------------- | -------------------- | ------------ | ----------------------------------- |
| header           | apollo.common.Header | 无           | 统一报头信息                        |
| frame_no         | uint64               | 无           | 图片帧数                            |
| measurement_time | double               | 无           | 成图时间                            |
| height           | uint32               | 无           | 图像高度，即矩阵的行数              |
| width            | uint32               | 无           | 图像宽度，即矩阵的列数              |
| encoding         | string               | 无           | 编码格式                            |
| step             | uint32               | 无           | Full row length in bytes            |
| data             | bytes                | 无           | 实际图像矩阵数据，大小等于step*rows |

压缩图像数据结构

| 字段名称         | 字段类型             | 示例 | 解释                                |
| ---------------- | -------------------- | ---- | ----------------------------------- |
| header           | apollo.common.Header | 无   | 统一报头信息                        |
| frame_no         | uint64               | 无   | 图片帧数                            |
| measurement_time | double               | 无   | 成图时间                            |
| format           | string               | 无   | 编码格式                            |
| data             | bytes                | 无   | 实际图像矩阵数据，大小等于step*rows |

#### **2.1.4 图像获取Python程序Demo**

a.数据类型import

在Python版本中，已经编译好了Python版本的图像数据结构对象，直接加载即可：

```python
from modules.sensors.proto.sensor_image_pb2 import Image
```

b.启动节点初始化

当需要数据流转通讯，形成通道的情形下，Cyber的需要初始化节点以在通道内监听或者发布数据。

```python
cyber.init()
exercise_node = cyber.Node("exercise1_node_name")
```

c.回调函数获取图像

以下示例打印头像的帧。

```python
def callback(self, data):
	print('Frame number is :%s' % data.frame_no)
	self.msg = data
	self.writer.write(self.msg)
```

d.运行python脚本及其环境变量配置

完整代码示例参考样例`modules/exercises/exercise1-Basic/example/exercise1.1.example.py`。

#### **2.1.5 压缩图像获取C++程序Demo**

a.代码编写

​	i.节点初始化

```c++
int main() {
  apollo::cyber::Init("image_save");
  auto node = apollo::cyber::CreateNode("image_save");
  auto reader = node->CreateReader<apollo::sensors::CompressedImage>(
      FLAGS_compressed_color_image_channel, ImageCallback);
  apollo::cyber::WaitForShutdown();
  return 0;
}
```

​	ii.回调函数

```c++
void ImageCallback(
    const std::shared_ptr<apollo::sensors::CompressedImage>& image) {
  // ADEBUG << "image, height :" << image->height() << " width:" <<
  // image->width();

  std::vector<uchar> buff(
      (unsigned char*)image->data().c_str(),
      (unsigned char*)image->data().c_str() + image->data().length());

  cv::Mat new_image = cv::imdecode(buff, CV_8UC2);
  // cv::Mat new_image = cv::Mat(static_cast<int>(image->height()),
  //                            static_cast<int>(image->width()), CV_8UC3,
  //                            const_cast<char*>(image->data().c_str()));
  std::string image_name =
      FLAGS_image_export_dir + std::to_string(image->frame_no()) + ".jpg";
  cv::imwrite(image_name, new_image);
  ADEBUG << "Saved image :" << image_name;
}
```

b.编译与运行

完整代码参考`modules/sensors/tools/image_save.cc`。

### 2.2 控制车辆电机、转向

#### 2.2.1 底盘控制逻辑简述，以及该基础服务的启停方法

底盘控制逻辑主要负责对底盘中纵向动力电机、横向转向的控制。与第一部分提到的服务启停使用脚本控制类似，该服务的启停方式为：

```bash
bash /apollo/scripts/control.sh {start | stop}
```

#### 2.2.2 control数据结构定义

**a.通讯通道** 

数据通道为**/control**，该通道数据类型为：**apollo.control.Control**，具体的字段对应如下表。

**b.数据结构**

apollo.control.Control数据字段

| 字段名称    | 字段类型 | 示例 | 解释           |
| ----------- | -------- | ---- | -------------- |
| steer_angle | float    | 无   | 下发车轮转角值 |
| throttle    | float    | 无   | 下发点击转速   |

```c++
message Control_Command {
  optional float steer_angle = 1;
  optional float throttle = 2;
}

message Control_Reference {
  optional float angular_speed = 1;
  optional float vehicle_speed = 2;
}

message Coefficient {
  optional double a = 1;
  optional double b = 2;
  optional double c = 3;
}
```

#### 2.2.3 发布相关信息的python程序demo

根据上述数据结构，接下来我们需要编写代码以输出Control_Command类型数据，下发到通道/control。

**a.数据类型import**

```python
from cyber_py import cyber
from cyber_py import cyber_time
from modules.control.proto.control_pb2 import Control_Command
```

**b.代码编写**

```python
def hotkey_w(self):
        throttle = self.msg.throttle + THROTTLE_STEP
        self.msg.throttle = THROTTLE_MAX if throttle >= THROTTLE_MAX else throttle
    def hotkey_s(self):
       throttle = self.msg.throttle - THROTTLE_STEP
        self.msg.throttle = THROTTLE_MIN if throttle <= THROTTLE_MIN else throttle
    def hotkey_a(self):
        steer_angle = self.msg.steer_angle + STEER_ANGLE_STEP
        self.msg.steer_angle = STEER_ANGLE_MAX if steer_angle >= STEER_ANGLE_MAX else steer_angle
    def hotkey_d(self):
        steer_angle = self.msg.steer_angle - STEER_ANGLE_STEP
        self.msg.steer_angle = STEER_ANGLE_MIN if steer_angle <= STEER_ANGLE_MIN else steer_angle
    def loop(self):
        try:
            while not cyber.is_shutdown():
                try :
                    c = sys.stdin.read(1)
                    if c:
                        \# print("Got character", repr(c))
                        if c == 'w': self.hotkey_w()
                        if c == 's': self.hotkey_s()
                        if c == 'a': self.hotkey_a()
                        if c == 'd': self.hotkey_d()
                        print(self.msg)
                        self.writer.write(self.msg)
                        \# ratio domain 100hz
                        time.sleep(0.01)
                except IOError: pass
        finally:
            termios.tcsetattr(fd, termios.TCSAFLUSH, oldterm)
           fcntl.fcntl(fd, fcntl.F_SETFL, oldflags)
```

以上代码绑定了键盘的WDSA等按键触发事件，以达到当按W时，对点击转速递增，S时递减；A时转向递增，D转向递减的目的，同时下发更新后的控制指令。

**c.运行python脚本及其环境变量配置**

完整版代码查看`modules/exercises/exercise1-Basic/example/exercise1.2.example.py`。

#### 2.2.4 c++程序demo

**a.代码编写**

```c++
  auto cmd = std::make_shared<Control_Command>();
  double t = 0.0;
  Rate rate(20.0);
  float error_sum = 0;
  float error_yawrate_sum = 0;
  while (true) {
    /*PID core*/
    float speed_ref = refs_.vehicle_speed();
    float angular_speed_ref = refs_.angular_speed();
    float speed_now = chassis_.speed();
    float error = speed_ref - speed_now;
    error_sum += static_cast<float>(error * 0.05);
    cmd->set_throttle(static_cast<float>(speed_ref);
    float error_yawrate =
        angular_speed_ref - static_cast<float>(pose_.angular_velocity().y());
    error_yawrate_sum += static_cast<float>(error_yawrate * 0.05);
    cmd->set_steer_angle(static_cast<float>(0));
    control_writer_->Write(cmd);
    t += 0.05;
    rate.Sleep();
  }
```

**b.编译与运行**

完整代码见`modules/control/control_component.cc`。

### 2.3 获取车身反馈信息

#### 2.3.1 车身数据获取逻辑简述，以及该基础服务的启停方法

为达到对车辆的精确控制，我们不仅要对车辆下发控制指令，还要监控这些指令的执行情况如何，所以底盘反馈逻辑主要负责对底盘中电机转速、车轮转角等其他数据进行解析并通过数据通道发布出来。与第一部分提到的服务启停使用脚本控制类似，该服务的启停方式为：

```bash
bash /apollo/scripts/chassis.sh {start | stop}
```

#### 2.3.2 chassis数据结构定义

**a.通讯通道** 

数据通道为**/chassis**，该通道数据类型为：**apollo.control.Chassis**，具体的字段对应如下表：

**b.数据结构**

apollo.control.Chassis数据字段

| 字段名称      | 字段类型     | 默认值 | 解释                  |
| ------------- | ------------ | ------ | --------------------- |
| steer_angle   | float        | 无     | 车轮转角反馈值        |
| throttle      | float        | 无     | 电机转速反馈值        |
| speed         | float        | 无     | 车辆速度反馈值        |
| v_bat         | float        | 无     | 整车电池电压          |
| nano_current  | float        | 无     | Jetson Nano 电压      |
| motor_current | float        | 无     | 动力电机电压          |
| range_measure | RangeMeasure | 无     | UWB测距，暂未开放     |
| device_num    | uint64       | 无     | UWB在线设备，暂未开放 |

```c
message Chassis {
  optional float steer_angle = 1;
  optional float throttle = 2;
  optional float speed = 3;
  optional float v_bat = 4;
  optional float nano_current = 5;
  optional float motor_current = 6;
  repeated RangeMeasure range_measure = 7;
  optional uint64 device_num = 8;
}
```

#### 2.3.3 订阅相关信息的python程序demo

1. 数据类型import
2. 代码编写
3. 运行python脚本及其环境变量配置

#### 2.3.4 c++程序demo

1. 代码编写
2. 编译与运行

### 2.4 获取点云或障碍物聚类结果

#### 2.4.1 RealSense点云处理发布逻辑简述，以及该基础服务的启停方法

底盘控制逻辑主要负责对底盘中纵向动力电机、横向转向的控制。

与第一部分提到的服务启停使用脚本控制类似，该服务的启停方式为：

```bash
bash /apollo/scripts/control.sh {start | stop}
```

#### 2.4.2 点云发布数据结构、简单聚类数据结构

**a.通讯通道**

数据通道为**/realsense/point_cloud**，该通道数据类型为：**apollo.sensors.PointCloud**，具体的字段对应如下表：

**b.数据结构**

apollo.sensors.PointXYZIT数据字段

| 字段名称  | 字段类型 | 默认值 | 解释       |
| --------- | -------- | ------ | ---------- |
| x         | float    | nan    | 点云x坐标  |
| y         | float    | nan    | 点云y坐标  |
| z         | float    | nan    | 点云z坐标  |
| intensity | float    | 0      | 反射强度   |
| timestamp | float    | 0      | 点云时间轴 |

apollo.sensors.PointCloud数据字段

| 字段名称         | 字段类型   | 默认值 | 解释         |
| ---------------- | ---------- | ------ | ------------ |
| header           | Header     | 无     | 公共header   |
| is_dense         | bool       | 无     | 稀疏         |
| point            | PointXYZIT | 无     | 点云         |
| measurement_time | double     | 无     | 测量时间     |
| width            | uint32     | 无     | 点云范围宽度 |
| height           | uint32     | 无     | 点云范围高度 |

```c
message PointXYZIT {
  optional float x = 1 [default = nan];
  optional float y = 2 [default = nan];
  optional float z = 3 [default = nan];
  optional uint32 intensity = 4 [default = 0];
  optional uint64 timestamp = 5 [default = 0];
}

message PointCloud {
  optional apollo.common.Header header = 1;
  optional bool is_dense = 3;
  repeated PointXYZIT point = 4;
  optional double measurement_time = 5;
  optional uint32 width = 6;
  optional uint32 height = 7;
}
```

#### 2.4.3 点云获取c++程序demo

1. 代码编写
2. 编译与运行

### 2.5 获取UWB测距、定位、IMU相关信息

#### 2.5.1 UWB数据获取转发逻辑简述，以及该基础服务的启停方法

geekcar使用UWB定位获取车身（tag）到基站（anchor）的距离、角速度、信息来判断给出相对的坐标信息。

与第一部分提到的服务启停使用脚本控制类似，该服务的启停方式为：

```bash
bash /apollo/scripts/nooploop.sh {start | stop}
```

#### 2.5.2 gyro, 基站测距数据结构定义

**a.通讯通道**

该部分设计的基础数据结构较多，如3D点、四元数、加速度、陀螺仪等数据结构，以下逐一展开介绍。

Point 类型数据结构

| 字段名称 | 字段类型 | 默认值 | 解释          |
| -------- | -------- | ------ | ------------- |
| x        | double   | 无     | x轴方向测量值 |
| y        | double   | 无     | y轴方向测量值 |
| z        | double   | 无     | z轴方向测量值 |

Quaternion类型数据结构

| 字段名称 | 字段类型 | 默认值 | 解释          |
| -------- | -------- | ------ | ------------- |
| x        | double   | 无     | x轴方向测量值 |
| y        | double   | 无     | y轴方向测量值 |
| z        | double   | 无     | z轴方向测量值 |
| w        | double   | 无     | w轴方向测量值 |

Acc类型数据结构

| 字段名称 | 字段类型 | 默认值 | 解释               |
| -------- | -------- | ------ | ------------------ |
| acc      | Point    | 无     | 轴方向加速度测量值 |

Gyro陀螺仪类型数据结构

| 字段名称 | 字段类型 | 默认值 | 解释               |
| -------- | -------- | ------ | ------------------ |
| gyro     | Point    | 无     | 轴方向加速度测量值 |

Pose姿态数据结构

| 字段名称             | 字段类型   | 默认值 | 解释                 |
| -------------------- | ---------- | ------ | -------------------- |
| frame_no             | uint64     | 无     | 帧数                 |
| translation          | Point      | 无     | 三轴坐标信息         |
| velocity             | Point      | 无     | 三轴速度             |
| rotation             | Quaternion | 无     | 旋转角               |
| angular_velocity     | Point      | 无     | 角速度               |
| angular_acceleration | Point      | 无     | 角加速度             |
| tracker_confidence   | uint32     | 无     | 跟踪置信度，暂未开放 |
| mapper_confidence    | uint32     | 无     | 绘图置信度，暂未开放 |

数据通道为/geek/acc，该通道数据类型为：**apollo.sensors.Pose**，具体的字段对应如下表：

**b.数据结构**

Pose姿态数据结构

| 字段名称            | 字段类型                 | 示例 | 解释                   |
| ------------------- | ------------------------ | ---- | ---------------------- |
| tag_id              | uint32                   | 无   | 用以标识车辆的tagID    |
| network_system_time | uint32                   | 无   | 系统网络时间           |
| pos                 | apollo.common.Point3D    | 无   | 车辆在基站坐标下的位置 |
| eop                 | apollo.common.Point3D    | 无   | 可能的误差范围         |
| vel                 | apollo.common.Point3D    | 无   | 速度                   |
| angle               | apollo.common.Point3D    | 无   | 角速度                 |
| rotation            | apollo.common.Quaternion | 无   | 旋转角                 |
| supply_voltage      | float                    | 无   | 设备电压               |
| dis                 | DistanceAnchor2Tag       | 无   | 与各基站的距离信息     |

更多Noolloop LTS产品协议细节，可以在此处找到：[www.nooploop.com/download/products/uwb/doc/LinkTrack_User_Manual_V1.1.pdf](http://www.nooploop.com/download/products/uwb/doc/LinkTrack_User_Manual_V1.1.pdf?accessToken=eyJhbGciOiJIUzI1NiIsImtpZCI6ImRlZmF1bHQiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE2NzUxMzg3MDUsImZpbGVHVUlEIjoiNkRreFF5eHZieWlsRjlBdiIsImlhdCI6MTY3NTEzODQwNSwiaXNzIjoidXBsb2FkZXJfYWNjZXNzX3Jlc291cmNlIiwidXNlcklkIjozNTYzNTUxOH0.Op8iz083rov4uR1xiRgPdw8r1m4xmkePs1cT51K9vA0)

#### 2.5.3 订阅相关信息的python程序demo

1. 数据类型import

2. 代码编写

3. 运行python脚本及其环境变量配置

4. #### 2.5.4 c++程序demo

1. 代码编写
2. 编译与运行

### 2.6 多车通讯

2.6.1 多车相互通讯功能简述，及其基础服务启停方法

ＵWB设备除基站定位功能外，具备多点广播通信，点对点测距功能。 

与第一部分提到的服务启停使用脚本控制类似，该服务的启停方式为：

```bash
bash /apollo/scripts/nooploop_dp.sh {start | stop}
```

2.6.2 chat/node数据结构定义

chat数据用于uwb在多车之间广播消息,　发送消息时需要发布该消息，底层驱动接收到该消息就会将其广播。

node消息用于接收多车之间的相互测距信息，数据广播信息。

**a.数据通道**

chat数据通道为/geek/chat，该通道数据类型为：**apollo.localization.chat**，具体的字段对应如下表：

node数据通道为/geek/node, 该通道数据类型为：**apoolo.localization.node**, 具体字段对应如下

**b.数据结构**

```c
message sigle_node{
  optional uint8 role= 1;
  optional uint8 id= 0x00;
  optional float distance = 0;
  optional uint16 data_len = 0x00;
  repeated uint8 data;
}

message node{
  repeated single_node nodes;
}

message chat{
  optional uint8 remote_role= 1;
  optional uint8 remote_id= 0x00;
  optional uint16 send_data_len = 0x00;
  repeated uint8 send_data;
}
```

2.6.3 接收node信息、发布chat信息的python程序demo

1. 数据类型import
2. 代码编写

2.6.4 运行python脚本及其环境变量配置

1. c++程序demo
2. 代码编写
3. 编译与运行

## 3 用户应用层（实验代码）接口

### 3.1 简易车道识别

#### 3.1.1 输入输出与处理逻辑简述

​        简易车道识别是通过提取图像中符合车道线特征的像素点，以此为车道中心线并输出给其他模块的过程。在当前给出的示例里，是通过识别小车前置摄像头所获取的图像，经过鸟瞰图变换和截取，在ROI目标区域中，识别亮橘色的线为车道线，并采用滑动窗口方法识别连续车道线位置。

处理过程待补图： 鸟瞰转换 -> 色彩模式转换 -> 蒙版提取 -> 滑动窗口 -> 坐标系变换

#### 3.1.2 输入接口（数据结构）与输出接口（数据结构）

​        简易车道识别示例是使用python进行编写的，输入使用基础服务中的压缩图像通道，输出则是复用坐标位置数据结构的新建通道。涉及以下两个数据通道：

| 输入\输出 | 通道名                                                      | 数据格式                                       |
| --------- | ----------------------------------------------------------- | ---------------------------------------------- |
| 输入      | 订阅通道：压缩图像通道**/realsense/color_image/compressed** | modules.sensors.proto.sensor_image_pb2.Image   |
| 输出      | 写入通道：中心线点通道**/perception/road_mean_point**       | modules.planning.proto.planning_pb2.Trajectory |

​        需注意的是，由于图像处理速度常常落后于获取速度，需要确保每次获取图像数据时为最新图像，不要设置缓冲帧或者缓存输入图像，否则会有处理信息滞后的问题。保持拿到最新图像并在同一个线程内处理即可。

输出的数据结构 Trajectory：

```python
# 输出是一个点的集合
self.planning_path = Trajectory()
# 从一个数组循环构建Point元素并填充到Trajectory中, 包含x和y坐标
for i, point in enumerate(mean_y_real):
    point_xy = Point()
    point_xy.x = mean_x_real[i]
    point_xy.y = point
    self.planning_path.point.append(point_xy)
```

 Point对象结构

```c
message Point {
  // meters
  optional double x = 1;
  optional double y = 2;
}
```

#### 3.1.3 运行demo脚本

```bash
cd /apollo/modules/exercises/exercise4_perception/example/
python3 perception_todo_3.py
```

#### 3.1.4 订阅输出python脚本demo

- 数据类型import

在Python版本中，需要引用与通道输出相关的数据结构对象，直接加载即可：

```python
from modules.planning.proto.planning_pb2 import Trajector
from modules.planning.proto.planning_pb2 import Point
```

- 启动节点初始化

当需要数据流转通讯，形成通道的情形下，Cyber的需要初始化节点以在通道内监听或者发布数据。

```python
cyber.init()
exercise_node = cyber.Node("your_node_name")
exercise_node.create_reader("/perception/road_mean_point", Trajector, callback)
```

- 回调函数获取图像

以下示例打印包含的点。

```python
def callback(self, data):
    point_list = data.point
    for i, p in enumerate(point_list):
        print(p.x, p.y)
```

- 运行python脚本及其环境变量配置

### 3.2 简易定位

1. 处理逻辑简述
2. 输入接口（数据结构）与输出接口（数据结构）
3. 运行demo脚本
4. 订阅输出python脚本demo

### 3.3 简易全局规划

#### 3.3.1 输入输出与处理逻辑简述

简易全局规划是指通过在已知的全局地图坐标系中指定目标点，规划模块结合从定位模块获取的当前位置信息，通过全局规划算法处理，输出全局规划路径信息的过程。在本实验示例代码中，我们采用了a-star规划算法。

其中全局地图信息，是由沙盘的俯视照片通过简单的图像处理得出的，其中灰度255（白）的地方为不可行驶区域，灰度为0（黑）的地方为可行驶区域。示例代码中将图像信息中的像素坐标直接对应为地图的全局坐标，并对地图进行网格化，从而完成A-Star全局规划。

#### 3.3.2 输入接口（数据结构）与输出接口（数据结构）

| 输入\输出 | 通道名                                                | 数据格式                                        |
| --------- | ----------------------------------------------------- | ----------------------------------------------- |
| 输入      | 订阅通道：当前位置通道**/geek/uwb/localization**      | modules.localization.proto.localization_pb2.pos |
|           | 订阅通道：目标点通道**/planning/mission_point**       | modules.localization.proto.localization_pb2.pos |
| 输出      | 写入通道：全局轨迹通道**/planning/global_trajectory** | modules.planning.proto.planning_pb2.Trajectory  |

- 输出的数据结构 Trajectory：

```python
self.planning_path = Trajectory()
if not pathList:
    print("Failed to find a path")
else:
    for path_point in pathList:
        point_xy.x = path_point[0]
	    point_xy.y = path_point[1]
        self.planning_path.point.append(point_xy)	
if not cyber.is_shutdown() and self.planning_path:
    self.writer.write(self.planning_path)
```

- Point对象结构

```c
message Point {
  // meters
  optional double x = 1;
  optional double y = 2;
}
```

#### 3.3.3 运行demo脚本

```bash
cd /apollo/modules/exercises/exercise6-planning/example/
python3 localization_example6.py  #运行定位模块脚本 
python3 planning_a_star_exercise6_todo.py
```

#### 3.3.4 订阅输出python脚本demo

- 数据类型import

在Python版本中，需要引用与通道输出相关的数据结构对象，直接加载即可：

```python
from modules.planning.proto.planning_pb2 import Trajectory 
from modules.planning.proto.planning_pb2 import Point 
```

- 启动节点初始化

当需要数据流转通讯，形成通道的情形下，Cyber的需要初始化节点以在通道内监听或者发布数据。

```python
cyber.init()
cyber_node = cyber.Node("planning")
self.node.create_reader("/geek/uwb/localization", pos, self.localizationcallback)
self.node.create_reader("/planning/mission_point", Point, self.missioncallback)
```

- 回调函数获取当前位置

```python
def localizationcallback(self, pos):
    self.start_x = int(pos.x*scale)
	self.start_y = int(pos.y*scale)
```

- 回调函数获取目标点

```python
def missioncallback(self, Point):
    self.goal_x = int(Point.x)
    self.goal_y = int(Point.y)
    
    pathList = self.start(self.start_x, self.start_y, self.goal_x, self.goal_y)
    self.planning_path = Trajectory()

	if not pathList:
	    print("Failed to find a path")
	else:
	    for path_point in pathList:
	        point_xy.x = path_point[0]
	        point_xy.y = path_point[1]
	
            self.planning_path.point.append(point_xy)

    if not cyber.is_shutdown() and self.planning_path:
        self.writer.write(self.planning_path)
```

- 运行python脚本及其环境变量配置

### 3.4 简易局部规划

#### 3.4.1 输入输出与处理逻辑简述

简易局部规划是通过结合深度相机所获取的障碍物位置、全局规划路径以及当前位置信息，经过局部规划算法处理，输出最优的局部规划路径和规划车速等信息。本示例代码中采用的是DWA算法，处理逻辑如下图所示。

![](./img/local_planning.png)

#### 3.4.2 输入接口（数据结构）与输出接口（数据结构）

| 输入\输出                                         | 通道名                                                       | 数据格式                                       |
| ------------------------------------------------- | ------------------------------------------------------------ | ---------------------------------------------- |
| 输入                                              | 订阅通道：全局轨迹通道**/planning/global_trajectory**        | modules.planning.proto.planning_pb2.Trajectory |
| 订阅通道：障碍物位置通道**/perception/obstacles** | modules.perception.proto.perception_obstacle_pb2.PerceptionObstacles |                                        |
| 订阅通道：当前位置通道**/geek/uwb/localization**  | modules.localization.proto.localization_pb2.pos              |                                                |
| 输出                                              | 写入通道：局部轨迹通道**/planning/dwa_trajectory**           | modules.planning.proto.planning_pb2.Trajectory |
| 写入通道：车速通道**/control/reference**          | modules.control.proto.control_pb2.Control_Reference          |                                                |

- 输出的数据结构 Trajectory和Control_Reference：

```python
# 输出是一个点的集合
self.planning_path = Trajectory()
self.speed = Control_Reference()
self.speed.vehicle_speed = u[0]	

if not best_trajectory.any():
    print("Failed to find a path")
else:
    for path_point in best_trajectory:
        point_xy.x = path_point[0]
	    point_xy.y = path_point[1]
        
        self.planning_path.point.append(point_xy)
        
point_xy.x = self.goal[0]
point_xy.y = self.goal[1]

self.planning_path.point.append(point_xy)	

if not cyber.is_shutdown() and self.planning_path:
    self.writer.write(self.planning_path)
    self.vwriter.write(self.speed)
```

- Point对象结构

```c
message Point {
  // meters
  optional double x = 1;
  optional double y = 2;
}
```

#### 3.4.3 运行demo脚本

```bash
cd /apollo/modules/exercises/exercise6-planning/example/
python3 planning_dwa_exercise6_todo.py 
python3 planning_a_star_exercise6_todo.py
python3 localization_example6.py 
python3 control_example_exercise6.py
mainboard -d /home/geek-car/geek_lite/modules/perception/dag/perception.dag
```

#### 3.4.4 订阅输出python脚本demo

- 数据类型import

在Python版本中，需要引用与通道输出相关的数据结构对象，直接加载即可：

```python
from modules.planning.proto.planning_pb2 import Trajectory 
from modules.planning.proto.planning_pb2 import Point 
from modules.control.proto.control_pb2 import Control_Reference
```

- 启动节点初始化

当需要数据流转通讯，形成通道的情形下，Cyber的需要初始化节点以在通道内监听或者发布数据。

```python
cyber.init()
cyber_node = cyber.Node("planning_dwa")
self.node.create_reader("/planning/global_trajectory", Trajectory, self.globalcallback)
self.node.create_reader("/perception/obstacles", PerceptionObstacles, self.obstaclecallback)
self.node.create_reader("/geek/uwb/localization", pos, self.callback)
```

- 回调函数获取当前位置

```python
def localizationcallback(self, pos):
    start_x = int(pos.x * scale) 
    start_y = int(pos.y * scale) 
```

- 回调函数获取全局轨迹

```python
def globalcallback(self, global_trajectory):
    pathList = []
    for point in global_trajectory.point:
        pathList.append([point.x, point.y])
	self.pathList = []
	self.pathList = pathList
```

- 回调函数获取障碍物位置

```python
def obstaclecallback(self, data):
    obstacle_info = []
	for obstacle in data.perception_obstacle:
	    min_x = obstacle.bbox2d.zmin
	    max_x = obstacle.bbox2d.zmax
	    min_y = -obstacle.bbox2d.xmin
	    max_y = -obstacle.bbox2d.xmax

	    obstacle_x = (max_x - min_x)/2 + min_x
	    obstacle_y = (max_y - min_y)/2 + min_y
	    obstacle_r = 0.2
        
        obstacle_info.append([obstacle_x, obstacle_y, obstacle_r])
        
    self.obstacleList = obstacle_info  
```

- 运行python脚本及其环境变量配置

### 3.5 简易横纵向控制

1. 输入输出与处理逻辑简述
2. 输入接口（数据结构）与输出接口（数据结构）
3. 运行demo脚本
4. 订阅输出python脚本demo
