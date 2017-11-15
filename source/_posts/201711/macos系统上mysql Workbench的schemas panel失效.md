---
title: macos系统上mysql Workbench的schemas panel失效
p: /201711/macos系统上mysql Workbench的schemas panel失效.md
date: 2017-11-15 14:58:00
tags:
- mysql
---

之前一直使用正常的mysql Workbench，今天突然发现左边的schemas panel中什么都显示了，仅显示
> No object selected
google了解决方案
```
cd ~/Library/Application\ Support/MySQL/Workbench/
rm wb_state.xml
rm wb_options.xml
rm -R cache
mkdir cache
```
重启Workbench

参考：https://stackoverflow.com/questions/26547926/mysql-workbench-schemas-panel-not-working