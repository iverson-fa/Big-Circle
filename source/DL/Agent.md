# Agent

## 1 Docs Index

- [Claude Code](https://code.claude.com/docs/zh-CN/overview)
- [智谱 Coding Plan](https://bigmodel.cn/glm-coding?utm_source=bigModel&utm_medium=Special&utm_content=glm-code&utm_campaign=Platform_Ops&_channel_track_key=8BAeCdUS)
- [Minimax](https://www.minimaxi.com/)
- [Minimax Doc](https://platform.minimaxi.com/docs/coding-plan/intro)
- [opencode github](https://github.com/anomalyco/opencode)
- [opencode 官方文档](https://opencode.ai/docs/zh-cn)
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
## 3 opencode

你 TUI 自动生成的配置：
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "disabled_providers": [],
  "provider": {              // ← 旧版单数
    "icompify": {
      "name": "icompify",
      "npm": "@ai-sdk/openai-compatible",   // ← 旧版 npm
      "options": {            // ← 旧版 options
        "baseURL": "https://api.icompify.com/v1"
      },
      "models": { ... }
    }
  }
}
```

### 3.1 用环境变量

**第一步：设置环境变量**

```bash
# 先去 icompify 后台重置一下之前泄露的 key！
# 拿到新 key 后，设置环境变量

# 临时（关掉终端失效）
export ICOMPIFY_API_KEY="sk-你的新key"

# 永久（推荐）
echo 'export ICOMPIFY_API_KEY="sk-你的新key"' >> ~/.bashrc
source ~/.bashrc

# 验证
echo $ICOMPIFY_API_KEY
```

**第二步：编辑 `opencode.jsonc`**

```bash
nano ~/.config/opencode/opencode.jsonc
```

在 `options` 里加一行 `"apiKey"`：

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "disabled_providers": [],
  "provider": {
    "icompify": {
      "name": "icompify",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "https://api.icompify.com/v1",
        "apiKey": "{env:ICOMPIFY_API_KEY}"    // ← 加这一行
      },
      "models": {
        "qwen3.8-27b": { "name": "qwen3.8-27b" },
        "glm-5.2": { "name": "glm-5.2" },
        "deepseek-v4-pro": { "name": "deepseek-v4-pro" },
        "qwen3.8": { "name": "qwen3.8" }
      }
    }
  }
}
```

**注意**：
- `baseURL` 那行末尾**有逗号**（因为后面还有 `apiKey`）
- `apiKey` 写的是 `"{env:ICOMPIFY_API_KEY}"`（**带双引号和花括号**）
- `~/.local/share/opencode/auth.json` 里应该**已经存了** key（你之前 `auth login` 时输的），但用环境变量更安全更可控

### 3.2  验证步骤

```bash
# 1. 确认环境变量已设置
echo $ICOMPIFY_API_KEY
# 应该输出 sk-xxx 之类

# 2. 启动 opencode
opencode

# 3. 在 TUI 里
/connect
# 看 icompify 是否出现

# 4. 切模型
/models
# 选你配置里的某个模型，比如 qwen3.8-27b

# 5. 试聊
你好
```




