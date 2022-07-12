# Orin 深度学习

## 1 TensorFlow + Keras 训练 LeNet

安装依赖：

```bash
sudo apt install python3-numpy python3-scipy python3-pandas python3-matplotlib python3-sklearn libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev liblapack-dev libblas-dev gfortran python3-pip
sudo pip3 install -U --no-deps numpy==1.19.4 future==0.18.2 mock==3.0.5 keras_preprocessing==1.1.2 keras_applications==1.0.8 gast==0.4.0 protobuf pybind11 cython pkgconfig keras -i https://pypi.tuna.tsinghua.edu.cn/simple
sudo env H5PY_SETUP_REQUIRES=0 pip3 install -U h5py==3.1.0
```

Jetpack 5.0 [安装地址](https://developer.download.nvidia.com/compute/redist/jp/v50/tensorflow/)：

```bash
sudo pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v50 'tensorflow<2'
```

检查是否安装成功：

```bash
python3
# 测试 tf
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



