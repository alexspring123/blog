---
title: Linux下tomcat的catalina.out日志文件过大处理方法
p: /201902/Linux下tomcat的catalina.out日志文件过大处理方法.md
date: 2019-02-23 10:46:00
tags:
- tomcat
---

在linux下运行tomcat会碰到catalina.out日志文件一直增大的问题，本文章给出多种不同的处理办法。
<!--more-->

# 禁用catalina.out
## 配置
修改``$CATALINA_BASE/bin/setenv.sh``文件（如果不存在则新建一个），文件中加入
```shell
export CATALINA_OUT="/dev/null"
```
## 原理
- 在``setenv.sh``文件中将``CATALINA_OUT``重定向到空设备，当然你可以将其定位到其他文件路径
- tomcat启动的会执行``$CATALINA_BASE/bin/setenv.sh``文件（具体可以查看``$CATALINA_BASE/bin/catalina.sh``文件）
```shell
#   Do not set the variables in this script. Instead put them into a script
#   setenv.sh in CATALINA_BASE/bin to keep your customizations separate.
#
#   CATALINA_HOME   May point at your Catalina "build" directory.
#
#   CATALINA_BASE   (Optional) Base directory for resolving dynamic portions
#                   of a Catalina installation.  If not present, resolves to
#                   the same directory that CATALINA_HOME points to.
#
#   CATALINA_OUT    (Optional) Full path to a file where stdout and stderr
#                   will be redirected.
#                   Default is $CATALINA_BASE/logs/catalina.out
```

# 切割catalina.out
Linux一般自带了``logrotate``命令，查看是否已安装，直接看手册``man logrotate``
修改``/etc/logrotate.d/tomcat``文件（没有则创建一个）
```shell
vim /etc/logrotate.d/tomcat
```
文件内容
```
$CATALINA_BASE/logs/catalina.out {  
    copytruncate  
    daily  
    rotate 7  
    compress  
    missingok  
    size 5M  
}
```
关于上面的配置：
- ``$CATALINA_BASE/logs/catalina.out``：这里的路径即需要切割的日志文件路径，需要替换成实际路径
- ``daily``：按天为单位切分 catalina.out 日志文件
- ``rotate 7``：最多保存 7 个切分的日志，可以根据自己需求修改
- ``compress``：切分后压缩处理 (gzip压缩)
- ``size 5M``：如果catalina.out未超过5M则不切分，只有大于5M时才切分
- ``copytruncate``：在创建备份之后清空原始文件(大部分程序是不能删除/移动原始文件的，即使之后又重新创建了一个名字一样的也是不行的)。在备份和清空的间隙日志可能会丢失一部分。控制台日志一般没那么严格的要求

## 工作原理
1. 每天晚上 cron 定时任务会扫码目录 ``/etc/cron.daily/``
2. 触发``/etc/cron.daily/logrotate``脚本，即运行脚本：
```
/usr/sbin/logrotate /etc/logrotate.conf
```
3. ``/etc/logrotate.conf``会扫码所有``/etc/logrotate.d/``目录的脚本
4. 触发``/etc/logrotate.d/tomcat``上面新建的配置

## 手工执行
```
/usr/sbin/logrotate /etc/logrotate.conf
```