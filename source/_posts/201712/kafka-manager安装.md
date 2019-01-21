---
title: kafka-manager安装
p: /201712/kafka-manager安装.md
date: 2017-12-14 14:58:00
tags:
- kafka
---
为了简化开发者和服务工程师维护Kafka集群的工作，yahoo构建了一个叫做Kafka管理器的基于Web工具，叫做 Kafka Manager。这个管理工具可以很容易地发现分布在集群中的哪些topic分布不均匀，或者是分区在整个集群分布不均匀的的情况。

<!--more-->

# 修改maven源
在开始安装官方文档进行配置前，因为Kafka-manager使用的Play框架，为了编译的速度更快，先配置sbt的maven仓库，由于默认仓库速度较慢，因此使用aliyun提供的maven仓库。  
通过 cd ~进入当前用户目录，然后通过命令mkdir .sbt创建.sbt目录，进入创建的该目录，使用vi创建repositories文件，编辑内容如下：
```
[repositories]
local
aliyun: http://maven.aliyun.com/nexus/content/groups/public
typesafe: http://repo.typesafe.com/typesafe/ivy-releases/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext], bootOnly
```

# 下载源码并编译
获取kafka-manager源码，并编译打包，包会生成在(kafka-manager/target/universal)
从github下载源码
```
git clone https://github.com/yahoo/kafka-manager
cd kafka-manager
./sbt clean dist
```
编译后会生成 kafka-manager/target/universal/kafka-manager-1.3.3.15.zip 文件

# 安装并配置
解压
```
unzip kafka-manager-1.3.3.15.zip
```
修改配置
```
vim kafka-manager-1.3.3.15/conf/application.conf
```
启动,指定配置文件位置和启动端口号，默认为9000
```
nohup bin/kafka-manager -Dconfig.file=/usr/install/kafka-manager-1.2.7/conf/application.conf -Dhttp.port=7778 &
```

windows 运行sbt run


