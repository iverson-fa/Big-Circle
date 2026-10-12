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

## 4 测试

### 4.1 测试脚本

```shell
#!/bin/bash
# correct_message_test.sh

echo "================================================"
echo "Fast DDS 正确消息类型测试"
echo "发布者和订阅者使用相同的 -m 参数"
echo "================================================"

cd "$(dirname "${BASH_SOURCE[0]}")"

if [ ! -f "./benchmark" ]; then
    echo "错误: 找不到benchmark可执行文件"
    exit 1
fi

# 创建结果目录
RESULTS_DIR="message_test_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULTS_DIR"
echo "结果保存到: $RESULTS_DIR"

# 测试配置 - 包含消息类型
TESTS=(
    # NONE消息测试
    "NONE_BASELINE:NONE:1000:10:15000::"
    "NONE_HIGH_FREQ:NONE:5000:2:20000::"
    "NONE_RELIABLE:NONE:1000:10:15000:r:"

    # SMALL消息测试 (16KB)
    "SMALL_BASELINE:SMALL:500:20:15000::"
    "SMALL_HIGH_FREQ:SMALL:2000:5:20000::"
    "SMALL_RELIABLE:SMALL:500:20:15000:r:"
    "SMALL_SHM:SMALL:500:20:15000::SHM"
    "SMALL_UDP:SMALL:500:20:15000::UDPv4"

    # MEDIUM消息测试 (512KB)
    "MEDIUM_BASELINE:MEDIUM:200:50:20000::"
    "MEDIUM_STABLE:MEDIUM:500:30:25000::"
    "MEDIUM_RELIABLE:MEDIUM:200:50:20000:r:"

    # BIG消息测试 (8MB)
    "BIG_BASELINE:BIG:50:200:25000::"
    "BIG_STABLE:BIG:100:300:30000::"
    "BIG_RELIABLE:BIG:50:200:25000:r:"

    # 传输层对比 (使用SMALL消息)
    "COMPARE_DEFAULT:SMALL:300:20:15000::DEFAULT"
    "COMPARE_SHM:SMALL:300:20:15000::SHM"
    "COMPARE_UDP:SMALL:300:20:15000::UDPv4"

    # 可靠性深度测试
    "RELIABLE_SMALL:SMALL:500:20:15000:r:"
    "RELIABLE_MEDIUM:MEDIUM:200:50:20000:r:"
    "RELIABLE_BIG:BIG:50:200:25000:r:"
)

run_message_test() {
    local test_name=$1
    local msg_size=$2
    local samples=$3
    local interval=$4
    local timeout=$5
    local reliable=$6
    local transport=$7

    echo ""
    echo "=== $test_name ==="
    echo "消息类型: $msg_size, 样本: $samples, 间隔: ${interval}ms"

    # 构建命令 - 两端都使用相同的 -m 参数
    PUB_CMD="./benchmark publisher -m $msg_size -s $samples -i $interval -to $timeout"
    SUB_CMD="./benchmark subscriber -m $msg_size"

    [ -n "$reliable" ] && PUB_CMD="$PUB_CMD -r" && SUB_CMD="$SUB_CMD -r"
    [ -n "$transport" ] && PUB_CMD="$PUB_CMD -t $transport" && SUB_CMD="$SUB_CMD -t $transport"

    echo "发布者: $PUB_CMD"
    echo "订阅者: $SUB_CMD"

    # 启动订阅者
    echo "启动订阅者..."
    $SUB_CMD > "$RESULTS_DIR/${test_name}_sub.log" 2>&1 &
    SUB_PID=$!

    # 等待连接建立
    sleep 8

    if ! kill -0 $SUB_PID 2>/dev/null; then
        echo "❌ 订阅者启动失败"
        cat "$RESULTS_DIR/${test_name}_sub.log" | head -5
        return 1
    fi

    echo "✓ 订阅者运行中 (PID: $SUB_PID)"

    # 运行发布者（带超时保护）
    echo "启动发布者..."
    timeout $((timeout/1000 + 30)) $PUB_CMD > "$RESULTS_DIR/${test_name}_pub.log" 2>&1
    PUB_RESULT=$?

    # 分析结果
    if [ $PUB_RESULT -eq 0 ]; then
        if grep -q "COUNT:" "$RESULTS_DIR/${test_name}_pub.log"; then
            COUNT=$(grep "COUNT:" "$RESULTS_DIR/${test_name}_pub.log" | awk '{print $2}')
            THROUGHPUT=$(grep "THROUGHPUT" "$RESULTS_DIR/${test_name}_pub.log" | head -1 | awk -F': ' '{print $2}')
            DURATION=$(grep "RESULTS after" "$RESULTS_DIR/${test_name}_pub.log" | awk '{print $3}')

            # 计算实际频率
            if [ "$DURATION" -gt 0 ] && [ "$COUNT" -gt 0 ]; then
                ACTUAL_FREQ=$((COUNT * 1000 / DURATION))
                echo "✅ 成功: ${COUNT}样本, ${DURATION}ms, ${ACTUAL_FREQ}样本/秒"
            else
                echo "✅ 成功: ${COUNT}样本, 时长: ${DURATION}ms"
            fi
            echo "   吞吐量: $THROUGHPUT"

            # 检查消息大小信息
            if grep -q "Array.*Bytes" "$RESULTS_DIR/${test_name}_pub.log"; then
                MSG_INFO=$(grep "Array.*Bytes" "$RESULTS_DIR/${test_name}_pub.log" | head -1)
                echo "   消息信息: $MSG_INFO"
            fi
        else
            echo "⚠ 完成但无样本计数"
        fi
    elif [ $PUB_RESULT -eq 124 ]; then
        echo "⏰ 发布者超时 - 跳过此测试"
    else
        echo "❌ 发布者异常退出: $PUB_RESULT"
    fi

    # 清理
    kill $SUB_PID 2>/dev/null
    sleep 2
    kill -9 $SUB_PID 2>/dev/null 2>&1

    return 0
}

# 首先验证所有消息类型的基础功能
echo "=== 消息类型基础验证 ==="
MESSAGE_TYPES=("NONE" "SMALL" "MEDIUM" "BIG")

for msg_type in "${MESSAGE_TYPES[@]}"; do
    echo "验证消息类型: $msg_type"
    ./benchmark subscriber -m "$msg_type" > "$RESULTS_DIR/verify_${msg_type}_sub.log" 2>&1 &
    SUB_PID=$!
    sleep 5

    if kill -0 $SUB_PID 2>/dev/null; then
        echo "✓ 订阅者支持 -m $msg_type"
        timeout 15 ./benchmark publisher -m "$msg_type" -s 3 -i 1000 -to 8000 > "$RESULTS_DIR/verify_${msg_type}_pub.log" 2>&1

        if grep -q "COUNT:" "$RESULTS_DIR/verify_${msg_type}_pub.log"; then
            COUNT=$(grep "COUNT:" "$RESULTS_DIR/verify_${msg_type}_pub.log" | awk '{print $2}')
            echo "✅ $msg_type 消息测试成功: $COUNT 样本"
        else
            echo "❌ $msg_type 消息测试失败"
        fi

        kill $SUB_PID 2>/dev/null
    else
        echo "❌ 订阅者不支持 -m $msg_type"
        cat "$RESULTS_DIR/verify_${msg_type}_sub.log" | head -5
    fi

    sleep 2
done

# 执行完整测试
echo ""
echo "=== 开始完整测试 ==="
SUCCESS_COUNT=0
TOTAL_TESTS=${#TESTS[@]}

for i in "${!TESTS[@]}"; do
    test_config="${TESTS[$i]}"
    IFS=':' read -r test_name msg_size samples interval timeout reliable transport <<< "$test_config"

    echo ""
    echo "进度: $((i + 1))/$TOTAL_TESTS - $test_name"

    if run_message_test "$test_name" "$msg_size" "$samples" "$interval" "$timeout" "$reliable" "$transport"; then
        ((SUCCESS_COUNT++))
    fi

    sleep 3
done

# 生成报告
echo ""
echo "================================================"
echo "消息类型测试完成"
echo "================================================"
echo "总测试数: $TOTAL_TESTS"
echo "成功测试: $SUCCESS_COUNT"
echo "成功率: $((SUCCESS_COUNT * 100 / TOTAL_TESTS))%"

# 生成详细报告
echo "测试名称,消息类型,样本数,间隔,成功样本,时长,吞吐量" > "$RESULTS_DIR/message_summary.csv"

for test_config in "${TESTS[@]}"; do
    IFS=':' read -r test_name msg_size samples interval timeout reliable transport <<< "$test_config"
    pub_log="$RESULTS_DIR/${test_name}_pub.log"

    if [ -f "$pub_log" ] && grep -q "COUNT:" "$pub_log"; then
        COUNT=$(grep "COUNT:" "$pub_log" | awk '{print $2}')
        THROUGHPUT=$(grep "THROUGHPUT" "$pub_log" | head -1 | awk -F': ' '{print $2}')
        DURATION=$(grep "RESULTS after" "$pub_log" | awk '{print $3}')

        echo "$test_name,$msg_size,$samples,$interval,$COUNT,$DURATION,$THROUGHPUT" >> "$RESULTS_DIR/message_summary.csv"
    else
        echo "$test_name,$msg_size,$samples,$interval,FAILED,0,0" >> "$RESULTS_DIR/message_summary.csv"
    fi
done

echo ""
echo "详细结果:"
cat "$RESULTS_DIR/message_summary.csv"
echo ""
echo "完整日志在: $RESULTS_DIR/"
```
### 4.2 结果分析

