# 共享内存

## 1 Docs Index

- [Agnocast](https://github.com/autowarefoundation/agnocast)

## 2 Agnocast

### 2.1 安装

按照setup安装会报错：

```shell
$ rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO
ERROR: the following packages/stacks could not have their rosdep keys resolved
to system dependencies:
agnocastlib: Cannot locate rosdep definition for [glog]
```

变为执行以下命令（参考`.github/workflows/build-and-test-agnocastlib-heaphook.yaml`）

```bash
rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO --skip-keys glog
sudo apt install libgoogle-glog-dev
# 安装rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y   
# 如果不是1.75版本，执行以下
source "$HOME/.cargo/env" && rustup toolchain install 1.75.0 && rustup default 1.75.0 && rustup component add clippy rustfmt 
```
