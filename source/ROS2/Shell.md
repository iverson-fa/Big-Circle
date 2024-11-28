# Shell
## 1 工具类
### 1.1 `cd`到具体的功能包
可以放在`.bashrc`中，自动加载，添加如下命令：`source /path/to/colcon_cd.sh`
```sh
#!/bin/bash
# file name: colcon_cd.sh
function colcon_cd() {
  if [ -z "$1" ]; then
    echo "Usage: colcon_cd <package_name>"
    return 1
  fi

  PACKAGE_NAME=$1
  PACKAGE_PATH=$(colcon list --packages-select "$PACKAGE_NAME" --paths-only)

  if [ -d "$PACKAGE_PATH" ]; then
    cd "$PACKAGE_PATH" || return
  else
    echo "Package '$PACKAGE_NAME' not found in current workspace."
  fi
}

alias ccd=colcon_cd
```

### 1.2 配置rosdep
```sh
#!/bin/bash

echo "配置并初始化rosdep..."
if [ ! -f "/etc/ros/rosdep/sources.list.d/20-default.list" ]; then
	# 创建rosdep文件夹
	mkdir -p /etc/ros/rosdep/sources.list.d/
	# 设置rosdistro
	export ROSDISTRO_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/rosdistro/index-v4.yaml
	# 下载rosdep源文件
	echo "下载rosdep源文件..."
	wget https://mirrors.tuna.tsinghua.edu.cn/github-raw/ros/rosdistro/master/rosdep/sources.list.d/20-default.list -O /etc/ros/rosdep/sources.list.d/20-default.list
	# 初始化rosdepsudo 
	rosdep init || true
	# 更新rosdep
	echo "更新rosdep..."
	rosdep update
fi
```