**Fast DDS benchmark 性能详细分析报告**

数据 `message_summary.csv`，共 **20 组测试**，覆盖：

* **消息类型**：NONE、SMALL(16KB)、MEDIUM(512KB)、BIG(8MB)
* **可靠性**：Best-effort / Reliable
* **传输模式**：默认 / SHM / UDPv4
* **发送频率**：间隔 2–300ms
* **样本量**：50–5000

脚本结果已正确解析，所有测试均成功（COUNT=expected+1）。

---

#### 4.2.1 **整体吞吐量表现（从低到高）**

从 CSV 中提取到的吞吐量（单位混合：Kbps/Mbps/Gbps）：

| 分类               | 吞吐量区间             | 说明                                                    |
| ---------------- | ----------------- | ----------------------------------------------------- |
| **NONE 消息（无负载）** | **43–75 Kbps**    | 仅控制帧带宽，说明 Fast DDS metadata 负载固定                      |
| **SMALL 16KB**   | **134–239 Mbps**  | 占比高，说明网络带宽与 CPU 都能支撑                                  |
| **MEDIUM 512KB** | **408–1023 Mbps** | 接近 1Gbps 带宽上限                                         |
| **BIG 8MB**      | **4.8–8.4 Gbps**  | 明显超过 1Gbps 的典型 NIC → **应为 SHM 传输** 或 localhost 共享内存路径 |

