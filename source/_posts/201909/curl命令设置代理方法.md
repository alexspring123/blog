---
title: curl命令设置代理方法
date: 2019-09-20 10:44:30
tags: linux
---

curl可以通过-x参数设置代理
```bash
curl -x 10.4.33.235:8888 www.baidu.com  
```
其中``10.4.33.235:8888``就是代理服务器地址和端口。
