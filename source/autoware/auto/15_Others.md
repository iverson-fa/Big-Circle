# 15 Orin 安装 Autoware.Auto

##  1 ADE

### 1.1 可能遇到的问题

**(1) docker: Error response from daemon: could not select device driver ““ with capabilities: [[gpu]]** 

docker 的问题主要是 docker 版本和 nvidia-docker 版本兼容的问题，使用[nvidia-docker 官方安装方法](https://big-circle.readthedocs.io/en/latest/NVIDIA/Docker.html#installation)，在 Orin中容易将添加的软件源识别为 `Ubuntu 18`，在执行 `sudo apt update` 时需要注意。需要从 NVIDIA 官网下载 `Jetpack 5.0` 的软件包，并按顺序安装。

先尝试不添加源安装 `nvidia-docker2`，安装信息：

```shell
Get:1 https://repo.download.nvidia.cn/jetson/common r34.1/main arm64 libnvidia-container0 arm64 0.11.0+jetpack [42.4 kB]
Get:2 https://repo.download.nvidia.cn/jetson/common r34.1/main arm64 libnvidia-container1 arm64 1.9.0-1 [812 kB]
Get:3 https://repo.download.nvidia.cn/jetson/common r34.1/main arm64 libnvidia-container-tools arm64 1.9.0-1 [22.1 kB]
Get:4 https://repo.download.nvidia.cn/jetson/common r34.1/main arm64 nvidia-container-toolkit arm64 1.9.0-1 [854 kB]
Get:5 https://repo.download.nvidia.cn/jetson/common r34.1/main arm64 nvidia-docker2 all 2.10.0-1 [5,536 B]
```

若 apt 定位不到，从 NVIDIA 官网下载，并按顺序安装：

```bash
sudo dpkg -i libnvidia-container0_0.11.0+jetpack_arm64.deb
sudo dpkg -i libnvidia-container1_1.9.0-1_arm64.deb
sudo dpkg -i libnvidia-container-tools_1.9.0-1_arm64.deb
sudo dpkg -i nvidia-container-toolkit_1.9.0-1_arm64.deb
sudo dpkg -i nvidia-docker2_2.10.0-1_all.deb
```

编辑 `/etc/docker/daemon.json`

```shell
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://71bj24w3.mirror.aliyuncs.com"]
}
{
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

**(2) 编译过程中，缺失某个python包**

 例如缺失 `GitPython` ，版本为 3.1.14，则执行

```bash
pip3 install GitPython==3.1.14 -i http://pypi.douban.com/simple --trusted-host pypi.douban.com
```

### 1.2 stderr

Auto 版本目前（2022年4月28日，branch：master，commit： e3e26be1ab4b822）一共157个 package，其中有19个存在 stderr output。

**(1) neural_networks**

```shell
--- stderr: neural_networks
CMake Warning at CMakeLists.txt:43 (message):
  Skipped download (enable by setting DOWNLOAD_ARTIFACTS)
```

**(2) tvm_utility**

```shell
--- stderr: tvm_utility
CMake Warning at CMakeLists.txt:115 (message):
  No model is generated for
  /home/orin-d/AutowareAuto/src/common/tvm_utility/test/yolo_v2_tiny,
  skipping test
```

**(3 )spinnaker_camera_driver**

```shell
--- stderr: spinnaker_camera_driver
CMake Warning at CMakeLists.txt:55 (message):
  SPINNAKER SDK not found, so spinnaker_camera_driver could not be built.
```

**(4) spinnaker_camera_nodes**

```shell
--- stderr: spinnaker_camera_nodes
CMake Warning at CMakeLists.txt:60 (message):
  SPINNAKER SDK not found, so spinnaker_camera_nodes could not be built.
```

**(5) gnss_conversion_nodes**

```shell
--- stderr: gnss_conversion_nodes
In file included from /opt/ros/foxy/include/rclcpp/client.hpp:40,
                 from /opt/ros/foxy/include/rclcpp/callback_group.hpp:23,
                 from /opt/ros/foxy/include/rclcpp/node.hpp:39,
                 from /home/orin-d/AutowareAuto/src/tools/gnss_conversion_nodes/include/gnss_conversion_nodes/gnss_conversion_node.hpp:25,
                 from /home/orin-d/AutowareAuto/src/tools/gnss_conversion_nodes/src/gnss_conversion_node.cpp:17:
/home/orin-d/AutowareAuto/src/tools/gnss_conversion_nodes/src/gnss_conversion_node.cpp: In member function ‘void autoware::gnss_conversion_nodes::GnssConversionNode::nav_sat_fix_callback(sensor_msgs::msg::NavSatFix_<std::allocator<void> >::ConstSharedPtr) const’:
/home/orin-d/AutowareAuto/src/tools/gnss_conversion_nodes/src/gnss_conversion_node.cpp:142:7: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  142 |       kDefaultLoggingInterval,
      |       ^~~~~~~~~~~~~~~~~~~~~~~
/home/orin-d/AutowareAuto/src/tools/gnss_conversion_nodes/src/gnss_conversion_node.cpp:159:7: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  159 |       kDefaultLoggingInterval,
      |       ^~~~~~~~~~~~~~~~~~~~~~~
---
```

**(6) apollo_lidar_segmentation**

```shell
WARNING:colcon.colcon_cmake.task.cmake.build:Could not run installation step for package 'apollo_lidar_segmentation' because it has no 'install' target
--- stderr: apollo_lidar_segmentation
** WARNING ** io features related to openni will be disabled
** WARNING ** io features related to openni2 will be disabled
** WARNING ** io features related to pcap will be disabled
** WARNING ** io features related to png will be disabled
** WARNING ** io features related to libusb-1.0 will be disabled
** WARNING ** visualization features related to openni will be disabled
** WARNING ** visualization features related to openni2 will be disabled
** WARNING ** apps features related to openni will be disabled
CMake Warning at CMakeLists.txt:80 (message):
  Neural network not found, skipping package.
```

**(7) grid_map_pcl**

```shell
--- stderr: grid_map_pcl
** WARNING ** io features related to openni will be disabled
** WARNING ** io features related to openni2 will be disabled
** WARNING ** io features related to pcap will be disabled
** WARNING ** io features related to png will be disabled
** WARNING ** io features related to libusb-1.0 will be disabled
** WARNING ** visualization features related to openni will be disabled
** WARNING ** visualization features related to openni2 will be disabled
** WARNING ** apps features related to openni will be disabled
---
```

**(8) mpc_controller**

```shell
--- stderr: mpc_controller
Argument QP_SOLVER not set, using default of QPOASES
Argument NAME not set, using default of code_generator
QP solver QPOASES is not recommended!
---
```

**(9) filter_node_base**

```shell
--- stderr: filter_node_base
** WARNING ** io features related to openni will be disabled
** WARNING ** io features related to openni2 will be disabled
** WARNING ** io features related to pcap will be disabled
** WARNING ** io features related to png will be disabled
** WARNING ** io features related to libusb-1.0 will be disabled
** WARNING ** visualization features related to openni will be disabled
** WARNING ** visualization features related to openni2 will be disabled
** WARNING ** apps features related to openni will be disabled
---
```

**(10) apollo_lidar_segmentation_nodes**

```bash
--- stderr: apollo_lidar_segmentation_nodes
CMake Warning at CMakeLists.txt:55 (message):
  apollo_lidar_segmentation not found, skipping package.
```

**(11) outlier_filter**

```shell
--- stderr: outlier_filter
** WARNING ** io features related to openni will be disabled
** WARNING ** io features related to openni2 will be disabled
** WARNING ** io features related to pcap will be disabled
** WARNING ** io features related to png will be disabled
** WARNING ** io features related to libusb-1.0 will be disabled
** WARNING ** visualization features related to openni will be disabled
** WARNING ** visualization features related to openni2 will be disabled
** WARNING ** apps features related to openni will be disabled
```

**(12) trajectory_follower**

```shell
--- stderr: trajectory_follower
In file included from /opt/ros/foxy/include/rclcpp/client.hpp:40,
                 from /opt/ros/foxy/include/rclcpp/callback_group.hpp:23,
                 from /opt/ros/foxy/include/rclcpp/any_executable.hpp:20,
                 from /opt/ros/foxy/include/rclcpp/memory_strategy.hpp:24,
                 from /opt/ros/foxy/include/rclcpp/memory_strategies.hpp:18,
                 from /opt/ros/foxy/include/rclcpp/executor_options.hpp:20,
                 from /opt/ros/foxy/include/rclcpp/executor.hpp:33,
                 from /opt/ros/foxy/include/rclcpp/executors/multi_threaded_executor.hpp:26,
                 from /opt/ros/foxy/include/rclcpp/executors.hpp:21,
                 from /opt/ros/foxy/include/rclcpp/rclcpp.hpp:146,
                 from /opt/ros/foxy/include/tf2_ros/buffer_interface.h:35,
                 from /opt/ros/foxy/include/tf2_geometry_msgs/tf2_geometry_msgs.h:38,
                 from /opt/ros/foxy/include/tf2/impl/utils.h:18,
                 from /opt/ros/foxy/include/tf2/utils.h:20,
                 from /home/orin-d/AutowareAuto/install/motion_common/include/motion_common/motion_common.hpp:25,
                 from /home/orin-d/AutowareAuto/src/control/trajectory_follower/include/trajectory_follower/mpc_utils.hpp:34,
                 from /home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc_utils.cpp:15:
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc_utils.cpp: In function ‘autoware::common::types::bool8_t autoware::motion::control::trajectory_follower::MPCUtils::calcNearestPoseInterp(const autoware::motion::control::trajectory_follower::MPCTrajectory&, const Pose&, geometry_msgs::msg::Pose*, size_t*, autoware::common::types::float64_t*, const rclcpp::Logger&, rclcpp::Clock&)’:
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc_utils.cpp:391:22: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  391 |       logger, clock, 5000, "[calcNearestPoseInterp] fail to get nearest. traj.size = %ul",
      |                      ^~~~
In file included from /opt/ros/foxy/include/rclcpp/client.hpp:40,
                 from /opt/ros/foxy/include/rclcpp/callback_group.hpp:23,
                 from /opt/ros/foxy/include/rclcpp/any_executable.hpp:20,
                 from /opt/ros/foxy/include/rclcpp/memory_strategy.hpp:24,
                 from /opt/ros/foxy/include/rclcpp/memory_strategies.hpp:18,
                 from /opt/ros/foxy/include/rclcpp/executor_options.hpp:20,
                 from /opt/ros/foxy/include/rclcpp/executor.hpp:33,
                 from /opt/ros/foxy/include/rclcpp/executors/multi_threaded_executor.hpp:26,
                 from /opt/ros/foxy/include/rclcpp/executors.hpp:21,
                 from /opt/ros/foxy/include/rclcpp/rclcpp.hpp:146,
                 from /opt/ros/foxy/include/tf2_ros/buffer_interface.h:35,
                 from /opt/ros/foxy/include/tf2_ros/buffer.h:40,
                 from /home/orin-d/AutowareAuto/src/control/trajectory_follower/include/trajectory_follower/mpc.hpp:23,
                 from /home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp:23:
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp: In member function ‘autoware::common::types::bool8_t autoware::motion::control::trajectory_follower::MPC::calculateMPC(const VehicleKinematicState&, autoware::common::types::float64_t, const Pose&, autoware_auto_control_msgs::msg::AckermannLateralCommand&, autoware_auto_planning_msgs::msg::Trajectory&, autoware_auto_system_msgs::msg::Float32MultiArrayDiagnostic&)’:
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp:53:46: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
   53 |     RCLCPP_WARN_THROTTLE(m_logger, *m_clock, 1000 /*ms*/, "fail to get Data.");
      |                                              ^~~~
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp:64:27: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
   64 |       m_logger, *m_clock, 1000 /*ms*/,
      |                           ^~~~
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp:75:7: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
   75 |       1000 /*ms*/, "trajectory resampling failed.");
      |       ^~~~
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp:85:46: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
   85 |     RCLCPP_WARN_THROTTLE(m_logger, *m_clock, 1000 /*ms*/, "optimization failed.");
      |                                              ^~~~
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp: In member function ‘autoware::common::types::bool8_t autoware::motion::control::trajectory_follower::MPC::getData(const autoware::motion::control::trajectory_follower::MPCTrajectory&, const VehicleKinematicState&, const Pose&, autoware::motion::control::trajectory_follower::MPCData*)’:
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp:274:27: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  274 |       m_logger, *m_clock, duration,
      |                           ^~~~~~~~
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp:303:27: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  303 |       m_logger, *m_clock, duration, "position error is over limit. error = %fm, limit: %fm",
      |                           ^~~~~~~~
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp:311:27: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  311 |       m_logger, *m_clock, duration, "yaw error is over limit. error = %fdeg, limit %fdeg",
      |                           ^~~~~~~~
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp:320:27: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  320 |       m_logger, *m_clock, 1000 /*ms*/, "path is too short for prediction.");
      |                           ^~~~
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp: In member function ‘autoware::common::types::bool8_t autoware::motion::control::trajectory_follower::MPC::resampleMPCTrajectoryByTime(autoware::common::types::float64_t, const autoware::motion::control::trajectory_follower::MPCTrajectory&, autoware::motion::control::trajectory_follower::MPCTrajectory*) const’:
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp:414:7: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  414 |       1000 /*ms*/,
      |       ^~~~
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp: In member function ‘autoware::common::types::bool8_t autoware::motion::control::trajectory_follower::MPC::executeOptimization(const autoware::motion::control::trajectory_follower::MPCMatrix&, const VectorXd&, Eigen::VectorXd*)’:
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp:668:27: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  668 |       m_logger, *m_clock, 1000 /*ms*/, "model matrix is invalid. stop MPC.");
      |                           ^~~~
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp:701:56: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  701 |     RCLCPP_WARN_SKIPFIRST_THROTTLE(m_logger, *m_clock, 1000 /*ms*/, "qp solver error");
      |                                                        ^~~~
