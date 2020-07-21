---
title: Ubuntu apt-get代理设置方法
date: 2019-09-20 10:38:34
tags: linux
---

有时候内网的Ubuntu机器无法直接访问外网，需要安装软件的时候非常不方便，此时可以通过给``apt-get``添加代理来安装。
```bash
sudo apt-get -o Acquire::http::proxy="http://10.4.33.235:8888" update

sudo apt-get install -o Acquire::http::proxy="http://10.4.33.235:8888" curl
```
其中``http://10.4.33.235:8888``就是代理服务器地址和端口。
