# Agent

## 1 Docs Index

- [Claude Code](https://code.claude.com/docs/zh-CN/overview)
- [智谱 Coding Plan](https://bigmodel.cn/glm-coding?utm_source=bigModel&utm_medium=Special&utm_content=glm-code&utm_campaign=Platform_Ops&_channel_track_key=8BAeCdUS)
- [Minimax](https://www.minimaxi.com/)
- [Minimax Doc](https://platform.minimaxi.com/docs/coding-plan/intro)
- [阿里云百炼](https://bailian.console.aliyun.com/cn-beijing/?spm=5176.42028462.nav-v2-dropdown-menu-0.d_main_2_0_0.37b6154a7CDH7o&tab=coding-plan&scm=20140722.M_10979710._.V_1#/efm/index)


## 2 Codex CLI 配置

### 2.1 Ubuntu

修改`.bashrc` 

```shell
codex() {
    HTTP_PROXY=http://127.0.0.1:7897 \
    HTTPS_PROXY=http://127.0.0.1:7897 \
    command codex "$@"
}
```

升级或安装要使用sudo

```bash
# 安装或升级
sudo npm install -g @openai/codex
# 升级
sudo npm update -g @openai/codex
# check
codex --version
# 弹出最近的会话列表，选中后按 Enter 继续
codex resume
# 继续当前目录下最近一次会话
codex resume --last
# 显示其他目录里的历史会话
codex resume --all --last
# 在 Codex CLI 交互界面里，也可以输入
/resume
# 额度使用
/status
# 显示会话配置和 token 使用情况
/usage
# 切换模型
/model
# 查看 Codex 改了哪些文件
/diff
# 让 Codex review 当前工作区改动，适合改完代码后检查一遍
/review
# 进入计划模式，让 Codex 先给方案，不直接动手改
/plan
# 会话太长时压缩上下文，保留关键点，减少上下文占用
/compact
# 清屏并开始一个新的聊天上下文
/clear
# 在同一个 CLI 会话里开新对话；官方说明它会重置聊天上下文但不退出 CLI
/new
# 把某个文件或文件夹附加到对话，让 Codex 重点看它
/mention
# 在当前目录生成 AGENTS.md，用来保存项目级长期指令，比如代码风格、构建命令、测试方式
/init
# 退出
/quit
/exit
```

