---
title: ubuntu安装tomcat8.5
p: /201709
date: 2017-09-15 17:07:19
tags:
- linux
- tomcat
---

此文章记录在阿里云的ubuntu16 64位系统上安装tomcat8.5.20的过程。

<!--more-->
# JDK
其中tomcat需要用到jdk，jdk的安装不此文章中介绍。  
此处我们假设已经安装好jdk，目录为/usr/lib/jvm/jdk1.8.0_144

# 下载
在本地下载tomcat安装包，下载地址https://tomcat.apache.org/download-80.cgi#8.5.20，下载得到apache-tomcat-8.5.20.tar.gz压缩文件  
通过下面命令上传到阿里云服务器
```Shell
$ scp ~/Downloads/apache-tomcat-8.5.20.tar.gz {user}@{ip}:/home/{user}
```
{user}是阿里云操作系统的用户名  
{ip}是阿里云机器的公网IP  
过程中需要输入{user}对应的密码（当然如果配置了ssh免密除外）

# 创建tomcat用户
为了提高系统安全，tomcat不应该使用root运行。为它创建一个新用户和组。
创建一个tomcat组：
```Shell
$ sudo groupadd tomcat
```
创建一个叫tomcat的用户：
```
$ sudo useradd -s /bin/false -g tomcat -d /opt/apache-tomcat-8.5.20 tomcat
```
tomcat用户属于tomcat组，家目录是/opt/apache-tomcat-8.5.20，我要把tomcat安装在这个目录。/bin/false代表这个用户是不能登录的。

# 解压
解压tomcat到/opt/apache-tomcat-8.5.20目录下
```shell
$ sudo cd /opt/
$ sudo mkdir apache-tomcat-8.5.20
$ sudo tar -zxvf ~/apache-tomcat-8.5.20.tar.gz -C /opt/
```

# 更改权限
赋给tomcat用户各种权限
```shell
$ sudo cd /opt/apache-tomcat-8.5.20
```
tomcat用户可以访问conf目录
```shell
$ sudo chgrp -R tomcat conf
$ sudo chmod g+rwx conf
$ sudo chmod g+r conf/*
```
修改各种目录的所有者
```shell
$ sudo chown -R tomcat webapps/ work/ temp/ logs/
```

# 安装服务
我们需要把tomcat配置为服务，为了做到这一点，需要创建systemd服务配置文件  
在/etc/systemd/system目录创建服务文件tomcat.service
```shell
$ sudo vim /etc/systemd/system/tomcat.service
```
文件内容
```
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target
 
[Service]
Type=forking
 
Environment=JAVA_HOME=/usr/lib/jvm/jdk1.8.0_144
Environment=CATALINA_PID=/opt/apache-tomcat-8.5.20/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/apache-tomcat-8.5.20
Environment=CATALINA_BASE=/opt/apache-tomcat-8.5.20
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'
 
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
 
User=tomcat
Group=tomcat
 
[Install]
WantedBy=multi-user.target
```
替换JAVA_HOME的值。上面配置内存要根据需要修改。  
修改完成之后，重新加载systemd：
```
$ sudo systemctl daemon-reload
```
启动tomcat：
```
$ sudo systemctl start tomcat
```
确认tomcat已启动
```
$ sudo systemctl status tomcat
```
关闭tomcat
```
$ sudo systemctl stop tomcat
```

# 安装service脚本
我们还可以再安装一个service服务
```shell
$ cp /opt/apache-tomcat-8.5.20/bin/catalina.sh /etc/init.d/tomcat
```
修改/etc/init.d/tomcat文件
```shell
$ vim /etc/init.d/tomcat
```
在最上面添加
```
CATALINA_HOME=/opt/apache-tomcat-8.5.20
```
我们用下面命令启动和关闭服务
```
$ sudo service tomcat start
```
```
$ sudo service tomcat stop
```



