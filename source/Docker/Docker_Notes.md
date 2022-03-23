# Docker Notes

## 1 参考资料

- [官网](https://www.docker.com/get-started/)
- [官方文档](https://docs.docker.com/get-started/overview/)
- 


## 2 基本用法

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
sudo add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
```

```bash
# 更新 apt 索引库
sudo apt-get update
# 安装 docker-ce
sudo apt-get install docker-ce
# 加入 sudo 权限
sudo usermod -aG docker dafa
```

**使用阿里云镜像源**

国内拉取 Docker Hub 的速度非常慢，阿里云提供了镜像加速器。

编辑 `/etc/docker/daemon.json` 文件：

```bash
sudo vim /etc/docker/daemon.json
```

加入如下内容：

```bash
{
  "registry-mirrors": ["https://n6syp70m.mirror.aliyuncs.com"]
}
```

重启 Docker 服务，让修改生效：

```bash
sudo service docker restart
```

通过运行一个 `hello-world` 的镜像来验证 `Docker CE` 是否被正确的安装，使用如下命令：

```bash
docker run hello-world
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

## 4 存储管理