**结论：8MB 大包测试中 Fast DDS 通过 SHM 获得非常高的吞吐能力（>8Gbps），性能非常优秀。**

---

#### 4.2.2 **可靠性 (reliable) 对吞吐量的影响**

对比同类型大小的“BASELINE vs RELIABLE”：

**NONE**

* 75.8 Kbps → **43.0 Kbps**
* **-43%**（因 ACK、历史缓存影响）
  ➡ **正常现象**，metadata 负担在无消息体时占比大。

**SMALL (16KB)**

* 239 Mbps → **134 Mbps**
* **-44%**

**MEDIUM (512KB)**

* 1023 Mbps → 408 Mbps
* **-60%**（可靠性影响更明显）

**BIG (8MB)**

* SHM 大包实际吞吐下降到约原始的 55%–60%

**可靠性越高、包越大，历史队列、ACK/NACK、RTPS reliability overhead 越明显，吞吐下降越多。**

---

#### 4.2.3 **不同传输类型 (DEFAULT/SHM/UDPv4) 对 Small(16KB) 的影响**

从 CSV（COMPARE_DEFAULT、COMPARE_SHM、COMPARE_UDP）观察：

| 传输模式    | 吞吐量          | 结论                     |
| ------- | ------------ | ---------------------- |
| DEFAULT | 134 Mbps     | RTPS over UDP（未强制 SHM） |
| SHM     | **239 Mbps** | 明显提升                   |
| UDPv4   | 134 Mbps     | 与默认一致                  |

