# 15 Orin 安装 Autoware.Auto

##  1 ADE

### 1.1 可能遇到的问题

**(1) docker: Error response from daemon: could not select device driver ““ with capabilities: [[gpu]]** 

docker 的问题主要是 docker 版本和 nvidia-docker 版本兼容的问题，使用[nvidia-docker 官方安装方法](https://big-circle.readthedocs.io/en/latest/NVIDIA/Docker.html#installation)，在 Orin中容易将添加的软件源识别为 `Ubuntu 18`，在执行 `sudo apt update` 时需要注意。需要从 NVIDIA 官网下载 `Jetpack 5.0` 的软件包，并按顺序安装:

```bash
sudo dpkg -i libnvidia-container1_1.9.0-1_arm64.deb
sudo dpkg -i libnvidia-container0_0.11.0+jetpack_arm64.deb
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

 例如确实 `GitPython` ，版本为 3.1.14，则执行

```bash
pip3 install GitPython==3.1.14 -i http://pypi.douban.com/simple --trusted-host pypi.douban.com
```

### 1.2 stderr

Auto 版本目前一共157个 package，其中有19个存在 stderr output。

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

