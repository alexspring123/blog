---
title: 解决vim中文乱码问题
date: 2017-08-17 10:12:00
tags:
- vim
---

打开~.vimrc文件，加上fileencodings参数
```
set fileencodings=utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1
```
