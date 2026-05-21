# 给朋友试用的话

我做了一个小工具，叫 **Terminal Beauty**，主要是给 macOS 自带 Terminal 用的。

它不是让你换一个新的终端 App，而是把 Apple Terminal 里本来就能设置、但很难发现和配置的主题系统，做成一个「看预览 → 选主题 → 自动备份 → 自动应用 → 可回滚」的流程。

你可以先打开主题预览：

https://mayimian123.github.io/terminal-beauty/

如果你想试一下，推荐选一个主题，比如 `catppuccin`，然后在仓库里运行：

```bash
scripts/install.sh --import-terminal-profiles catppuccin
```

如果想要预览图里那种漂亮 prompt，需要装 Starship：

```bash
brew install starship
```

安装脚本每次都会先备份，备份目录会打印出来。如果不喜欢，可以回滚：

```bash
scripts/rollback.sh
scripts/rollback.sh ~/.terminal-beauty-backups/<timestamp>
```

我主要想请你帮我看：

- 哪一步让你不确定？
- 你能不能理解 Starship 和 Terminal profile 的区别？
- 自动导入主题后，新开的 Terminal 窗口有没有变色？
- README 和 gallery 有没有让你知道下一步该做什么？
- 有没有哪里让你担心它会改坏电脑？

这是 beta 版，感谢帮忙试用。
