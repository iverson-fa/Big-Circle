# 01 DevelopmentEnvironment

## 1 使用 ADE 安装

ADE 开发环境是模块化 [Docker ](https://docs.docker.com/)工具，可确保  一个项目中的所有开发人员都有一个 **共同的、一致的开发环境** 。安装前需要的环境：

- Docker 19.03 或更新的版本
- nvidia-docker2
- [NVIDIA Nsight Systems](https://docs.nvidia.com/nsight-systems/InstallationGuide/index.html#system-requirements)

安装 ADE

```shell
# Jetson
wget https://gitlab.com/ApexAI/ade-cli/-/jobs/1859684349/artifacts/raw/dist/ade+aarch64
# X86
wget https://gitlab.com/ApexAI/ade-cli/uploads/f6c47dc34cffbe90ca197e00098bdd3f/ade+x86_64
mv ade+x86_64 ade
chmod +x ade
sudo mv ade /usr/local/bin
cd /usr/local/bin 
./ade --version # latest-version:4.4.0
```

## 2 测试环境部署

```bash
cd
mkdir adehome
cd adehome
touch .adehome
git clone -b foxy https://gitee.com/qingcen/ros_ex.git
cd ros_ex
source .aderc
ade start --enter
```

`.aderc` 是容器环境的配置文件，可以修改容器的相关参数。

```bash
# in ADE
cd ros_ex
colon build
source install/setup.bash
nsys profile -o ros2_test --sampling-trigger=perf ros2 run examples_rclcpp_minimal_publisher publisher_member_function
```

注：需要满足 Nsight Sy

