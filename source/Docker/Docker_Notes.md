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

### 6.1 上下文

### 6.2 FROM

### 6.3 USER

### 6.4 WORKDIR

### 6.5 RUN & CMD & ENTRYPOINT

### 6.6 COPY & ADD

### 6.7 ENV

### 6.8 VOLUME

### 6.9 EXPOSE

### 6.10 从 DockerFile 创建镜像

