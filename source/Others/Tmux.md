# Tmux 笔记

## 1 安装

```bash
sudo apt install tmux
```

使用 [oh my tmux](https://github.com/gpakosz/.tmux)， 参考[知乎](https://zhuanlan.zhihu.com/p/112426848)

```bash
cd
git clone https://gitee.com/qingcen/tmux.git .tmux
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .
```

## 2 快捷键

一般情况下 tmux 中所有的快捷键都需要和前缀快捷键 `⌃b` 来组合使用（注：⌃ 为 Mac 的 control 键），以下是常用的窗格（pane）快捷键列表，大家可以依次尝试下：

### 2.1 窗格操作

- `%` 左右平分出两个窗格
- `"` 上下平分出两个窗格
- `x` 关闭当前窗格
- `{` 当前窗格前移
- `}` 当前窗格后移
- `;` 选择上次使用的窗格
- `o` 选择下一个窗格，也可以使用上下左右方向键来选择
- `space` 切换窗格布局，tmux 内置了五种窗格布局，也可以通过 `⌥1` 至 `⌥5`来切换
- `z` 最大化当前窗格，再次执行可恢复原来大小
- `q` 显示所有窗格的序号，在序号出现期间按下对应的数字，即可跳转至对应的窗格

### 2.2 窗口操作

tmux 除了窗格以外，还有窗口（window） 的概念。依次使用以下快捷键来熟悉 tmux 的窗口操作：

- `c` 新建窗口，此时当前窗口会切换至新窗口，不影响原有窗口的状态
- `p` 切换至上一窗口
- `n` 切换至下一窗口
- `w` 窗口列表选择，注意 macOS 下使用 `⌃p` 和 `⌃n` 进行上下选择
- `&` 关闭当前窗口
- `,` 重命名窗口，可以使用中文，重命名后能在 tmux 状态栏更快速的识别窗口 id
- `0` 切换至 0 号窗口，使用其他数字 id 切换至对应窗口
- `f` 根据窗口名搜索选择窗口，可模糊匹配

### 2.3 会话操作

如果运行了多次 `tmux` 命令则会开启多个 tmux 会话（session）。在 tmux 会话中，使用前缀快捷键 `⌃b` 配合以下快捷键可操作会话：

- `$` 重命名当前会话
- `s` 选择会话列表
- `d` detach 当前会话，运行后将会退出 tmux 进程，返回至 shell 主进程

在 shell 主进程下运行以下命令可以操作 tmux 会话：

```bash
tmux new -s foo # 新建名称为 foo 的会话
tmux ls # 列出所有 tmux 会话
tmux a # 恢复至上一次的会话
tmux a -t foo # 恢复名称为 foo 的会话，会话默认名称为数字
tmux kill-session -t foo # 删除名称为 foo 的会话
tmux kill-server # 删除所有的会话
tmux source-file ~/.tmux.conf # 立即生效
```

除以上提到的快捷键以外，tmux 还有许多其他的快捷键和命令，使用前缀快捷键 `⌃b` 加 `?` 可以查看所有的快捷键列表，该列表视图为 **tmux copy 模式**，该模式下可使用以下快捷键（无需加 `⌃b` 前缀）：

- `⌃v` 下一页
- `Meta v` 上一页 （tmux 快捷键为 Emacs 风格，这里的 Meta 键可用 Esc 模拟）
- `⌃s` 向前搜索
- `q` 退出 copy 模式

## 3 常见配置与问题

### 3.1 鼠标滚屏

tmux 默认配置中最糟糕的体验就是滚屏查看和文本复制（大家可以先试试看）。你需要先使用 `⌃b` `[` 快捷键进入 copy 模式，然后使用翻页、字符定位来选择需要的字符，效率远没有鼠标选择来的快。

因此 tmux 提供了一些个性化配置项来优化这些配置，首先在 shell 中运行 `touch ~/.tmux.conf` 新建用户配置文件。在文件中增加以下内容：

```shell
# 开启鼠标模式
set -g mode-mouse on

# 允许鼠标选择窗格
set -g mouse-select-pane on

# 如果喜欢给窗口自定义命名，那么需要关闭窗口的自动命名
set-option -g allow-rename off

# 如果对 vim 比较熟悉，可以将 copy mode 的快捷键换成 vi 模式
set-window-option -g mode-keys vi
```

配置文件修改完成后，可以 `tmux kill-server` 重启所有 tmux 进程，或者在 tmux 会话中使用 `⌃b` `:` 进入控制台模式，输入 `source-file ~/.tmux.conf` 命令重新加载配置。

### 3.2 鼠标复制

tmux 下开启鼠标滚屏后，使用 `⌃b` `z` 进入窗格全屏模式，鼠标选择文本的同时按住 option 键 `⌥`，然后使用 `⌘c` 进行复制。

### 3.3 复制到系统剪切板

```bash
sudo apt install xsel
```
编辑 `.tmux.conf.local`，将 `tmux_conf_copy_to_os_clipboard` 的值改为 `true`。
