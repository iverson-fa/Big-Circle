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