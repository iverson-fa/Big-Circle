# Camera

- [Libargus Camera API](https://docs.nvidia.com/jetson/l4t-multimedia/group__LibargusAPI.html)
- [Jetson Linux API Reference](https://docs.nvidia.com/jetson/l4t-multimedia/)


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
cd /usr/src/jetson_multimedia_api/argus/cmake
cmake ..
make
sudo make install
```

## 2 Gstreamer

### 2.1 命令解析

1 将视频存成文件

```shell
gst-launch-1.0 nvarguscamerasrc ! 'video/x-raw(memory:NVMM), width=1920, height=1080, format=(string)NV12, framerate=(fraction)30/1' ! nvoverlaysink -e
```

`gst-launch-1.0`:

GStreamer 的命令行工具，用于创建并运行多媒体处理的管道。

`nvarguscamerasrc`:

NVIDIA 提供的一个 GStreamer 插件，专门用于从 Argus Camera API 捕获视频流。适用于 NVIDIA Jetson 平台上相机设备的硬件加速。

`!`：

管道符号，用来将不同的 GStreamer 元素串联起来处理数据流。

`video/x-raw(memory:NVMM)`：

指定使用 NVMM 内存类型（NVIDIA 的内存管理，用于硬件加速的内存缓冲区）。这对 Jetson 平台上的硬件加速是必要的。

`width=1920, height=1080`:

设置视频流的分辨率为 1920x1080 (Full HD)。

`format=(string)NV12`:

指定视频格式为 NV12，一种常见的 YUV 4:2:0 色度子采样格式，用于硬件编码和解码。

`framerate=(fraction)30/1`:

指定视频的帧率为 30 FPS（每秒 30 帧）。

`nvoverlaysink`:

NVIDIA 提供的用于将视频显示到屏幕的 GStreamer 插件。nvoverlaysink 是一个硬件加速的显示插件，适合 Jetson 平台，用于低延迟输出。

`-e`:

这个选项表示在 GStreamer 管道关闭时，发送一个 EOS (End of Stream) 信号，确保流在关闭时可以正常结束。

> 注意事项：
确保摄像头能够支持指定的分辨率、帧率和格式。如果无法支持，管道可能会因为不兼容的参数而报错。
nvarguscamerasrc 适用于 Jetson 平台的 CSI 摄像头。对于 USB 摄像头，你可能需要使用 v4l2src 而不是 nvarguscamerasrc。

> 运行后的效果：

该命令会从相机捕获 1920x1080 的视频流，以 30 帧/秒的速度，通过硬件加速的方式将其显示到屏幕上。

2 将视频输出到HDMI屏幕

```shell
gst-launch-1.0 nvarguscamerasrc num-buffers=200 ! 'video/x-raw(memory:NVMM), width=1920, height=1080, framerate=30/1, format=NV12' ! omxh264enc ! qtmux ! filesink location=test.mp4 -e
```

`gst-launch-1.0`:

GStreamer 的命令行工具，用于创建并运行多媒体处理的管道。

`nvarguscamerasrc`:

NVIDIA 提供的 Argus Camera API GStreamer 插件，用于捕获来自相机的视频流（通常是 CSI 摄像头）。

`num-buffers=200`:

指定捕获 200 帧。由于帧率为 30 FPS，所以这大约会捕获 6.67 秒的视频。

`!`：

管道符号，将不同的 GStreamer 元素串联起来处理数据流。

`video/x-raw(memory:NVMM), width=1920, height=1080, framerate=30/1, format=NV12`:

设置捕获的视频格式为 NV12（一种 YUV 4:2:0 色度子采样格式），分辨率为 1920x1080，帧率为 30 帧/秒。(memory:NVMM) 表示使用 NVIDIA 硬件加速内存缓冲区。

`omxh264enc`:

使用 NVIDIA Jetson 平台上的硬件加速 H.264 编码器（OpenMAX H.264 编码器）对视频流进行 H.264 编码。

`qtmux`:

将编码后的 H.264 视频流封装为 MP4 容器格式（QuickTime/MPEG-4 格式封装器）。

`filesink location=test.mp4`:

指定将输出文件保存为 test.mp4。filesink 用于将处理后的数据保存到文件。

`-e`:

指定在结束时发送 EOS (End of Stream) 信号，确保流正常结束并正确写入文件。

> 运行结果：

该命令会捕获 200 帧视频（大约 6.67 秒），分辨率为 1920x1080，帧率为 30 FPS，将其编码为 H.264 格式，并保存为 test.mp4 文件。
捕获过程中会使用 NVIDIA Jetson 平台的硬件加速来处理视频编码和内存操作，确保性能高效。

> 注意事项：

如果需要更长时间的录制，可以增大 num-buffers 或者将其去掉来无限录制，直到手动终止管道。
文件路径 `location=test.mp4` 可以替换为任意有效的路径。

### 2.2 应用程序使用GStreamer与V4L2源插件

如果使用拜耳传感器、YUV传感器或USB摄像头输出YUV图像而不进行ISP处理，则不使用NVIDIA摄像头软件栈。

举例：对一个YUV sensor输出480p/30/UYVY格式：

```
# save
$ gst-launch-1.0 -v v4l2src device=/dev/video0 ! 'video/x-raw, format=(string)UYVY, width=(int)640, height=(int)480, framerate=(fraction)30/1' ! nvvidconv ! 'video/x-raw(memory:NVMM), format=(string)NV12' ! omxh264enc ! qtmux ! filesink location=test.mp4 -ev

# 输出到屏幕
# 该命令会从 /dev/video0 捕获 640x480 分辨率、30 FPS 的 UYVY 格式视频流，并使用 xvimagesink 在显示器上输出视频画面。
$ export DISPLAY=:0 //if you are operating from remote console
$ gst-launch-1.0 v4l2src device=/dev/video0 ! 'video/x-raw, format=(string)UYVY, width=(int)640, height=(int)480, framerate=(fraction)30/1' ! xvimagesink -ev
```

`xvimagesink`:

一个 GStreamer 插件，用于将视频流直接显示在 X Window 系统中。xvimagesink 使用 Xv（X Video Extension），这是 X Window 系统中的硬件加速视频显示机制。

`-ev`:

-e：在结束时发送 EOS (End of Stream) 信号，确保流正常结束。
-v：启用详细的调试输出，帮助你查看管道的状态。

### 2.3 应用直接使用V4L2 IOCTL

```
v4l2-ctl --set-fmt-video=width=1920,height=1080,pixelformat=RG10 --stream-mmap --stream-count=1 -d /dev/video0 --stream-to=ov5693.raw
```

`v4l2-ctl`:

Video4Linux2 控制工具，用于查询和配置 V4L2 设备（如摄像头）的属性和控制其行为。

`--set-fmt-video=width=1920,height=1080,pixelformat=RG10`:

设置视频格式：

width=1920 和 height=1080：设置捕获的分辨率为 1920x1080（Full HD）。

pixelformat=RG10：设置像素格式为 RG10，这是一种 10 位 RAW 图像格式，通常用于传感器直接输出未处理的原始图像数据（如 OV5693 传感器）。

`--stream-mmap`:

使用内存映射（MMAP）方式从摄像头设备中获取视频流。MMAP 是一种高效的内存管理方法，通过将设备的内存缓冲区映射到用户空间，从而提升性能。

`--stream-count=1`:

指定流式传输的帧数。在此命令中，设置为 1，即捕获一帧视频数据。

`-d /dev/video0`:

指定视频设备为 /dev/video0。如果你有多个视频设备，可能需要更改这个设备路径（如 /dev/video1）。

`--stream-to=ov5693.raw`:

指定将捕获的帧保存到 ov5693.raw 文件中。文件将包含原始的未处理图像数据。

> 运行效果：

该命令会从 /dev/video0 捕获一帧 1920x1080 分辨率、像素格式为 RG10 的原始图像数据，并保存为 ov5693.raw 文件。
捕获的 .raw 文件会是传感器的原始数据，未经处理（如去马赛克、色彩校正等）。

> 注意事项：

RG10 是一种传感器原始格式（RAW10），通常会根据特定传感器的需求使用。你可能需要图像处理工具（如 raw2rgb 或其他解码器）来处理该原始文件并将其转换为可视化的图像。
如果你希望捕获更多帧，可以增加 --stream-count 的值。
确保你的摄像头支持你指定的像素格式和分辨率，否则可能会出现格式不支持的错误。