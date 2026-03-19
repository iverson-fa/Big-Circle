# Claude

## 1 Docs Index

- [Claude Code](https://code.claude.com/docs/zh-CN/overview)
- [智谱 Coding Plan](https://bigmodel.cn/glm-coding?utm_source=bigModel&utm_medium=Special&utm_content=glm-code&utm_campaign=Platform_Ops&_channel_track_key=8BAeCdUS)
- [Minimax](https://www.minimaxi.com/)
- [Minimax Doc](https://platform.minimaxi.com/docs/coding-plan/intro)
- [阿里云百炼](https://bailian.console.aliyun.com/cn-beijing/?spm=5176.42028462.nav-v2-dropdown-menu-0.d_main_2_0_0.37b6154a7CDH7o&tab=coding-plan&scm=20140722.M_10979710._.V_1#/efm/index)


## 2 安装

### 2.1 Windows

powershell中输入

```shell
irm https://claude.ai/install.ps1 | iex
```

手动添加环境变量或执行以下命令

```bash
[Environment]::SetEnvironmentVariable(
  "Path",
  $env:Path + ";C:\Users\zhangjunfa\.local\bin",
  [EnvironmentVariableTarget]::User
)
```

验证

```shell
claude --version
```
