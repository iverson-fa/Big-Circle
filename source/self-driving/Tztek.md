# 天准J6域控

## 1 ROS2 环境配置

```shell
├── deps.tar.gz
├── humble-arm-20240410.221244.tar.gz
└── python-3.10.12.tar.gz
```
分别解压，得到

```shell
├── deps
├── humble
└── Python-3.10.12
```

执行以下脚本配置ROS2环境

```shell
#!/bin/bash
ros_distro=$(printenv ROS_DISTRO)

# 检查Python版本
python_version=$(python3 --version | awk '{print $2}')
if [ "$python_version" != "3.10.12" ]; then
    echo "Python版本不是3.10.12，正在修改..."
    rm -rf /usr/bin/python3
    rm -rf /usr/bin/python
    rm -rf /usr/lib/libpython3.10.so.1.0
    ln -s /userdata/nvme/zjf/ros2/Python-3.10.12/install/bin/python3 /usr/bin/python
    ln -s /userdata/nvme/zjf/ros2/Python-3.10.12/install/bin/python3 /usr/bin/python3
    ln -s /userdata/nvme/zjf/ros2/Python-3.10.12/install/lib/libpython3.10.so.1.0 /usr/lib/libpython3.10.so.1.0
else
    # 打印Python版本
    echo "Python  版本: $(python --version)"
    echo "Python3 版本: $(python3 --version)"
fi

# 检查ROS版本
if [ ! -d "/opt/ros/humble" ]; then
    echo "/opt/ros下没有humble，正在创建..."
    mkdir -p /opt/ros
    ln -s /userdata/nvme/zjf/ros2/humble /opt/ros/humble
    source /opt/ros/humble/setup.bash
    if [ "$ros_distri" = "humble" ]; then
        echo "ROS版本已设置为 : $ros_distro."
    else
        echo "ROS版本设置失败."
    fi
else
    source /opt/ros/humble/setup.bash
    echo "检查ROS版本..."
    if [ "$ros_distro" = "humble" ]; then
	echo "ROS 版本: $ros_distro"
    else
	echo "ROS 版本: $ros_distro"
    fi
fi

# 检查并添加环境变量和source命令到~/.bashrc
if ! grep -q 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/userdata/nvme/zjf/ros2/deps' ~/.bashrc; then
    echo 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/userdata/nvme/zjf/ros2/deps' >> ~/.bashrc
    source ~/.bashrc
fi
if ! grep -q 'source /opt/ros/humble/setup.bash' ~/.bashrc; then
    echo 'source /opt/ros/humble/setup.bash' >> ~/.bashrc
    source ~/.bashrc
fi
    source ~/.bashrc
echo "环境变量和source命令已检查并添加到~/.bashrc."
```

**查找和添加python依赖的package**

如果报错缺少依赖package，在安装了相同python版本的arm平台上，使用命令pip show [package名]查找其安装路径（Location），例如查找numpy：pip show numpy，提示其Location为/usr/lib/python3/dist-packages。
然后将package拷贝到J6的python安装路径的lib/python3.10/site-packages/路径下。