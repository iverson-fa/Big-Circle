# Leopard_camera

## 1 Run camera

**Argus software**

[Download](https://www.dropbox.com/s/qz0ey3ygvb6a6nj/jetson_multimedia_api.tar.gz?dl=0) the Multimedia package from link and copy it to Orin.

Open a terminal, do

 ```bash
 sudo apt-get install cmake
 sudo apt-get install build-essential
 sudo apt-get install pkg-config
 sudo apt-get install libx11-dev
 sudo apt-get install libgtk-3-dev
 sudo apt-get install libexpat1-dev
 sudo apt-get install libjpeg-dev
 sudo apt-get install libgstreamer1.0-dev
 ```

Uncompress the tgz file.

```bash
tar zxvf jetson_multimedia_api.tgz
# jetson_multimedia_api/argus/cmake
make ..
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
 v4l2-ctl --set-fmt-video=width=2048,height=1280,pixelformat=RG12 --set-ctrl bypass_mode=0 --stream-mmap --stream-count=1 --stream-to=imx264.raw -d /dev/video0
 ```

