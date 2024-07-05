# Camera

## 1 Argus

安装

```bash
sudo apt update
sudo apt install cmake build-essential pkg-config libx11-dev libgtk-3-dev libexpat1-dev libjpeg-dev libgstreamer1.0-dev
```

samples需要安装CUDA相关，如果不需要，执行完上面安装命令即可。解压`jetson_multimedia_api.tar.gz`的压缩文件（根据Jetpack版本）

```bash
tar zxvf jetson_multimedia_api.tar.gz
# jetson_multimedia_api/argus/cmake
cmake ..
make
sudo make install
```

完整安装

```bash
sudo apt update
sudo apt install nvidia-l4t-jetson-multimedia-api
```