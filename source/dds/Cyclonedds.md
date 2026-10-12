# CycloneDDS

- [官方网址](https://cyclonedds.io/)
- [最新版文档](https://cyclonedds.io/docs/cyclonedds/latest/)
- [Github](https://github.com/eclipse-cyclonedds/cyclonedds)

## 1 优点

- 跨平台
- 资源占用较小
- 确定性与实时性
- 兼容OMG-DDS规范，可以和Iceoryx配合使用

## 2 编译

### 2.1 本地单独编译及测试

```shell
git clone https://github.com/eclipse-cyclonedds/cyclonedds.git
cd cyclonedds
## build_noshm install_noshm用于正常构建，build install用于构建共享内存为iceoryx
cmake -Bbuild_noshm -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=install_noshm -DBUILD_EXAMPLES=On -DCMAKE_PREFIX_PATH=~/iceoryx/install/
cmake --build build_noshm --config Release --target install

## 本地测试

cd $HOME/cyclonedds/examples/helloworld
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/cyclonedds/install_noshm
make
# terminal 1
$HOME/cyclonedds/examples/helloworld/build/HelloworldPublisher
# terminal 2
$HOME/cyclonedds/examples/helloworld/build/HelloworldSubscriber
```

### 2.2 使用Iceoryx进行本地编译

```shell
cd $HOME/cyclonedds/
cmake -Bbuild -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=install -DENABLE_ICEORYX=On -DBUILD_EXAMPLES=On -DCMAKE_PREFIX_PATH=~/iceoryx/install/
cmake --build build --config Release --target install
```

编译时会出现如下报错：

```shell
[ 98%] Building CXX object src/psmx_iox/CMakeFiles/psmx_iox.dir/src/psmx_iox_impl.cpp.o
/home/dafa/CycloneDDS/cyclonedds/src/psmx_iox/src/psmx_iox_impl.cpp:27:10: fatal error: iceoryx_hoofs/posix_wrapper/signal_watcher.hpp: 没有那个文件或目录
   27 | #include "iceoryx_hoofs/posix_wrapper/signal_watcher.hpp"
      |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
compilation terminated.
make[2]: *** [src/psmx_iox/CMakeFiles/psmx_iox.dir/build.make:76：src/psmx_iox/CMakeFiles/psmx_iox.dir/src/psmx_iox_impl.cpp.o] 错误 1
make[1]: *** [CMakeFiles/Makefile2:573：src/psmx_iox/CMakeFiles/psmx_iox.dir/all] 错误 2
make: *** [Makefile:156：all] 错误 2
```

根据 [shared memory exchange](https://cyclonedds.io/docs/cyclonedds/latest/shared_memory/shared_memory.html#shared-memory-exchange) 介绍，需要使用iceoryx的2.0版本，需要重新编译iceoryx

```shell
# 参考文档，安装依赖
sudo apt install cmake libacl1-dev libncurses5-dev pkg-config maven
cd $HOME/iceoryx
git checkout release_2.0
cmake -Bbuild -Hiceoryx_meta -DCMAKE_INSTALL_PREFIX=$HOME/iceoryx/Host2Install -DBUILD_SHARED_LIBS=ON
cd build
make && make install
# 重新编译Cyclonedds
rm -rf $HOME/cyclonedds/Build/*
cd $HOME/cyclonedds/Build
cmake .. -Bbuild -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=install -DENABLE_ICEORYX=On -DBUILD_EXAMPLES=On -DCMAKE_PREFIX_PATH=~/iceoryx/install/
make && make install
```
测试

```shell
cd $HOME/cyclonedds/examples/helloworld/
mkdir BuildIce && cd BuildIce
cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/Cyclonedds/HostInstall
make
# terminal 1
$HOME/cyclonedds/examples/helloworld/BuildIce/HelloworldPublisher
# terminal 1 output
=== [Publisher]  Waiting for a reader to be discovered ...
=== [Publisher]  Writing : Message (1, Hello World)
# terminal 2
$HOME/cyclonedds/examples/helloworld/BuildIce/HelloworldSubscriber
# terminal 2 output
=== [Subscriber] Waiting for a sample ...
=== [Subscriber] Received : Message (1, Hello World)
```

### 2.3 CycloneDDS交叉编译

```shell
mkdir -p $HOME/CycloneDDS/ARMInstall
rm -rf $HOME/CycloneDDS/cyclonedds/Build/*
cd $HOME/CycloneDDS/cyclonedds/Build
cmake .. -DENABLE_SSL=OFF -DCMAKE_INSTALL_PREFIX=$HOME/CycloneDDS/ARMInstall -DCMAKE_TOOLCHAIN_FILE=$HOME/CycloneDDS/arm.cmake
make && make install
```

测试

```shell
cd $HOME/CycloneDDS/cyclonedds/examples/helloworld/examples/helloworld
mkdir BuildARM && cd BuildARM
cmake .. -DCMAKE_PREFIX_PATH=$HOME/CycloneDDS/ARMInstall -DCMAKE_TOOLCHAIN_FILE=$HOME/CycloneDDS/arm.cmake
```

报错：

```shell
CMake Error at /home/dafa/CycloneDDS/ARMInstall/lib/cmake/CycloneDDS/idlc/Generate.cmake:41 (message):
  Unable to find IDLC C-backend library: cycloneddsidlc
Call Stack (most recent call first):
  CMakeLists.txt:24 (idlc_generate)
```

```shell
# 手动生成HelloWorldData.c文件
cd $HOME/CycloneDDS/cyclonedds/examples/helloworld
$HOME/CycloneDDS/HostInstall/bin/idlc HelloWorldData.idl
# 注释掉 CmakeLists.txt 的第24行，并将27、28行修改为
add_executable(HelloworldPublisher publisher.c HelloWorldData.c)
add_executable(HelloworldSubscriber subscriber.c HelloWorldData.c)
# 将最后两行修改为
target_link_libraries(HelloworldPublisher CycloneDDS::ddsc)
target_link_libraries(HelloworldSubscriber CycloneDDS::ddsc)
# 重新执行以下命令编译
cd BuildARM
rm -rf *
cmake .. -DCMAKE_PREFIX_PATH=$HOME/CycloneDDS/ARMInstall -DCMAKE_TOOLCHAIN_FILE=$HOME/CycloneDDS/arm.cmake
make -j$nproc
```

## 3 Jetson AGX Orin 上测试

### 3.1 **先编译安装 iceoryx**

```bash
cd /home/orin/iceoryx
cmake -Bbuild \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=install \
      -DROUDI_ENVIRONMENT=ON \
      -DBUILD_SHARED_LIBS=ON \
      -Hiceoryx_meta
cmake --build build --target install
```

安装后目录结构大致是：

```
/home/orin/iceoryx/install/
├── include/
├── lib/
├── share/
│   └── iceoryx_hoofs/cmake/iceoryx_hoofsConfig.cmake
```

### 3.2 **再编译 Cyclone DDS**（带 SHM 支持）

```bash
cd /home/orin/cyclonedds
cmake -Bbuild \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=install \
      -DENABLE_ICEORYX=On \
      -DBUILD_EXAMPLES=On \
      -DCMAKE_PREFIX_PATH=/home/orin/iceoryx/install
cmake --build build --target install
```