/home/orin-d/AutowareAuto/src/control/trajectory_follower/src/mpc.cpp:713:27: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  713 |       m_logger, *m_clock, 1000 /*ms*/, "model Uex includes NaN, stop MPC.");
      |                           ^~~~
---
```

**(13) trajectory_follower_nodes**

```shell
--- stderr: trajectory_follower_nodes
In file included from /opt/ros/foxy/include/rclcpp/client.hpp:40,
                 from /opt/ros/foxy/include/rclcpp/callback_group.hpp:23,
                 from /opt/ros/foxy/include/rclcpp/any_executable.hpp:20,
                 from /opt/ros/foxy/include/rclcpp/memory_strategy.hpp:24,
                 from /opt/ros/foxy/include/rclcpp/memory_strategies.hpp:18,
                 from /opt/ros/foxy/include/rclcpp/executor_options.hpp:20,
                 from /opt/ros/foxy/include/rclcpp/executor.hpp:33,
                 from /opt/ros/foxy/include/rclcpp/executors/multi_threaded_executor.hpp:26,
                 from /opt/ros/foxy/include/rclcpp/executors.hpp:21,
                 from /opt/ros/foxy/include/rclcpp/rclcpp.hpp:146,
                 from /opt/ros/foxy/include/tf2_ros/buffer_interface.h:35,
                 from /opt/ros/foxy/include/tf2_ros/buffer.h:40,
                 from /home/orin-d/AutowareAuto/install/trajectory_follower/include/trajectory_follower/mpc.hpp:23,
                 from /home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/include/trajectory_follower_nodes/lateral_controller_node.hpp:26,
                 from /home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/src/lateral_controller_node.cpp:23:
