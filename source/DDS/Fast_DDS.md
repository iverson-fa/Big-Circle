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

### 3.1 编译Fast DDS-Gen时换源

```shell
mkdir -p ~/Fast-DDS/src
cd ~/Fast-DDS/src
git clone --recursive https://github.com/eProsima/Fast-DDS-Gen.git fastddsgen
cd fastddsgen
./gradlew assemble
```
如果出现类似如下的报错：

```shell
Could not unzip ... gradle-7.6-bin.zip
Reason: zip END header not found
Exception in thread "main" java.util.zip.ZipException: zip END header not found
```

则进行以下操作进行换源：

```shell
# 删除损坏缓存
$ rm -rf /root/.gradle/wrapper/dists/gradle-7.6-bin

# 可选：配置国内源（推荐）
$ vim gradle/wrapper/gradle-wrapper.properties
# 修改 distributionUrl 为镜像地址
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-7.6-bin.zip
# 重新构建
$ ./gradlew assemble
```

### 3.2 全局编译安装

```shell
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/ -DBUILD_SHARED_LIBS=ON
sudo cmake --build . --target install
```










