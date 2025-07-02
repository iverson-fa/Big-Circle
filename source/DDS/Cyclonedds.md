# CycloneDDS

- [官方网址](https://cyclonedds.io/)
- [最新版文档](https://cyclonedds.io/docs/cyclonedds/latest/)
- [Github](https://github.com/eclipse-cyclonedds/cyclonedds)

# 1 优点

- 跨平台
- 资源占用较小
- 确定性与实时性
- 兼容OMG-DDS规范，可以和Iceoryx配合使用

# 2 本地编译

```shell
mkdir CycloneDDS && cd CycloneDDS
git clone https://github.com/eclipse-cyclonedds/cyclonedds.git
mkdir -p HostInstall cyclonedds/Build
cd cyclonedds/Build
cmake .. -DENABLE_SSL=OFF -DCMAKE_INSTALL_PREFIX=$HOME/CycloneDDS/HostInstall
make && make install

## 本地测试

cd $Home/CycloneDDS//cyclonedds/examples/helloworld
mkdir Build && cd Build
cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/CycloneDDS/HostInstall
make
# terminal 1
./$Home/CycloneDDS//cyclonedds/examples/helloworld/HelloworldPublisher
# terminal 2
./$Home/CycloneDDS//cyclonedds/examples/helloworld/HelloworldSubscriber
```