/home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/src/lateral_controller_node.cpp: In member function ‘void autoware::motion::control::trajectory_follower_nodes::LateralController::onTimer()’:
/home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/src/lateral_controller_node.cpp:218:35: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  218 |       get_logger(), *get_clock(), 5000 /*ms*/,
      |                                   ^~~~
/home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/src/lateral_controller_node.cpp: In member function ‘autoware::common::types::bool8_t autoware::motion::control::trajectory_follower_nodes::LateralController::updateCurrentPose()’:
/home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/src/lateral_controller_node.cpp:301:35: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  301 |       get_logger(), *get_clock(), 5000 /*ms*/,
      |                                   ^~~~
/home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/src/lateral_controller_node.cpp:304:35: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  304 |       get_logger(), *get_clock(), 5000 /*ms*/,
      |                                   ^~~~
In file included from /opt/ros/foxy/include/rclcpp/client.hpp:40,
                 from /opt/ros/foxy/include/rclcpp/callback_group.hpp:23,
                 from /opt/ros/foxy/include/rclcpp/any_executable.hpp:20,
                 from /opt/ros/foxy/include/rclcpp/memory_strategy.hpp:24,
                 from /opt/ros/foxy/include/rclcpp/memory_strategies.hpp:18,
                 from /opt/ros/foxy/include/rclcpp/executor_options.hpp:20,
                 from /opt/ros/foxy/include/rclcpp/executor.hpp:33,
                 from /opt/ros/foxy/include/rclcpp/executors/multi_threaded_executor.hpp:26,
                 from /opt/ros/foxy/include/rclcpp/executors.hpp:21,
                 from /opt/ros/foxy/include/rclcpp/rclcpp.hpp:146,
                 from /opt/ros/foxy/include/tf2_ros/buffer_interface.h:35,
                 from /opt/ros/foxy/include/tf2_geometry_msgs/tf2_geometry_msgs.h:38,
                 from /opt/ros/foxy/include/tf2/impl/utils.h:18,
                 from /opt/ros/foxy/include/tf2/utils.h:20,
                 from /home/orin-d/AutowareAuto/install/motion_common/include/motion_common/motion_common.hpp:25,
                 from /home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/include/trajectory_follower_nodes/longitudinal_controller_node.hpp:30,
                 from /home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/src/longitudinal_controller_node.cpp:22:
/home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/src/longitudinal_controller_node.cpp: In member function ‘void autoware::motion::control::trajectory_follower_nodes::LongitudinalController::callbackTrajectory(autoware_auto_planning_msgs::msg::Trajectory_<std::allocator<void> >::ConstSharedPtr)’:
/home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/src/longitudinal_controller_node.cpp:223:35: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  223 |       get_logger(), *get_clock(), 3000,
      |                                   ^~~~
/home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/src/longitudinal_controller_node.cpp:230:35: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  230 |       get_logger(), *get_clock(), 3000,
      |                                   ^~~~
/home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/src/longitudinal_controller_node.cpp: In member function ‘autoware::motion::control::trajectory_follower_nodes::LongitudinalController::Motion autoware::motion::control::trajectory_follower_nodes::LongitudinalController::calcEmergencyCtrlCmd(autoware::common::types::float64_t) const’:
/home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/src/longitudinal_controller_node.cpp:473:26: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  473 |     get_logger(), clock, 3000,
      |                          ^~~~
In file included from /opt/ros/foxy/include/rclcpp/client.hpp:40,
                 from /opt/ros/foxy/include/rclcpp/callback_group.hpp:23,
                 from /opt/ros/foxy/include/rclcpp/any_executable.hpp:20,
                 from /opt/ros/foxy/include/rclcpp/memory_strategy.hpp:24,
                 from /opt/ros/foxy/include/rclcpp/memory_strategies.hpp:18,
                 from /opt/ros/foxy/include/rclcpp/executor_options.hpp:20,
                 from /opt/ros/foxy/include/rclcpp/executor.hpp:33,
                 from /opt/ros/foxy/include/rclcpp/executors/multi_threaded_executor.hpp:26,
                 from /opt/ros/foxy/include/rclcpp/executors.hpp:21,
                 from /opt/ros/foxy/include/rclcpp/rclcpp.hpp:146,
                 from /home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/include/trajectory_follower_nodes/latlon_muxer_node.hpp:27,
                 from /home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/src/latlon_muxer_node.cpp:18:
/home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/src/latlon_muxer_node.cpp: In member function ‘bool autoware::motion::control::trajectory_follower_nodes::LatLonMuxer::checkTimeout()’:
/home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/src/latlon_muxer_node.cpp:53:21: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
   53 |       *get_clock(), 1000 /*ms*/,
      |                     ^~~~
/home/orin-d/AutowareAuto/src/control/trajectory_follower_nodes/src/latlon_muxer_node.cpp:60:21: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
   60 |       *get_clock(), 1000 /*ms*/,
      |                     ^~~~
---
```

**(14) recordreplay_planner_nodes**

```shell
--- stderr: recordreplay_planner_nodes
In file included from /opt/ros/foxy/include/rclcpp/client.hpp:40,
                 from /opt/ros/foxy/include/rclcpp/callback_group.hpp:23,
                 from /opt/ros/foxy/include/rclcpp/any_executable.hpp:20,
                 from /opt/ros/foxy/include/rclcpp/memory_strategy.hpp:24,
                 from /opt/ros/foxy/include/rclcpp/memory_strategies.hpp:18,
                 from /opt/ros/foxy/include/rclcpp/executor_options.hpp:20,
                 from /opt/ros/foxy/include/rclcpp/executor.hpp:33,
                 from /opt/ros/foxy/include/rclcpp/executors/multi_threaded_executor.hpp:26,
                 from /opt/ros/foxy/include/rclcpp/executors.hpp:21,
                 from /opt/ros/foxy/include/rclcpp/rclcpp.hpp:146,
                 from /opt/ros/foxy/include/tf2_ros/transform_listener.h:39,
                 from /home/orin-d/AutowareAuto/src/planning/recordreplay_planner_nodes/include/recordreplay_planner_nodes/recordreplay_planner_node.hpp:17,
                 from /home/orin-d/AutowareAuto/src/planning/recordreplay_planner_nodes/src/recordreplay_planner_nodes/recordreplay_planner_node.cpp:17:
