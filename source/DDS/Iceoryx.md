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
rm -rf pkgconfig
# 编译
cd $HOME/Iceoryx/iceoryx
cmake -Bbuild -Hiceoryx_meta \
  -DCMAKE_INSTALL_PREFIX=$HOME/Iceoryx/ARMInstall \
  -DCMAKE_PREFIX_PATH=$HOME/Iceoryx/ARMInstall -DCMAKE_TOOLCHAIN_FILE=$HOME/Iceoryx/arm.cmake -DBUILD_SHARED_LIBS=ON
cd build
make && make install
```
### 1.5 配置文件

一般位于安装目录的etc目录下，我在jetson上iceoryx的安装目录为`/home/orin/iceoryx`，配置文件目录为`/home/orin/iceoryx/install/etc/roudi_config_example.toml`。

原始文件如下：

```shell
# Adapt this config to your needs and rename it to e.g. roudi_config.toml
[general]
version = 1

[[segment]]

[[segment.mempool]]
size = 128
count = 10000

[[segment.mempool]]
size = 1024
count = 5000

[[segment.mempool]]
size = 16384
count = 1000

[[segment.mempool]]
size = 131072
count = 200

[[segment.mempool]]
size = 524288
count = 50

[[segment.mempool]]
size = 1048576
count = 30

[[segment.mempool]]
size = 4194304
count = 10
```

当前用户名是 `orin`，所以修改配置文件：

```shell
# /home/orin/iceoryx/config/roudi_config.toml
[general]
version = 1

[[segment]]
shared_memory_segment_id = 1
memory_size = 268435456  # 256MB
reader = "orin"
writer = "orin"

[[segment.mempool]]
size = 128
count = 2000

[[segment.mempool]]
size = 1024
count = 1500

[[segment.mempool]]
size = 8192
count = 800

[[segment.mempool]]
size = 65536
count = 200

[[segment.mempool]]
size = 1048576
count = 50

[[segment.mempool]]
size = 4194304
count = 20

[[process]]
name = "cyclonedds"
capabilities = "SHM"
```

> 注意：`reader` 和 `writer` 字段必须是系统中存在的组名。
> 可以执行：
>
> ```bash
> groups orin
> ```
>
> 查看 `orin` 用户属于哪些组。

也可以直接使用 `root` 权限启动。因为 root 用户有权限创建 `/dev/shm/iox_*` 文件，无需依赖组名解析。

使用指定配置文件启动：

```bash
/home/orin/iceoryx/install/bin/iox-roudi --config /home/orin/iceoryx/config/roudi_config.toml -m off
```
其中，`-m off` 是监控模式设置，`off`表示禁用监控功能，如果设置为`on`，RouDi会监控发布者/订阅者的运行状态。

---

额外说明

Iceoryx 在创建共享内存时，调用了内部 POSIX 权限接口：

```cpp
shm_open(name.c_str(), O_CREAT | O_EXCL | O_RDWR, permissions)
```

其中 `permissions` 来源于配置文件指定的 group 权限。
如果 group 查找失败（`getgrnam("user")`），则会返回 `ENOENT`，并导致整个创建过程失败。

---

正确启动时日志应类似：

```shell
Log level set to: [Warning]
Reserving 66048512 bytes in the shared memory [iceoryx_mgmt]
[ Reserving shared memory successful ]
Reserving 157950480 bytes in the shared memory [orin]
[ Reserving shared memory successful ]
RouDi is ready for clients
```
以上日志说明，Iceoryx 内部管理段约 63 MB，用户数据段约 150 MB，可用于 CycloneDDS SHM 数据传输。