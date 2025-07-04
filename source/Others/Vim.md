# Vim

## 0 Docs_Index

- [The official Vim repository](https://github.com/vim/vim)
- [从入门到精通](https://github.com/wsdjeg/vim-galore-zh_cn)
- [vim 中文文档](https://yianwillis.github.io/vimcdoc/doc/help.html)
- [LazyVim](https://www.lazyvim.org/)
- [LazyVim for Ambitious Developers](https://lazyvim-ambitious-devs.phillips.codes/course/chapter-1/)

```bash
# vim fast
curl https://gitee.com/mirrorvim/vim-fast/raw/master/shell/webinstall.sh |bash
```

## 1 基础操作

### 1.1 进入编辑模式：

- i	  (insert)
- a   (append)
- o   (open a line below)

### 1.2 Visual 模式一般用来块状选择文本

- Normal 模式下使用 `v` 进入 visual 选择
- 使用 `V` 选择行
- 使用 `<C-v>` 进行方块选择

###  1.3 可以用在终端的快捷键

- `<C-h>`  删除上一个字符
- `<C-w>`  删除上一个单词
- `<C-u>`  删除当前行的光标前边的字符
- `<C-a>`  移动到行首
- `<C-e>` 移动到行尾
- `<C-b>` 往后移动
- `<C-f>` 往前移动

### 1.4 移动快捷键

**单词间移动**

- `gi` 回到上次编辑位置

- w/W 移动到下一个 word/WORD 开头，e/E 下一个 word/WORD 结尾
- b/B 移动到上一个 word/WORD 开头
- word 指的是以非空白符分割的单词，WORD 以空白符分割的单词

**行间搜索移动**

- 使用 `f{char}` 可以移动到 char 字符上，`t{char}` 移动到 char 的前一个字符
- 如果第一次没搜到，可以使用 `;/,` 继续搜该行的下一个/上一个
- `F` 表示反过来搜前边的字符

**水平移动**

- `0` 移动到行首第一个字符，`^` 移动到第一个非空白字符
- `$` 移动到行尾，`g_`移动到行尾非空白字符
- 常用 `0`  和`$`

**页面移动**

- `gg/G` 移动到文件的开头和结尾，`<C-o>` 快速返回
- `H/M/L` 跳转到文件开头，结尾和中间
- `<C-u>` / `<C-b>` 上翻页；`<C-f>` 下翻页；`zz`把屏幕置为中间

### 1.5 增删改查

**快速删除**

- Normal 模式下使用 `x` 删除一个字符
- 使用 `d`(delete)配合文本对象快速删除一个单词，`daw`(d around word)，或者为 `dw`，`diw` 只删除单词
- `d` 和 `x` 都可以搭配数字来执行多次
- `dt)` 往后删除到后括号前边的内容
- `dt" ` 往后删除到后引号前边的内容
- `d$`  删除到行尾，`d0` 删除到行首
- `dd` 删除当前行，`2dd` 删除当前行及下一行，`4x` 往后删除4个字符

**快速修改**

- `r` - replace / `c` - change / `s` - substitute
- Normal 模式下使用 `r` 可以替换一个字符，`s` 删除当前字符并进入插入模式
- Normal 模式下使用 `R` 可以一直替换字符，`S` 删除整行并进入插入模式
- `4s` 删除4个字符并进入插入模式
- 使用 `c` 配合文本对象，快速进行修改
- `cw` 或 `caw`，删除当前字符至单词结尾，进入插入模式
- `C` 删除当前字符至行尾，进入插入模式
- `ct"` 往后删除到后引号前边的内容，进入插入模式
- `ct)` 往后删除到后括号前边的内容，进入插入模式

**查询**

- `/` - 前向搜索，`?` - 反向搜索
- `n` - 跳转到下一个匹配，`N` - 跳转到上一个匹配
- `*` - 当前单词的前向匹配，`#` - 当前单词的后向匹配

**搜索替换**

`substitute` 命令查找并替换文本，支持正则表达式

- `:[range] s[ubstitute]/{pattern}/{string}/[flags]`
- range 表示范围，比如 `10,20` 表示 10-20 行，`%` 表示全部
- pattern 是要替换的模式，string 是替换后的文本

替换标志位，常用的标志

- `g` - global，全局范围内执行
- `c` - confirm，确认或拒绝修改
- `n` - number，报告匹配到的次数而不替换，可以用来查询匹配次数

- `% s/hello//g` 查询文档中 `hello` 出现的次数
- `% s/\<hello\</welcome/g` 使用 `\<` 精确匹配 `hello` 并替换为`welcome`，而不会修改 `say_hello` 这样的词

### 1.6 多文件操作

相关概念

- Buffer - 打开的一个文件的内存缓冲区
  - Vim 打开一个文件后会家在文件内容到缓冲区
  - 之后的修改都是针对内存中的缓冲区，并不会直接保存到文件
  - 直到执行 `:w` 才会把修改内容写入文件
  - `:ls` 列举当前缓冲区，然后使用 `：b n` 跳转到第 n 个缓冲区
  - `:bpre` / `:bnext` / `:bfirst` / `:blast`，跳转到上一个/下一个/第一个/最后一个缓冲区
  - `:b buffer_name` 也可以跳转
- Window - Buffer 可视化的分割区域
  - 一个 Buffer 可以分割为多个 Window，每个 Window 也可以打开不同的 Buffer
  - 水平分割，`<C-w> s` or `:sp`
  - 垂直分割，`<C-w> v` or `:vs`
  - 每个窗口可以被无限分割
  - 重排窗口可以改变窗口大小，`:h window-resize` 查看文档

| 命令                  | 作用                                      |
| --------------------- | ----------------------------------------- |
| `<C-w> w`             | 在窗口间循环切换                          |
| `<C-w> h` / `<C-W> H` | 切换到 左边 窗口 / 将活动窗口移动到 左边  |
| `<C-w> j` / `<C-W> J` | 切换到 下边 窗口 / 将活动窗口移动到 下边  |
| `<C-w> k` / `<C-W> K` | 切换到 上边 窗口 / 将活动窗口移动到 上边  |
| `<C-w> l` / `<C-W> L` | 切换到 右边  窗口 / 将活动窗口移动到 右边 |
| `<C-w> =`             | 使所有窗口等宽、等高                      |
| `<C-w> _`             | 最大化活动窗口的高度                      |
| `<C-w>                | `                                         | 最大化活动窗口的宽度      |
| `[N]<C-w> _`          | 将活动窗口的高度设为 N 行                 |
| `[N]<C-w>             | `                                         | 将活动窗口的宽度设为 N 行 |

- Tab - 组织窗口为一个工作区，将窗口分组
  - Vim 的 Tab 与其他编辑器有差别，可以当作 Linux 的虚拟桌面
  - 比如一个 Tab 用来编辑 Python 文件，一个 Tab 用来编辑 C++ 文件
  - 相比 Window，Tab 用的比较少，管理较麻烦

| 命令                        | 作用                             |
| --------------------------- | -------------------------------- |
| `:tabe[dit] {filename}`     | 在新标签页打开 {filename}        |
| `<C-w> T`                   | 把当前窗口移到一个新的标签页     |
| `:tabc[lose]`               | 关闭当前标签页及其中所有窗口     |
| `:tabo[nly]`                | 只保留活动标签页，关闭其他标签页 |
| `:tabn[ext] {N}` / `{N} gt` | 切换到编号为 {N} 的标签页        |
| `:tabn[ext]` / gt           | 切换到下一标签页                 |
| `:tabp[revious]` / `gT`     | 切换到上一标签页                 |

### 1.7 文本对象

类比面向对象编程，Vim 中也有对象的概念，例如一个单词、一个句子等，通过操作文本对象来修改要比只操作单个字符高效。

- `[number]<command>[text object]`
- number - 次数，command - 命令: d(elete) / c(hange) / y(ank)
- text object 是要操作的文本对象，例如 w - 单词，s - 句子，p - 段落

**iw** 表示 inner word，如果使用 `viw` 命令，将进入选择模式，选中当前单词。

**aw** 表示 a word，不但会选中当前单词，还会包含当前单词之后的空格。

以下加粗的 **[ ]** 表示作用范围：

| 命令        | 作用范围                                                           |
| ----------- | ------------------------------------------------------------------ |
| `iw`        | This is a **[**test**]** sentense.                                 |
| `aw`        | This is a **[**test **]**sentense.                                 |
| `iW`        | This is a **[**...test...**]** sentense.                           |
| `aW`        | This is a **[**...test... **]**sentense.                           |
| `is`        | ...sentense. **[**This is a sentense.**]** This ...                |
| `as`        | ...sentense. **[**This is a sentense. **]**This ...                |
| `ip`        | **[**This is a paragraph. It has two sentense.**]**<br />The next. |
| `ap`        | **[**This is a paragraph. It has two sentense.<br />**]**The next. |
| `i(` / `i)` | 1 * (**[**2 + 3**]**)                                              |
| `a(` / `a)` | 1 * **[**(2 + 3)**]**                                              |
| `i<` / `i>` | the < **[**tag**]** >                                              |
| `a<` / `a>` | the **[**< taga >**]**                                             |
| `i{` / `i}` | some {**[**code block**]**}                                        |
| `a{` / `a}` | some **[**{code block}**]**                                        |
| `i[` / `i]` | some [**[**code block**]**]                                        |
| `a[` / `a]` | some **[**[code block]**]**                                        |
| `i"`        | some "**[**words**]**"                                             |
| `a"`        | some**[** "words"**]**                                             |
| `i'`        | some '**[**words**]**'                                             |
| `a'`        | some**[** 'words'**]**                                             |

### 1.8 复制粘贴与寄存器的使用

**Normal 模式复制粘贴**

- `y` - 复制，`p` - 粘贴，`d` - 剪切
- 配合文本对象：`yiw` 复制一个单词，`yy` 复制一行，`dd`- 删除一行

**Insert 模式复制粘贴**

很多人会使用鼠标进行选中，然后使用 `<C-v>` 或者 `<cmd-v>` 粘贴

- 这和其他文本编辑器差不多，但是粘贴代码有个坑
- 在 `vimrc` 中设置了 `autoindent`，粘贴 Python 代码会缩进混乱
- 可以使用 `:set paste` 和 `:set nopaste` 解决
- 最方便的是在 Normal 模式下粘贴，不会出现格式错误

**Vim 寄存器**

- Vim 操作的是寄存器，不是系统剪切板，这点与其他编辑器不一样
- 删除和复制的内容默认当到了“无名寄存器”
- `x` 删除一个字符，再用 `p` 粘贴，可以调换两个字符

Vim 不使用单一剪切板进行剪切、复制和粘贴，而是多组寄存器

- 使用 `"{register}` 前缀可以制定寄存器，不指定默认使用无名寄存器
- 例如 `"ayiw` 复制一个单词到寄存器 `a` 中，`"bdd` 删除当前行到寄存器 `b` 中
- `:reg a` 可以查看寄存器 `a` 中的内容
- `""` 表示无名寄存器，缺省使用

除了 `a-z` 寄存器，还有其他常见的寄存器

- 复制专用寄存器 `"0` ，使用 `y` 复制文本同时会被拷到复制寄存器 0
- 系统剪切板 `"+` ，可以在复制前加上 `"+` 复制到系统剪切板
- `:echo has('clipboard')` 1 表示支持系统剪切板，0 表示不支持
- `sudo apt install vim-gnome` 可以使 Vim 支持系统检测板
- `:set clipboard=unnamed` 可以将系统剪切板作为默认寄存器
- Insert 模式下，`<C-R> +` 可以粘贴系统剪切板内容，并进入插入模式
- 其他，`"%` 当前文件名，`".` 上次插入的文本，不常使用

### 1.9 Vim 宏（macro)

**简单介绍**

- 宏可以看成是一系列命令的集合
- 可以使用宏“录制”一系列操作，然后用于“回放”
- 宏可以非常方便地把一系列命令用在多行文本上

宏的使用分为录制和回放，在 Normal 模式下

- 使用 `q` 录制和结束录制
- `a{register}` 选择要保存的寄存器，把录制的命令保存其中
- `@{register}` 回放寄存器中保存的一系列命令

**简单举例**

在多行文本中，每一行加上双引号

方法1

- `qa` 开始录制，第一行加上双引号
- 退出插入模式，`q` 结束录制
- 选中剩余行，`:` 进入命令行模式，输入 `normal @a`，回车执行

方法2

- `qa` 开始录制，第一行加上双引号
- 退出插入模式，`q` 结束录制
- 移动到下一行，`:'<,'>normal @a`

方法3

- `:'<,'>normal I"`
- `:'<,'>normal A"`

### 1.10 补全

Vim 自带多种补全方式

| 命令         | 补全类型         |
| ------------ | ---------------- |
| `<C-n>`      | 普通关键字       |
| `<C-x><C-n>` | 当前缓冲区关键字 |
| `<C-x><C-i>` | 包含文件关键字   |
| `<C-x><C-]>` | 标签文件关键字   |
| `<C-x><C-k>` | 字典查找         |
| `<C-x><C-l>` | 整行补全         |
| `<C-x><C-f>` | 文件名补全       |
| `<C-x><C-o>` | 全能（Omni）补全 |

三种常用的补全方式

- `<C-n><C-p>` 补全单词
- `<C-x><C-f>` 补全文件名
- `<C-x><C-o>` 补全代码，需要开启文件类型检查，安装插件

### 1.11 更换配色

- `:colorscheme` 显示当前的主题配色，默认是 default
- `:colorscheme <C-d>` 可以显示所有的配色
- `:colorscheme 配色名` 可以修改配色
- [Github 下载1](https://github.com/flazz/vim-colorschemes)
- [Github 下载2](https://github.com/w0ng/vim-hybrid)

### 1.12 indent 折叠

常用的折叠方式：indent（缩进折叠），maker（标志折叠）。

**indent**

激活：`set foldmethod=indent`，在折叠处输入命令：

| 命令 | 操作                                                 |
| ---- | ---------------------------------------------------- |
| za   | 打开或关闭当前折叠                                   |
| zM   | 关闭所有折叠                                         |
| zR   | 打开所有折叠                                         |
| zc   | 折叠                                                 |
| zC   | 对所在范围内所有嵌套的折叠点进行折叠                 |
| zo   | 展开折叠                                             |
| zO   | 对所在范围内所有嵌套的折叠点展开                     |
| [z   | 到当前打开的折叠的开始处                             |
| ]z   | 到当前打开的折叠的末尾处                             |
| zj   | 向下移动。到达下一个折叠的开始处。关闭的折叠也被计入 |
| zk   | 向上移动到前一折叠的结束处。关闭的折叠也被计入       |

## 2 编写 Vim 配置

### 2.1 基础配置

需要设置的内容

- 常用设置，比如 `:set nu` 设置行号，`colorscheme hybrid` 设置主题
- 常用的 vim 映射，比如 `noremap <leader>w :w<cr>` 保存文件
- 自定义的 vimscript 函数和插件的配置

vim 中的映射比较复杂，源于 vim 的多种模式

- 设置 leader 键，常用的是逗号或空格，`let mapleader = ","`
- `inoremap <leader>w <Esc>:w<cr>` 在插入模式保存
- 后面介绍复杂的映射

参考配置 [vim-go](https://github.com/faith/vim-go-tutorial/blob/master/vimrc)

### 2.2 映射

vim 映射就是把一个操作映射为另一个操作。基本映射为 normal 模式下的映射。

**基本映射**

- 使用 `map` 实现映射，`map - x` 将 `-` 映射为 `x`
- `:map <space> viw` 按下空格选中整个单词
- `:map <c-d> dd` ctrl + d 删除一行

Normal / Visual / Insert 都可以定义映射，使用 `nmap / vmap /imap`。

- `imap <c-d> <Esc>ddi` 插入模式下删除一行
- 为规避递归映射，使用 **`nnoremap / vnoremap / inoremap`**

## 3 安装和使用插件

### 3.1 安装插件

Vim 插件是使用 vimscript 或者其他语言编写的 Vim 功能扩展。常见的插件管理器有 vim-plug / Vundle / Pathogen / Dein.Vim / volt 等，综合性能、易用性、文档等几个方面，推荐使用 [vim-plug](https://github.com/junegunn/vim-plug)。

插件网站 [vimawesome](https://vimawesome.com/)

### 3.2 美化插件

- 修改启动界面 [vim-startify](https://github.com/mhinz/vim-startify)
- 状态栏美化 [vim-airline](https://github.com/vim-airline/vim-airline)
- 增加代码缩进线条 [indentline](https://github.com/yggdroot/indentline)

配色方案

- [vim-hybrid](https://github.com/w0ng/vim-hybrid)
- [solarized](https://github.com/altercation/vim-colors-solarized)
- [gruvbox](https://github.com/morhetz/gruvbox)

### 3.3 文件目录和搜索插件

文件目录树管理插件 [Nerdtree](https://github.com/scrooloose/nerdtree)

- `autocmd vimenter * NERDTree` 可以在启动 vim 的时候自动打开
- 帮助文档 `:help NERDTree`

模糊搜索 [ctrlp](https://github.com/ctrlpvim/ctrlp.vim)

- `let g:ctrlp_map='<c-p>'`

### 3.4 快速定位插件 easymotion

- [插件地址](https://github.com/easymotion/vim-easymotion)
- 常用映射 `nmap ss <Plug>(easymotion-s2)`

### 3.5 成对编辑 vim-surround

normal 模式下增加，删除，修改成对内容

- `ds`  - delete a surrounding
- `cs`  - change a surrounding
- `ys`  - you add a surrounding

### 3.6 模糊搜索和替换插件

- `/` 可以搜索当前文件
- `Ag.vim` or [`fzf.vim`](https://github.com/junegunn/fzf.vim) 可以很好的支持多文件的模糊搜索
- `Ag [PATTERN]` 模糊搜索字符串，`<C-j>` 往下移动
- `Files [PATH]` 模糊搜索目录

批量搜索替换插件 [far.vim](https://github.com/brooth/far.vim)，例如将某文件夹下的 python 文件中的 foo 替换为 bar ，代码重构时会用到

- `:Far foo bar **/*.py`
- `:Fardo`

### 3.7 Python-mode

- [Python-mode](http://github.com/python-mode/python-mode) 具有基本的补全、跳转、重构和格式化功能

### 3.8 浏览代码

- [tagbar](https://github.com/majutsushi/tabar)
- [interestingwords](https://github.com/lfv89/vim-interestingwords)

### 3.9 代码补全

- [deoplete.nvim](https://github.com/shougo/deoplete.nvim)
- 多编程语言的支持，支持模糊匹配
- 需要安装对应编程语言的扩展

- 另一个神器：[coc.vim](https://github.com/neoclide/coc.vim)

## 4 Vim 8

### 4.1 Install

```bash
sudo add-apt-repository ppa:jonathonf/vim

sudo apt update

sudo apt install vim
```

## 5 不用插件的 vim 配置

```bash
"------------------------配置----------------------------------
if has("gui_macvim")
      let macvim_hig_shift_movement = 1
endif
colorscheme hybrid
set background=dark
set modelines=0     " 禁用模式行（安全措施）
set encoding=utf-8           "编码设置
set number                   "显示行号
set smartindent              "智能缩进
set autoindent               "自动对齐
set smarttab
set tabstop=4                "tab缩进
set shiftwidth=4             "设定自动缩进为4个字符
set expandtab                "用space替代tab的输入
"set lines=38 columns=150     "设置默认窗口大小
set splitright               "设置左右分割窗口时，新窗口出现在右侧
set splitbelow               "设置水平分割窗口时，新窗口出现在下方

set nobackup                 "不需要备份
set noswapfile               "禁止生成临时文件
set autoread                 "文件自动检测外部更改

set nocompatible             "去除vi一致性
set ambiwidth=double         "解决中文标点显示的问题
set vb t_vb=                 "消除‘嘟嘟’的警报声
set nowrap                   "不自动折行
set mouse=a                  "使用鼠标
set mousehide                "输入时隐藏光标
syntax on                    "语法高亮
filetype on                  "开启文件类型检测

set sm!                      "高亮显示匹配括号
set cursorline             "高亮显示当前行
set hlsearch                 "高亮查找匹配
set showmatch                "显示匹配
set ruler                    "显示标尺，在右下角显示光标位置
set novisualbell             "不要闪烁
set showcmd                  "显示输入的命令

set completeopt=longest,menu             "自动补全配置让Vim补全菜单行为跟IDE一致
set backspace=indent,eol,start           "允许用退格键删除字符
set guifont=DroidSansMono_Nerd_Font:h14  "设置字体和字体大小

" 禁止显示滚动条
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R

" 禁止显示菜单和工具条
set guioptions-=m
set guioptions-=T

" 设置代码折叠---------------------------------
set nofoldenable             " 启动 vim 时关闭折叠代码
set foldmethod=indent        " 设置语法折叠
setlocal foldlevel=99        " 设置折叠层数
nnoremap <space> za          " 用空格键来开关折叠


" 设置状态行-----------------------------------
" 设置状态行显示常用信息
" %F 完整文件路径名
" %m 当前缓冲被修改标记
" %m 当前缓冲只读标记
" %h 帮助缓冲标记
" %w 预览缓冲标记
" %Y 文件类型
" %b ASCII值
" %B 十六进制值
" %l 行数
" %v 列数
" %p 当前行数占总行数的的百分比
" %L 总行数
" %{...} 评估表达式的值，并用值代替
" %{"[fenc=".(&fenc==""?&enc:&fenc).((exists("+bomb") && &bomb)?"+":"")."]"} 显示文件编码
" %{&ff} 显示文件类型

set laststatus=2
set statusline=%1*%F%m%r%h%w%=\ %2*\ %Y\ %3*%{\"\".(\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\"+\":\"\").\"\"}\ %4*[%l,%v]\ %5*%p%%\ \|\ %6*%LL\

" 设置netrw-------------------------------------
let g:netrw_banner = 1       "设置是否显示横幅
let g:netrw_liststyle = 3    "设置目录列表样式：树形
"let g:netrw_browse_split = 4 "在之前的窗口编辑文件
"let g:netrw_altv = 1         "水平分割时，文件浏览器始终显示在左边
"let g:netrw_winsize = 25     "设置文件浏览器窗口宽度为25%
"自动打开文件浏览器
"augroup ProjectDrawer
"    autocmd!
"    autocmd VimEnter * :Vexplore
"augroup END

nnoremap <C-n> :Lexplore<CR>    " 打开或关闭目录树


" 快捷键映射-------------------------------------
let mapleader=',' "leader映射','
inoremap <leader>w <Esc>:w<CR>
inoremap kj <Esc>

" 运行对应文件的映射-----------------------------
map <F5> :call CompileRunGcc()<CR>
func! CompileRunGcc()
        exec "w"
        if &filetype == 'c'
                exec "!g++ % -o %<"
                exec "!time ./%<"
        elseif &filetype == 'cpp'
                exec "!g++ % -o %<"
                exec "!time ./%<"
        elseif &filetype == 'java'
                exec "!javac %"
                exec "!time java %<"
        elseif &filetype == 'sh'
                :!time bash %
        elseif &filetype == 'python'
                exec "!clear"
                exec "!time python3 %"
        elseif &filetype == 'html'
                exec "!time open % &"
        elseif &filetype == 'go'
                " exec "!go build %<"
                exec "!time go run %"
        elseif &filetype == 'javascript'
                exec "!clear"
                exec "!node %"
        elseif &filetype == 'mkd'
                exec "!~/.vim/markdown.pl % > %.html &"
                exec "!time open %.html &"
        endif
endfunc

" black格式化Python文件,需要提前用pip安装好black模块-----------

augroup format_py
    autocmd!
    autocmd FileType python nnoremap <F6>
                \ :!time python3 -m black %<CR>
augroup END
```

## 6 Windows使用GVIM 9 的配置

在 **Windows** 系统中使用 `vim9script` 的方式与 Linux 相似，但需要注意 Windows 的一些路径、终端、字体和依赖工具的不同。下面是完整的 Windows 安装与使用指南：

---

### 6.1 推荐 Vim 版本

建议下载：

* `gvim_9.x.x_x64.exe`

---

### 6.2 配置 Vim 环境

### 1. 配置文件路径

Windows 下配置文件为：

```
$HOME/_vimrc
```

或

```
%USERPROFILE%\_vimrc
```

你可以把你的 `vim9script` 脚本内容全部粘贴进去，但 **必须加上开头**：

```vim
vim9script
```

或者将整个内容保存为：

```
%USERPROFILE%\_vimrc
```

---

### 6.3 安装字体（Nerd Font）

**方式 1：手动下载并安装**

* 访问：[https://www.nerdfonts.com/font-downloads](https://www.nerdfonts.com/font-downloads)
* 下载如：`JetBrainsMono Nerd Font`, `FiraCode Nerd Font`, `CascadiaCode Nerd Font`
* 双击 `.ttf` 文件并点击“安装”

**方式 2：使用字体包**

```powershell
Invoke-WebRequest -Uri https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip -OutFile JetBrainsMono.zip
Expand-Archive JetBrainsMono.zip -DestinationPath "$HOME\Fonts"
```

然后在 gVim 菜单中设置字体，或在 `_vimrc` 里加上：

```vim
set guifont=JetBrainsMono\ Nerd\ Font:h11
```

---

### 6.4 安装插件管理器 vim-plug

打开 PowerShell 执行：

```powershell
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim | ni "$HOME/vimfiles/autoload/plug.vim" -Force
```

---

### 6.5 安装工具依赖

在 Windows 上使用命令行工具（如 `rg`, `clangd` 等）可通过如下方式获取：

推荐安装方式：使用 [Scoop](https://scoop.sh/)

在 PowerShell 中安装 Scoop：

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
```

然后安装依赖：

```powershell
scoop install ripgrep
scoop install clangd
scoop install marksman
scoop install taplo
scoop install rust-analyzer
```

这些工具会自动加入到系统环境变量 `PATH`。

---

### 6.6 插件安装

打开 `gVim`，运行：

```vim
:PlugInstall
```

这将自动下载并安装你配置的所有插件。

---

### 6.7 使用终端（可选）

如果你也想用终端版本 Vim（例如 `vim.exe`）而非 gVim：

使用 PowerShell/Windows Terminal

推荐使用：

* **Windows Terminal**
* **PowerShell 7**
* **字体设置为 Nerd Font**
* `vim.exe` 来自 Vim 安装目录（如 `C:\Program Files (x86)\Vim\vim90\vim.exe`）

---

### 6.8 检查配置是否成功

打开 gVim 或终端 Vim：

* 检查是否支持 vim9script：

```vim
:echo has('vim9script')
```

应返回 `1`。

* 测试 `def!` 函数是否可用
* 测试插件是否加载成功
* 测试 LSP 是否生效（例如进入 `.c` 文件后执行 `:LspHover`）

---

### 6.9 示例补充路径（Windows专用）

Windows 下可能还要修改：

```vim
set undodir=$HOME/vim/undo
set viminfofile=$HOME/vim/.viminfo
```

可改为：

```vim
set undodir=$HOME\\vim\\undo
set viminfofile=$HOME\\vim\\.viminfo
```

或者使用 Vim9 的语法：

```vim
set undodir=expand('$HOME\\vim\\undo')
```

---

### 6.10 总结

| 模块      | Windows 下要点                                       |
| ------- | ------------------------------------------------- |
| Vim9 支持 | 安装 gVim 9.0+                                      |
| 字体      | 安装 Nerd Font 并设置                                  |
| 插件      | 用 `vim-plug` 管理（PowerShell 安装）                    |
| 外部工具    | 使用 Scoop 安装 `rg`, `clangd`, `marksman`, `taplo` 等 |
| 配置路径    | `%USERPROFILE%\_vimrc`                            |

---

### 6.11 gvim其他设置


```shell
" 设置启动全屏
autocmd GUIEnter * simalt ~x
" 不生成undo文件
set noundofile
" 不生成swp文件
set nobackup
```

### 6.12 gvim配置

```shell
vim9script

source $VIMRUNTIME/defaults.vim
language messages en_US
g:mapleader = ' '

# === 插入模式/命令模式快捷键 ===
cnoremap <C-v> <C-r>*
cnoremap <M-i> <Tab>
cnoremap <M-u> <S-Tab>

# === 常用编辑快捷键 ===
nnoremap * *Nzz
nnoremap <C-d> <C-d>zz
nnoremap <C-f> <C-u>zz
nnoremap <C-p> :find *
nnoremap <silent> <C-q> :q<CR>
nnoremap <C-s> :%s/\s\+$//e<bar>w<CR>
nnoremap <C-w>i gt
nnoremap <C-w>u gT
nnoremap <F2> :%s/\C\<<C-r><C-w>\>/<C-r><C-w>/g<Left><Left>
nnoremap <M-i> :b<Space><Tab>
nnoremap <M-u> :b<Space><Tab><S-Tab><S-Tab>
nnoremap <M-j> :m .+1<CR>==
nnoremap <M-k> :m .-2<CR>==
nnoremap <leader>lh :noh<CR>
nnoremap <leader>vim :vs $MYVIMRC<CR>
nnoremap K i<CR><Esc>
nnoremap O O<Space><BS><Esc>
nnoremap gd <C-]>

if has('gui_running')
    nnoremap go "0yi):!start <C-r>0<CR>
endif

nnoremap j gj
nnoremap k gk
nnoremap o o<Space><BS><Esc>
noremap <leader>P "0P
noremap <leader>p "0p
noremap H g^
noremap L g_

# === 视觉模式 ===
vnoremap / "-y/<C-r>-<CR>N
vnoremap <C-d> <C-d>zz
vnoremap <C-f> <C-u>zz
vnoremap <F2> "-y:%s/<C-r>-\C/<C-r>-/g<Left><Left>
vnoremap <M-j> :m '>+1<CR>gv=gv
vnoremap <M-k> :m '<-2<CR>gv=gv
vnoremap <leader>ss :sort<CR>
vnoremap p pgv<Esc>

# === 基础设置 ===
set autoindent
set autoread
set background=dark
set belloff=all
set breakindent
set clipboard=unnamed
set colorcolumn=81,101
set complete=.,w,b,u,t
set completeopt=menuone,noselect,popup
set cursorcolumn
set cursorline
set expandtab
set fileformat=unix
set grepformat=%f:%l:%c:%m,%f:%l:%m
set guifont=0xProto_Nerd_Font_Mono:h16
set hlsearch
set ignorecase
set infercase
set iskeyword=@,48-57,_,192-255,-
set laststatus=2
set nofoldenable
set noswapfile
set nowrap
set number list listchars=tab:-->,trail:~,nbsp:␣
set path+=**
set pumheight=50
set relativenumber
set shiftwidth=4
set shortmess=flnxtocTOCI
set signcolumn=yes
set smartcase
set smarttab
set softtabstop=4
set splitbelow
set splitright
set statusline=%f:%l:%c\ %m%r%h%w%q%y\ [enc=%{&fileencoding}]\ [%{&ff}]
set tabstop=4
set termguicolors
set textwidth=100
set viminfofile=$HOME\\vim\\.viminfo
set wildcharm=<Tab>
set wildignorecase
set wildoptions=pum

# === 自定义函数 ===
def! g:LiveGrep()
    var user_input = input('Enter your search pattern: ')
    execute("silent! grep " .. user_input .. " .")
    execute("copen")
    execute("redraw!")
enddef

def! g:Retab()
    set ts=4
    set noet
    execute("%retab!")
    set et
enddef

# === grep 使用 ripgrep（需安装 rg） ===
if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case\ --hidden
    set grepformat=%f:%l:%c:%m
    nnoremap <leader>gg :silent! grep <C-R><C-W> .<CR>:copen<CR>:redraw!<CR>
    nnoremap <leader>gf :call LiveGrep()<CR>
endif

# === 安装 vim-plug 自动检测 ===
const vimplug = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
if has('win32') && empty(glob('$HOME\\vimfiles\\autoload\\plug.vim'))
    execute 'silent !powershell -command "iwr -useb ' .. vimplug
        .. ' | ni $HOME\\vimfiles\\autoload\\plug.vim -Force"'
endif

# === 插件列表 ===
call plug#begin('$HOME\\vimfiles\\plugged')
Plug 'junegunn/vim-easy-align'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'yegappan/lsp'
Plug 'sainnhe/everforest'
Plug 'skywind3000/asyncrun.vim'
call plug#end()

# === 外观 ===
autocmd! VimEnter * colorscheme everforest | AirlineTheme everforest
g:everforest_disable_italic_comment = 1

# === LSP 设置 ===
autocmd User LspSetup call LspOptionsSet({autoHighlightDiags: v:true})
autocmd User LspSetup call LspAddServer([
\ {name: 'c', filetype: ['c', 'cpp'], path: 'clangd', args: ['--background-index']},
\ {name: 'rust', filetype: ['rust'], path: 'rust-analyzer', args: [], syncInit: v:true},
\ {name: 'markdown', filetype: ['markdown'], path: 'marksman', args: ['server'], syncInit: v:true},
\ {name: 'toml', filetype: ['toml'], path: 'taplo', args: ['lsp', 'stdio'], syncInit: v:true},
\ ])

nnoremap <leader>rn :LspRename<CR>
nnoremap <silent> <S-M-f> :LspFormat<CR>
nnoremap <silent> gd :LspGotoDefinition<CR>
nnoremap <silent> gh :LspHover<CR>
nnoremap <silent> gr :LspShowReferences<CR>
nnoremap <silent> gs :LspDocumentSymbol<CR>

autocmd GUIEnter * simalt ~x
set noundofile
set nobackup
```

## 7 其他

### 7.1 其他设置

```shell
" 设置相对行号
set relativenumber
" 互换ESC和Capslock
inoremap <CapsLock> <Esc>
nnoremap <CapsLock> <Esc>
vnoremap <CapsLock> <Esc>

```

> `<C-x>` 数字减一
> `<C-a>` 数字加一

## 8 实用技巧

### 8.1 一箭双雕

| 复合命令 | 等效的长命令 | 解释                                               |
| -------- | ------------ | -------------------------------------------------- |
| C        | c$           | 自光标位置起，删除它到行末的所有内容并进入插入模式 |
| s        | cl           | 删除光标所在位置的字符并进入插入模式               |
| S        | ^c           | 删除光标所在行并进入插入模式                       |
| I        | ^i           | 光标回到行首并进入插入模式                         |
| A        | $a           | 光标回到行末并进入插入模式                         |
| o        | A<CR>        | 在当前行的下面新插入一行，光标位于新行的行首       |
| O        | ko           | 在当前行的上面新插入一行，光标位于新行的行首       |

