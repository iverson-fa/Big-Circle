# Iceoryx

## 1 环境搭建

### 1.1 cmake

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

### 1.2 iceoryx本地编译

```shell
sudo apt install gcc g++ cmake libacl1-dev libncurses5-dev pkg-config
cd
mkdir -p Iceoryx/HostInstall
cd Iceoryx
git clone https://github.com/eclipse-iceoryx/iceoryx.git
cd iceoryx
mkdir build
# 构建动态库
cmake -Bbuild -Hiceoryx_meta -DCMAKE_PREFIX_PATH=$HOME/Iceoryx/HostInstall -DCMAKE_INSTALL_PREFIX=$HOME/Iceoryx/HostInstall -DBUILD_SHARED_LIBS=ON
cd build
make -j$(nproc)
make install
```

在`$HOME/Iceoryx/HostInstall/bin`目录下有生成的编译二进制文件`iox-roudi`，运行时会有如下提示：

```shell
2025-06-20 16:24:49.803 [Info ]: No config file provided and also not found at '/etc/iceoryx/roudi_config.toml'. Falling back to built-in config.
2025-06-20 16:24:49.898 [Info ]: Resource prefix: iox1
2025-06-20 16:24:49.898 [Info ]: Domain ID: 0
2025-06-20 16:24:49.898 [Info ]: RouDi is ready for clients
```
### 1.3 运行示例程序

```shell
cd $HOME/Iceoryx/iceoryx/iceoryx_examples/icehello/
mkdir build && cd build
cmake .. -DCMAKE_PREFIX_PATH=$HOME/Iceoryx/HostInstall
make
```

```shell
# terminal 1
$HOME/Iceoryx/HostInstall/bin/iox-roudi
# terminal 2
$HOME/Iceoryx/iceoryx/iceoryx_examples/icehello/build/iox-cpp-publisher-helloworld
# terminal 3
$HOME/Iceoryx/iceoryx/iceoryx_examples/icehello/build/iox-cpp-subscriber-helloworld
```

### 1.4 交叉编译iceoryx

```shell
mkdir -p $HOME/Iceoryx/ARMInstall
# 安装树莓派的编译器
sudo apt install gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf
# 查看是否安装成功
arm-linux-gnueabihf-g++ --version
arm-linux-gnueabihf-gcc --version
# 清理本地编译文件
rm -rf $HOME/Iceoryx/iceoryx/build/*
```

生成`arm.cmake`

```bash
touch $HOME/Iceoryx/arm.cmake
```

内容如下：

```shell
SET(CMAKE_SYSTEM_NAME Linux)

SET(CMAKE_C_COMPILER "/usr/bin/arm-linux-gnueabihf-gcc")
SET(CMAKE_CXX_COMPILER "/usr/bin/arm-linux-gnueabihf-g++")

SET(CMAKE_CXX_FLAGS "-I /home/dafa/Iceoryx/acl/include -L /home/dafa/Iceoryx/acl/lib")
```

安装编译`acl`与`attr`，**其他 arm 环境，注意替换CC**

```shell
mkdir -p $HOME/Iceoryx/ACL/acl
cd $HOME/Iceoryx/ACL
wget https://download.savannah.gnu.org/releases/acl/acl-2.3.1.tar.gz
wget https://download.savannah.gnu.org/releases/attr/attr-2.5.1.tar.xz
tar xfv attr-2.5.1.tar.xz
tar xfv acl-2.3.1.tar.gz
cd attr-2.5.1
./configure CC=/usr/bin/arm-linux-gnueabihf-gcc --host=arm-linux-gnueabihf --target=arm-linux --prefix=$HOME/Iceoryx/ACL/acl
make
make install
cd ../acl-2.3.1
export C_INCLUDE_PATH=$HOME/Iceoryx/ACL/acl/include:$C_INCLUDE_PATH
export LIBRARY_PATH=$HOME/Iceoryx/ACL/acl/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=$HOME/Iceoryx/ACL/acl/lib:$LD_LIBRARY_PATH
./configure CC=/usr/bin/arm-linux-gnueabihf-gcc --host=arm-linux-gnueabihf --target=arm-linux --prefix=$HOME/Iceoryx/ACL/acl LDFLAGS="-L/home/dafa/Iceoryx/ACL/acl/lib"
make
make install
# 将编译文件单独拿出
cd $HOME/Iceoryx/
mkdir acl
cp -r ACL/acl/lib ACL/acl/include acl/
# 删除所有动态库
cd acl/lib
rm -rf *.so*
# 编译
cd $HOME/Iceoryx/iceoryx
cmake -Bbuild -Hiceoryx_meta \
  -DCMAKE_INSTALL_PREFIX=$HOME/Iceoryx/ARMInstall \
  -DCMAKE_PREFIX_PATH=$HOME/Iceoryx/ARMInstall -DBUILD_SHARED_LIBS=ON

```