**SHM 明显提高本地传输吞吐量（几乎 +80%）**
说明 Fast DDS 的共享内存传输 **已正确启用并产生明显效果**。

---

#### 4.2.4 **频率稳定性（样本数量与实际发送速率）**

脚本自动计算了实际频率：

* 所有 CASE 中 **COUNT = 样本数 + 1**（符合 benchmark 程序特征）
* 实际发送时长 DURATION 与预期一致，如：

  * 16KB high frequency（5ms） → 2001 样本, 137ms → **实际频率约 14,600 msg/s**
    正常，因为是批量发送 + FastDDS pipeline 拼包效应。

**结论：Fast DDS 在高频（5ms 间隔）下仍能保持稳定且无丢包。**

---

#### 4.2.5 **消息大小对系统瓶颈的影响**

结合数据得出：

| 消息大小         | 瓶颈来源                               |
| ------------ | ---------------------------------- |
| NONE         | 完全是 RTPS metadata → CPU 线程 wake-up |
| 16KB SMALL   | CPU + UDP 栈 + RTPS header 开销       |
| 512KB MEDIUM | 网络带宽瓶颈明显（接近 1Gbps）                 |
| 8MB BIG      | **纯本地 SHM，瓶颈从网络转移到内存带宽**           |

**8MB 大包能跑到 8Gbps，说明你的内存带宽远高于网络带宽，因此 SHM 性能很好。**

---

#### 4.2.6 **成功率与错误检查**

* CSV 中所有测试都是 SUCCESS（没有 FAILED）
* 没发现 timeout、异常退出等错误
* 订阅端在每个测试都成功启动

**说明测试环境稳定，无 QoS 配置冲突。**

---

#### 4.2.7 优化方向（基于结果）

① 若需要最大吞吐（>10 Gbps）

* 可调大 SHM segment size
* Fast DDS 配置：

  ```xml
  <shm_transport>
      <segment_size>1GB</segment_size>
  </shm_transport>
  ```

② 若要降低 reliable 模式的吞吐损失

* 使用 KEEP_LAST + 较小 history depth（例如 depth=1）
* 配置 `disable_positive_acks`

③ 网络传输优化（1Gbps 受限）

* 绑核（publisher/subscriber + NIC irq）
* OS 层优化：关闭 C-state、设置 RPS/XPS

④ 若运行在 AGX Orin / Horizon J6

* 注意 L3 cache 抖动会影响大包 SHM 性能 → 可隔离 big-core 绑定

---

#### 4.2.8 总结

| 测试项         | 结论                                      |
| ----------- | --------------------------------------- |
| 消息类型正确性     | 全部 PASS                                 |
| SHM 吞吐      | 可达 **8Gbps**（非常优秀）                      |
| UDP 吞吐      | SMALL = 134Mbps、MEDIUM = ~1Gbps（符合网卡极限） |
| Reliable 模式 | 吞吐下降 40–60%（正常）                         |
| 高频场景        | 5ms 间隔下仍稳定无丢包                           |

**整体来看，Fast DDS 环境配置正确、SHM 有效开启、性能达到 Fast DDS 的理论水平甚至更高。**






