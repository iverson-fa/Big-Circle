# 16 Orin 编译过程
```shell
Starting >>> autoware_auto_cmake
Starting >>> autoware_auto_geometry_msgs
Starting >>> autoware_auto_mapping_msgs
Starting >>> autoware_auto_system_msgs
Starting >>> autoware_testing
Starting >>> autoware_auto_control_msgs
Starting >>> mpark_variant_vendor
Starting >>> grid_map_cmake_helpers
Starting >>> lexus_rx_450h_description
Starting >>> vesc_msgs
Starting >>> asio_cmake_module
Starting >>> lgsvl
Finished <<< autoware_testing [1.10s]
Finished <<< autoware_auto_cmake [1.16s]
Finished <<< mpark_variant_vendor [1.20s]
Starting >>> autoware_auto_common
Starting >>> time_utils
Finished <<< lexus_rx_450h_description [1.22s]
Starting >>> reference_tracking_controller
Finished <<< grid_map_cmake_helpers [1.24s]
Starting >>> autoware_auto_algorithm
Finished <<< asio_cmake_module [1.25s]
Starting >>> grid_map_core
Starting >>> grid_map_msgs
Finished <<< autoware_auto_geometry_msgs [1.57s]
Starting >>> autoware_auto_perception_msgs
Finished <<< autoware_auto_control_msgs [1.60s]
Starting >>> io_context
Finished <<< autoware_auto_mapping_msgs [1.68s]
Starting >>> autoware_auto_planning_msgs
Finished <<< vesc_msgs [1.67s]
Starting >>> avp_web_interface
Finished <<< autoware_auto_system_msgs [1.91s]
Starting >>> neural_networks
Finished <<< lgsvl [3.33s]
Starting >>> motion_model_testing_simulator
Finished <<< reference_tracking_controller [4.28s]
Starting >>> lgsvl_simulation
--- stderr: neural_networks
CMake Warning at CMakeLists.txt:43 (message):
  Skipped download (enable by setting DOWNLOAD_ARTIFACTS)


---

Finished <<< neural_networks [3.75s]
Finished <<< avp_web_interface [4.03s]
Starting >>> tvm_utility
Starting >>> vesc_ackermann
Finished <<< time_utils [5.34s]
Starting >>> autoware_auto_create_pkg
Finished <<< motion_model_testing_simulator [18.5s]
Starting >>> autoware_auto_debug_msgs
[Processing: autoware_auto_algorithm, autoware_auto_common, autoware_auto_create_pkg, autoware_auto_debug_msgs, autoware_auto_perception_msgs, autoware_auto_planning_msgs, grid_map_core, grid_map_msgs, io_context, lgsvl_simulation, tvm_utility, vesc_ackermann]
Finished <<< autoware_auto_create_pkg [49.9s]
Finished <<< lgsvl_simulation [50.9s]
Starting >>> autoware_auto_examples
Starting >>> f1tenth_base_description
--- stderr: tvm_utility
CMake Warning at CMakeLists.txt:115 (message):
  No model is generated for
  /home/orin-d/AutowareAuto/src/common/tvm_utility/test/yolo_v2_tiny,
  skipping test


---

Finished <<< tvm_utility [50.8s]
Starting >>> monitored_node
Finished <<< io_context [55.1s]
Starting >>> udp_driver
Finished <<< autoware_auto_algorithm [55.5s]
Starting >>> serial_driver
Finished <<< grid_map_msgs [59.3s]
[Processing: autoware_auto_common, autoware_auto_debug_msgs, autoware_auto_examples, autoware_auto_perception_msgs, autoware_auto_planning_msgs, f1tenth_base_description, grid_map_core, monitored_node, serial_driver, udp_driver, vesc_ackermann]
Finished <<< autoware_auto_examples [42.3s]
Finished <<< f1tenth_base_description [42.3s]
Finished <<< autoware_auto_common [1min 38s]
Starting >>> state_vector
Starting >>> signal_filters
Starting >>> optimization
Starting >>> fake_test_node
Finished <<< vesc_ackermann [1min 33s]
Starting >>> velodyne_driver
[Processing: autoware_auto_debug_msgs, autoware_auto_perception_msgs, autoware_auto_planning_msgs, fake_test_node, grid_map_core, monitored_node, optimization, serial_driver, signal_filters, state_vector, udp_driver, velodyne_driver]
[Processing: autoware_auto_debug_msgs, autoware_auto_perception_msgs, autoware_auto_planning_msgs, fake_test_node, grid_map_core, monitored_node, optimization, serial_driver, signal_filters, state_vector, udp_driver, velodyne_driver]
Finished <<< monitored_node [2min 6s]
Starting >>> freespace_planner
Finished <<< serial_driver [2min 6s]
Finished <<< state_vector [1min 24s]
Starting >>> motion_model
Starting >>> hungarian_assigner
Finished <<< velodyne_driver [1min 24s]
Starting >>> osqp_interface
Finished <<< autoware_auto_perception_msgs [3min 2s]
Starting >>> autoware_auto_tf2
Finished <<< signal_filters [1min 34s]
Starting >>> off_map_obstacles_filter
Finished <<< grid_map_core [3min 12s]
Starting >>> grid_map_cv
Finished <<< autoware_auto_debug_msgs [2min 52s]
Starting >>> lidar_integration
Finished <<< optimization [1min 54s]
Starting >>> localization_common
[Processing: autoware_auto_planning_msgs, autoware_auto_tf2, fake_test_node, freespace_planner, grid_map_cv, hungarian_assigner, lidar_integration, localization_common, motion_model, off_map_obstacles_filter, osqp_interface, udp_driver]
Finished <<< fake_test_node [2min 42s]
Starting >>> covariance_insertion
Finished <<< udp_driver [3min 25s]
Starting >>> grid_map_octomap
Finished <<< autoware_auto_tf2 [1min 19s]
Starting >>> ground_truth_detections
Finished <<< autoware_auto_planning_msgs [4min 20s]
Starting >>> autoware_auto_vehicle_msgs
Finished <<< osqp_interface [1min 21s]
Starting >>> had_map_utils
Finished <<< covariance_insertion [20.1s]
Finished <<< motion_model [1min 39s]
Starting >>> state_estimation
Starting >>> benchmark_tool
Finished <<< freespace_planner [1min 39s]
Finished <<< hungarian_assigner [1min 39s]
Starting >>> lonely_world_prediction
Starting >>> spinnaker_camera_driver
[Processing: autoware_auto_vehicle_msgs, benchmark_tool, grid_map_cv, grid_map_octomap, ground_truth_detections, had_map_utils, lidar_integration, localization_common, lonely_world_prediction, off_map_obstacles_filter, spinnaker_camera_driver, state_estimation]
Finished <<< grid_map_cv [2min 24s]
Starting >>> grid_map_ros
Finished <<< localization_common [2min 5s]
Finished <<< lidar_integration [2min 24s]
Starting >>> localization_nodes
Starting >>> vehicle_constants_manager
--- stderr: spinnaker_camera_driver
CMake Warning at CMakeLists.txt:55 (message):
  SPINNAKER SDK not found, so spinnaker_camera_driver could not be built.


---

Finished <<< spinnaker_camera_driver [55.7s]
Starting >>> covariance_insertion_nodes
Finished <<< grid_map_octomap [1min 16s]
Starting >>> vesc_driver
Finished <<< off_map_obstacles_filter [2min 25s]
Starting >>> grid_map_costmap_2d
[Processing: autoware_auto_vehicle_msgs, benchmark_tool, covariance_insertion_nodes, grid_map_costmap_2d, grid_map_ros, ground_truth_detections, had_map_utils, localization_nodes, lonely_world_prediction, state_estimation, vehicle_constants_manager, vesc_driver]
[Processing: autoware_auto_vehicle_msgs, benchmark_tool, covariance_insertion_nodes, grid_map_costmap_2d, grid_map_ros, ground_truth_detections, had_map_utils, localization_nodes, lonely_world_prediction, state_estimation, vehicle_constants_manager, vesc_driver]
Finished <<< lonely_world_prediction [2min 14s]
Finished <<< ground_truth_detections [2min 34s]
Starting >>> grid_map_sdf
Starting >>> xsens_driver
Finished <<< vehicle_constants_manager [1min 19s]
Finished <<< vesc_driver [1min 19s]
Starting >>> gnss_conversion_nodes
Starting >>> prediction_nodes
Finished <<< benchmark_tool [2min 17s]
Starting >>> benchmark_tool_nodes
[Processing: autoware_auto_vehicle_msgs, benchmark_tool_nodes, covariance_insertion_nodes, gnss_conversion_nodes, grid_map_costmap_2d, grid_map_ros, grid_map_sdf, had_map_utils, localization_nodes, prediction_nodes, state_estimation, xsens_driver]
Finished <<< localization_nodes [1min 57s]
Finished <<< grid_map_costmap_2d [1min 57s]
Starting >>> spinnaker_camera_nodes
Starting >>> vesc
Finished <<< state_estimation [2min 53s]
Starting >>> measurement_conversion
Finished <<< grid_map_ros [1min 57s]
Starting >>> grid_map_filters
Finished <<< benchmark_tool_nodes [35.7s]
Starting >>> grid_map_loader
Finished <<< had_map_utils [3min 39s]
--- stderr: spinnaker_camera_nodes
CMake Warning at CMakeLists.txt:60 (message):
  SPINNAKER SDK not found, so spinnaker_camera_nodes could not be built.


---

Finished <<< spinnaker_camera_nodes [28.7s]
Starting >>> lanelet2_map_provider
Starting >>> trajectory_planner_node_base
Finished <<< vesc [28.7s]
Starting >>> costmap_generator
Finished <<< xsens_driver [1min 24s]
Starting >>> grid_map_rviz_plugin
[Processing: autoware_auto_vehicle_msgs, costmap_generator, covariance_insertion_nodes, gnss_conversion_nodes, grid_map_filters, grid_map_loader, grid_map_rviz_plugin, grid_map_sdf, lanelet2_map_provider, measurement_conversion, prediction_nodes, trajectory_planner_node_base]
Finished <<< grid_map_sdf [2min 15s]
Starting >>> grid_map_visualization
Finished <<< grid_map_loader [1min 37s]
Starting >>> grid_map_pcl
Finished <<< covariance_insertion_nodes [3min 34s]
Finished <<< prediction_nodes [2min 17s]
Finished <<< autoware_auto_vehicle_msgs [5min 2s]
Starting >>> autoware_auto_geometry
Starting >>> motion_testing
Starting >>> vehicle_interface
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

Finished <<< gnss_conversion_nodes [2min 29s]
Starting >>> autoware_auto_msgs
Finished <<< measurement_conversion [2min 0s]
Starting >>> state_estimation_nodes
[Processing: autoware_auto_geometry, autoware_auto_msgs, costmap_generator, grid_map_filters, grid_map_pcl, grid_map_rviz_plugin, grid_map_visualization, lanelet2_map_provider, motion_testing, state_estimation_nodes, trajectory_planner_node_base, vehicle_interface]
Finished <<< trajectory_planner_node_base [2min 28s]
Finished <<< autoware_auto_msgs [1min 6s]
Starting >>> joystick_vehicle_interface
Starting >>> autoware_state_monitor
Finished <<< costmap_generator [2min 28s]
Starting >>> costmap_generator_nodes
Finished <<< motion_testing [1min 28s]
Starting >>> controller_testing
[Processing: autoware_auto_geometry, autoware_state_monitor, controller_testing, costmap_generator_nodes, grid_map_filters, grid_map_pcl, grid_map_rviz_plugin, grid_map_visualization, joystick_vehicle_interface, lanelet2_map_provider, state_estimation_nodes, vehicle_interface]
Finished <<< lanelet2_map_provider [3min 42s]
Starting >>> off_map_obstacles_filter_nodes
Finished <<< joystick_vehicle_interface [1min 15s]
Finished <<< grid_map_rviz_plugin [3min 25s]
Starting >>> emergency_handler
Starting >>> odom_to_state_conversion_nodes
Finished <<< costmap_generator_nodes [1min 15s]
Finished <<< controller_testing [1min 7s]
Finished <<< autoware_auto_geometry [2min 40s]
Starting >>> motion_common
Starting >>> lidar_utils
Starting >>> autoware_rviz_plugins
[Processing: autoware_rviz_plugins, autoware_state_monitor, emergency_handler, grid_map_filters, grid_map_pcl, grid_map_visualization, lidar_utils, motion_common, odom_to_state_conversion_nodes, off_map_obstacles_filter_nodes, state_estimation_nodes, vehicle_interface]
[Processing: autoware_rviz_plugins, autoware_state_monitor, emergency_handler, grid_map_filters, grid_map_pcl, grid_map_visualization, lidar_utils, motion_common, odom_to_state_conversion_nodes, off_map_obstacles_filter_nodes, state_estimation_nodes, vehicle_interface]
Finished <<< grid_map_visualization [4min 22s]
Starting >>> tracking_test_framework
[Processing: autoware_rviz_plugins, autoware_state_monitor, emergency_handler, grid_map_filters, grid_map_pcl, lidar_utils, motion_common, odom_to_state_conversion_nodes, off_map_obstacles_filter_nodes, state_estimation_nodes, tracking_test_framework, vehicle_interface]
Finished <<< off_map_obstacles_filter_nodes [2min 48s]
Starting >>> apollo_lidar_segmentation
Finished <<< odom_to_state_conversion_nodes [2min 48s]
Finished <<< autoware_state_monitor [4min 2s]
Finished <<< vehicle_interface [5min 13s]
Starting >>> vesc_interface
Finished <<< lidar_utils [2min 36s]
Starting >>> voxel_grid
Starting >>> euclidean_cluster
Starting >>> point_cloud_fusion
[887.105s] WARNING:colcon.colcon_cmake.task.cmake.build:Could not run installation step for package 'apollo_lidar_segmentation' because it has no 'install' target
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


---

Finished <<< apollo_lidar_segmentation [13.4s]
Starting >>> ray_ground_classifier
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

Finished <<< grid_map_pcl [5min 42s]
Starting >>> velodyne_nodes
[Processing: autoware_rviz_plugins, emergency_handler, euclidean_cluster, grid_map_filters, motion_common, point_cloud_fusion, ray_ground_classifier, state_estimation_nodes, tracking_test_framework, velodyne_nodes, vesc_interface, voxel_grid]
Finished <<< point_cloud_fusion [1min 9s]
Starting >>> point_cloud_fusion_nodes
Finished <<< motion_common [3min 45s]
Finished <<< state_estimation_nodes [6min 15s]
Starting >>> controller_common
Starting >>> trajectory_smoother
Finished <<< emergency_handler [4min 4s]
Starting >>> behavior_planner
Finished <<< tracking_test_framework [2min 24s]
Starting >>> lgsvl_interface
Finished <<< euclidean_cluster [1min 20s]
Starting >>> lanelet2_global_planner
[Processing: autoware_rviz_plugins, behavior_planner, controller_common, grid_map_filters, lanelet2_global_planner, lgsvl_interface, point_cloud_fusion_nodes, ray_ground_classifier, trajectory_smoother, velodyne_nodes, vesc_interface, voxel_grid]
Finished <<< ray_ground_classifier [2min 13s]
Starting >>> ray_ground_classifier_nodes
Finished <<< voxel_grid [2min 47s]
Finished <<< trajectory_smoother [1min 38s]
Starting >>> voxel_grid_nodes
Starting >>> object_collision_estimator
Finished <<< vesc_interface [2min 50s]
Starting >>> lane_planner
Finished <<< behavior_planner [1min 38s]
Starting >>> ssc_interface
Finished <<< controller_common [1min 53s]
Starting >>> mpc_controller
[Processing: autoware_rviz_plugins, grid_map_filters, lane_planner, lanelet2_global_planner, lgsvl_interface, mpc_controller, object_collision_estimator, point_cloud_fusion_nodes, ray_ground_classifier_nodes, ssc_interface, velodyne_nodes, voxel_grid_nodes]
[Processing: autoware_rviz_plugins, grid_map_filters, lane_planner, lanelet2_global_planner, lgsvl_interface, mpc_controller, object_collision_estimator, point_cloud_fusion_nodes, ray_ground_classifier_nodes, ssc_interface, velodyne_nodes, voxel_grid_nodes]
Finished <<< autoware_rviz_plugins [6min 41s]
Starting >>> behavior_planner_nodes
Finished <<< point_cloud_fusion_nodes [2min 56s]
Starting >>> recordreplay_planner
Finished <<< velodyne_nodes [3min 52s]
Starting >>> point_cloud_filter_transform_nodes
Finished <<< object_collision_estimator [1min 21s]
Starting >>> object_collision_estimator_nodes
Finished <<< lanelet2_global_planner [3min 2s]
Starting >>> lanelet2_global_planner_nodes
Finished <<< lgsvl_interface [3min 5s]
Starting >>> tracking
[Processing: behavior_planner_nodes, grid_map_filters, lane_planner, lanelet2_global_planner_nodes, mpc_controller, object_collision_estimator_nodes, point_cloud_filter_transform_nodes, ray_ground_classifier_nodes, recordreplay_planner, ssc_interface, tracking, voxel_grid_nodes]
Finished <<< lane_planner [2min 12s]
Starting >>> lane_planner_nodes
Finished <<< voxel_grid_nodes [2min 36s]
Starting >>> ndt
Finished <<< ray_ground_classifier_nodes [3min 3s]
Starting >>> euclidean_cluster_nodes
Finished <<< ssc_interface [2min 35s]
Starting >>> motion_testing_nodes
Finished <<< recordreplay_planner [1min 42s]
Starting >>> trajectory_follower
Finished <<< lanelet2_global_planner_nodes [1min 48s]
Starting >>> pure_pursuit
Finished <<< point_cloud_filter_transform_nodes [2min 6s]
Starting >>> filter_node_base
--- stderr: mpc_controller
Argument QP_SOLVER not set, using default of QPOASES
Argument NAME not set, using default of code_generator

QP solver QPOASES is not recommended!
---

Finished <<< mpc_controller [3min 9s]
Starting >>> outlier_filter
[Processing: behavior_planner_nodes, euclidean_cluster_nodes, filter_node_base, grid_map_filters, lane_planner_nodes, motion_testing_nodes, ndt, object_collision_estimator_nodes, outlier_filter, pure_pursuit, tracking, trajectory_follower]
Finished <<< object_collision_estimator_nodes [2min 42s]
Starting >>> recordreplay_planner_nodes
[Processing: behavior_planner_nodes, euclidean_cluster_nodes, filter_node_base, grid_map_filters, lane_planner_nodes, motion_testing_nodes, ndt, outlier_filter, pure_pursuit, recordreplay_planner_nodes, tracking, trajectory_follower]
[Processing: behavior_planner_nodes, euclidean_cluster_nodes, filter_node_base, grid_map_filters, lane_planner_nodes, motion_testing_nodes, ndt, outlier_filter, pure_pursuit, recordreplay_planner_nodes, tracking, trajectory_follower]
Finished <<< behavior_planner_nodes [3min 57s]
Starting >>> point_type_adapter
Finished <<< lane_planner_nodes [3min 3s]
Starting >>> polygon_remover
Finished <<< euclidean_cluster_nodes [2min 39s]
Starting >>> detection_2d_visualizer
Finished <<< pure_pursuit [2min 8s]
Starting >>> apollo_lidar_segmentation_nodes
Finished <<< motion_testing_nodes [2min 59s]
Starting >>> controller_common_nodes
[Processing: apollo_lidar_segmentation_nodes, controller_common_nodes, detection_2d_visualizer, filter_node_base, grid_map_filters, ndt, outlier_filter, point_type_adapter, polygon_remover, recordreplay_planner_nodes, tracking, trajectory_follower]
[1433.439s] WARNING:colcon.colcon_cmake.task.cmake.build:Could not run installation step for package 'apollo_lidar_segmentation_nodes' because it has no 'install' target
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

Finished <<< filter_node_base [3min 2s]
Starting >>> freespace_planner_nodes
--- stderr: apollo_lidar_segmentation_nodes
CMake Warning at CMakeLists.txt:55 (message):
  apollo_lidar_segmentation not found, skipping package.


---

Finished <<< apollo_lidar_segmentation_nodes [53.4s]
Finished <<< tracking [4min 50s]
Starting >>> cluster_projection_node
Starting >>> tracking_nodes
--- stderr: outlier_filter
** WARNING ** io features related to openni will be disabled
** WARNING ** io features related to openni2 will be disabled
** WARNING ** io features related to pcap will be disabled
** WARNING ** io features related to png will be disabled
** WARNING ** io features related to libusb-1.0 will be disabled
** WARNING ** visualization features related to openni will be disabled
** WARNING ** visualization features related to openni2 will be disabled

** WARNING ** apps features related to openni will be disabled
---

Finished <<< outlier_filter [3min 7s]
Starting >>> global_velocity_planner
Finished <<< polygon_remover [1min 24s]
Starting >>> ne_raptor_interface
[Processing: cluster_projection_node, controller_common_nodes, detection_2d_visualizer, freespace_planner_nodes, global_velocity_planner, grid_map_filters, ndt, ne_raptor_interface, point_type_adapter, recordreplay_planner_nodes, tracking_nodes, trajectory_follower]
Finished <<< point_type_adapter [2min 4s]
Starting >>> simple_planning_simulator
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

Finished <<< trajectory_follower [4min 19s]
Starting >>> trajectory_follower_nodes
Finished <<< cluster_projection_node [1min 6s]
Starting >>> trajectory_spoofer
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

Finished <<< recordreplay_planner_nodes [3min 28s]
Starting >>> joystick_vehicle_interface_nodes
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

Finished <<< ndt [4min 56s]
Finished <<< freespace_planner_nodes [1min 6s]
Starting >>> ndt_nodes
Starting >>> point_cloud_mapping
Finished <<< detection_2d_visualizer [2min 42s]
Starting >>> outlier_filter_nodes
[Processing: controller_common_nodes, global_velocity_planner, grid_map_filters, joystick_vehicle_interface_nodes, ndt_nodes, ne_raptor_interface, outlier_filter_nodes, point_cloud_mapping, simple_planning_simulator, tracking_nodes, trajectory_follower_nodes, trajectory_spoofer]
[Processing: controller_common_nodes, global_velocity_planner, grid_map_filters, joystick_vehicle_interface_nodes, ndt_nodes, ne_raptor_interface, outlier_filter_nodes, point_cloud_mapping, simple_planning_simulator, tracking_nodes, trajectory_follower_nodes, trajectory_spoofer]
[Processing: controller_common_nodes, global_velocity_planner, grid_map_filters, joystick_vehicle_interface_nodes, ndt_nodes, ne_raptor_interface, outlier_filter_nodes, point_cloud_mapping, simple_planning_simulator, tracking_nodes, trajectory_follower_nodes, trajectory_spoofer]
[Processing: controller_common_nodes, global_velocity_planner, grid_map_filters, joystick_vehicle_interface_nodes, ndt_nodes, ne_raptor_interface, outlier_filter_nodes, point_cloud_mapping, simple_planning_simulator, tracking_nodes, trajectory_follower_nodes, trajectory_spoofer]
Finished <<< tracking_nodes [3min 41s]
Starting >>> polygon_remover_nodes
Finished <<< trajectory_spoofer [2min 35s]
Finished <<< global_velocity_planner [3min 54s]
--- stderr: point_cloud_mapping
** WARNING ** io features related to openni will be disabled
** WARNING ** io features related to openni2 will be disabled
** WARNING ** io features related to pcap will be disabled
** WARNING ** io features related to png will be disabled

** WARNING ** io features related to libusb-1.0 will be disabled
---

Finished <<< point_cloud_mapping [2min 52s]
Starting >>> ndt_mapping_nodes
Finished <<< joystick_vehicle_interface_nodes [3min 4s]
Finished <<< simple_planning_simulator [3min 22s]
Finished <<< controller_common_nodes [5min 23s]
Starting >>> mpc_controller_nodes
Starting >>> pure_pursuit_nodes
[Processing: grid_map_filters, mpc_controller_nodes, ndt_mapping_nodes, ndt_nodes, ne_raptor_interface, outlier_filter_nodes, polygon_remover_nodes, pure_pursuit_nodes, trajectory_follower_nodes]
--- stderr: ndt_nodes
** WARNING ** io features related to openni will be disabled
** WARNING ** io features related to openni2 will be disabled
** WARNING ** io features related to pcap will be disabled
** WARNING ** io features related to png will be disabled

** WARNING ** io features related to libusb-1.0 will be disabled
---

Finished <<< ndt_nodes [3min 59s]
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

Finished <<< outlier_filter_nodes [3min 33s]
[Processing: grid_map_filters, mpc_controller_nodes, ndt_mapping_nodes, ne_raptor_interface, polygon_remover_nodes, pure_pursuit_nodes, trajectory_follower_nodes]
Finished <<< ne_raptor_interface [5min 40s]
Finished <<< pure_pursuit_nodes [1min 21s]
Finished <<< polygon_remover_nodes [2min 15s]
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

Finished <<< trajectory_follower_nodes [5min 8s]
[Processing: grid_map_filters, mpc_controller_nodes, ndt_mapping_nodes]
Finished <<< mpc_controller_nodes [2min 1s]
Starting >>> autoware_auto_launch
Starting >>> test_trajectory_following
Finished <<< test_trajectory_following [6.00s]
Finished <<< autoware_auto_launch [7.01s]
Starting >>> autoware_demos
Starting >>> localization_system_tests
Starting >>> scenario_simulator_launch
Finished <<< scenario_simulator_launch [3.49s]
Finished <<< autoware_demos [3.74s]
--- stderr: ndt_mapping_nodes
** WARNING ** io features related to openni will be disabled
** WARNING ** io features related to openni2 will be disabled
** WARNING ** io features related to pcap will be disabled
** WARNING ** io features related to png will be disabled

** WARNING ** io features related to libusb-1.0 will be disabled
---

Finished <<< ndt_mapping_nodes [2min 51s]
Finished <<< grid_map_filters [23min 15s]
Starting >>> grid_map_demos
[Processing: grid_map_demos, localization_system_tests]
Finished <<< localization_system_tests [56.7s]
[Processing: grid_map_demos]te] [grid_map_demos:build 56% - 1min 10.3s]
[Processing: grid_map_demos]
[Processing: grid_map_demos]
[Processing: grid_map_demos]
[Processing: grid_map_demos]
[Processing: grid_map_demos]
[Processing: grid_map_demos]
[Processing: grid_map_demos]
Finished <<< grid_map_demos [4min 49s]
Starting >>> grid_map
Finished <<< grid_map [1.57s]

Summary: 157 packages finished [35min 41s]
  19 packages had stderr output: apollo_lidar_segmentation apollo_lidar_segmentation_nodes filter_node_base gnss_conversion_nodes grid_map_pcl mpc_controller ndt ndt_mapping_nodes ndt_nodes neural_networks outlier_filter outlier_filter_nodes point_cloud_mapping recordreplay_planner_nodes spinnaker_camera_driver spinnaker_camera_nodes trajectory_follower trajectory_follower_nodes tvm_utility
```



