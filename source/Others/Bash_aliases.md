# bash_aliases

`home` 路径下 `.bash_aliases`

```shell
alias gg='init 0'
alias pi='python3 -m pip install -U -i http://pypi.douban.com/simple --trusted-host pypi.douban.com'
alias co='cd ~/doc/Code'
alias gp='git push gitee main && git push github main'
alias tn='tmux new -s'
alias si='source install/setup.bash'
alias bli='rm -rf build log install'
alias cb='colcon build --symlink-install'
alias cb1='colcon build --symlink-install --packages-select'

export LS_COLORS='ow=01;94:'
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export PATH=~/.local/bin:$PATH

#source /opt/ros/galactic/setup.bash



find_git_branch ()
{
  local dir=. head
  until [ "$dir" -ef / ]; do
    if [ -f "$dir/.git/HEAD" ]; then
      head=$(< "$dir/.git/HEAD")
      if [[ $head = ref:\ refs/heads/* ]]; then
        git_branch="(*${head#*/*/})"
      elif [[ $head != '' ]]; then
        git_branch="(*(detached))"
      else
        git_branch="(*(unknow))"
      fi
      return
    fi
    dir="../$dir"
  done
  git_branch=''
}
PROMPT_COMMAND="find_git_branch; $PROMPT_COMMAND"
export PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[0;32m\]\$git_branch\[\033[0m\]\$ "

export WS=/home/dafa/jetson_flash/r35.1
export L4T_RELEASE_PACKAGE=$WS/Jetson_Linux_R35.1.0_aarch64.tbz2
export SAMPLE_FS_PACKAGE=$WS/Tegra_Linux_Sample-Root-Filesystem_R35.1.0_aarch64.tbz2
export BOARD=jetson-agx-orin-devkit
# 交叉编译环境
export TEGRA_KERNEL_OUT=$WS/kernel_out
export CROSS_COMPILE=$WS/l4t-gcc/bin/aarch64-buildroot-linux-gnu-
export LOCALVERSION=-tegra
# 内核目录
export KERNEL_SOURCE=$WS/Linux_for_Tegra/source/public/kernel/kernel-5.10
export ARCH=arm64
```
