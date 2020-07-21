---
title: linux下mysql8忘记密码后重置密码
p: /202007/linux下mysql8忘记密码后重置密码.md
date: 2020-07-21 19:33:00
tags:
- mysql
- linux
---

在忘记mysql8的root账号密码时，可以通过此篇文章进行重置。
<!--more-->

# 配置免密码登陆
找到mysql配置文件``my.cnf``（ubuntu下是``/etc/mysql/mysql.conf.d/mysqld.cnf``）。
在【mysqld】模块添加：``skip-grant-tables`` 保存退出，例如下方的文件。
```
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /data/mysql_data
log-error       = /var/log/mysql/error.log
skip-grant-tables
```

# 重启使配置生效
重启后msyql服务使配置生效 ``service mysqld restart``（在ubuntu下需要使用``service msyql stop``和``service mysql start``）。

# 将旧密码置空
执行``mysql -u root -p``登录数据库，提示输入密码时直接敲回车。
选择数据库
``use mysql``
将密码置空
``update user set authentication_string = '' where user = 'root';``
退出
``quit``

# 去除免密码登陆配置
删掉步骤1的语句``skip-grant-tables``.
重启服务 ``service mysqld restart``（在ubuntu下需要使用``service msyql stop``和``service mysql start``）。

# 修改密码
执行``mysql -u root -p``登录数据库，提示输入密码时直接敲回车，刚刚已经将密码置空了。
执行``ALTER USER 'root'@'localhost' IDENTIFIED BY 'abc123@xxx';``,'abc123@xxx'是新密码，当然也可以设置成其他你希望的密码；

> mysql5.7.6版本后 废弃user表中 password字段 和 password（）方法，所以旧方法重置密码对mysql8.0版本是行不通的

参考文章：
- https://zhuanlan.zhihu.com/p/55015491