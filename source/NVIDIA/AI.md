# Jetson 深度学习

## 1 Jetson 深度学习

安装：

- TensorFlow：[为 Jetson 平台安装 TensorFlow - NVIDIA 文档](https://docs.nvidia.com/deeplearning/frameworks/install-tf-jetson-platform/index.html)
- PyTorch：[为 Jetson 平台安装 PyTorch - NVIDIA Docs](https://docs.nvidia.com/deeplearning/frameworks/install-pytorch-jetson-platform/index.html)
- 预装了框架的容器：
    - [数据科学、机器学习、AI、HPC 容器 | NVIDIA NGC](https://catalog.ngc.nvidia.com/containers?filters=&orderBy=scoreDESC&query=l4t)

教程：

- Jetson-inference：[Hello AI World 指南，使用 TensorRT 和 NVIDIA Jetson 部署深​​度学习推理网络和深度视觉原语](https://github.com/dusty-nv/jetson-inference)
- TensorRT 示例：[Jetson/L4T/TRT 定制示例 - eLinux.org](https://elinux.org/Jetson/L4T/TRT_Customized_Example#TensorRT_Python)

## 2 环境配置

**（1）[miniforge](https://github.com/conda-forge/miniforge)**

`conda` 和 `miniconda` 都是无法在 `aarch64` 的架构上使用的，`miniforge` 是其替代品，使用方法和 `conda` 几乎一样。

```bash
# 下载源码后进入目录
$ bash Miniforge3-Linux-aarch64.sh
# 添加环境变量
$ sudo vim ~/.bashrc
export PATH="/home/aipt/miniforge3/bin:$PATH"
$ conda --version
# 添加镜像源
# 使用国科大镜像源
$ conda config --prepend channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/
$ conda config --prepend channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/
$ conda config --set show_channel_urls yes
```

**（2）Pytorch**

有了 `miniforge` 之后，可以创建一个虚拟环境，进行不同配置的隔离，然后就可以装 `pytorch` 了。

Jetson 的 pytorch 只能由[这种方式](https://forums.developer.nvidia.com/t/pytorch-for-jetson-version-1-11-now-available/72048)安装，不能像 `PC` 那样安装。不同的 `JetPack` 版本对应于不同的 `python` 和 `pytorch` 版本，可以根据 [Jetson Zoo](https://elinux.org/Jetson_Zoo) 进行选择。例如 `JetPack 5.0`，匹配 `python 3.8` + `pytorch 1.11.0`。

```bash
conda create -n dlTorch python=3.8
conda activate dlTorch
pip install Cython
pip install torch-1.11.0-cp38-cp38-linux_aarch64.whl
conda install numpy
```

NOTE：pytorch 安装成功，但仅仅是在 dlTorch 这个虚拟环境中安装成功。其他环境需要重复此步骤。

**（3）torchvision**

pytorch 对应的 torchvision 版本[查询](https://pypi.org/project/torchvision/)。`pytorch 1.11.0` 对应 `torchvision=0.12.0`，安装：

```bash
sudo apt-get install libjpeg-dev zlib1g-dev libpython3-dev libavcodec-dev libavformat-dev libswscale-dev
git clone --branch <version> https://github.com/pytorch/vision torchvision   # see below for version of torchvision to download
cd torchvision
export BUILD_VERSION=0.x.0  # where 0.x.0 is the torchvision version
python3 setup.py install --user
cd ../  # attempting to load torchvision from build dir will result in import error
pip install 'pillow<7' # always needed for Python 2.7, not needed torchvision v0.5.0+ with Python 3.6
```

NOTE：这里的 `<version>` 和 `BUILD_VERSION=0.x.0` 用 `0.12.0` 替换掉，`pip install 'pillow<7'` 可以省略。

**（4）opencv链接到虚拟环境**

由于 JetPack 已经安装了 opencv 库，但是是在系统预装的 python 路径里面的，虚拟环境里无法 `import` ，于是需要我们将其软连接到当前的虚拟环境。首先查找 cv2 的位置：

```bash
sudo find / -iname "*cv2*"
```

根据 `python3.8` 的路径显示，cv2 的路径如下：`/usr/lib/python3.8/dist-packages/cv2/python-3.8/cv2.cpython-38-aarch64-linux-gnu.so`，而当前虚拟环境的路径如下 `/home/miniforge3/envs/dlTorch/lib/python3.8/site-packages`。建立软链接：

```bash
sudo ln -s /usr/lib/python3.8/dist-packages/cv2/python-3.8/cv2.cpython-38-aarch64-linux-gnu.so cv2.so
```

此时在虚拟环境 dlTorch 中启动 python 也可以 import cv2 了。

## 3 TensorFlow + Keras 训练 LeNet

安装依赖：

```bash
sudo apt install python3-numpy python3-scipy python3-pandas python3-matplotlib python3-sklearn libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev liblapack-dev libblas-dev gfortran python3-pip
sudo pip3 install -U --no-deps numpy==1.19.4 future==0.18.2 mock==3.0.5 keras_preprocessing==1.1.2 keras_applications==1.0.8 gast==0.4.0 protobuf pybind11 cython pkgconfig keras -i https://pypi.tuna.tsinghua.edu.cn/simple
sudo env H5PY_SETUP_REQUIRES=0 pip3 install -U h5py==3.1.0
```

TensorFlow 1.15 [安装地址](https://developer.download.nvidia.com/compute/redist/jp/v50/tensorflow/)：

```bash
sudo pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v50 'tensorflow<2'
```

检查是否安装成功：

```bash
python3
# 测试 tf
import tensorflow as tf
tf.__version__
tf.__path__
# 测试 Keras
import tensorflow.keras
```

训练代码：keras_lenet.py

```python
import tensorflow.keras
from tensorflow.keras.datasets import mnist
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Flatten, Conv2D, MaxPooling2D
from tensorflow.keras import backend as K

num_classes = 10
img_rows, img_cols = 28, 28

# 通过Keras封装好的API加载MNIST数据。其中trainX就是一个60000 * 28 * 28的数组，
# trainY是每一张图片对应的数字。
(trainX, trainY), (testX, testY) = mnist.load_data()

# 根据对图像编码的格式要求来设置输入层的格式。
if K.image_data_format() == 'channels_first':
    trainX = trainX.reshape(trainX.shape[0], 1, img_rows, img_cols)
    testX = testX.reshape(testX.shape[0], 1, img_rows, img_cols)
    input_shape = (1, img_rows, img_cols)
else:
    trainX = trainX.reshape(trainX.shape[0], img_rows, img_cols, 1)
    testX = testX.reshape(testX.shape[0], img_rows, img_cols, 1)
    input_shape = (img_rows, img_cols, 1)

trainX = trainX.astype('float32')
testX = testX.astype('float32')
trainX /= 255.0
testX /= 255.0

# 将标准答案转化为需要的格式（one-hot编码）。
trainY = tensorflow.keras.utils.to_categorical(trainY, num_classes)
testY = tensorflow.keras.utils.to_categorical(testY, num_classes)
# 2. 通过Keras的API定义卷积神经网络
# 使用Keras API定义模型。
model = Sequential()
model.add(Conv2D(32, kernel_size=(5, 5), activation='relu', input_shape=input_shape))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Conv2D(64, (5, 5), activation='relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Flatten())
model.add(Dense(500, activation='relu'))
model.add(Dense(num_classes, activation='softmax'))

# 定义损失函数、优化函数和评测方法。
model.compile(loss=tensorflow.keras.losses.categorical_crossentropy,
              optimizer=tensorflow.keras.optimizers.SGD(),
              metrics=['accuracy'])

# 3. 通过Keras的API训练模型并计算在测试数据上的准确率
model.fit(trainX, trainY,
          batch_size=128,
          epochs=10,
          validation_data=(testX, testY))

# 在测试数据上计算准确率。
score = model.evaluate(testX, testY)
print('Test loss:', score[0])
print('Test accuracy:', score[1])
```

开始训练，会自动下载 MNIST 数据集并加载训练参数：

```bash
python3 keras_learn.py
```

