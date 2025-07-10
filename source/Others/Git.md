# Git

## 1 学习资料

- [Git 在线学习](https://learngitbranching.js.org/?locale=zh_CN)
- [Git Community Book中文版](http://gitbook.liuhui998.com/index.html)
- [Git教程](https://git-scm.com/book/zh/v2)
- [Pro Git中文版](http://git.oschina.net/progit/)
- [Gitee帮助文档](http://git.mydoc.io/)
- [Git使用流程规范](http://www.jizhuomi.com/software/436.html)
- [Gitlab项目分支管理的一种策略](https://segmentfault.com/a/1190000006062453)
- [Git rebase简介](http://blog.csdn.net/hudashi/article/details/7664631/)
- [Git分支管理策略](http://www.ruanyifeng.com/blog/2012/07/git.html)
- [git cherry-pick教程](http://www.ruanyifeng.com/blog/2020/04/git-cherry-pick.html)

## 2 bash终端显示Git分支

> 将下列程序写在`.bashrc`文件中

```shell
# These shell commands block are for the purpose of displaying the
# current branch name of the current repository.
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

> 在`.gitconfig`文件中添加别名，[safe]可以避免检测是否安全目录，共享平台谨慎使用
```shell
[alias]
	co = checkout
	st = status
	br = branch
	ci = commit
	lg = log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
	go = reset --hard
[safe]
    directory = *
```

上述[safe]的配置也可以输入以下命令：
```bash
git config --global --add safe.directory '*'
# 撤销
git config --global --unset-all safe.directory
```

## 3 备忘命令

|                  命令                   |                             说明                             |
| :-------------------------------------: | :----------------------------------------------------------: |
|             `git add --all`             | 将当前工作区（working directory）修改添加到暂存区（stage），只有添加到暂存区的修改才能被提交（commit） |
|       `git checkout branch_name`        |                 切换到名为 branch_name 分支                  |
|      `git checkout -b branch_name`      |                创建名为 branch_name 的新分支                 |
|        `git checkout commit_id`         |              切换到 id 为 commit_id 对应的提交               |
|        `git checkout tag_number`        |            切换到 tag 号 为 tag_number 对应的提交            |
|         `git checkout - <file>`         |                   删除本地文件<file>的修改                   |
|            `git checkout .`             |                       删除本地所有修改                       |
|        `git commit -m "comment"`        |      向本地仓库提交修改，comment 代表本次提交的注释内容      |
|               `git push`                |                  向远程仓库推送更新本地提交                  |
|            `git push --tags`            |            向远程仓库推送本地仓库的所有 tag 信息             |
|               `git stash`               | 将工作区与暂存区中的修改临时保存到 git 栈（需要时可以恢复），并将工作区与暂存区恢复至上一次提交的状态 |
|      `git stash save -u "message"`      | 将工作区与暂存区中的修改以及未被追踪的修改（-u）临时保存到 git 栈（需要时可以恢复），并将工作区与暂存区恢复至上一次提交的状态，message 表示此次操作的备注信息 |
|            `git stash list`             | 列举当前 git 栈中所有被临时保存的修改，每一次临时修改都对应唯一的 stash_id，从 0 开始，依次往后追加 |
|             `git stash pop`             |   将 git 栈栈顶（即最新的）的临时修改弹出并恢复至当前分支    |
|   `git stash apply stash@{stash_id}`    | 将 git 栈中 stash_id 对应的临时修改恢复至当前分支，但不会删除 git 栈中的对应内容 |
|    `git stash drop stash@{stash_id}`    |           将 git 栈中 stash_id 对应的临时修改删除            |
|            `git stash clear`            |                 删除 git 栈中所有的临时修改                  |
|          `git tag tag_number`           |           为最新提交打上名为 tag_number 的 tag 号            |
|     `git tag tag_number commit_id`      |  为 id 为 commit_id 对应的提交打上名为 tag_number 的 tag 号  |
|         `git tag -d tag_number`         |            删除本地仓库名为 tag_number 的 tag 号             |
| `git push origin :refs/tags/tag_number` |            删除远程仓库名为 tag_number 的 tag 号             |
|         `git reset --hard HEAD`         | 丢弃工作区与暂存区中的修改（未被跟踪的修改需要先添加至暂存区），并恢复至最新提交的状态 |
|      `git reset --hard commit_id`       | 丢弃工作区与暂存区中的修改（未被跟踪的修改需要先添加至暂存区），并恢复至 id 为 commit_id 对应的提交的状态 |
|             `git branch -a`             |                   查看本地及远程的所有分支                   |
|       `git branch -D branch_name`       |             删除本地仓库名为 branch_name 的分支              |
| `git push origin --delete branch_name`  |           删除远程仓库仓库名为 branch_name 的分支            |
|                `git log`                |                         查看提交日志                         |
|              `git status`               |        查看工作树状态，分别列举工作区和暂存区中的修改        |
|               `git diff`                |               详细展现工作树与上次提交间的变更               |
|       `git diff branch1 branch2`        |         详细展现 branch2 分支相比 branch1 分支的修改         |
|           `git config --list`           |                   查看本地仓库的 git 配置                    |

1. 版本切换

    - `HEAD` 指向的版本就是当前版本，切换版本使用命令 `git reset --hard commit_id`。
    - 切换前用 `git log` 可以查看提交历史，以便确定要回退到哪个版本。
    - 要切换未来版本，用 `git reflog` 查看命令历史，以便确定要回到未来的哪个版本。

2. 撤销修改

    - 场景1：如果改乱了工作区某个文件的内容，想直接丢弃工作区的修改时，用命令 `git checkout -- file` 或 `git restore <file>`。
    - 场景2：如果不但改乱了工作区某个文件的内容，还添加到了暂存区时，想丢弃修改，分两步，第一步用命令 `git reset HEAD <file>` 或 `git restore --staged <file>...`，就回到了场景1，第二步按场景1操作。
    - 场景3：已经提交了不合适的修改到版本库时，想要撤销本次提交，参考上一节，不过前提是没有推送到远程库。

3. 删除文件

    - 命令 `git rm` 用于删除一个文件。如果一个文件已经被提交到版本库，那么你永远不用担心误删，但是要小心，你只能恢复文件到最新版本，你会丢失最近一次提交后你修改的内容。
    - `git checkout -- <file>` 或 `git restore <file>` 其实是用版本库里的版本替换工作区的版本，无论工作区是修改还是删除，都可以“一键还原”。
    - 从来没有被添加到版本库就被删除的文件，是无法恢复的！
    - 删除远程文件夹
    ```bash
    # 删除单一文件夹
    git rm -r --cached test # --cached 不会把本地的 test 文件夹删除
    git commit -m "delete test dir"
    git push github main
    # 批量删除
    # 先将需要删除的远程文件夹写在 .gitignore 文件中
    git rm -r --cached .
    git add .
    git commit -m "delete lots of folds"
    git push github main

    # 未添加到暂存区
    ## 删除一个文件的修改
    git checkout – <file>
    ## 删除本地所有的修改
    git checkout .

    # 已添加到暂存区，删除完之后要删除本地（参考上面）
    ## 删除一个文件的修改
    git reset HEAD <file>
    ## 删除暂存区所有修改
    git reset HEAD .

    # 已添加到本地仓库
    ## 回退到上一次提交
    git reset --hard HEAD^
    ## 回退到任意一次提交
    git reset --hard commitid

    # 放弃本地修改，强制和远程同步
    git fetch --all
    git reset --hard origin/master
    git pull
    ```

## 4 远程仓库

1. 创建 SSH Key，添加到托管网站的个人设置中。

   `ssh-keygen -t rsa -C "youremail@example.com"`

2. 添加远程库
    - 要关联一个远程库，使用命令 `git remote add origin git@server-name:path/repo-name.git`；
    - 关联一个远程库时必须给远程库指定一个名字，origin是默认习惯命名；
    - 关联后，使用命令 `git push -u origin master` 第一次推送 `master` 分支的所有内容；
    - 此后，每次本地提交后，只要有必要，就可以使用命令 `git push origin master` 推送最新修改。
    - Git支持多种协议，包括 https 和 ssh，但 ssh 协议速度最快。

3. 常用指令

    - `git remote -v`查看远程库信息
    - 使用多个远程库时，我们要注意，git给远程库起的默认名称是origin，如果有多个远程库，我们需要用不同的名称来标识不同的远程库。
    - `git remote add github git@github.com:xxx.git`;`git remote add gitee git@gitee.com:xxx.git`

## 5 分支管理

1. 创建与合并分支
    - 查看分支：`git branch`
    - 创建分支：`git branch <name>`
    - 切换分支：`git checkout <name>`或者`git switch <name>`
    - 创建+切换分支：`git checkout -b <name>`或者`git switch -c <name>`
    - 合并某分支到当前分支：`git merge <name>`
    - 删除分支：`git branch -d <name>`

2. 解决冲突
    - 当Git无法自动合并分支时，就必须首先解决冲突。解决冲突后，再提交，合并完成。
    - 解决冲突就是把Git合并失败的文件手动编辑为我们希望的内容，再提交。
    - 用`git log --graph`命令可以看到分支合并图。
3. 分支管理策略
    - 通常，合并分支时，如果可能，Git会用`Fast forward`模式，但这种模式下，删除分支后，会丢掉分支信息。
    - 如果要强制禁用`Fast forward`模式，Git就会在merge时生成一个新的commit，这样，从分支历史上就可以看出分支信息。
    - `git merge --no-ff -m "infomation" <name>`
4. Bug分支
    - 修复bug时，我们会通过创建新的bug分支进行修复，然后合并，最后删除。
    - 当手头工作没有完成时，先把工作现场git stash一下，然后去修复bug。
    - 修复后，`git stash list`可以查看工作现场，恢复的两个方法：一是用`git stash apply`恢复，但是恢复后，stash内容并不删除，你需要用`git stash drop`来删除；另一种方式是用`git stash pop`，恢复的同时把stash内容也删了。
    - 在master分支上修复的bug，想要合并到当前dev分支，可以用`git cherry-pick <commit>`命令，把bug提交的修改“复制”到当前分支，避免重复劳动。
    - `git stash apply stash@{0}`恢复指定的stash。
5. Feature分支
    - 开发一个新feature，最好新建一个分支；如果要丢弃一个没有被合并过的分支，可以通过`git branch -D <name>`强行删除。
    - `master`分支是主分支，因此要时刻与远程同步。
    - `dev`分支是开发分支，团队所有成员都需要在上面工作，所以也需要与远程同步。
    - `bug`分支只用于在本地修复bug，就没必要推到远程了，除非老板要看看你每周到底修复了几个bug。
    - `feature`分支是否推到远程，取决于你是否和你的小伙伴合作在上面开发。
6. 多人协作
    - 查看远程库信息，使用`git remote -v`。
    - 本地新建的分支如果不推送到远程，对其他人就是不可见的。
    - 从本地推送分支，使用`git push origin branch-name`，如果推送失败，先用`git pull`抓取远程的新提交。
    - 在本地创建和远程分支对应的分支，使用`git checkout -b branch-name origin/branch-name`，本地和远程分支的名称最好一致。
    - 建立本地分支和远程分支的关联，使用`git branch --set-upstream branch-name origin/branch-name`。
    - 从远程抓取分支，使用`git pull`，如果有冲突，要先处理冲突。
7. Rebase
    - rebase操作可以把本地未push的分叉提交历史整理成直线；
    - rebase的目的是使得我们在查看历史提交的变化时更容易，因为分叉的提交需要三方对比。

## 6 标签管理

1. 创建标签
    - 命令`git tag <tagname>`用于新建一个标签，默认为HEAD，也可以指定一个commit id；
    - 命令`git tag -a <tagname> -m "infomation"`可以指定标签信息；
    - 命令`git tag`可以查看所有标签。

2. 删除标签
    - 命令`git push origin <tagname>`可以推送一个本地标签；
    - 命令`git push origin --tags`可以推送全部未推送过的本地标签；
    - 命令`git tag -d <tagname>`可以删除一个本地标签；
    - 命令`git push origin :refs/tags/<tagname>`可以删除一个远程标签。

## 7 git config

```
git config --global -e  # 默认为 --global
git config  -e    # or git config --edit
git config --list
git config --global core.editor vim  # 配置默认编辑器 vim

#  设置代理服务- 全局
git config --global http.proxy  socks5://127.0.0.1:1080 # 代理服务器
git config --global https.proxy socks5://127.0.0.1:1080

git config --global --unset http.proxy   # 撤销代理服务器
git config --global --unset https.proxy

git config --global --get http.proxy   # 查询理服务器
git config --global --get https.proxy


#设置代理服务 - 只对github.com
git config --global http.https://github.com.proxy socks5://127.0.0.1:1080

#取消代理
git config --global --unset http.https://github.com.proxy


# 记住密码
$ git config credential.helper store # 永久记住密码
$ git config credential.helper cache  # 临时记住密码15分钟
$ git config credential.helper 'cache --timeout=3600' # 临时记住密码1小时
```

## 8 git format-patch

```shell
# 打包最近的一个patch,有几个^就打包几个patch的内容
git format-patch HEAD^
# 或
git format-patch -n
# 打包版本n1与n2之间的patch
git format-patch -n1 -n2
# 某次提交以后的所有patch,xxx是commit名
git format-patch xxx
# 某次提交(含)之前的几次提交
git format-patch -n xxx
# 某两次提交之间的所有patch
git format-patch xxx..xxx
# 将所有patch输出到一个指定位置的指定文件
git format-patch xxx --stdout > xxx.patch
```

## 9 输出Git管理的文件

如果只需要拷贝当前目录中被 Git 管理的文件和 `.git` 目录，可以使用以下方法：

---

### **方法 1：使用 `git archive`**
`git archive` 是 Git 提供的工具，用于生成包含版本控制文件的归档。

1. 生成归档（如 ZIP 文件）：
   ```bash
   git archive --format=zip HEAD -o repo.zip
   ```

   - `HEAD` 表示当前分支的最新提交。
   - `-o repo.zip` 指定输出文件。

2. 解压缩归档到目标目录：
   ```bash
   unzip repo.zip -d /path/to/target_directory
   ```

> **注意**：这种方式不会包含 `.git` 目录，仅包含被 Git 管理的文件。如果需要 `.git` 目录，请参考其他方法。

---

### **方法 2：拷贝被管理文件及 `.git` 目录**
以下命令可以直接复制当前目录中被 Git 管理的文件和 `.git` 目录：

1. 创建目标目录：
   ```bash
   mkdir /path/to/target_directory
   ```

2. 使用 `rsync` 拷贝：
   ```bash
   rsync -av --exclude-from=.gitignore . /path/to/target_directory
   ```

   - `-a`：保持文件属性。
   - `-v`：显示详细信息。
   - `--exclude-from=.gitignore`：根据 `.gitignore` 中的规则排除未被管理的文件。
   - 默认会将当前目录的 `.gitignore` 和 `.git` 目录同步到目标目录，若不需要，将其添加到 `.gitignore`。

---

### **方法 3：通过 `git` 命令**
这种方式只能同步到本机的位置，如果目标目录是一个新的 Git 仓库：

1. 克隆当前仓库到目标目录：
   ```bash
   git clone --no-checkout file://$(pwd) /path/to/target_directory
   ```

2. 进入目标目录，签出文件：
   ```bash
   cd /path/to/target_directory
   git checkout <commit-id>
   ```

> **优势**：这种方法确保目标目录中既有所有被 Git 管理的文件，也有 `.git` 目录。

---

### **总结**
- 如果 **不需要 `.git` 目录**，推荐使用 `git archive`。
- 如果 **需要 `.git` 目录**，可以使用 `rsync` 或 `git clone`。