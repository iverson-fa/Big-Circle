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
# apt install v4l-utils
v4l2-ctl --set-fmt-video=width=1920,height=1280,pixelformat=BA12 --set-ctrl bypass_mode=0 --stream-mmap --stream-count=1 --stream-to=1.raw -d /dev/video0
```

`v4l2-ctl` 是一个用于控制视频设备的工具，它可以用于获取设备的信息、设置设备的参数等。v4l2-ctl 后面可以接的参数取决于你想要执行的操作。

使用以下命令查看支持的格式和控制参数：
```bash
v4l2-ctl --list-formats-ext -d /dev/video0
v4l2-ctl --all -d /dev/video0
```

第一行命令的输出为
```shell
ioctl: VIDIOC_ENUM_FMT
        Type: Video Capture

        [0]: 'BA12' (12-bit Bayer GRGR/BGBG)
                Size: Discrete 2048x1280
                        Interval: Discrete 0.033s (30.000 fps)
                Size: Discrete 1920x1080
                        Interval: Discrete 0.033s (30.000 fps)
```

可以得到以下信息：
- 像素格式：
    - BA12（12-bit Bayer GRGR/BGBG）
- 支持的分辨率：
    - 2048x1280
    - 1920x1080
- 帧率：
    - 30.000 fps

捕捉 **2048x1280** 分辨率的图像
```bash
sudo v4l2-ctl --set-fmt-video=width=2048,height=1280,pixelformat=BA12 \
              --set-ctrl=bypass_mode=0 \
              --stream-mmap \
              --stream-count=1 \
              --stream-to=video0_2048x1280.raw \
              -d /dev/video0
```

捕捉 **1920x1080** 分辨率的图像
```bash
sudo v4l2-ctl --set-fmt-video=width=1920,height=1080,pixelformat=BA12 \
              --set-ctrl=bypass_mode=0 \
              --stream-mmap \
              --stream-count=1 \
              --stream-to=video0_1920x1080.raw \
              -d /dev/video0
```

命令解释

1. `--set-fmt-video=width=2048,height=1280,pixelformat=BA12` 或 `--set-fmt-video=width=1920,height=1080,pixelformat=BA12`
    > 设置视频格式为设备支持的分辨率和像素格式。

2. `--set-ctrl=bypass_mode=0`
    > 设置 bypass_mode 控制参数为 0。
3. `--stream-mmap`
    > 使用内存映射方式进行视频流捕捉。
4. `--stream-count=1`
    > 捕捉一帧视频。
5. `--stream-to=imx274_2048x1280.raw` 或 `--stream-to=imx274_1920x1080.raw`
    > 将捕捉到的视频流保存到相应的文件中。
6. `-d /dev/video0`
    > 指定视频设备为 /dev/video0。


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
# 出图的时候读，0x0a 代表9295工作正常
i2ctransfer -f -y 30 w2@0x42 0x01 0x02 r1
i2ctransfer -f -y 30 w2@0x42 0x01 0x12 r1
i2ctransfer -f -y 30 w2@0x42 0x01 0x0a r1
i2ctransfer -f -y 30 w2@0x42 0x01 0x1a r1
```

