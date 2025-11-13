# Fast DDS

## 1 介绍

eProsima Fast DDS 是由对象管理组（OMG）定义的 DDS（数据分发服务）规范的 C++ 实现。eProsima Fast DDS 库提供了一个应用程序编程接口（API）和一种通信协议，部署了以数据为中心的发布者-订阅者（DCPS）模型，旨在为实时系统建立高效可靠的信息分发。

eProsima Fast DDS 具有可预测性、可扩展性、灵活性，并在资源处理方面高效。为了满足这些要求，它使用类型化的接口，并基于一种多对多的分布式网络范式，该范式巧妙地实现了通信的发布者和订阅者之间的分离。eProsima Fast DDS 包括：

- [DDS API](https://fast-dds.docs.eprosima.com/en/stable/fastdds/dds_layer/dds_layer.html#dds-layer) 实现
- [Fast DDS-Gen](https://fast-dds.docs.eprosima.com/en/stable/fastddsgen/introduction/introduction.html#fastddsgen-intro)，一个用于连接类型化接口与中间件实现的生成工具
- 底层的 [RTPS](https://fast-dds.docs.eprosima.com/en/stable/fastdds/rtps_layer/rtps_layer.html#rtps-layer) 线协议实现

### 1.1 DDS API

DDS 采用的通信模型是一种多对多的单向数据交换，其中产生数据的应用将其发布到属于消费数据的应用的订阅者的本地缓存中。信息流由负责数据交换的实体之间建立的服务质量（QoS）策略进行调节。

作为以数据为中心的模型，DDS 基于“全局数据空间”的概念构建，该空间对所有感兴趣的应用程序开放。想要贡献信息的应用程序声明其意图成为发布者，而想要访问数据空间部分的应用程序则声明其意图成为订阅者。每当发布者向该空间发布新数据时，中间件会将信息传播给所有感兴趣的订阅者。

通信跨越域进行，即连接所有能够相互通信的分布式应用程序的隔离抽象平面。同一域内的实体才能交互，而订阅数据与发布数据的实体之间的匹配中介是Topic。Topic是不明确的标识符，将一个在域内唯一的名称与数据类型以及一组附加的数据特定 QoS 关联起来。

DDS 实体被建模为类或带类型的接口。后者意味着更高效的资源处理，因为执行前对数据类型的了解允许预先分配内存而不是动态分配。

![DDS 域内信息流动的概念图](https://fast-dds.docs.eprosima.com/en/stable/_images/DDS_concept.svg)

以上是 DDS 域内信息流动的概念图。只有属于同一域的实体才能通过匹配主题相互发现，并因此实现发布者和订阅者之间的数据交换。

### 1.2 RTPS Wire Protocol

eProsima Fast DDS 用于在标准网络上交换消息的协议是实时发布-订阅协议 Real-Time Publish-Subscribe protocol（RTPS），这是一种由 OMG 联盟定义和维护的 DDS 互操作性线路协议。该协议提供在 TCP/UDP/IP 等传输上的发布者-订阅者通信，并保证不同 DDS 实现之间的兼容性。

鉴于其发布-订阅的根源以及其规范设计用于满足 DDS 应用领域所处理的要求，RTPS 协议映射到许多 DDS 概念，因此是 DDS 实现的自然选择。所有 RTPS 核心实体都与一个 RTPS 域相关联，该域表示一个隔离的通信平面，其中端点相匹配。RTPS 协议中指定的实体与 DDS 实体一一对应，从而允许通信发生。

## 2 主要特性

- **Two API Layers** 两层 API。eProsima Fast DDS 包含一个专注于可用性的高层 DDS 合规层和一个提供对 RTPS 协议更细粒度访问的低层 RTPS 合规层。

- **Real-Time behaviour** 实时行为。eProsima Fast DDS 可以配置为提供实时功能，保证在指定的时间限制内做出响应。

- **Built-in Discovery Server** 内置发现服务器。eProsima Fast DDS 基于对现有发布者和订阅者的动态发现，并持续执行此任务，无需联系或设置任何服务器。然而，客户端-服务器发现以及其他发现范式也可以配置。

- **Sync and Async publication modes** 同步和异步发布模式。eProsima Fast DDS 支持同步和异步数据发布。

- **Best effort and reliable communication** 尽力而为和可靠通信。eProsima Fast DDS 支持在尽力而为通信协议（如 UDP）上实现可选的可靠通信模式。此外，另一种设置可靠通信的方式是使用我们的 TCP 传输。

- **Transport layers** 传输层。eProsima Fast DDS 实现了可插拔传输的架构。当前版本实现了五种传输：UDPv4、UDPv6、TCPv4、TCPv6 和 SHM（共享内存）。

- **Security** 安全性。eProsima Fast DDS 可以配置为提供安全通信。为此，它在三个级别实现了可插拔的安全性：远程参与者的身份验证、实体的访问控制以及数据的加密。

- **Statistics Module** 统计模块.eProsima Fast DDS 可以配置为收集并提供用户应用程序交换的数据信息。

- **Flow controllers** 流量控制器。我们支持用户可配置的流量控制器，可用于在特定条件下限制发送的数据量。

- **Plug-and-play Connectivity** 即插即用连接性。新应用程序和服务可以自动发现，并随时加入和离开网络，无需重新配置。

- **Scalability and Flexibility** 可扩展性和灵活性。DDS 基于全局数据空间的概念。中间件负责在发布者和订阅者之间传播信息。这保证了分布式网络能够适应重新配置，并扩展到大量实体。

- **Application Portability** 应用可移植性。DDS 规范包含特定平台的 IDL 映射，允许使用 DDS 的应用程序只需重新编译即可在多个 DDS 实现之间切换。

- **Extensibility** 可扩展性。eProsima Fast DDS 允许协议通过添加新服务进行扩展和增强，而不会破坏向后兼容性和互操作性。

- **Configurability and Modularity** 可配置性和模块化。eProsima Fast DDS 提供了一种直观的配置方式，可以通过代码或 XML 配置文件进行配置。模块化允许简单设备实现协议的子集，并仍然能够参与网络。

- **High performance** 高性能。eProsima Fast DDS 使用静态低级序列化库 Fast CDR，这是一个 C++库，根据 RTPS 规范中定义的标准 CDR 序列化机制进行序列化（参考数据封装章节）。

- **Easy to use** 易于使用。该项目自带开箱即用的示例 DDSHelloWorld，该示例使发布者和订阅者建立通信，展示了 eProsima Fast DDS 的部署方式。此外，用户还可以通过交互式演示 ShapesDemo 深入探索 DDS 世界。DDS 层和 RTPS 层的详细说明请参见 DDS 层和 RTPS 层部分。

- **Low resources consumption** 低资源消耗。eProsima Fast DDS：
    - 允许预分配资源，以最小化动态资源分配。
    - 避免使用unbounded resources。
    - 最小化数据复制的需求

- **Multi-platform** 跨平台。操作系统依赖被视为可插拔模块。用户可以使用 eProsima Fast DDS 库在其目标平台上轻松实现平台模块。默认情况下，该项目可以在 Linux、Windows 和 MacOS 上运行。

- **Free and Open Source** 免费且开源。Fast DDS 库、底层的 RTPS 库、生成工具、内部依赖（如 eProsima Fast CDR）和外部依赖（如 foonathan 库）都是免费且开源的。

## 3 安装编译

### 3.1 安装脚本


```shell
#!/bin/bash

# Fast DDS 完整安装脚本
# 所有组件安装到 /home/orin/fastdds/install

set -e  # 遇到错误立即退出

echo "=========================================="
echo "Fast DDS 完整安装脚本"
echo "安装目录: /home/orin/fastdds/install"
echo "=========================================="

# 定义目录变量
DDS_HOME="/home/orin/fastdds"
INSTALL_DIR="$DDS_HOME/install"

# 记录开始时间
START_TIME=$(date +%s)

# 创建目录结构（先判断是否存在）
echo "检查并创建目录结构..."
if [ ! -d "$DDS_HOME" ]; then
    echo "创建主目录: $DDS_HOME"
    mkdir -p $DDS_HOME
else
    echo "✓ 主目录已存在: $DDS_HOME"
fi

if [ ! -d "$INSTALL_DIR" ]; then
    echo "创建安装目录: $INSTALL_DIR"
    mkdir -p $INSTALL_DIR
else
    echo "✓ 安装目录已存在: $INSTALL_DIR"
fi
echo "✓ 目录结构检查完成"

# 函数：安装系统依赖
install_dependencies() {
    echo "步骤 1/5: 安装系统依赖..."

    # 更新系统包
    sudo apt update

    # 安装基础编译工具
    sudo apt install -y build-essential g++ python3-pip wget git curl \
        libasio-dev libtinyxml2-dev libssl-dev libp11-dev softhsm2 \
        libpython3-dev swig openjdk-11-jdk

    # 安装 Python 工具
    pip3 install -U colcon-common-extensions vcstool

    # 配置 SoftHSM
    sudo usermod -a -G softhsm orin 2>/dev/null || true

    echo "✓ 系统依赖安装完成"
}

# 函数：安装 CMake
install_cmake() {
    echo "步骤 2/5: 安装 CMake 3.24.3..."

    # 检查当前 CMake 版本
    # Ubuntu 默认版本为3.22.1
    if command -v cmake &> /dev/null; then
        CURRENT_VERSION=$(cmake --version | head -n1 | awk '{print $3}')
        echo "当前 CMake 版本: $CURRENT_VERSION"

        # 检查版本是否已满足要求
        REQUIRED_VERSION="3.24.3"
        if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$CURRENT_VERSION" | sort -V | head -n1)" = "$REQUIRED_VERSION" ]; then
            echo "✓ CMake 版本已满足要求，跳过安装"
            return 0
        fi
    fi

    # 下载并编译 CMake
    cd /tmp
    echo "下载 CMake 3.24.3..."
    wget https://github.com/Kitware/CMake/releases/download/v3.24.3/cmake-3.24.3.tar.gz
    tar -xzf cmake-3.24.3.tar.gz
    cd cmake-3.24.3

    echo "编译 CMake..."
    ./bootstrap --prefix=/usr/local --parallel=$(nproc)
    make -j$(nproc)
    sudo make install

    # 验证安装
    echo "新 CMake 版本:"
    /usr/local/bin/cmake --version

    # 清理临时文件
    cd /tmp
    rm -rf cmake-3.24.3*

    echo "✓ CMake 安装完成"
}

# 函数：克隆所有代码仓库
clone_repositories() {
    echo "步骤 3/5: 克隆所有代码仓库..."

    cd $DDS_HOME

    # 1. foonathan_memory_vendor
    echo "克隆 foonathan_memory_vendor..."
    if [ ! -d "foonathan_memory_vendor" ]; then
        git clone https://github.com/eProsima/foonathan_memory_vendor.git
    else
        echo "✓ foonathan_memory_vendor 已存在，跳过"
    fi

    # 2. Fast-CDR
    echo "克隆 Fast-CDR..."
    if [ ! -d "Fast-CDR" ]; then
        git clone https://github.com/eProsima/Fast-CDR.git
    else
        echo "✓ Fast-CDR 已存在，跳过"
    fi

    # 3. Fast-DDS
    echo "克隆 Fast-DDS..."
    if [ ! -d "Fast-DDS" ]; then
        git clone https://github.com/eProsima/Fast-DDS.git
    else
        echo "✓ Fast-DDS 已存在，跳过"
    fi

    # 4. Fast-DDS-Python
    echo "克隆 Fast-DDS-Python..."
    if [ ! -d "Fast-DDS-python" ]; then
        git clone https://github.com/eProsima/Fast-DDS-python.git
    else
        echo "✓ Fast-DDS-python 已存在，跳过"
    fi

    # 5. Fast-DDS-Gen
    echo "克隆 Fast-DDS-Gen..."
    cd Fast-DDS/src
    if [ ! -d "fastddsgen" ]; then
        git clone --recursive https://github.com/eProsima/Fast-DDS-Gen.git fastddsgen
    else
        echo "✓ Fast-DDS-Gen 已存在，跳过"
    fi

    echo "✓ 所有代码仓库克隆完成"
}

# 函数：编译所有组件
build_components() {
    echo "步骤 4/5: 编译所有组件..."

    # 设置编译选项
    export MAKEFLAGS="-j$(nproc)"
    export CMAKE_PREFIX_PATH="$INSTALL_DIR"

    # 1. 编译 foonathan_memory_vendor
    echo "编译 foonathan_memory_vendor..."
    cd $DDS_HOME/foonathan_memory_vendor
    cmake -Bbuild \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_BUILD_TYPE=Release
    cmake --build build --target install
    echo "✓ foonathan_memory_vendor 编译完成"

    # 2. 编译 Fast-CDR
    echo "编译 Fast-CDR..."
    cd $DDS_HOME/Fast-CDR
    cmake -Bbuild \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
        -DCMAKE_BUILD_TYPE=Release
    cmake --build build --target install
    echo "✓ Fast-CDR 编译完成"

    # 3. 编译 Fast-DDS
    echo "编译 Fast-DDS..."
    cd $DDS_HOME/Fast-DDS
    cmake -Bbuild \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
        -DCMAKE_BUILD_TYPE=Release
    cmake --build build --target install
    echo "✓ Fast-DDS 编译完成"

    # 4. 编译 Fast-DDS-Python
    echo "编译 Fast-DDS-Python..."
    cd $DDS_HOME/Fast-DDS-python/fastdds_python
    cmake -Bbuild \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
        -DCMAKE_BUILD_TYPE=Release
    cmake --build build --target install
    echo "✓ Fast-DDS-Python 编译完成"

    # 5. 编译 Fast-DDS-Gen
    echo "编译 Fast-DDS-Gen..."
    cd $DDS_HOME/Fast-DDS/src/fastddsgen
    ./gradlew assemble
    echo "✓ Fast-DDS-Gen 编译完成"

    echo "✓ 所有组件编译完成"
}

# 函数：配置环境变量
setup_environment() {
    echo "步骤 5/5: 配置系统环境..."

    # 确保 .bash_aliases 文件存在
    touch /home/orin/.bash_aliases


    # 添加环境变量配置到 .bash_aliases
    echo "" >> /home/orin/.bash_aliases
    echo "# ==========================================" >> /home/orin/.bash_aliases
    echo "# Fast DDS Environment Configuration" >> /home/orin/.bash_aliases
    echo "# Generated by DDS installation script" >> /home/orin/.bash_aliases
    echo "# ==========================================" >> /home/orin/.bash_aliases
    echo "export LD_LIBRARY_PATH=\"$INSTALL_DIR/lib:\$LD_LIBRARY_PATH\"" >> /home/orin/.bash_aliases
    echo "export PATH=\"$DDS_HOME/Fast-DDS/src/fastddsgen/scripts:\$PATH\"" >> /home/orin/.bash_aliases

    # 添加 pkg-config 路径
    # if [ -d "$INSTALL_DIR/lib/pkgconfig" ]; then
    #     echo "export PKG_CONFIG_PATH=\"$INSTALL_DIR/lib/pkgconfig:\$PKG_CONFIG_PATH\"" >> /home/orin/.bash_aliases
    # fi

    echo "# ==========================================" >> /home/orin/.bash_aliases
    source /home/orin/.bashrc
    echo "✓ 环境变量已添加到 /home/orin/.bash_aliases"
}

install_dependencies
install_cmake
clone_repositories
build_components
setup_environment
```

要在系统范围内而不是本地安装 eProsima Fast DDS，删除 Fast-CDR 和 Fast-DDS 配置步骤中出现的所有标志，并将 foonathan_memory_vendor 配置步骤中的第一个标志更改为以下内容：

```shell
-DCMAKE_INSTALL_PREFIX=/usr/local/ -DBUILD_SHARED_LIBS=ON
```










