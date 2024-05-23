# Leopard_camera

## 1 Run camera

**Argus software**

[Download](https://www.dropbox.com/s/qz0ey3ygvb6a6nj/jetson_multimedia_api.tar.gz?dl=0) the Multimedia package from link and copy it to Orin.

Open a terminal, do

```bash
sudo apt-get install cmake build-essential pkg-config libx11-dev libgtk-3-dev libexpat1-dev libjpeg-dev libgstreamer1.0-dev
```

Uncompress the tgz file.

```bash
tar zxvf jetson_multimedia_api.tgz
# jetson_multimedia_api/argus/cmake
cmake ..
make
sudo make install
argus_camera --device=0
```

**Gstreamer**

```bash
gst-launch-1.0 nvarguscamerasrc sensor-id=0 ! 'video/x-raw(memory:NVMM), width=(int)2048, height=(int)1280, framerate=30/1'  ! nvvidconv flip-method=0 ! 'video/x-raw, format=(string)I420' ! xvimagesink -e
```

**v4l2-ctl capture raw**

```bash
# 需要先安装 v4l-utils
v4l2-ctl --set-fmt-video=width=2048,height=1280,pixelformat=RG12 --set-ctrl bypass_mode=0 --stream-mmap --stream-count=1 --stream-to=imx264.raw -d /dev/video0
```
关于`v4l2-ctl`的说明：
v4l2-ctl 是一个用于控制视频设备的工具，它可以用于获取设备的信息、设置设备的参数等。v4l2-ctl 后面可以接的参数取决于你想要执行的操作。
- device=/dev/video0： 指定要操作的视频设备文件，例如 /dev/video0、/dev/video1 等。
- query=all： 获取设备的所有信息，包括设备名称、驱动版本、输入源、输出源、帧率等。
- query=input=<input_index>： 获取指定输入源的信息，例如 --query=input=0 获取第一个输入源的信息。
- query=output=<output_index>： 获取指定输出源的信息，例如 --query=output=0 获取第一个输出源的信息。
- query=std=<std_id>： 获取指定标准的信息，例如 --query=std=PAL 获取 PAL 标准的信息。
- query=ctrl=<ctrl_id>： 获取指定控件的信息，例如 --query=ctrl=brightness 获取亮度控件的信息。
- query=range=<ctrl_id>： 获取指定控件的范围信息，例如 --query=range=brightness 获取亮度控件的范围信息。
- set=<ctrl_id>=<value>： 设置指定控件的值，例如 --set=brightness=50 将亮度设置为 50。
- update： 将设置立即应用到设备中。

## 2 I2C配置

```bash
i2cdetect -y -r 1
i2cset -y -r 1 0x74 0x81 0x07 # 设置0x74仲裁器，占用下游总线

i2cget -y 1 0x74 0x81 # 回读

i2cset -y -r 1 0x70 0x01 # 选择0x70的 0通道
i2cset -y -r 1 0x70 0x02 # 选择0x70的 1通道
i2cset -y -r 1 0x70 0x04 # 选择0x70的 2通道
i2cset -y -r 1 0x70 0x08 # 选择0x70的 3通道

i2cget -y -r 1 0x70 0x01 # 回读
```

```bash
i2ctransfer -f -y 1 w2@0x74 0x81 0x07
i2ctransfer -f -y 1 w1@0x70 0x01
```

```bash
# 出图的时候读，0x8a 代表有正确数据到9296
i2ctransfer -f -y 30 w2@0x48 0x01 0x02 r1
i2ctransfer -f -y 30 w2@0x48 0x01 0x12 r1
i2ctransfer -f -y 30 w2@0x48 0x01 0x0a r1
i2ctransfer -f -y 30 w2@0x48 0x01 0x1a r1
```

