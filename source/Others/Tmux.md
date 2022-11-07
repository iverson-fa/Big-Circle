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
根据 [tmux-yank](https://github.com/tmux-plugins/tmux-yank)，执行以下命令：

```bash
# clone/path 根据实际情况填写
git clone https://github.com/tmux-plugins/tmux-yank ~/clone/path
# 在 .tmux.conf 最后添加
.tmux.confrun-shell ~/clone/path/yank.tmux 
# 重新加载 tmux 环境
tmux source-file ~/.tmux.conf 
```

Linux有几个cut-and-paste剪贴板：`primary`、`secondary`和`clipboard`（在tmux-yank中默认为`clipboard`），打开鼠标支持后（见下文），鼠标选择的默认剪贴板是`primary`。通过设置 `@yank_selection` 和`@yank_selection_mouse`来更改：

```bash 
# in .tmux.conf
set -g @yank_selection 'primary'
set -g @yank_selection_mouse 'clipboard'
```

## 4 .tmux.conf.local

- [原配置](https://github.com/gpakosz/.tmux/blob/master/.tmux.conf.local)

- [参考](https://zhuanlan.zhihu.com/p/112426848)

```shell
# https://github.com/gpakosz/.tmux
# (‑●‑●)> dual licensed under the WTFPL v2 license and the MIT license,
#         without any warranty.
#         Copyright 2012— Gregory Pakosz (@gpakosz).


# -- navigation ----------------------------------------------------------------

# if you're running tmux within iTerm2
#   - and tmux is 1.9 or 1.9a
#   - and iTerm2 is configured to let option key act as +Esc
#   - and iTerm2 is configured to send [1;9A -> [1;9D for option + arrow keys
# then uncomment the following line to make Meta + arrow keys mapping work
#set -ga terminal-overrides "*:kUP3=\e[1;9A,*:kDN3=\e[1;9B,*:kRIT3=\e[1;9C,*:kLFT3=\e[1;9D"


# -- windows & pane creation ---------------------------------------------------

# new window retains current path, possible values are:
#   - true
#   - false (default)
tmux_conf_new_window_retain_current_path=false

# new pane retains current path, possible values are:
#   - true (default)
#   - false
tmux_conf_new_pane_retain_current_path=true

# new pane tries to reconnect ssh sessions (experimental), possible values are:
#   - true
#   - false (default)
tmux_conf_new_pane_reconnect_ssh=false

# prompt for session name when creating a new session, possible values are:
#   - true
#   - false (default)
tmux_conf_new_session_prompt=false


# -- display -------------------------------------------------------------------

tmux_conf_theme_24b_colour=true
#  Base component color of "Polar Night".
#  Used for texts, backgrounds, carets and structuring characters like curly- and square brackets.
#  Markup:
#  <div style="background-color:#2e3440; width=60; height=60"></div>
#  Styleguide Nord - Polar Night
nord0="#2e3440"

#  Lighter shade color of the base component color.
#  Used as a lighter background color for UI elements like status bars.
#  Markup:
#  <div style="background-color:#3b4252; width=60; height=60"></div>
#  Styleguide Nord - Polar Night
nord1="#3b4252"

#  Lighter shade color of the base component color.
#  Used as line highlighting in the editor.
#  In the UI scope it may be used as selection- and highlight color.
#  Markup:
#  <div style="background-color:#434c5e; width=60; height=60"></div>
#  Styleguide Nord - Polar Night
nord2="#434c5e"

#  Lighter shade color of the base component color.
#  Used for comments, invisibles, indent- and wrap guide marker.
#  In the UI scope used as pseudoclass color for disabled elements.
#  Markup:
#  <div style="background-color:#4c566a; width=60; height=60"></div>
#  Styleguide Nord - Polar Night
nord3="#4c566a"

#  Base component color of "Snow Storm".
#  Main color for text, variables, constants and attributes.
#  In the UI scope used as semi-light background depending on the theme shading design.
#  Markup:
#  <div style="background-color:#d8dee9; width=60; height=60"></div>
#  Styleguide Nord - Snow Storm
nord4="#d8dee9"

#  Lighter shade color of the base component color.
#  Used as a lighter background color for UI elements like status bars.
#  Used as semi-light background depending on the theme shading design.
#  Markup:
#  <div style="background-color:#e5e9f0; width=60; height=60"></div>
#  Styleguide Nord - Snow Storm
nord5="#e5e9f0"

#  Lighter shade color of the base component color.
#  Used for punctuations, carets and structuring characters like curly- and square brackets.
#  In the UI scope used as background, selection- and highlight color depending on the theme shading design.
#  Markup:
#  <div style="background-color:#eceff4; width=60; height=60"></div>
#  Styleguide Nord - Snow Storm
nord6="#eceff4"

#  Bluish core color.
#  Used for classes, types and documentation tags.
#  Markup:
#  <div style="background-color:#8fbcbb; width=60; height=60"></div>
#  Styleguide Nord - Frost
nord7="#8fbcbb"

#  Bluish core accent color.
#  Represents the accent color of the color palette.
#  Main color for primary UI elements and methods/functions.
#  Can be used for
#    - Markup quotes
#    - Markup link URLs
#  Markup:
#  <div style="background-color:#88c0d0; width=60; height=60"></div>
#  Styleguide Nord - Frost
nord8="#88c0d0"

#  Bluish core color.
#  Used for language-specific syntactic/reserved support characters and keywords, operators, tags, units and
#  punctuations like (semi)colons,commas and braces.
#  Markup:
#  <div style="background-color:#81a1c1; width=60; height=60"></div>
#  Styleguide Nord - Frost
nord9="#81a1c1"

#  Bluish core color.
#  Used for markup doctypes, import/include/require statements, pre-processor statements and at-rules (`@`).
#  Markup:
#  <div style="background-color:#5e81ac; width=60; height=60"></div>
#  Styleguide Nord - Frost
nord10="#5e81ac"

#  Colorful component color.
#  Used for errors, git/diff deletion and linter marker.
#  Markup:
#  <div style="background-color:#bf616a; width=60; height=60"></div>
#  Styleguide Nord - Aurora
nord11="#bf616a"

#  Colorful component color.
#  Used for annotations.
#  Markup:
#  <div style="background-color:#d08770; width=60; height=60"></div>
#  Styleguide Nord - Aurora
nord12="#d08770"

#  Colorful component color.
#  Used for escape characters, regular expressions and markup entities.
#  In the UI scope used for warnings and git/diff renamings.
#  Markup:
#  <div style="background-color:#ebcb8b; width=60; height=60"></div>
#  Styleguide Nord - Aurora
nord13="#ebcb8b"

#  Colorful component color.
#  Main color for strings and attribute values.
#  In the UI scope used for git/diff additions and success visualizations.
#  Markup:
#  <div style="background-color:#a3be8c; width=60; height=60"></div>
#  Styleguide Nord - Aurora
nord14="#a3be8c"

#  Colorful component color.
#  Used for numbers.
#  Markup:
#  <div style="background-color:#b48ead; width=60; height=60"></div>
#  Styleguide Nord - Aurora
nord15="#b48ead"

# RGB 24-bit colour support (tmux >= 2.2), possible values are:
#  - true
#  - false (default)

# window style
tmux_conf_theme_window_fg='default'
tmux_conf_theme_window_bg='default'

# highlight focused pane (tmux >= 2.1), possible values are:
#   - true
#   - false (default)
tmux_conf_theme_highlight_focused_pane=false

# focused pane colours:
tmux_conf_theme_focused_pane_fg='default'
tmux_conf_theme_focused_pane_bg='#0087d7'               # light blue

# pane border style, possible values are:
#   - thin (default)
#   - fat
tmux_conf_theme_pane_border_style=thin

# pane borders colours:
tmux_conf_theme_pane_border=$nord0                   # gray
tmux_conf_theme_pane_active_border=$nord10            # light blue

# pane indicator colours
tmux_conf_theme_pane_indicator=$nord10                # light blue
tmux_conf_theme_pane_active_indicator=$nord10         # light blue

# status line style
tmux_conf_theme_message_fg=$nord0                    # black
tmux_conf_theme_message_bg=$nord13
tmux_conf_theme_message_attr='bold'

# status line command style (<prefix> : Escape)
tmux_conf_theme_message_command_fg=$nord12            # yellow
tmux_conf_theme_message_command_bg=$nord5            # black
tmux_conf_theme_message_command_attr='bold'

# window modes style
tmux_conf_theme_mode_fg=$nord0                       # black
tmux_conf_theme_mode_bg=$nord13                       # yellow
tmux_conf_theme_mode_attr='bold'

# status line style
tmux_conf_theme_status_fg=$nord1                     # light gray
tmux_conf_theme_status_bg=$nord1                     # dark gray
tmux_conf_theme_status_attr='none'

# terminal title
#   - built-in variables are:
#     - #{circled_window_index}
#     - #{circled_session_name}
#     - #{hostname}
#     - #{hostname_ssh}
#     - #{username}
#     - #{username_ssh}
#   ﲵ            ﮊ ﮏ ♥ ﰸ ﯅  
tmux_conf_theme_terminal_title='#S ● #I #W'
# window status style
#   - built-in variables are:
#     - #{circled_window_index}
#     - #{circled_session_name}
#     - #{hostname}
#     - #{hostname_ssh}
#     - #{username}
#     - #{username_ssh}
tmux_conf_theme_window_status_fg=$nord4              # light gray
tmux_conf_theme_window_status_bg=$nord1              # dark gray
tmux_conf_theme_window_status_attr='none'
tmux_conf_theme_window_status_format='#I #W'
#tmux_conf_theme_window_status_format='#{circled_window_index} #W'
#tmux_conf_theme_window_status_format='#I #W#{?window_bell_flag,🔔,}#{?window_zoomed_flag,🔍,}'

# window current status style
#   - built-in variables are:
#     - #{circled_window_index}
#     - #{circled_session_name}
#     - #{hostname}
#     - #{hostname_ssh}
#     - #{username}
#     - #{username_ssh}
#   ﲵ            ﮊ ﮏ ♥ ﰸ ﯅  
tmux_conf_theme_window_status_current_fg=$nord6      # black
tmux_conf_theme_window_status_current_bg=$nord10      # light blue
tmux_conf_theme_window_status_current_attr='bold'
tmux_conf_theme_window_status_current_format=' #W '
#tmux_conf_theme_window_status_current_format='#{circled_window_index} #W'
#tmux_conf_theme_window_status_current_format='#I #W#{?window_zoomed_flag,🔍,}'

# window activity status style
tmux_conf_theme_window_status_activity_fg='default'
tmux_conf_theme_window_status_activity_bg='default'
tmux_conf_theme_window_status_activity_attr='underscore'

# window bell status style
tmux_conf_theme_window_status_bell_fg='#ffff00'         # yellow
tmux_conf_theme_window_status_bell_bg='default'
tmux_conf_theme_window_status_bell_attr='blink,bold'

# window last status style
tmux_conf_theme_window_status_last_fg='default'         # light blue
tmux_conf_theme_window_status_last_bg='default'
tmux_conf_theme_window_status_last_attr='none'
tmux_conf_theme_window_status_last_format='#I #W-'

# status left/right sections separators
tmux_conf_theme_left_separator_main='\uE0B0'
tmux_conf_theme_left_separator_sub='\uE0B1'
tmux_conf_theme_right_separator_main='\uE0B2'
tmux_conf_theme_right_separator_sub='\uE0B3'
#tmux_conf_theme_left_separator_main=''
#tmux_conf_theme_left_separator_sub='|'
#tmux_conf_theme_right_separator_main=''
#tmux_conf_theme_right_separator_sub='|'
#tmux_conf_theme_left_separator_main='\uE0B0'  # /!\ you don't need to install Powerline
#tmux_conf_theme_left_separator_sub='\uE0B1'   #   you only need fonts patched with
#tmux_conf_theme_right_separator_main='\uE0B2' #   Powerline symbols or the standalone
#tmux_conf_theme_right_separator_sub='\uE0B3'  #   PowerlineSymbols.otf font, see README.md

# status left/right content:
#   - separate main sections with '|'
#   - separate subsections with ','
#   - built-in variables are:
#     - #{battery_bar}
#     - #{battery_hbar}
#     - #{battery_percentage}
#     - #{battery_status}
#     - #{battery_vbar}
#     - #{circled_session_name}
#     - #{hostname_ssh}
#     - #{hostname}
#     - #{loadavg}
#     - #{pairing}
#     - #{prefix}
#     - #{root}
#     - #{synchronized}
#     - #{uptime_y}
#     - #{uptime_d} (modulo 365 when #{uptime_y} is used)
#     - #{uptime_h}
#     - #{uptime_m}
#     - #{uptime_s}
#     - #{username}
#     - #{username_ssh}

#   ﲵ            ﮊ ﮏ ♥ ﰸ ﯅  
tmux_conf_theme_status_left='  #S '
#tmux_conf_theme_status_right='#{prefix}#{pairing}#{synchronized}#{?battery_bar, #{battery_bar},}#{?battery_percentage, #{battery_percentage},} | %b%d日#(curl wttr.in?format="%%c%%20%%t") | %R | #{username}#{root} | ﯅#{hostname} '
tmux_conf_theme_status_right='#{prefix}#{pairing}#{synchronized}#{?battery_bar, #{battery_bar},}#{?battery_percentage, #{battery_percentage},} |#(curl wttr.in?format="%%c%%20%%t") | %R | #{username}#{root} | ﯅#{hostname} '

# status left style
tmux_conf_theme_status_left_fg=$nord5 # '#e4e4e4,#e4e4e4,#e4e4e4'  # black, white , white
tmux_conf_theme_status_left_bg=$nord0 #',#00afff'  # yellow, pink, white blue
tmux_conf_theme_status_left_attr='bold,none,none'

# status right style
tmux_conf_theme_status_right_fg=$nord0,$nord6,$nord5,$nord4,$nord4
tmux_conf_theme_status_right_bg=$nord1,$nord2,$nord3,$nord1,$nord0 # dark gray, red, white
tmux_conf_theme_status_right_attr='none,none,bold,none,none,none'

# pairing indicator
tmux_conf_theme_pairing='👓 '          # U+1F453
tmux_conf_theme_pairing_fg='none'
tmux_conf_theme_pairing_bg='none'
tmux_conf_theme_pairing_attr='none'

# prefix indicator
tmux_conf_theme_prefix='⌨ '            # U+2328
tmux_conf_theme_prefix_fg=$nord11
tmux_conf_theme_prefix_bg='none'
tmux_conf_theme_prefix_attr='none'

# root indicator
tmux_conf_theme_root='!'
tmux_conf_theme_root_fg='none'
tmux_conf_theme_root_bg='none'
tmux_conf_theme_root_attr='bold,blink'

# synchronized indicator
tmux_conf_theme_synchronized='🔒'     # U+1F512
tmux_conf_theme_synchronized_fg='none'
tmux_conf_theme_synchronized_bg='none'
tmux_conf_theme_synchronized_attr='none'

# battery bar symbols
tmux_conf_battery_bar_symbol_full='◼'
tmux_conf_battery_bar_symbol_empty='◻'
#tmux_conf_battery_bar_symbol_full='♥'
#tmux_conf_battery_bar_symbol_empty='·'

# battery bar length (in number of symbols), possible values are:
#   - auto
#   - a number, e.g. 5
tmux_conf_battery_bar_length='7'

# battery bar palette, possible values are:
#   - gradient (default)
#   - heat
#   - 'colour_full_fg,colour_empty_fg,colour_bg'
tmux_conf_battery_bar_palette='heat'
#tmux_conf_battery_bar_palette='#d70000,#e4e4e4,#000000'   # red, white, black

# battery hbar palette, possible values are:
#   - gradient (default)
#   - heat
#   - 'colour_low,colour_half,colour_full'
tmux_conf_battery_hbar_palette='gradient'
#tmux_conf_battery_hbar_palette='#d70000,#ff5f00,#5fff00'  # red, orange, green

# battery vbar palette, possible values are:
#   - gradient (default)
#   - heat
#   - 'colour_low,colour_half,colour_full'
tmux_conf_battery_vbar_palette='gradient'
#tmux_conf_battery_vbar_palette='#d70000,#ff5f00,#5fff00'  # red, orange, green

# symbols used to indicate whether battery is charging or discharging
#tmux_conf_battery_status_charging='↑'       # U+2191
#tmux_conf_battery_status_discharging='↓'    # U+2193
#tmux_conf_battery_status_charging='⚡ '    # U+26A1
tmux_conf_battery_status_charging='🔌 '    # U+1F50C
tmux_conf_battery_status_discharging='🔋 ' # U+1F50B

# clock style (when you hit <prefix> + t)
# you may want to use %I:%M %p in place of %R in tmux_conf_theme_status_right
tmux_conf_theme_clock_colour='#00afff'  # light blue
tmux_conf_theme_clock_style='24'


# -- clipboard -----------------------------------------------------------------

# in copy mode, copying selection also copies to the OS clipboard
#   - true
#   - false (default)
# on macOS, this requires installing reattach-to-user-namespace, see README.md
# on Linux, this requires xsel or xclip
tmux_conf_copy_to_os_clipboard=false

# test 
## 此时s1/s4字体颜色为1，背景色为2,字体加粗
## s2/s5的字体颜色为2，背景色为3,字体正常
## s3/s6/s6ss1的字体颜色为3,背景色为1,字体正常
#color_1='#ff0000'
#color_2='#00ff00'
#color_3='#0000ff'
#tmux_conf_theme_status_left='s1|s2|s3|s4|s5|s6,s6ss1'
## 前景色/字符颜色控制
#tmux_conf_theme_status_left_fg=$color_1,$color_2,$color_3
## 背景色
#tmux_conf_theme_status_left_bg=$color_2,$color_3,$color_1
## 字体特殊显示:粗体bold，正常none
#tmux_conf_theme_status_left_attr='bold,none,none'
# test``
# -- user customizations -------------------------------------------------------
# this is the place to override or undo settings

# increase history size
#set -g history-limit 10000

# start with mouse mode enabled
#set -g mouse on

# force Vi mode
#   really you should export VISUAL or EDITOR environment variable, see manual
#set -g status-keys vi
#set -g mode-keys vi

# replace C-b by C-a instead of using both prefixes
# set -gu prefix2
# unbind C-a
# unbind C-b
# set -g prefix C-a
# bind C-a send-prefix

# move status line to top
#set -g status-position top

# Tmux is automatically started after the computer/server is turned on.
# set -g @continuum-boot 'on'
# set -g @continuum-restore 'on'
# set -g @continuum-boot-options 'kitty'

# List of plugins
set -g @tpm_plugins '          \
  tmux-plugins/tpm             \
  tmux-plugins/tmux-resurrect  \
'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
```