/home/orin-d/AutowareAuto/src/planning/recordreplay_planner_nodes/src/recordreplay_planner_nodes/recordreplay_planner_node.cpp: In member function ‘void motion::planning::recordreplay_planner_nodes::RecordReplayPlannerNode::on_ego(const SharedPtr&)’:
/home/orin-d/AutowareAuto/src/planning/recordreplay_planner_nodes/src/recordreplay_planner_nodes/recordreplay_planner_node.cpp:189:49: warning: use of old-style cast to ‘rcutils_duration_value_t’ {aka ‘long int’} [-Wold-style-cast]
  189 |       this->get_logger(), *(this->get_clock()), 1000 /*ms*/,
      |                                                 ^~~~
---
```

**(15) ndt**

```shell
--- stderr: ndt
** WARNING ** io features related to openni will be disabled
** WARNING ** io features related to openni2 will be disabled
** WARNING ** io features related to pcap will be disabled
** WARNING ** io features related to png will be disabled
** WARNING ** io features related to libusb-1.0 will be disabled
CMake Warning (dev) at CMakeLists.txt:62 (find_package):
  Policy CMP0074 is not set: find_package uses <PackageName>_ROOT variables.
  Run "cmake --help-policy CMP0074" for policy details.  Use the cmake_policy
  command to set the policy and suppress this warning.

  CMake variable PCL_ROOT is set to:

    /usr

  For compatibility, CMake is ignoring the variable.
This warning is for project developers.  Use -Wno-dev to suppress it.

