# Vim

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
| `<C-w> |`             | 最大化活动窗口的宽度                      |
| `[N]<C-w> _`          | 将活动窗口的高度设为 N 行                 |
| `[N]<C-w> |`          | 将活动窗口的宽度设为 N 行                 |

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

| 命令        | 作用范围                                                     |
| ----------- | ------------------------------------------------------------ |
| `iw`        | This is a **[**test**]** sentense.                           |
| `aw`        | This is a **[**test **]**sentense.                           |
| `iW`        | This is a **[**...test...**]** sentense.                     |
| `aW`        | This is a **[**...test... **]**sentense.                     |
| `is`        | ...sentense. **[**This is a sentense.**]** This ...          |
| `as`        | ...sentense. **[**This is a sentense. **]**This ...          |
| `ip`        | **[**This is a paragraph. It has two sentense.**]**<br />The next. |
| `ap`        | **[**This is a paragraph. It has two sentense.<br />**]**The next. |
| `i(` / `i)` | 1 * (**[**2 + 3**]**)                                        |
| `a(` / `a)` | 1 * **[**(2 + 3)**]**                                        |
| `i<` / `i>` | the < **[**tag**]** >                                        |
| `a<` / `a>` | the **[**< taga >**]**                                       |
| `i{` / `i}` | some {**[**code block**]**}                                  |
| `a{` / `a}` | some **[**{code block}**]**                                  |
| `i[` / `i]` | some [**[**code block**]**]                                  |
| `a[` / `a]` | some **[**[code block]**]**                                  |
| `i"`        | some "**[**words**]**"                                       |
| `a"`        | some**[** "words"**]**                                       |
| `i'`        | some '**[**words**]**'                                       |
| `a'`        | some**[** 'words'**]**                                       |

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

