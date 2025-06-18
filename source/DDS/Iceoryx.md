# Iceoryx

# 1 环境搭建

## 1.1 cmake

下载指定版本的cmake，编译要求不低于3.16

- [cmake v3.28.1 github assets](https://github.com/Kitware/CMake/releases/tag/v3.28.1)

```shell
# 安装cmake
chmod +x cmake-3.28.1-linux-x86_64.sh
./cmake-3.28.1-linux-x86_64.sh
cd cmake-3.28.1-linux-x86_64/bin/
sudo ln -s $HOME/cmake-3.28.1-linux-x86_64/bin/cmake /usr/bin/cmake
cmake --version
```

## 1.2 编译iceoryx

```shell
sudo apt install gcc g++ cmake libacl1-dev libncurses5-dev pkg-config
cd
mkdir -p Iceoryx/HostInstall
cd Iceoryx
git clone https://github.com/eclipse-iceoryx/iceoryx.git
cd iceoryx
mkdir build
cmake -Bbuild -Hiceoryx_meta -DCMAKE_PREFIX_PATH=$HOME/Iceoryx/HostInstall
```