---
```

**(16) ndt_nodes**

```shell
--- stderr: ndt_nodes
** WARNING ** io features related to openni will be disabled
** WARNING ** io features related to openni2 will be disabled
** WARNING ** io features related to pcap will be disabled
** WARNING ** io features related to png will be disabled
** WARNING ** io features related to libusb-1.0 will be disabled
---
```

**(17) ndt_mapping_nodes**

```shell
--- stderr: ndt_mapping_nodes
** WARNING ** io features related to openni will be disabled
** WARNING ** io features related to openni2 will be disabled
** WARNING ** io features related to pcap will be disabled
** WARNING ** io features related to png will be disabled
** WARNING ** io features related to libusb-1.0 will be disabled
---
```

**(18) point_cloud_mapping**

```shell
--- stderr: point_cloud_mapping
** WARNING ** io features related to openni will be disabled
** WARNING ** io features related to openni2 will be disabled
** WARNING ** io features related to pcap will be disabled
** WARNING ** io features related to png will be disabled
** WARNING ** io features related to libusb-1.0 will be disabled
---
```

**(19) outlier_filter_nodes**

```shell
--- stderr: outlier_filter_nodes
** WARNING ** io features related to openni will be disabled
** WARNING ** io features related to openni2 will be disabled
** WARNING ** io features related to pcap will be disabled
** WARNING ** io features related to png will be disabled
** WARNING ** io features related to libusb-1.0 will be disabled
** WARNING ** visualization features related to openni will be disabled
** WARNING ** visualization features related to openni2 will be disabled
** WARNING ** apps features related to openni will be disabled
---
```

### 1.3 Packages List

apollo_lidar_segmentation
apollo_lidar_segmentation_nodes
asio_cmake_module
autoware_auto_algorithm
autoware_auto_cmake
autoware_auto_common
autoware_auto_control_msgs
autoware_auto_create_pkg
autoware_auto_debug_msgs
autoware_auto_examples
autoware_auto_geometry
autoware_auto_geometry_msgs
autoware_auto_launch
autoware_auto_mapping_msgs
autoware_auto_msgs
autoware_auto_perception_msgs
autoware_auto_planning_msgs
autoware_auto_system_msgs
autoware_auto_tf2
autoware_auto_vehicle_msgs
autoware_demos
autoware_rviz_plugins
autoware_state_monitor
autoware_testing
avp_web_interface
behavior_planner
behavior_planner_nodes
benchmark_tool
benchmark_tool_nodes
cluster_projection_node
controller_common
controller_common_nodes
controller_testing
costmap_generator
costmap_generator_nodes
covariance_insertion
covariance_insertion_nodes
detection_2d_visualizer
emergency_handler
euclidean_cluster
euclidean_cluster_nodes
f1tenth_base_description
fake_test_node
filter_node_base
freespace_planner
freespace_planner_nodes
global_velocity_planner
gnss_conversion_nodes
grid_map
grid_map_cmake_helpers
grid_map_core
grid_map_costmap_2d
grid_map_cv
grid_map_demos
grid_map_filters
grid_map_loader
grid_map_msgs
grid_map_octomap
grid_map_pcl
grid_map_ros
grid_map_rviz_plugin
grid_map_sdf
grid_map_visualization
ground_truth_detections
had_map_utils
hungarian_assigner
io_context
joystick_vehicle_interface
joystick_vehicle_interface_nodes
lanelet2_global_planner
lanelet2_global_planner_nodes
lanelet2_map_provider
lane_planner
lane_planner_nodes
lexus_rx_450h_description
lgsvl
lgsvl_interface
lgsvl_simulation
lidar_integration
lidar_utils
localization_common
localization_nodes
localization_system_tests
lonely_world_prediction
measurement_conversion
monitored_node
motion_common
motion_model
motion_model_testing_simulator
motion_testing
motion_testing_nodes
mpark_variant_vendor
mpc_controller
mpc_controller_nodes
ndt
ndt_mapping_nodes
ndt_nodes
ne_raptor_interface
neural_networks
object_collision_estimator
object_collision_estimator_nodes
odom_to_state_conversion_nodes
off_map_obstacles_filter
off_map_obstacles_filter_nodes
optimization
osqp_interface
outlier_filter
outlier_filter_nodes
point_cloud_filter_transform_nodes
point_cloud_fusion
point_cloud_fusion_nodes
point_cloud_mapping
point_type_adapter
polygon_remover
polygon_remover_nodes
prediction_nodes
pure_pursuit
pure_pursuit_nodes
ray_ground_classifier
ray_ground_classifier_nodes
recordreplay_planner
recordreplay_planner_nodes
reference_tracking_controller
scenario_simulator_launch
serial_driver
signal_filters
simple_planning_simulator
spinnaker_camera_driver
spinnaker_camera_nodes
ssc_interface
state_estimation
state_estimation_nodes
state_vector
test_trajectory_following
time_utils
tracking
tracking_nodes
tracking_test_framework
trajectory_follower
trajectory_follower_nodes
trajectory_planner_node_base
trajectory_smoother
trajectory_spoofer
tvm_utility
udp_driver
vehicle_constants_manager
vehicle_interface
velodyne_driver
velodyne_nodes
vesc
vesc_ackermann
vesc_driver
vesc_interface
vesc_msgs
voxel_grid
voxel_grid_nodes
xsens_driver
