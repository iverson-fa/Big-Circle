# Tmux 笔记

## 1 安装

```bash
sudo apt install tmux
```

- [Tmux 使用手册](http://louiszhai.github.io/2017/09/30/tmux/#%E5%AF%BC%E8%AF%BB)

使用 [oh my tmux](https://github.com/gpakosz/.tmux)， 参考[知乎](https://zhuanlan.zhihu.com/p/112426848)

```bash
$ cd
$ git clone https://github.com/gpakosz/.tmux.git
$ ln -s -f .tmux/.tmux.conf
$ cp .tmux/.tmux.conf.local .
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

## 4 .tmux.conf.local

- [原配置](https://github.com/gpakosz/.tmux/blob/master/.tmux.conf.local)

- [参考](https://zhuanlan.zhihu.com/p/112426848)

## 5 开箱即用方案

### 5.1 不需要复制终端内容

```shell
# file_name: .tmux.conf
# 修改前缀键为 Ctrl + a（默认是 Ctrl + b）
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# 重新加载 tmux 配置文件
bind r source-file ~/.tmux.conf \; display "Config Reloaded!"

# 启用鼠标支持
set-option -g mouse on

# 窗口状态栏样式优化
set-option -g status-bg black
set-option -g status-fg white
set-option -g status-left "#[fg=green]#H #[fg=cyan][#S] "
set-option -g status-right "#[fg=yellow]%Y-%m-%d %H:%M#[default]"

# 分割窗口的快捷键（更符合直觉）
unbind '"'
unbind %
bind | split-window -h   # 横向分屏
bind - split-window -v   # 纵向分屏

# 绑定快捷键快速切换窗口
bind -r h select-pane -L
bind -r j select-pane -D
bind -r k select-pane -U
bind -r l select-pane -R

# 允许窗口名称自动更新
set-option -g automatic-rename on
set-option -g allow-rename off

# 使 tmux 退出后保留会话（默认不启用）
set-option -g detach-on-destroy off

# 滚动历史增加（默认2000）
set-option -g history-limit 5000

# 允许使用 Alt + 上/下/左/右 调整窗口大小
bind -r C-Left resize-pane -L 5
bind -r C-Right resize-pane -R 5
bind -r C-Up resize-pane -U 5
bind -r C-Down resize-pane -D 5
```

### 5.2 需要复制终端内容

要将 `tmux` 剪贴板的内容同步到系统剪贴板，可以使用 `xclip` 或 `xsel`，这两款工具能将内容从 `tmux` 剪贴板传递到 X 系统的剪贴板。

**方法 1：使用 `xclip`**

1. **安装 `xclip`**
   如果你的系统还没有安装 `xclip`，可以通过以下命令安装：
   ```bash
   sudo apt-get install xclip
   ```

2. **将 `tmux` 剪贴板内容复制到系统剪贴板**
   使用以下命令将 `tmux` 剪贴板的内容通过 `xclip` 转移到系统剪贴板：
   ```bash
   tmux show-buffer | xclip -selection clipboard
   ```

   - `show-buffer` 会获取 `tmux` 剪贴板的内容。
   - `xclip -selection clipboard` 会将内容放到系统剪贴板（可粘贴到任何应用中）。

---

**方法 2：使用 `xsel`**

1. **安装 `xsel`**
   如果没有安装 `xsel`，可以通过以下命令安装：
   ```bash
   sudo apt-get install xsel
   ```

2. **将 `tmux` 剪贴板内容复制到系统剪贴板**
   使用以下命令将 `tmux` 剪贴板的内容通过 `xsel` 转移到系统剪贴板：
   ```bash
   tmux show-buffer | xsel --clipboard --input
   ```

   - `xsel --clipboard --input` 将内容放入 X 系统的剪贴板。

---

**自动化（可选）**

如果希望更方便地复制 `tmux` 剪贴板内容到系统剪贴板，可以在 `~/.tmux.conf` 配置文件中添加以下快捷键：
```bash
# 绑定快捷键将 tmux 剪贴板内容同步到系统剪贴板
bind C-c run "tmux show-buffer | xclip -selection clipboard"
```
然后使用 `Ctrl + a C-c` 直接将 `tmux` 剪贴板的内容同步到系统剪贴板。

## 6 主题

推荐使用 **`tmux-powerline`** 主题，它是一个非常受欢迎的 tmux 主题，提供了漂亮、功能丰富的状态栏，并且非常容易配置。它支持显示多个信息，如当前会话、窗口、系统负载、Git 状态等，提升 tmux 使用体验。

### **tmux-powerline 安装和使用**

#### **1. 安装依赖**

首先，需要确保系统中安装了以下依赖：
- Python 2.x 或 3.x
- `pip`（Python 包管理器）
- `powerline-shell` 和其他必要的 Python 库

安装 `pip`（如果未安装）：
```bash
sudo apt install python3-pip
```

#### **2. 安装 tmux-powerline**

通过 `pip` 安装 `tmux-powerline`：
```bash
pip install tmux-powerline
```

#### **3. 配置 tmux 使用 tmux-powerline**

1. **修改 `~/.tmux.conf`**

将以下内容添加到你的 `~/.tmux.conf` 文件中：

```bash
# 使用 tmux-powerline
set-option -g status on
set-option -g status-interval 2
set-option -g status-right-length 90
set-option -g status-left-length 60

# 指定 tmux-powerline 脚本路径
set-option -g status-right "#(powerline-shell segments)"
set-option -g status-left "#(powerline-shell segments)"
```

2. **创建 `~/.config/powerline-shell/config.json` 配置文件**

`tmux-powerline` 默认使用 `powerline-shell` 来渲染状态栏。需要一个配置文件，来定义显示的内容。创建目录和配置文件：

```bash
mkdir -p ~/.config/powerline-shell
```

然后，创建并编辑 `~/.config/powerline-shell/config.json` 文件，加入你需要的配置信息，例如：

```json
{
  "segments": [
    ["virtualenv", "before"],
    ["hostname", "after"],
    ["cwd", "before"],
    ["gitstatus", "after"],
    ["load", "after"]
  ]
}
```

可以根据需要添加和调整这些段的顺序。

#### **4. 启动 tmux**

完成配置后，重新启动 `tmux`：
```bash
tmux source-file ~/.tmux.conf
```

如果你已经在 `tmux` 会话中，按 `Ctrl + a` 然后输入 `:source-file ~/.tmux.conf`。

#### **5. 自定义主题**

根据个人喜好修改 `~/.config/powerline-shell/config.json` 文件中的段（`segments`）部分，添加更多信息，如系统负载、CPU、内存、网络、时间等，或选择不同的颜色主题。

#### **6. 安装其他主题**

`tmux-powerline` 支持主题，并有许多现成的主题可以使用。你可以在网上找到适合自己需求的主题，或者从 `tmux-powerline` GitHub 仓库中下载更多预设的主题。

---

### **其他流行的 tmux 主题**

除了 `tmux-powerline`，还有一些其他受欢迎的 tmux 主题：

1. **`tmux-themepack`**
   - 这是一个提供多种主题的 tmux 插件，包含了多个现代化的漂亮主题。
   - GitHub 地址：[https://github.com/erikw/tmux-themepack](https://github.com/erikw/tmux-themepack)

2. **`powerline`（经典版）**
   - 经典的 `powerline` 提供了丰富的插件系统，支持 Vim、tmux 和其他程序。
   - GitHub 地址：[https://github.com/powerline/powerline](https://github.com/powerline/powerline)

3. **`tmuxinator`**
   - 提供图形化的 tmux 会话管理器，可以为不同项目设置专属的 tmux 配置。
   - GitHub 地址：[https://github.com/tmuxinator/tmuxinator](https://github.com/tmuxinator/tmuxinator)

---

### **总结**
- `tmux-powerline` 是一个功能强大的 tmux 主题，提供美观的状态栏和丰富的功能，适合大多数用户。
- 通过修改 `~/.tmux.conf` 和 `~/.config/powerline-shell/config.json`，你可以自定义显示的内容。
- 如果你想要更多选择，可以尝试 `tmux-themepack` 或其他主题插件。