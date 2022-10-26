# bash_aliases

`home` 路径下 `.bash_aliases`

```shell
alias gg='init 0'
alias pi='python3 -m pip install -U -i http://pypi.douban.com/simple --trusted-host pypi.douban.com'
alias co='cd ~/doc/Code'
alias gp='git push gitee main && git push github main'

export LS_COLORS='ow=01;94:'
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export PATH=~/.local/bin:$PATH

source /opt/ros/galactic/setup.bash



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

```

