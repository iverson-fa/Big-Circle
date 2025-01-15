# Docker Notes

## 0 参考资料

- [官网](https://www.docker.com/get-started/)
- [官方文档](https://docs.docker.com/get-started/overview/)
- [Docker Swarm](https://blog.daocloud.io/233.html)
- [Linux Capabilities](https://www.cnblogs.com/sparkdev/p/11417781.html)
- [GPUS - 使用Docker容器的入门技巧](https://zhuanlan.zhihu.com/p/553091318)
- [Docker Hub OSRF镜像](https://hub.docker.com/r/osrf/ros/tags)

## 1 Common

### 1.1 常用命令

#### 1.1.1 创建容器

使用 `docker container create` 命令可以创建一个容器，但不会立即启动它。你的命令创建了一个名为 `neotic` 的容器，配置了一系列挂载和权限。

**命令详解**
```bash
docker container create --name=noetic --privileged \
  -v /home/dafa:/home/dafa \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  --device=/dev/dri/renderD128 \
  -v /dev:/dev \
  -v /dev/dri:/dev/dri \
  --device=/dev/snd \
  -e DISPLAY=unix$DISPLAY \
  -w /home/dafa \
  fishros2/ros:noetic-desktop-full
# 或
docker run -dit --name=noetic --privileged \
  -v /home/dafa:/home/dafa \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  --device=/dev/dri/renderD128 \
  -v /dev:/dev \
  -v /dev/dri:/dev/dri \
  --device=/dev/snd \
  -e DISPLAY=unix$DISPLAY \
  -w /home/dafa \
  fishros2/ros:noetic-desktop-full
```

- `docker container create`: 创建一个容器，但不会启动它。
- `-dit`: 同 `docker run` 中的选项，分别表示：
  - `-d`: 后台模式运行容器。
  - `-i`: 保持容器的标准输入打开。
  - `-t`: 分配一个伪终端。
- `--name=neotic`: 将容器命名为 `neotic`。
- `--privileged`: 提供特权模式，允许容器访问更多的主机资源。
- 各种 `-v` 和 `--device` 选项配置了挂载和设备访问权限（如 GPU、音频等）。
- `-e DISPLAY=unix$DISPLAY`: 设置 X11 的显示环境变量。
- `-w /home/dafa`: 设置容器内的工作目录。
- `fishros2/ros:noetic-desktop-full`: 使用 ROS Noetic 桌面全功能镜像。

---

**创建容器后操作**
1. **查看创建的容器**：
   ```bash
   docker ps -a
   ```
   输出中应显示名为 `neotic` 的容器，状态为 `Created`。

2. **启动容器**：
   ```bash
   docker start neotic
   ```

3. **进入容器**：
   ```bash
   docker exec -it neotic bash
   ```

---

**测试容器配置**
如果需要验证容器配置是否正确，可以在容器中运行以下命令：


```bash
xclock
```
如果显示了时钟界面，说明图形界面配置成功。

**测试音频设备**
```bash
aplay -l
```
如果列出了音频设备，说明音频配置正常。

---

**修改容器配置**
如果需要调整容器的挂载或权限，可以通过 `docker container rm` 删除容器后重新创建，或者使用 `docker commit` 生成新的镜像再启动容器。

#### 1.1.2 将当前的容器保存为新的镜像

要将当前运行中的容器保存为新的镜像，可以使用 `docker commit` 命令。以下是具体步骤：

**步骤 1: 获取容器的 ID 或名称**

运行以下命令查看当前的容器列表：
```bash
docker ps -a
```
找到你要保存的容器的 **CONTAINER ID** 或 **NAMES**。

**步骤 2: 将容器保存为新的镜像**

使用 `docker commit` 命令将容器保存为镜像：
```bash
docker commit [OPTIONS] CONTAINER_ID/NAME IMAGE_NAME[:TAG]
```

- **CONTAINER_ID/NAME**：容器的 ID 或名称。
- **IMAGE_NAME**：新镜像的名称。
- **TAG**（可选）：镜像的标签，例如 `v1.0`。

例如，将容器保存为名为 `my_new_image` 的镜像：
```bash
docker commit 0a4a40d5d399 my_new_image:latest
```

**步骤 3: 验证镜像**

保存后，可以通过以下命令查看新的镜像：
```bash
docker images
```

**选项说明**

- **`-a`**：指定镜像的作者，例如 `-a "Your Name <email@example.com>"`。
- **`-m`**：提供对镜像的注释信息，例如 `-m "Added new configuration"`。

完整示例：
```bash
docker commit -a "Your Name" -m "Customized image" 0a4a40d5d399 my_new_image:customized
```

**其他操作**
- 如果需要基于新镜像启动容器：
  ```bash
  docker run -it my_new_image:latest
  ```
- 如果需要推送镜像到 Docker Hub：
  1. 登录 Docker Hub：
     ```bash
     docker login
     ```
  2. 推送镜像：
     ```bash
     docker tag my_new_image:latest your_dockerhub_username/my_new_image:latest
     docker push your_dockerhub_username/my_new_image:latest
     ```
#### 1.1.3 保存镜像及导出镜像

要将运行中的容器保存为一个新的镜像并导出为文件，可以按照以下步骤操作：

---

**1. 提取容器为镜像**
假设你的容器名称或 ID 为 `container_name`，运行以下命令将容器保存为镜像：
```bash
docker commit container_name new_image_name
```
- `container_name` 是你的容器名称或 ID。
- `new_image_name` 是你要创建的镜像名称。

---

**2. 导出镜像为文件**
使用以下命令将镜像保存为 `.tar` 文件：
```bash
docker save -o new_image.tar new_image_name
```
- `new_image_name` 是刚刚创建的镜像名称。
- `new_image.tar` 是导出的文件名。

---

**3. 检查导出的文件**
确认 `.tar` 文件已经成功生成：
```bash
ls -lh new_image.tar
```

---

**4. 导入镜像文件（验证）**
在其他机器或环境中，可以使用以下命令重新加载镜像：
```bash
docker load -i new_image.tar
```

---

**示例完整流程**
```bash
# 查看正在运行的容器
docker ps

# 保存容器为镜像
docker commit container_name new_image_name

# 导出镜像为文件
docker save -o new_image.tar new_image_name

# 检查文件
ls -lh new_image.tar

# 重新加载镜像（可选）
docker load -i new_image.tar
```

---

完成后，分享或备份 `new_image.tar` 文件，该文件可以用于在其他环境中直接恢复镜像。

### 1.2 安装及镜像加速

推荐用 `fishros` 脚本安装，或者使用以下方法：

安装一些软件包，以允许 `apt` 通过 HTTPS 使用存储库：

```bash
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
```

首先，添加阿里云提供的镜像源以便于加快国内安装速度，先添加相应的密钥：

```bash
curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
```

再添加相应源的信息：

```bash
# arm平台需要修改 arch=arm64
sudo add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
```

```bash
# 更新 apt 索引库
sudo apt-get update
# 安装最新版 docker-ce
sudo apt-get install docker-ce
# 加入 sudo 权限
sudo usermod -aG docker dafa
# 防止自动更新
sudo apt-mark hold docker-ce
```

如果需要安装指定版本的docker，例如v20.10.2，先查看可以安装的版本，然后再安装

```shell
# 查看可安装版本
apt-cache madison docker-ce
# or
apt list -a docker-ce
# install order
sudo apt install docker-ce=<VERSION> docker-ce-cli=<VERSION> containerd.io
# install v20.10.2
sudo apt install docker-ce=5:20.10.2~3-0~ubuntu-focal docker-ce-cli=5:20.10.2~3-0~ubuntu-focal containerd.io
```

**使用[阿里云镜像源](https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors)**

国内拉取 Docker Hub 的速度非常慢，阿里云提供了镜像加速器，账号需要自己申请。

编辑 `/etc/docker/daemon.json` 文件：

```bash
sudo vim /etc/docker/daemon.json
```

加入如下内容：

```bash
{
  "registry-mirrors": ["https://71bj24w3.mirror.aliyuncs.com"]
}
```

重启 Docker 服务，让修改生效：

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

**使用[南大镜像源](https://mirror.nju.edu.cn/)**

```bash
{
  "registry-mirrors": [
  "https://docker.nju.edu.cn/",
  "https://71bj24w3.mirror.aliyuncs.com"]
}
```

对于 ghcr.io 的镜像，将 `ghcr.io` 替换为 `ghcr.nju.edu.cn` 即可。其他Container Registry的用法参考镜像网站。


对于2024年docker hub禁用后，可以使用以下方案暂时代替：

```shell
# 三选一
# method 1
{
  "registry-mirrors": ["https://docker.1panel.live"]
}
# method 2
{
  "registry-mirrors": ["https://docker.m.daocloud.io"]
}
# method 3
{
    "registry-mirrors": [
            "https://docker.211678.top",
            "https://docker.1panel.live",
            "https://hub.rat.dev",
            "https://docker.m.daocloud.io",
            "https://do.nark.eu.org",
            "https://dockerpull.com",
            "https://dockerproxy.cn",
            "https://docker.awsl9527.cn"
      ]
}
```

## 2 容器管理

### 2.1 创建容器

严格意义上来讲，`docker run` 命令的作用并不是创建一个容器，而是在一个新的容器中运行一个命令。而用于创建一个新容器的命令为

```bash
# Management Commands
docker container create [OPTIONS] IMAGE [COMMAND] [ARG...]

# 旧的命令格式如下：
docker create [OPTIONS] IMAGE [COMMAND] [ARG...]
```

该命令会在指定的镜像 IMAGE 上创建一个可写容器层，并 **准备** 运行指定的命令。即该命令只创建容器，并不会运行容器。

一些常见的配置项如下所示：

- `--name` 指定一个容器名称，未指定时，会随机产生一个名字
- `--hostname` 设置容器的主机名
- `--mac-address` 设置 `MAC` 地址
- `--ulimit` 设置 `ulimit` 选项

关于上述提到的 `ulimit`，可以通过其对容器运行时的一些资源进行限制。`ulimit` 是一种 Linux 系统的内建功能，一些简单的描述，可以参考 [通过 ulimit 改善系统性能](https://linux.cn/article-1963-1.html) ，而对于在下面将要设置的部分值的含义，可以参考 [How to set ulimit values](https://access.redhat.com/solutions/61334)。

除此之外，关于创建容器，还可以设置有关存储和网络的详细内容，将会在下一节的内容中进行介绍。

创建一个实例，指定容器的名字为 `dafa`，主机名为 `dafa`，设置相应的 `MAC` 地址，并通过 `ulimit` 设置最大进程数（`1024:2048` 分别代表软硬资源限制，详细内容可以参考上面的链接），使用 `ubuntu` 的镜像，并运行 `bash`：

```bash
docker container create \
    --name dafa \
    --hostname dafa \
    --mac-address 00:01:02:03:04:05 \
    --ulimit nproc=1024:2048 \
    -it ubuntu /bin/bash
```

此时，容器创建成功后，会打印该容器的 `ID`，这里需要简单说明一下，在 Docker 中，容器的标识有三种比较常见的标识方式：

- `UUID` 长标识符，例如 `1f6789f885029dbdd4a6426d7b950996a5bcc1ccec9f8185240313aa1badeaff`。
- `UUID` 短标识符，从长标识符开始，只要不与其它标识符冲突，可以从头开始，任意选用位数，例如针对上面的长标识符，可以使用 `1f`，`1f678` 等。
- `Name` 最后一种方式即是使用容器的名字。

在容器创建成功后，查看其运行状态使用如下命令：

```bash
# 此时该容器并未运行，需要使用 -a 参数
docker container ls -a
```

新创建的容器的状态 (`STATUS`) 为 `Created`，并且其容器名被设置为对应的值，而之前没有指定名字的容器都是随机生成的名字。

### 2.2 启动容器

```bash
# Management Commands
docker container start [OPTIONS] CONTAINER [CONTAINER...]

# 旧的命令格式如下：
docker start [OPTIONS] CONTAINER [CONTAINER...]
```

对于上述 `dafa` 容器，启动：

```bash
docker container start dafa
```

上述的两个命令如果使用 `docker container run` 只需要一步即可，即此时 `run` 命令同时完成了 `create` 及 `start` 操作：

```bash
docker container run \
    --name dafa \
    --hostname dafa \
    --mac-address 00:01:02:03:04:05 \
    --ulimit nproc=1024:2048 \
    -it ubuntu /bin/bash
```
```bash
apt install net-tools # ifconfig
apt install iputils-ping # ping
```

除此之外，上面的 `run` 命令还完成一些其它的操作，例如没有镜像时会 `pull` 镜像，使用 `-it` 参数时完成了 `attach` 操作，使用 `--rm` 参数在容器退出后还会完成 `container rm` 操作。`run` 命令是一个综合性的命令，如果能够熟练的使用它可以简化很多步骤。

### 2.3 停止容器

```bash
# Management Commands
docker container stop CONTAINER [CONTAINER...]

# 旧的命令格式如下：
docker stop CONTAINER [CONTAINER...]
```

在交互式界面，同时按下 `ctrl` 和 `p` 键，再同时按 `ctrl` 和 `q` 键，让这个容器进入到后台运行。

使用 `docker container ls -a` 命令查看容器的状态，可以看到容器正在运行。输入 `docker container stop dafa`，docker 返回了容器的 `UUID`，再次使用 `docker container ls -a` 命令查看容器的状态，发现容器已经停止运行了。

### 2.4 重启容器

```bash
# Management Commands
docker container restart CONTAINER [CONTAINER...]

# 旧的命令格式如下：
docker restart CONTAINER [CONTAINER...]
```

### 2.5 进程

**暂停进程**

暂停容器中进程的命令格式如下：

```bash
# Management Commands
docker container pause CONTAINER [CONTAINER...]

# 旧的命令格式如下：
docker pause [OPTIONS] CONTAINER [CONTAINER...]
```

这里还是使用 `dafa` 这个容器，执行下述命令。

```bash
docker container pause dafa
docker container ls -a
```

容器被暂停后处于 `Paused` 状态。

**恢复进程**

恢复容器中进程的命令格式如下：

```bash
# Management Commands
docker container unpause CONTAINER [CONTAINER...]

# 旧的命令格式如下：
docker unpause [OPTIONS] CONTAINER [CONTAINER...]
```

使用 `dafa` 这个容器，执行下述命令。

```bash
# 恢复容器中的进程
docker container unpause dafa
```

### 2.6 查看容器列表

```bash
# Management Commands
docker container ls [OPTIONS]

# 旧的命令格式如下：
docker ps [OPTIONS]
```

在使用命令时，使用一些可选的配置项 `[OPTIONS]`。

- `-a` 显示所有的容器。
- `-q` 仅显示 `ID`。
- `-s` 显示总的文件大小。

默认情况下，直接使用该命令仅显示正在运行的容器，如下所示：

```bash
docker container ls
```

![](https://doc.shiyanlou.com/courses/uid977658-20190426-1556274022838#crop=0&crop=0&crop=1&crop=1&id=MPt1q&originHeight=243&originWidth=1058&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)

使用 `-a` 参数，来显示所有的容器，并加上 `-s` 选项，显示大小，命令如下：

```bash
docker container ls -a -s
```

### 2.7 连接到正在运行的容器

```bash
# Management Commands
docker container attach [OPTIONS] CONTAINER

# 旧的命令格式如下：
docker attach [OPTIONS] CONTAINER
```

启动容器，并使用连接命令：

```bash
docker container start dafa
docker container attach dafa
```

连接到容器后，查看相应的主机名（输入 `hostname` 命令）和 `Mac` 地址（输入 `ifconfig` 命令），可以判断连接到了刚刚创建的容器。

如果提示无 `ifconfig` 命令，可以在容器中执行 `apt update && apt install net-tools` 安装。

### 2.8 查看容器元数据

```bash
# Management Commands
docker container inspect [OPTIONS] CONTAINER [CONTAINER...]

# 旧的命令格式如下：
docker inspect [OPTIONS] CONTAINER [CONTAINER...]
```

查看刚刚创建的容器的详细信息就可以使用以下命令：

```bash
# 使用容器名
docker container inspect dafa

# 使用 ID ，因生成的 ID 不同，需要修改为相应的 ID
docker container inspect 1f6789

docker container inspect 1f6
```

### 2.9 删除容器

```bash
# Management Commands
docker container rm [OPTIONS] CONTAINER [CONTAINER...]

# 旧的命令格式如下：
docker rm [OPTIONS] CONTAINER [CONTAINER...]
```

**在删除容器后，在容器中进行的操作并不会持久化到镜像中。**

删除之前创建的所有容器：

```bash
docker container rm -f $(docker container ls -aq)
```

`docker container ls -aq` 会输出所有容器的 UUID ，rm 命令可以根据 UUID 去删除容器。这里用选项 `-f` 是因为还有在运行中的容器，所以需要强制删除。`ls` 列出的 UUID 传递给 `rm` 进行删除。

如果 docker 版本为 1.13 及以上版本，还可以更方便的 **prune**。

```bash
docker container prune [OPTIONS]
```

常用的配置项有：

- `-f` 或 `--force` 跳过警告提示
- `--filter` 执行过滤删除

如直接删除所有停止的容器**（慎用）**：

```bash
docker container prune -f
```

### 2.10 容器日志管理

获取容器的输出信息可以使用如下命令：

```bash
# Management Commands
docker container logs [OPTIONS] CONTAINER

# 旧的命令格式如下：
docker logs [OPTIONS] CONTAINER
```

常用的配置项有：

- `-t` 或 `--timestamps` 显示时间戳
- `-f` 实时输出，类似于 `tail -f`

重新运行一个容器，让它在后台执行一个不断输出的脚本，命令如下：

```bash
docker container run \
    --name dafa01 \
    -i -t -d \
    ubuntu /bin/sh -c "while true; do echo hello dafa; sleep 2; done"
```

> "while true; do echo hello world; sleep 2; done" 是一个脚本，它的功能是每 2 秒输出一次 “ hello dafa”。


查看刚刚创建的容器的日志，使用如下命令：

```bash
docker container logs -tf dafa01
```

### 2.11 显示容器中的进程信息

除了获取日志之外，还可以显示运行中的容器的进程信息，命令格式如下：

```bash
# Management Commands
docker container top CONTAINER

# 旧的命令格式如下：
docker top CONTAINER
```

查看刚刚创建的容器的进程信息：

```bash
docker container top dafa01
```

> 需要注意的是，该命令对于并未运行的容器是无效的。


### 2.12 查看文件修改

查看相对于镜像的文件系统来说，容器中做了哪些改变，使用如下命令：

```bash
# Management Commands
docker container diff CONTAINER

# 旧的命令格式如下：
docker diff CONTAINER
```

在 `dafa` 中创建一个文件：

```bash
docker container restart dafa
docker container attach dafa
touch ~/a.txt
```

`Ctrl+p Ctrl+q` 退出当前容器，使用 `docker container diff dafa` 命令查看到相应的修改。

### 2.13 容器中执行命令

除了使用 `docker container run` 执行命令之外，还可以在一个运行中的容器中执行命令：

```bash
# Management Commands
docker container exec [OPTIONS] CONTAINER COMMAND [ARG...]

# 旧的命令格式如下：
docker exec [OPTIONS] CONTAINER COMMAND [ARG...]
```

例如，在 `dafa` 容器中执行 `echo "test_exec"` 命令，就可以使用如下命令：

```bash
# 重启容器
docker container restart dafa
# 执行命令
docker container exec dafa echo "test_exec"
```

## 3 镜像管理

镜像是一个容器的只读模板，用来创建容器。当运行容器时需要指定镜像，如果本地没有该镜像，则会从 Docker Registry 下载。默认查找的是 Docker Hub。Docker 的镜像是增量的修改，每次创建新的镜像都会在老的镜像上面构建一个增量的层，使用到的技术是 Another Union File System(AUFS)，相关文档 [InfoQ: 剖析 Docker 文件系统：Aufs 与 Devicemapper](https://blog.csdn.net/zhaihaifei/article/details/51263232)。

镜像存储中的核心概念仓库（Repository）是镜像存储的位置。Docker 注册服务器（Registry）是仓库存储的位置。每个仓库包含不同的镜像。

比如一个镜像名称 `ubuntu:14.04`，冒号前面的 `ubuntu` 是仓库名，后面的 `14.04` 是 TAG，不同的 TAG 可以对应相同的镜像，TAG 通常设置为镜像的版本号。如果不加 TAG，这时 Docker 会使用默认的 TAG：`latest`。

Docker Hub 是 Docker 官方提供的公共仓库，提供大量的常用镜像，由于国内网络原因连接会比较慢。

并且 Docker 的镜像是分层存储，每一个镜像都是由很多层组成的。而一些镜像会共享一些相同的层。

### 3.1查看镜像列表

```bash
# Management Commands
docker image ls

# 旧的命令格式如下：
docker images
```

也可以查看指定仓库的镜像，例如。查看 `ubuntu` 仓库的镜像：

```bash
# 拉取 ubuntu 镜像
docker image pull ubuntu
# 查看镜像
docker image ls ubuntu
```

### 3.2 查看镜像详细信息

```bash
# Management Commands
docker image inspect ubuntu

# 旧的命令格式如下：
docker inspect ubuntu
```

**注意**：`docker inspect` 命令不但可以用来查看镜像的信息，也可以用来查看容器的信息。

### 3.3 搜索镜像

```bash
docker search ubuntu
```

这个命令会列出 Docker Hub 中所有包含 ubuntu 关键字的镜像。

### 3.4 拉取镜像

使用如下命令：

```bash
# Management Commands
docker image pull [OPTIONS] NAME[:TAG|@DIGEST]

# 旧的命令格式如下：
docker pull [OPTIONS] NAME[:TAG|@DIGEST]
```

比较常用的配置参数为 `-a`，代表下载仓库中的所有镜像，即下载整个存储库。

下载 `ubuntu:14.04` 镜像，使用如下命令：

```bash
docker image pull ubuntu:14.04
```

除了通过标签来拉取具体的镜像， 还可以通过摘要来拉取不同标签的镜像。从刚刚下载的结果，有一行 Digest 信息，这就是摘要信息。

还可以通过摘要拉取镜像：首先删除刚刚下载的镜像 `docker image rm ubuntu:14.04`。此处以获取到的 Digest 为例，具体 Digest 参数应参照你操作时的实际值。

### 3.5 构建镜像

`pull` 的新镜像 `ubuntu:14.04` 对其进行更新，可以创建一个容器，在容器中进行修改，然后将修改提交到一个新的镜像中。

提交修改使用如下命令：

```bash
# Management Commands
docker container commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]

# 旧的命令格式如下：
docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]
```

该命令的解释为从一个容器的修改中创建一个新的镜像。例如，运行一个容器，然后在其中创建一个文件，最后使用 `commit` 命令：

```bash
# 使用 run 创建运行一个新命令
docker container run \
    --name dafa \
    -it busybox /bin/sh

# 在运行的容器中创建两个文件，test1 和 test2
touch test1 test2

# 使用 ctrl + p  及  ctrl + q 键退出
# 使用提交命令，提交容器 dafa 的修改到镜像 busybox:test 中
docker container commit dafa busybox:test

# 查看通过提交创建的镜像
docker image ls busybox
```

通过上述操作创建了一个新的镜像 `busybox:test`。但是这个方法不推荐用在生产系统中，因为未来会很难维护镜像。最好的创建镜像的方法是 Dockerfile，修改镜像的方法是修改 Dockerfile，然后重新从 Dockerfile 中构建新的镜像。

**BUILD 镜像**

Docker 可以从一个 Dockerfile 文件中自动读取指令构建一个新的镜像。 Dockerfile 是一个包含用户构建镜像命令的文本文件。在创建该文件后使用如下命令构建镜像：

```bash
docker image build [OPTIONS] PATH | URL
```

构建镜像的第一件事是将 Dockerfile 文件所在目录下的所有内容递归的发送到守护进程。所以在大多数情况下，最好是创建一个新的目录，在其中保存 Dockerfile，并在其中添加构建 Dockerfile 所需的文件。

对于一个 Dockerfile 文件内容来说，基本语法格式如下所示：

```bash
# Comment
INSTRUCTION arguments
```

使用 `#` 号作为注释，指令（`INSTRUCTION`）不区分大小写，但是为了可读性，一般将其大写。而 Dockerfile 的指令一般包含下面几个部分：

- 基础镜像：以哪个镜像为基础进行制作，使用 `FROM` 指令来指定基础镜像，一个 Dockerfile 必须以 `FROM` 指令启动。
- 维护者信息：可以指定该 Dockerfile 编写人的姓名及邮箱，使用 `MAINTAINER` 指令。
- 镜像操作命令：对基础镜像要进行的改造命令，比如安装新的软件，进行哪些特殊配置等，常见的是 `RUN` 命令。
- 容器启动命令：基于该镜像的容器启动时需要执行哪些命令，常见的是 `CMD` 命令或 `ENTRYPOINT`

例如一个最基本的 Dockerfile：

```dockerfile
# 指定基础镜像
FROM ubuntu:14.04

# 维护者信息
MAINTAINER fa1053@163.com

# 镜像操作命令
RUN \
    apt-get -yqq update && \
    apt-get install -yqq apache2

# 容器启动命令
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
```

通过阅读上述命令创建了一个 `apache` 的镜像。包含了最基本的四项信息。

其中 `FROM` 指定基础镜像。`RUN` 命令默认使用 `/bin/sh`，并使用 `root` 权限执行。`CMD` 命令也是默认在 `/bin/sh` 中执行，但是只能有一条 `CMD` 指令，如果有多条则只有最后一条会被执行。

创建一个空目录，并在其中编辑 Dockerfile 文件，并基于此构建一个新的镜像，使用如下操作：

```bash
# 首先创建目录并切换目录
mkdir /home/dafa/test1 && cd /home/dafa/test1

# 编辑 Dockerfile 文件，默认文件名为 Dockerfile，也可以使用其它值，使用其它值需要在构建时通过 `-f` 参数指定，这里使用默认值。并在其中添加上述示例的内容。
vim Dockerfile

# 使用 build 命令，`-t` 参数指定新的镜像，. 是基于该目录下的 Dockerfile 构建
docker image build -t dafa:1.0 .
```

在执行构建命令后，需要花费一些时间来完成构建。构建完成后，使用该镜像启动一个容器来运行 `apache` 服务，运行如下命令：

```bash
# 使用 -p 参数将本机的 8000 端口映射到容器中的 80 端口上。
docker container run \
    -d -p 8000:80 \
    --restart=always \
    --name dafa_apache dafa:1.0
```

其中 `--restart=always` 选项保证容器始终不关闭，如果不加此参数无法运行时，可以加上这个参数保证容器一直在运行。

此时，容器启动成功后，并且配置了端口映射可以通过本机的 `8000` 端口访问容器 `dafa_apache` 中的 `apache` 服务了。打开浏览器，输入 `localhost:8000`，可以看到 apache 界面。

如果 `localhost:8000` 无法访问，那么可以输入 `127.0.0.1:8000`。更多有关于 Dockerfile 文件格式的信息可以参考官方文档 https://docs.docker.com/engine/reference/builder/。

### 3.6 删除镜像

```bash
# Management Commands
docker image rm ubuntu:latest

# 旧的命令格式如下：
docker rmi ubuntu:latest
```

如果该镜像正在被一个容器所使用，需要将容器删除才能成功的删除镜像。

### 3.7 导出与导入镜像

导出本地镜像

```shell
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
test               latest              aba01f181a4a        5 seconds ago       593 MB
# 使用save根据ID导出
$ docker save aba01f181a4a > /opt/test.tar
# 根据tag导出, -o 和 > 作用相同
$ docker save -o test.tar test:latest
# 使用import
$ docker export -o test.tar test:latest
```

复制到目标机器导入

```shell
# -i 与 < 作用相同
$ docker load -i test.tar
# 使用import导入
$ docker import test.tar test:latest
$ docker images
REPOSITORY         TAG          IMAGE ID            CREATED             SIZE
<none>             <none>       aba01f181a4a        20 minutes ago      593 MB
# 增加仓库名与标签
$ docker tag aba01f181a4a test:latest
# 运行
$ docker run -itd test:latest
```

## 4 存储管理

- 使用 volumes
- 使用 bind mounts
- 使用 tmpfs
- 数据卷容器
- 数据卷的备份与恢复

### 4.1 存储

对于数据来说，可以将其保存在容器中，但是会存在一些缺点：

- 当容器不再运行时，无法使用数据，并且容器被删除时，数据并不会被保存。
- 数据保存在容器中的可写层中，无法轻松的将数据移动到其他地方。

针对上述的缺点而言，有些数据信息，例如数据库文件，不应该将其保存在镜像或者容器的可写层中。Docker 提供三种不同的方式将数据从 Docker 主机挂载到容器中，分别为卷（`volumes`），绑定挂载（`bind mounts`），临时文件系统（`tmpfs`）。很多时候，`volumes` 总是正确的选择。

- `volumes` 卷存储在 Docker 管理的主机文件系统的一部分中（`/var/lib/docker/volumes/`）中，完全由 Docker 管理。
- `bind mounts` 绑定挂载，可以将主机上的文件或目录挂载到容器中。
- `tmpfs` 仅存储在主机系统的内存中，而不会写入主机的文件系统。

无论使用上述的哪一种方式，数据在容器内看上去都是一样的。它被认为容器文件系统中的目录或单个文件。

#### 4.1.1 卷列表

对于三种不同的存储数据的方式来说，卷是唯一完全由 Docker 管理的。它更容易备份或迁移，并且可以使用 `Docker CLI` 命令来管理卷。

列出本地可用的卷列表可以使用如下命令：

```bash
docker volume ls
```

![image](https://doc.shiyanlou.com/courses/uid214893-20200529-1590735670983)

运行之后，可能会看到一些环境中预置镜像对应的卷，或者显示为空。

**创建卷**

```bash
docker volume create
```

上述命令会创建一个数据卷，并且会随机生成一个名称。创建之后可以查看卷列表：

```bash
docker volume ls
```

这种由系统随机生成名称的创建卷的方式被称为 **匿名卷**，直接使用该卷需要指定卷名，即自动生成的 `ID`，所以创建卷时一般手动指定其 `name`，例如我们创建一个名为 `volume1` 的卷。

```bash
docker volume create volume1
```

**挂载卷**

创建卷之后，用卷来启动一个容器，这里需要了解 `docker container run` 命令的两个参数：

- ```bash
  -v 或 --volume
  ```

  - 由三个冒号（:）分隔的字段组成，`[HOST-DIR:]CONTAINER-DIR[:OPTIONS]`。
  - `HOST-DIR` 代表主机上的目录或数据卷的名字。省略该部分时，会自动创建一个匿名卷。如果是指定主机上的目录，需要使用绝对路径。
  - `CONTAINER-DIR` 代表将要挂载到容器中的目录或文件，即表现为容器中的某个目录或文件
  - `OPTIONS` 代表配置，例如设置为只读权限（`ro`），此卷仅能被该容器使用（`Z`），或者可以被多个容器使用（`z`）。多个配置项由逗号分隔。

例如，使用 `-v volume1:/volume1:ro,z`。代表的是意思是将卷 `volume1` 挂载到容器中的 `/volume1` 目录。`ro,z` 代表该卷被设置为只读（`ro`），并且可以多个容器使用该卷（`z`）。

- ```bash
  --mount
  ```

  - 由多个键值对组成，键值对之间由逗号分隔。例如：`type=volume,source=volume1,destination=/volume1,ro=true`。
  - `type`，指定类型，可以指定为 `bind`，`volume`，`tmpfs`。
  - `source`，当类型为 `volume` 时，指定卷名称，匿名卷时省略该字段。当类型为 `bind`，指定路径。可以使用缩写 `src`。
  - `destination`，挂载到容器中的路径。可以使用缩写 `dst` 或 `target`。
  - `ro` 为配置项，多个配置项直接由逗号分隔一般使用 `true` 或 `false`。

针对上述创建的卷 `volume1`，用其来运行一个容器就可以使用如下命令：

```bash
docker container run \
    -it \
    --name dafa01 \
    -v volume1:/volume1 \
    --rm ubuntu /bin/bash
```

或者也可以使用 `--mount`，其语法格式如下：

```bash
docker container run \
    -it --name dafa02 \
    --mount type=volume,src=volume1,target=/volume1 \
    --rm ubuntu /bin/bash
```

从命令中，可以很明显的得出，`--mount` 的可读性更好。所以推荐使用 `--mount`。

在 `docker container run` 中使用了参数 `--rm`，它的作用在容器退出时删除容器。如果创建的镜像只是希望它短期运行，其用户数据并无保留的必要，可以在容器启动时设置 `--rm` 选项，这样在容器退出时就能够自动清理容器内部的文件系统。

值得注意的是，后台运行的容器无法使用 `-d` 与 `--rm` 选项。

上述操作分别运行了两个容器，并分别挂载了一个卷，还可多次使用该参数挂载多个卷或目录。并且对于这两个容器来说，由于使用的是同一个卷，所以他们将共享该数据卷，但是对于多个容器共享数据卷时，需要注意并发性。可以分别连接到两个容器中，操作数据，验证其是同步的。

#### 4.1.2 绑定挂载

对于数据卷来说，其优点在于方便管理。而对于绑定挂载 bind-mounts 来说，通过将主机上的目录绑定到容器中，容器就可以操作和修改主机上该目录的内容。这既是其优点也是其缺点。

例如，将 `/home/dafa` 目录挂载到容器中的 `/home/dafa` 目录下，使用的命令如下：

```bash
docker container run \
    -it \
    -v /home/dafa:/home/dafa \
    --name dafa03 \
    --rm ubuntu /bin/bash
```

而如果使用的是 `--mount`，相应的语句如下：

```bash
docker container run \
    -it \
    --mount type=bind,src=/home/dafa,target=/home/dafa \
    --name dafa04 \
    --rm ubuntu /bin/bash
```

如果绑定挂载时指定的容器目录是非空的，则该目录中的内容将会被覆盖。并且如果主机上的目录不存在，会自动创建该目录。

上述两个操作针对的是目录，而对于挂载文件来说，可能会出现一些特殊情况，涉及到绑定挂载和使用卷的区别。下面重现这一操作：

1. 首先在当前目录，即 `/home/dafa` 目录下，创建一个 `test.txt` 文件。并向其中写入文本内容 "test1"：

   ```bash
   echo "test1" > test.txt
   ```

2. 接着创建一个容器 `dafa05`，将 `test.txt` 文件挂载到容器中的 `/test.txt` 文件，并查看容器中 `/test.txt` 文件的内容：

   ```bash
   docker container run \
       -it \
       -v /home/dafa/test.txt:/test.txt \
       --name dafa05 ubuntu /bin/bash
   ```

3. 这时新打开一个终端，通过 `echo` 命令向 `/home/dafa/test.txt` 文件追加内容 "test2"，并在容器中查看 `/test.txt` 文件的内容：

   ```bash
   echo "test2" >> test.txt
   ```

4. 这时无论是在容器中还是主机上都能查看到该文件的内容。接下来在主机上通过 `ls -i test.txt` 查看 `test.txt` 的 `inode` 号，并使用 VIM 编辑该文件，添加 "test3"，并查看该文件的内容。

在主机上使用 VIM 编辑后，通过 VIM 做出的修改不能在容器中查看到。这是因为 VIM 编辑保存文件的时候，会将文件内容写入到一个新的文件中，保存好后，删除掉原来的文件，并将新文件重命名，从而完成保存的操作。但是标识文件是通过 `inode`，因此 Docker 绑定的主机文件，依旧是 VIM 编辑之前的 `inode`，即旧文件。所以容器中看到的，依然是旧的内容。

对于数据卷来说，由 Docker 完全管理，而绑定挂载，则需要用户自己去维护。需要自己手动去处理这些问题，这些问题并不仅仅是上面的内容，还可能有用户权限，`SELINUX` 等问题。

简单说一下临时文件系统 `tmpfs`。它只存储在主机的内存中。当容器停止时，相应的数据就会被移除。

```bash
docker run \
    -it \
    --mount type=tmpfs,target=/test \
    --name dafa06 \
    --rm ubuntu bash
```

### 4.2 数据卷容器

如果容器之间需要共享一些持续更新的数据，最简单的方式就是使用用户数据卷容器。其他容器通过挂载这个容器实现数据共享，这个挂载数据卷的容器就叫做数据卷容器。数据卷容器就是一种普通容器，它专门提供数据卷供其它容器挂载使用。

首先，创建一个数据卷和数据卷容器：

```bash
# 创建一个名为 vdata 的数据卷
docker volume create vdata

# 创建一个挂载了 vdata 的容器，这个容器就是数据卷容器
docker container run \
    -it \
    -v vdata:/vdata \
    --name dafaVolume ubuntu /bin/bash

# 在 /vdata 目录下创建一个文本文件
echo "I am dafaVolume" > /vdata/f.txt
```

分别打开新的终端输入以下命令，创建两个容器，在执行 `docker container run` 时，添加参数 `--volumes-from` 继承数据卷容器 dafaVolume 挂载的数据卷。进入容器后分别创建文件

```bash
# 创建容器 test1
docker container run \
    -it \
    --volumes-from dafaVolume \
    --name test1 ubuntu /bin/bash

# 查看 vdata 目录是否存在
ls -dl /vdata/

# 创建一个文件，并写入内容
echo "I am test1" > /vdata/test1.txt
```

执行上述操作，创建容器 test2。

```bash
# 创建容器 test2
docker container run \
    -it \
    --volumes-from dafaVolume \
    --name test2 ubuntu /bin/bash

# 查看 vdata 目录是否存在
ls -dl /vdata/

# 创建一个文件，并写入内容
echo "I am test2" > /vdata/test2.txt
```

进入到 dafaVolume 容器所在的终端，在挂载的数据中查看文件的内容：

```bash
# 查看数据卷中的内容
ls -al /vdata/
```

从结果中可以看到数据卷在三个容器之间是共享的。

#### 4.2.1 数据备份

数据存在于数据卷中，如果想要备份它，可以采用创建备份容器的方式。

```bash
docker container run \
   --volumes-from dafaVolume \
   -v /home/dafa/backup:/backup \
   ubuntu tar cvf /backup/backup.tar /vdata/
```

- `--volumes-from dafaVolume` 使得备份容器继承容器 dafaVolume 的数据卷。
- `-v /home/dafa/backup:/backup` 把 `/home/dafa/backup` 目录采用绑定挂载的方式，挂载到容器的 `/backup` 目录上。
- `tar cvf /backup/backup.tar /vdata` 容器中执行了这么一条压缩归档命令，将 `/vdata` 中的全部数据打包到了 `/backup/backup.tar`，而刚刚的数据绑定，使得整个压缩包存在于主机中，从而达到了数据备份的效果。

执行完毕可以看到数据卷中的所有数据都被打包到了 `/home/dafa/backup` 目录中。

#### 4.2.2 数据恢复

与数据备份相同的方式，可以使用如下命令创建恢复容器，来还原数据卷中的数据。

```bash
docker container run \
   --volumes-from dafaVolume \
   -v /home/dafa/backup:/backup \
   ubuntu tar xvf /backup/backup.tar -C /
```

这里解压的路径为 `/` 即 `/vdata` 的上一级目录。

## 5 网络管理

将前面创建或启动的容器全部删除。

```bash
# 暂停所有运行中的容器
docker container ls -q | xargs docker container stop

# 删除所有的容器，慎用
docker container ls -aq | xargs docker container rm
```

安装 Docker 后默认会自动创建三个网络。查看网络：

```bash
docker network ls
```

三种默认的网络分别为 `bridge`，`host`，`none`。

### 5.1 桥接网络

bridge 即桥接网络，在安装 Docker 后会创建一个桥接网络，该桥接网络的名称为 `docker0`。可以通过下面两条命令去查看该值。

```bash
# 查看 bridge 网络的详细信息，并通过 grep 获取名称项
docker network inspect bridge | grep name

# 使用 ifconfig 查看 docker0 网络
ifconfig
```

默认情况下，创建一个新的容器都会自动连接到 bridge 网络。使用 `docker network inspect bridge` 查看网桥网络的详细信息。

看到 `docker0` 的默认网段 Subnet 项。尝试创建一个容器，该容器会自动连接到 bridge 网络，创建一个名为 `dafa001` 的容器：

```bash
docker container run --name dafa001 -itd ubuntu /bin/bash
```

上述命令中默认使用 `--network bridge` ，即指定 bridge 网络。创建后，再次查看 bridge 的信息：

![image](https://doc.shiyanlou.com/courses/uid214893-20200529-1590739047961)

这时可以查看到相应的容器的网络信息，该容器在连接到 bridge 网络后，会从子网的地址池中获得一个 IP 地址。

使用 `docker container attach dafa001` 命令，也可查看相应的地址信息：

> 如果提示无 `ifconfig` 命令，可以在容器中执行 `apt update && apt install net-tools` 安装。

并且对于连接到默认的 bridge 之间的容器可以通过 IP 地址互相通信。启动一个 `dafa002` 的容器，它可以与 `dafa001` 通过 IP 地址进行通信。

> 如果提示无 `ping` 命令，可以在容器中执行 `apt update && apt install -y iputils-ping` 安装。

其具体的实现原理可以参考链接 [Linux 上的基础网络设备](https://cloud.tencent.com/developer/article/1115583)，以及涉及到 [网桥的工作原理](https://www.jianshu.com/p/9070f4bfeddf)

但是对于应用程序来讲，如果需要在外部进行访问，还会涉及到端口的使用，而 Docker 对于 bridge 网络使用端口的方式为设置端口映射，通过 `iptables` 实现。

下面我们通过 `iptables` 来实现在 docker 中实现端口映射的方式，主要针对 `nat` 表和 `filter` 表：

首先删除掉上面创建的两个容器，查看 `nat` 表的转发规则，使用如下命令：

```bash
sudo iptables -t nat -nvL
```

![image](https://doc.shiyanlou.com/courses/uid214893-20200529-1590740971811)

由于此时并未创建 docker 容器，nat 表中没有什么特殊的规则。接下来，我们使用之前在 Docker 镜像管理中构建的 `dafa:1.0` 镜像创建一个容器 `dafa001`。构建镜像 `dafa:1.0` 的 DockerFile 如下，具体的构建过程请参考之前的内容：

```dockerfile
# 指定基础镜像
FROM ubuntu:14.04

# 维护者信息
MAINTAINER fa1053@163.com

# 镜像操作命令
RUN \
    apt-get -yqq update && \
    apt-get install -yqq apache2

# 容器启动命令
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
```

构建好 `dafa:1.0` 镜像后，启动一个容器 `dafa001`，并将本机的端口 `10001` 映射到容器中的 `80` 端口上。

```bash
docker run -d -p 10001:80 --name dafa001 dafa:1.0
```

其中 `docker container run` 命令的 `-p` 参数是通过端口映射的方式，将容器的端口发布到主机的端口上。其使用格式为 `-p ip:hostPort:containerPort`。并且还可以指定范围，例如 `-p 10001-10100:1-100`，代表将容器 `1-100` 的端口映射到主机上的 `10001-10100` 端口上，两者一一对应。

创建成功后，我们可以在浏览器中输入 `localhost:10001` 访问到容器 `dafa001` 的 `apache` 服务。

查看此时 `iptables` 中 `nat` 表和 `filter` 表的规则，其中分别新增了一条比较重要的内容。

### 5.2 自定义网络

对于默认的 bridge 网络来说，使用端口可以通过端口映射的方式来实现，并且容器之间通过 IP 地址互相进行通信。但是对于默认的 bridge 网络来说，每次重启容器，容器的 IP 地址都是会发生变化的，因为对于默认的 bridge 网络来说，并不能在启动容器的时候指定 ip 地址，在启动单个容器时并不容易看到这一区别。

**旧版的容器互联**

容器间都是通过在 `/etc/hosts` 文件中添加相应的解析，通过容器名，别名，服务名等来识别需要通信的容器。

先把之前的 `dafa001` 容器删除，启动两个容器，来演示旧的容器互联：

首先启动一个名为 `dafa001` 的容器，使用镜像 `busybox`：

```bash
docker run -it --rm --name dafa001 busybox /bin/sh
```

然后，打开一个新的终端，启动一个名为 `dafa002` 的容器，并使用 `--link` 参数与容器 `dafa001` 互联。

```bash
docker run -it --rm --name dafa002 --link dafa001 busybox /bin/sh
```

docker run 命令的 `--link` 参数的格式为 `--link <name or id>:alias`。格式中的 `name` 为容器名，`alias` 为别名。即可以通过 `alias` 访问到该容器。

`dafa001` 的 IP 为 `172.17.0.2`， `dafa002` 的 IP 为 `172.17.0.3`。在后者中可以使用 `ping dafa001` 通信。

如果此时 `dafa001` 容器退出，这时我们启动一个 `dafa003`，再次启动一个 `dafa001`：

```bash
docker run -itd --name dafa003 --rm busybox /bin/sh
docker run -it --name dafa001 --rm busybox /bin/sh
```

按照顺序分配的原则，此时 `dafa003` 的 IP 地址为 `172.17.0.2`，容器 `dafa001` 的 IP 地址为 `172.17.0.4`。并且此时容器 `dafa002` 中 `/etc/hosts` 文件的解析依旧不变，所以不能获取到正确的解析。

旧的容器 `dafa002` 通过 `--link` 连接到 `dafa001`。而在 `dafa001` 重启后，由于 IP 地址的变化，此时 `dafa002` 并不能正确的访问到 `dafa001`，`ping dafa001` 显示的是地址是 `172.17.0.2`。

除了使用 `--link` 链接的方式来达到容器间互联的效果，在 Docker 中，容器间通信的推荐方式为自定义网络。

**自定义网络**

Docker 在安装时会默认创建一个桥接网络，除了使用默认网络之外，还可以创建自己的 bridge 或 `overlay` 网络。

创建一个名为 `network1` 的桥接网络，简单命令如下：

```bash
docker network create network1
docker network ls
```

创建成功后，可以使用 `ifconfig` 或者 `ip addr show` 命令查看该桥接网络的网络接口信息，而对于该网络的详细信息可以通过 `docker network inspect network1` 命令来查看，其相应的网络接口名称和子网都是由 docker 随机生成，当然也可以手动指定：

```bash
# 首先删除掉刚刚创建的 network1
docker network rm network1
# 再次创建 network1，指定子网
docker network create -d bridge --subnet=192.168.16.0/24 --gateway=192.168.16.1 network1
```

运行一个容器 `dafa001`（需要把之前创建运行的 `dafa001` 容器删除），指定其网络为 `network1`，使用 `--network network1`：

```bash
docker run -it --name dafa001 --network network1 --rm busybox /bin/sh
```

使用 `exit` 退出该容器使其自动删除，再次创建该容器，但是不指定其 `--network`：

```bash
docker run -it --name shiyanlou001 --rm busybox /bin/sh
```

此时，该容器连接到默认的 bridge 网络，这时，**可以新打开一个终端**，在其中运行如下命令，将 `dafa001` 连接到 `network1` 网络中：

```bash
# 在新打开的终端中运行，将容器 dafa001 连接到 network1 网络中
docker network connect network1 dafa001
```

这时再次在容器 `dafa001` 中使用 `ifconfig` 命令，可以看到出现了一个 `eth1` 接口，此时，`eth0` 连接到默认的 bridge 网络，`eth1` 连接到 `network1` 网络。

对于自定义的网络来说，docker 嵌入的 `DNS` 服务支持连接到该网络的容器名的解析。这意味着连接到同一个网络的容器都可以通过容器名去 `ping` 另一个容器。

如下所示，启动两个容器，连接到 `network1`：

```bash
docker run -itd --name dafa_1 --network network1 --rm busybox /bin/sh
docker run -it --name dafa_2 --network network1 --rm busybox /bin/sh
```

启动之后，由于上述的两个容器都是连接到 `network1` 网络，所以可以通过容器名 `ping` 通。除此之外，在用户自定义的网络中，是可以通过 `--ip` 指定 IP 地址的，但在默认的 bridge 网络不能指定 IP 地址：

```bash
# 连接到 network1 网络，运行成功
docker run -it --network network1 --ip 192.168.16.100 --rm busybox /bin/sh
# 连接到默认的 bridge 网络，下面的命令运行失败
docker run -it --rm busybox --ip 192.168.16.100 --rm busybox /bin/sh
```

### 5.3 host 和 none

当容器的网络为 `host` 时，容器可以直接访问主机上的网络。

启动一个容器，指定网络为 `host`：

```bash
docker run -it --network host --rm busybox /bin/sh
```

`none` 网络，容器中不提供其它网络接口。none 网络的容器创建之后还可以自己 connect 一个网络，比如使用 `docker network connect bridge 容器名` 可以将这个容器添加到 bridge 网络中。

```bash
docker run -it --network none --rm busybox /bin/sh
```

## 6 编写 DockerFile

Dockerfile 是一个文本文件，其中包含为了构建 Docker 镜像而手动执行的所有命令。Docker 可以从 Dockerfile 中读取指令来自动构建镜像。可以使用 `docker build` 命令来自动构建。

### 6.1 上下文

在 3.5 一节中有提到构建镜像的一些知识。

构建镜像时，该过程的第一件事是将 Dockerfile 文件所在目录下的所有内容递归的发送到守护进程。所以在大多数情况下，最好是创建一个新的目录，在其中保存 Dockerfile，并在其中添加构建 Dockerfile 所需的文件。而 Dockerfile 文件所在的路径也被称为上下文（context）。

首先创建一个目录，以便开始后面的实验过程：

```bash
mkdir dir1 && cd dir1
```

下面简单介绍 Dockerfile 中常用的指令。

### 6.2 FROM

使用 FROM 指令指定一个基础镜像，后续指令将在此镜像的基础上运行：

```dockerfile
FROM ubuntu:14.04
```

### 6.3 USER

在 Dockerfile 中可以指定一个用户，后续的 `RUN`，`CMD` 以及 `ENTRYPOINT` 指令都会使用该用户去执行，但是该用户必须提前存在。

```dockerfile
USER dafa
```

### 6.4 WORKDIR

除了指定用户之外，还可以使用 `WORKDIR` 指定工作目录，对于 `RUN`，`CMD`，`COPY`，`ADD` 指令将会在指定的工作目录中去执行。也可以理解为命令执行时的当前目录。

```dockerfile
WORKDIR /
```

### 6.5 RUN & CMD & ENTRYPOINT

RUN 指令用于执行命令，该指令有两种形式：

- `RUN <command>`，使用 shell 去执行指定的命令 `command`，一般默认的 shell 为 `/bin/sh -c`。
- `RUN ["executable", "param1", "param2", ...]`，使用可执行的文件或程序 `executable`，给予相应的参数 `param`。

例如执行更新命令：

```dockerfile
RUN apt-get update
```

CMD 的使用方式跟 RUN 类似，不过**在一个 Dockerfile 文件中只能有一个 CMD 指令，如果有多个 CMD 指令，则只有最后一个会生效**。该指令为运行容器时提供默认的命令，例如：

```dockerfile
CMD echo "hello dafa"
```

在构建镜像时使用了上面的 `CMD` 指令，则可以直接使用 `docker run image`，该命令等同于 `docker run image echo "hello dafa"`。即作为默认执行容器时默认使用的命令，也可在 `docker run` 中指定需要运行的命令来覆盖默认的 `CMD` 指令。

除此之外，该指令还有一种特殊的用法，在 Dockerfile 中，如果使用了 ENTRYPOINT 指令，则 CMD 指令的值会作为 ENTRYPOINT 指令的参数：

```shell
CMD ["param1", "param2"]
```

**ENTRYPOINT 指令会覆盖 CMD 指令作为容器运行时的默认指令，并且不会在 `docker run` 时被覆盖**，如下示例：

```shell
FROM ubuntu:latest
ENTRYPOINT ["ls", "-a"]
CMD ["-l"]
```

上述构建的镜像，在使用 `docker run <image>` 时等同于 `docker run <image> ls -a -l` 命令。使用 `docker run <image> -i -s` 命令等同于 `docker run <image> ls -a -i -s` 指令。即 **CMD 指令的值会被当作 ENTRYPOINT 指令的参数附加到 ENTRYPOINT 指令的后面，并且如果 `docker run` 中指定了参数，会覆盖 `CMD` 中给出的参数。**

### 6.6 COPY & ADD

COPY 和 ADD 都用于将文件，目录等复制到镜像中。使用方式如下：

```dockerfile
ADD <src>... <dest>
ADD ["<SRC>",... "<dest>"]

COPY <src>... <dest>
COPY ["<src>",... "<dest>"]
```

`<src>` 可以指定多个，但是其路径不能超出上下文的路径，即必须在跟 Dockerfile 同级或子目录中。

`<dest>` 不需要预先存在，不存在路径时会自动创建，如果没有使用绝对路径，则 `<dest>` 为相对于工作目录的相对路径。

COPY 和 ADD 的不同之处在于，ADD 可以添加远程路径的文件，并且 `<src>` 为可识别的压缩格式，如 gzip 或 tar 归档文件等，ADD 会自动将其解压缩为目录。

### 6.7 ENV

ENV 指令用于设置环境变量：

```dockerfile
ENV <key> <value>
ENV <key>=<value> <key>=<value>...
```

### 6.8 VOLUME

VOLUME 指令将会创建指定的挂载目录，在容器运行时，将创建相应的匿名卷：

```dockerfile
VOLUME /data1 /data2
```

上述指令将会在容器运行时，创建两个匿名卷，并挂载到容器中的 `/data1` 和 `/data2` 目录上。

### 6.9 EXPOSE

EXPOSE 指定在容器运行时监听指定的网络端口，它与 `docker run` 命令的 `-p` 参数不一样，并不实际映射端口，只是将该端口暴露出来，允许外部或其它的容器进行访问。

要将容器端口暴露出来，需要在 `dcoker run` 命令中使用 `-p` 或者 `--publish` 参数。如果采用 `-P` 随机映射端口的方式，Docker 会将在 DockerFile 中声明的所有 EXPOSE 的端口随机映射。

```dockerfile
EXPOSE port
```

### 6.10 从 DockerFile 创建镜像

基于上述指令来构建一个镜像。如下所示，搭建一个 ssh 服务:

```dockerfile
# 指定基础镜像
FROM ubuntu:14.04

# 安装软件
RUN apt-get update && apt-get install -y openssh-server && mkdir /var/run/sshd

# 添加用户 shiyanlou 及设定密码
RUN useradd -g root -G sudo dafa && echo "dafa:123456" | chpasswd dafa

# 暴露 SSH 端口
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
```

建一个空目录 `dir1` 中编辑 Dockerfile 文件，并将上面的内容复制到该文件中，相关的命令如下所示：

```bash
# 创建目录
mkdir dir1 && cd dir1

# 编辑 Dockerfile，将上面的内容写入
vim Dockerfile

# 最后执行构建命令
docker build -t sshd:test .
```

在上面的命令执行完成之后，该镜像就构建成功了，直接使用该镜像启动一个容器就可以运行一个 ssh 的服务：

```bash
docker run -itd -p 10001:22 sshd:test
```

这时就可以通过公网的 IP 地址，以及端口 10001，并且使用用户 `dafa`，密码 `123456`，远程通过 `ssh` 连接到该容器中了。

使用回环地址来进行测试，即自己请求自己的 ssh 连接。

首先安装 openssh 客户端，对应的命令为 `apt-get install openssh-client`。然后连接本机的 ssh-server，使用的命令为 `ssh -p 10001 dafa@127.0.0.1`，这里的 `-p 10001` 即使用端口 10001，也就是刚刚映射的端口。

## 7 理解 Dockerfile

### 7.1 创建 Dockerfile 文件

通过 Dockerfile 创建 MongoDB 或 Redis 应用。Dockerhub 上已经提供了官方的 MongoDB 和 Redis 镜像，本文档仅用于学习 Dockerfile 及 Docker 机制。

MongoDB 是一个基于分布式文件存储的数据库。由 C++ 语言编写。旨在为 WEB 应用提供可扩展的高性能数据存储解决方案。MongoDB 是一个介于关系数据库和非关系数据库之间的产品，是非关系数据库当中功能最丰富，最像关系数据库的。特点是高性能、易部署、易使用，存储数据非常方便。

Redis 是一个开源的使用 ANSI C 语言编写、支持网络、可基于内存亦可持久化的日志型、Key-Value 数据库，并提供多种语言的 API。

除了安装所需的核心服务外，还安装一个 ssh 服务提供便捷的管理。

为了提高 `docker build` 速度，使用阿里云的 Ubuntu 源。因此要在 Dockerfile 开始位置增加下面一句命令：

```dockerfile
RUN echo "deb http://mirrors.cloud.aliyuncs.com/ubuntu/ trusty main universe" > /etc/apt/sources.list
```

创建一个目录来存放 Dockerfile 文件，目录名称可以任意，在目录里创建 Dockerfile 文件：

```bash
cd
mkdir dafamongodb dafaredis
touch dafamongodb/Dockerfile dafaredis/Dockerfile
```

### 7.2 Dockerfile 基本框架

输入下面的基本框架内容：

```dockerfile
# Version 0.1

# 基础镜像
FROM ubuntu:14.04

# 维护者信息
MAINTAINER fa1053@163.com

# 镜像操作命令
RUN echo "deb http://mirrors.cloud.aliyuncs.com/ubuntu/ trusty main universe" > /etc/apt/sources.list
RUN apt-get update && apt-get install -yqq supervisor && apt-get clean

# 容器启动命令
CMD ["supervisord"]
```

上面的 Dockerfile 创建了一个简单的镜像，并使用 `Supervisord` 启动服务。

在上述基本的架构下，根据需求可以增加新的内容到 Dockerfile 中，完成 MongoDB Dockerfile。首先，进入到 dafamongodb 的目录编辑 Dockerfile，并填入上面的框架：

```bash
cd /home/dafa/dafamongodb/
vim Dockerfile
```

##### 7.2.1 安装 SSH 服务

```dockerfile
RUN apt-get install -yqq openssh-server openssh-client
```

创建运行目录：

```dockerfile
RUN mkdir -p /var/run/sshd
```

设置 root 密码及允许 root 通过 ssh 登录：

```dockerfile
RUN echo 'root:dafa' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
```

##### 7.2.2 安装最新的 MongoDB

在 Ubuntu 最新版本下安装 MongoDB 非常简单，参考 [MongoDB 安装文档](https://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/) 。有两种方法：

方法 1：添加 mongodb 的源，执行 `apt-get install mongodb-org` 就可以安装下面的所有软件包：

- mongodb-org-server：mongod 服务和配置文件。
- mongodb-org-mongos：mongos 服务。
- mongodb-org-shell：mongo shell 工具。
- mongodb-org-tools：mongodump，mongoexport 等工具。

方法 2：下载二进制包，然后解压出来就可以。

由于 MongoDB 的官网连接网速问题，建议使用第二种方案，并把最新的 MongoDB 的包放到阿里云上。

MongoDB 的下载链接如下。下载链接较长，建议保存到工具栏中的剪切板，在云主机中复制即可。

```shell
https://labfile.oss.aliyuncs.com/courses/498/mongodb-linux-x86_64-ubuntu1404-3.2.3.tgz
```

接着，完善 Dockerfile，使用 ADD 命令添加压缩包到镜像：

```dockerfile
RUN mkdir -p /opt
ADD https://labfile.oss.aliyuncs.com/courses/498/mongodb-linux-x86_64-ubuntu1404-3.2.3.tgz /opt/mongodb.tar.gz
RUN cd /opt && tar zxvf mongodb.tar.gz && rm -rf mongodb.tar.gz
RUN mv /opt/mongodb-linux-x86_64-ubuntu1404-3.2.3 /opt/mongodb
```

创建 MongoDB 的数据存储目录：

```dockerfile
RUN mkdir -p /data/db
```

将 MongoDB 的执行路径添加到环境变量里：

```dockerfile
ENV PATH=/opt/mongodb/bin:$PATH
```

MongoDB 和 SSH 对外的端口：

```dockerfile
EXPOSE 27017 22
```

##### 7.2.3 编写 Supervisord 配置文件

添加 Supervisord 配置文件来启动 MongoDB 和 SSH，**创建文件 `/home/dafa/dafamongodb/supervisord.conf`，添加以下内容：**

```shell
[supervisord]
nodaemon=true

[program:mongodb]
command=/opt/mongodb/bin/mongod

[program:ssh]
command=/usr/sbin/sshd -D
```

Dockerfile 中增加向镜像内拷贝该文件的命令：

```dockerfile
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
```

##### 7.2.4 完整的 Dockerfile

```dockerfile
# Version 0.1

# 基础镜像
FROM ubuntu:14.04

# 维护者信息
MAINTAINER dafa@fa1053@163.com

# 镜像操作命令
RUN echo "deb http://mirrors.cloud.aliyuncs.com/ubuntu/ trusty main universe" > /etc/apt/sources.list
RUN apt-get -yqq update && apt-get install -yqq supervisor
RUN apt-get install -yqq openssh-server openssh-client

RUN mkdir /var/run/sshd
RUN echo 'root:dafa' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN mkdir -p /opt
ADD https://labfile.oss.aliyuncs.com/courses/498/mongodb-linux-x86_64-ubuntu1404-3.2.3.tgz /opt/mongodb.tar.gz
RUN cd /opt && tar zxvf mongodb.tar.gz && rm -rf mongodb.tar.gz
RUN mv /opt/mongodb-linux-x86_64-ubuntu1404-3.2.3 /opt/mongodb

RUN mkdir -p /data/db

ENV PATH=/opt/mongodb/bin:$PATH

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 27017 22

# 容器启动命令
CMD ["supervisord"]
```

##### 7.2.5 创建 MongoDB 镜像

`docker build` 执行创建，`-t` 参数指定镜像名称：

```bash
cd /home/dafa/dafamongodb/
docker build -t dafamongodb:0.1 .
```

Biuld 结束之后，可以查看创建的新镜像是否已经出现在了镜像列表中：

```bash
docker image ls
```

由该镜像创建新的容器 mongodb：

```bash
docker run -P -d --name mongodb dafamongodb:0.1
```

这里的 `-P` 参数将容器 EXPOSE 的端口随机映射到主机的端口。查看映射到那个端口的方式是输入 `docker container ls`，在最后一项 `STATUS` 中有映射的端口信息。

对 MongoDB 是否启动进行测试，打开终端中输入下面的命令连接 mongodb 容器中的服务：

```bash
# 安装 MongoDB
sudo apt-get update && sudo apt-get install -y mongodb
# 连接容器
mongo --host 127.0.0.1 --port 32768
```

### 7.3 编写 Redis Dockerfile

##### 7.3.1 安装Redis

```dockerfile
RUN apt-get install redis-server
```

添加对外的端口号：

```dockerfile
EXPOSE 6379 22
```

##### 7.3.2 编写 Supervisord 配置文件

添加 `Supervisord` 配置文件来启动 redis-server 和 ssh，**创建文件 `/home/dafa/dafaredis/supervisord.conf`，添加以下内容：**

```shell
[supervisord]
nodaemon=true

[program:redis]
command=/usr/bin/redis-server

[program:ssh]
command=/usr/sbin/sshd -D
```

Dockerfile 中增加向镜像内拷贝该文件的命令：

```dockerfile
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
```

##### 7.3.3 完整的Dockerfile

```dockerfile
# Version 0.1

# 基础镜像
FROM ubuntu:14.04

# 维护者信息
MAINTAINER dafa@fa1053@163.com

# 镜像操作命令
RUN echo "deb http://mirrors.cloud.aliyuncs.com/ubuntu/ trusty main universe" > /etc/apt/sources.list
RUN apt-get -yqq update && apt-get install -yqq supervisor redis-server
RUN apt-get install -yqq openssh-server openssh-client

RUN mkdir /var/run/sshd
RUN echo 'root:dafa' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 6379 22

# 容器启动命令
CMD ["supervisord"]
```

#####  7.3.4 创建 Redis 镜像

`docker build` 执行创建，`-t` 参数指定镜像名称：

```bash
docker image build -t dafaredis:0.1 .
```

`docker images ls` 查看创建的新镜像已经出现在了镜像列表中：

```bash
docker image ls
```

由该镜像创建新的容器 redis：

```bash
docker run -P -d --name redis dafaredis:0.1
docker container ls
```

上述 `docker container ls` 命令的输出可以看到 Redis 的端口号已经被自动映射到了本地的 32770 端口，SSH 服务的端口号也映射到了 32771 端口。

打开终端中输入下面的命令连接 Redis 容器中的 SSH 和 Redis 服务：

```bash
ssh root@127.0.0.1 -p 32771
```

退出 SSH 连接，访问 Redis 服务。

```bash
# 安装 Redis
sudo apt-get install -y redis-server
redis-cli -h 127.0.0.1 -p 32771
```

### 7.4 Docker 运行 WordPress

`supervisord.conf` 文件启动 php5-fpm，nginx，mysql 和 ssh：

```shell
[supervisord]
nodaemon=true

[program:php5-fpm]
command=/usr/sbin/php5-fpm -c /etc/php5/fpm
autorstart=true

[program:mysqld]
command=/usr/bin/mysqld_safe

[program:nginx]
command=/usr/sbin/nginx
autorstart=true

[program:ssh]
command=/usr/sbin/sshd -D
```

为了能让 Nginx 顺利支持 `/var/www/wordpress` 目录下的 WordPress，需要添加文件到 `/etc/nginx/sites-available/default`。

**在 Dockerfile 所在的 `/home/dafa/dafawordpress` 目录下创建文件 nginx-config**，并输入以下内容：

```nginx
server {
 listen *:80;
 server_name localhost;

    root /var/www/wordpress;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php{
        try_files $uri =404;
        include fastcgi_params;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
    }
}
```

这是一个基本的 Nginx 配置，包含的核心配置信息：

- 指定 WordPress 的目录：`/var/www/wordpress`
- 设置对 PHP 页面的支持，包括设置默认 index 页面为 `index.php` 等

WordPress 配置文件为 `/var/www/wordpress/wp-config.php` ，有两种方法修改这个文件：

- 使用 sed 更改文件中需要配置的项目。
- 预先配置好该文件，在 `docker build` 过程中拷贝到镜像中替换原文件。

介绍第 1 种方法：

```dockerfile
RUN sed -i 's/database_name_here/wordpress/g' /var/www/wordpress/wp-config-sample.php
RUN sed -i 's/username_here/root/g' /var/www/wordpress/wp-config-sample.php
RUN sed -i 's/password_here/shiyanlou/g' /var/www/wordpress/wp-config-sample.php
RUN mv /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
```

其中配置了数据库连接的用户名和密码，修改完成后的 `wp-config.php` 文件节选：

```php
define('DB_NAME', 'wordpress');
/** MySQL database username */
define('DB_USER', 'root');
/** MySQL database password */
define('DB_PASSWORD', 'dafa');
```

最终得到的 Dockerfile 文件如下：

```dockerfile
# Version 0.1
FROM ubuntu:14.04

MAINTAINER dafa@fa1053@163.com

RUN echo "deb http://mirrors.cloud.aliyuncs.com/ubuntu/ trusty main universe" > /etc/apt/sources.list
RUN apt-get -yqq update
RUN apt-get -yqq install nginx supervisor wget php5-fpm php5-mysql
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

RUN mkdir -p /var/www
ADD https://labfile.oss-cn-hangzhou-internal.aliyuncs.com/courses/498/wordpress-4.4.2.tar.gz /var/www/wordpress-4.4.2.tar.gz
RUN cd /var/www && tar zxvf wordpress-4.4.2.tar.gz && rm -rf wordpress-4.4.2.tar.gz
RUN chown -R www-data:www-data /var/www/wordpress

RUN mkdir /var/run/sshd
RUN apt-get install -yqq openssh-server openssh-client
RUN echo 'root:dafa' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN echo "mysql-server mysql-server/root_password password dafa" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password dafa" | debconf-set-selections
RUN apt-get  install -yqq mysql-server mysql-client
# 80 web端口，22 ssh 端口
EXPOSE 80 22

COPY nginx-config /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN service mysql start && mysql -uroot -pshiyanlou -e "create database wordpress;"
RUN sed -i 's/database_name_here/wordpress/g' /var/www/wordpress/wp-config-sample.php
RUN sed -i 's/username_here/root/g' /var/www/wordpress/wp-config-sample.php
RUN sed -i 's/password_here/shiyanlou/g' /var/www/wordpress/wp-config-sample.php
RUN mv /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php

CMD ["/usr/bin/supervisord"]
```

完成后查看目录文件，并使用 `docker build` 执行创建，`-t` 参数指定镜像名称：

```bash
docker build -t dafawordpress:0.1 .
```

查看创建的新镜像已经出现在了镜像列表中。然后由该镜像创建新的容器 wordpress，并映射本地的 80 端口到容器的 80 端口：

```bash
docker image ls
docker run -d -p 80:80 --name wordpress dafawordpress:0.1
```

**注意：**如果出现 `Error starting userland proxy: listen tcp 0.0.0.0:80: bind: address already in use.` 报错，是由于本地的 Nginx 占用了端口，使用 `sudo service nginx stop` 关闭即可。

最后打开桌面上的 Firefox 浏览器，输入本地地址访问 `127.0.0.1/wp-admin/install.php` ，看到WordPress 网站安装配置界面，由于默认会连接 Google 的文件，所以打开会比较慢。

## 8 安全管理

### 8.1 使用证书加固 Docker Daemon 安全

Docker Daemon 启动的服务对外提供的是 HTTP 接口，为了增强 HTTP 连接的安全性，通过设置 TLS 来认证客户端是可信的，只有通过证书验证的客户端才可以连接 Docker Daemon。

通常情况下服务器和客户端证书都需要通过第三方 CA 签发，为了操作方便，使用的是自签名的证书。

**创建 CA 证书**

有时候在创建 CA 密钥的时候可能会产生一个 `unable to write 'random state'` 的报错，需要先设置一个 `RANDFILE` 的环境变量：

```bash
export RANDFILE=.rnd
```

首先创建一组 CA 私钥和公钥，先创建 CA 私钥，注意需要输入密码，这个密码是不会显示的，务必记住，下面每次使用 CA 签名时都需要输入：

```bash
sudo openssl genrsa -aes256 -out ca-key.pem 4096
Generating RSA private key, 4096 bit long modulus
................................................++
...................................++
e is 65537 (0x10001)
Enter pass phrase for ca-key.pem:        # 此处输入想设置的密码
Verifying - Enter pass phrase for ca-key.pem:  # 再次输入
```

然后使用 `ca-key.pem` 创建用来签名的公钥 `ca.pem` ，输入必要的信息：

```bash
sudo openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
Enter pass phrase for ca-key.pem:  # 输入之前设置的密码
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:CN  # 输入国家代码
State or Province Name (full name) [Some-State]:Beijing
Locality Name (eg, city) []:Beijing
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Shiyanlou # 输入组织名
Organizational Unit Name (eg, section) []:CourseTeam
Common Name (e.g. server FQDN or YOUR name) []:localhost # 输入服务器域名
Email Address []:dafa@fa1053@163.com
```

**服务端证书配置**

接着创建服务器的 key 和证书 `server.csr`，然后使用 CA 证书签发服务器证书：

```bash
sudo openssl genrsa -out server-key.pem 4096
sudo openssl req -subj "/CN=localhost" -sha256 -new -key server-key.pem -out server.csr
sudo echo subjectAltName = IP:127.0.0.1 >> extfile.cnf
# 设置仅用于服务器身份验证
sudo echo extendedKeyUsage = serverAuth >> extfile.cnf
sudo openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile extfile.cnf
```

上面的步骤中 `extfile.cnf` 文件的作用是添加允许连接的 IP 地址，注意服务器证书创建时需要输入服务器的域名，在本实验中我们是用的是 `localhost`。

**客户端证书配置**

客户端的证书用来连接 Docker Daemon 服务，同服务器端证书的操作类似，先创建 key 和 csr 证书，然后使用 CA 签发：

```bash
sudo openssl genrsa -out client-key.pem 4096
sudo openssl req -subj '/CN=client' -new -key client-key.pem -out client.csr
sudo echo extendedKeyUsage = clientAuth > client-extfile.cnf
sudo openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile client-extfile.cnf
```

终端会有如下显示：

```shell
Signature ok
subject=/CN=client
Getting CA Private Key
Enter pass phrase for ca-key.pem:   # 输入之前设置的密码
```

通过 `ll` 可以看到，已经生成了 `cert.pem` 和 `server-cert.pem`，可以删除两个证书签名请求了：

```bash
rm -v client.csr server.csr
```

为防止意外损坏密钥，删除其写入权限：

```bash
sudo chmod -v 0400 ca-key.pem server-key.pem client-key.pem
sudo chmod -v 0444 ca.pem server-cert.pem cert.pem
```

**配置服务端**

客户端的证书用来连接 Docker Daemon 服务，同服务器端证书的操作类似，先创建 key 和 csr 证书，然后使用 CA 签发：

```bash
sudo openssl genrsa -out client-key.pem 4096
sudo openssl req -subj '/CN=client' -new -key client-key.pem -out client.csr
sudo echo extendedKeyUsage = clientAuth > client-extfile.cnf
sudo openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile client-extfile.cnf
```

终端会有如下显示：

```shell
Signature ok
subject=/CN=client
Getting CA Private Key
Enter pass phrase for ca-key.pem:   # 输入之前设置的密码
```

`ll` 查看已经生成了 `cert.pem` 和 `server-cert.pem`，可以删除两个证书签名请求了：

```bash
rm -v client.csr server.csr
```

为防止意外损坏密钥，我们删除其写入权限：

```bash
sudo chmod -v 0400 ca-key.pem server-key.pem client-key.pem
sudo chmod -v 0444 ca.pem server-cert.pem cert.pem
```

**客户端连接 Docker**

直接使用不增加证书参数的方式连接并执行 `docker image ls` ，系统会返回不能连接。而使用客户端连接则可以正确执行。新开一个终端命令窗口执行如下命令：

```bash
sudo docker --tlsverify --tlscacert=ca.pem --tlscert=cert.pem --tlskey=client-key.pem -H=127.0.0.1:2376 image ls
```

为了后续实验的方便，创建一个 alias，来避免输入 docker 命令的 TLS 参数：

```bash
alias docker='sudo docker --tlsverify --tlscacert=ca.pem --tlscert=cert.pem --tlskey=client-key.pem -H=127.0.0.1:2376'

docker image ls
```

### 8.2 --privileged

有时需要容器具备更多的权限，比如操作内核模块，控制 swap 交换分区，挂载 USB 磁盘，修改 MAC 地址等。给予容器这些权限，仅仅通过一个简单的 `--privileged=true` 的参数。

为了对比，创建两台容器 dafa 和 pridafa，后者具备 `--privileged=true` 参数和特权。

首先创建一个不具备特权参数的容器 dafa，并查看容器的 IP 地址和 MAC 地址信息：

```bash
docker run -ti --name dafa ubuntu /bin/bash
```

我们在容器内尝试修改 MAC 地址，会收到 `Operation not permitted` 报错信息：

```bash
apt update && apt install -y iproute2
ip link set eth0 address 00:01:02:03:04:05
```

从 dafa 容器中退出，创建一个具备 `--privileged=true` 参数的 pridafa 容器，看是否有不同：

```bash
docker run -ti --privileged=true --name pridafa ubuntu /bin/bash
```

在这个容器中尝试修改 MAC 地址：

```bash
apt update && apt install -y iproute2
ip link set eth0 address 00:01:02:03:04:05
```

修改成功后使用 ifconfig 命令查看验证（如果提示没有安装可以使用 `apt update && apt install net-tools` 来安装）。

`Ctrl-P Ctrl-Q` 退出容器后查看两个容器中的配置信息：

```bash
docker inspect dafa | grep Privileged
docker inspect pridafa | grep Privileged
```

### 8.3 --cap-add

`--privileged=true` 的权限非常大，接近于宿主机的权限，为了防止用户的滥用，需要增加限制，只提供给容器必须的权限。所以 Docker 提供了权限白名单的机制，使用 `--cap-add` 来添加必要的权限。

为了能够修改 MAC 地址，给予新的容器 capshiyanlou 一个 `NET_ADMIN` 的权限。创建该容器，注意命令中的参数：

```bash
docker run -it --cap-add=NET_ADMIN --name capdafa ubuntu /bin/bash
```

尝试修改 MAC 地址，验证 `--cap-add` 是否起到作用。

退出容器后，可以在 `docker container inspect` 命令中查看容器的必要配置：

```bash
docker container inspect -f {{.HostConfig.Privileged}} capdafa
false

docker container inspect -f {{.HostConfig.CapAdd}} capdafa
{[NET_ADMIN]}
```

### 8.4 Docker Bench Security

Docker Benchmark Security 是一个用于 docker 安全检查的应用程序，它会去检查下面的这些项目，并提供警告信息。它是一个开源工具，参见 [GitHub-Docker Bench Security](https://github.com/docker/docker-bench-security/) 。

- 主机配置
- Docker 守护进程配置
- Docker 守护进程配置文件
- 容器镜像和构建文件
- 容器运行时间
- Docker 安全操作

接下来安装 Docker Bench Security，首先停止之前小节使用的服务端加密的进程，然后新打开一个终端，执行如下命令：

> 如果在当前终端执行需要在终端输入 `unalias docker` 取消设置别名，否则会报错。

```bash
sudo service docker start
docker run -it --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -v /var/lib:/var/lib \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/lib/systemd:/usr/lib/systemd \
    -v /etc:/etc --label docker_bench_security \
    docker/docker-bench-security
```

- `PASS` ：这些项目都是很稳固的，不需要关注，pass 越多越好。
- `WARN` ：需要修复的项目。
- `INFO` ：如果这些项目设置和安全需要相关，建议检查和修复这些项目。
- `NOTE` ：一些建议。

## 9 Docker Swarm

Swarm 是 Docker 发布的管理集群的工具，一个集群由多个运行 Docker 的主机组成。

#### Role

一个集群由多个运行 Docker 的主机组成，分别作为管理者（Manager）和工作者（Worker）两个角色。管理者管理集群中的成员，而工作者运行集群服务。给定的 Docker 主机可以是一个管理员，也可以是一个工作者，或者同时具备这两个角色。

#### Node

一个节点（Node）是参与到 Swarm 集群中的一个实例。一般表现为运行 Docker 的主机。

#### 服务与任务

一个服务是任务在管理节点或工作节点执行的定义，服务中运行的单个容器被称为任务。

使用集群模式运行服务时，一般有两种选项：

- `replicated services`（复制服务），根据设定的值，swarm 调度在节点之间运行指定的副本任务。
- `global services`（全局服务），集群在每个可用节点上运行一项任务。

一个服务的多个任务之间没有什么不同，但是对于一些特殊的服务而言，例如涉及到端口映射的服务，即便设定了多个任务，也只能启动一个。

#### 堆栈

堆栈（stack）是一组相互关联的服务，即一个堆栈能够定义和协调整个应用程序的功能，但是一些非常复杂的应用程序可能需要使用多个堆栈。

