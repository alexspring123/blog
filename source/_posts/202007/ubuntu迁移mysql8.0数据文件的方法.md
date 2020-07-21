---
title: ubuntu迁移mysql8.0数据文件的方法
p: /202007/ubuntu迁移mysql8.0数据文件的方法.md
date: 2020-07-21 19:53:00
tags:
- mysql
- linux
---

之前mysql通过apt安装的，运行一段时间之后，发现根分区过小，有必要将占用空间大的数据库迁移到home分区，于是，有了这篇文章。
<!--more-->

# 停掉正在使用的数据库
为了保证数据的完整性，先暂时停掉正在使用的数据库。
```
service mysql stop
```

# 修改数据目录配置
```
vim /etc/mysql/mysql.conf.d/mysqld.conf
```
找到datadir参数（默认情况下是``/var/lib/mysql``）。
将其修改为迁移后的目录，此处我放在了``/data/mysql_data``目录。

当然，如果``/data/mysql-data``目录不存在，则需要新新建
```
mkdir /data/mysql_data
```

# 复制数据文件
```
cp -a -r /var/lib/mysql/* /data/mysql_data
```
此处一定要跟上``-a``参数，不然复制过去的目录没有权限。

修改新目录的权限
```
chown -R mysql:mysql /data/mysql_data
```

# 修改AppArmor
要通过在默认目录和新位置之间创建别名来告诉AppArmor让MySQL写入新目录。需要编辑AppArmor alias文件
```
vim /etc/apparmor.d/tunables/alias
```
在文件底部添加
```
alias /var/lib/mysql/ -> /mnt/volume-nyc1-01/mysql/,
```
保存并退出。

重启AppArmor服务，使配置生效。
```
service apparmor restart
```

# 启动mysql
```
service mysql start
```
查看mysql状态
```
systemctl status mysql
```

# 检查新目录是否生效
登录mysql
```
mysql -u root -p
```
查看配置
```
show global variables like "%datadir%";
```
此时应该看到值为新目录``/data/mysql_data``，表示配置生效。

# 删除原文件
```
rm -rf /var/lib/mysql
```

参考文章：
- https://zhuanlan.zhihu.com/p/141802334
