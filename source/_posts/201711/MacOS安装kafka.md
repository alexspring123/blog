---
title: MacOS安装kafka
p: /201711/MacOS安装kafka.md
date: 2017-11-10 14:58:00
tags:
- kafka
---
Kafka是一种高吞吐量的分布式发布订阅消息系统，它可以处理任何规模网站中的所有动作流数据。Kafka的目的是通过Hadoop的并行加载机制来统一线上和离线的消息处理，也是为了通过集群机来提供实时的消费。下面介绍有关Kafka的简单安装和使用,想全面了解Kafka,请访问Kafka的官方网站。

<!--more-->

# 安装并启动zookeeper
Kafka的运行基于zookeeper，因此我们需要先安装zookeeper。（当然也可以使用Kafka内置的zookeeper，为了学习目的，我们还是独立安装一个zookeeper）
- 下载
```
http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.4.11/
```

- 解压安装
```
sudo cp ~/Downloads/zookeeper-3.4.11.tar.gz /usr/local/
cd /usr/local
sudo tar zxvf zookeeper-3.4.11.tar.gz 
sudo chown -R alex zookeeper-3.4.11
sudo chgrp -R admin zookeeper-3.4.11
```

- 设置dataDir
```
cd /usr/local/zookeeper-3.4.11
cp -rf conf/zoo_sample.cfg conf/zoo.cfg
cd conf/
vim zoo.cfg 
```
修改zook.cfg里头的dataDir
> dataDir=/Users/alex/Downloads/zookeeper

- 启动和停止服务
```
cd /usr/local/zookeeper-3.4.11/bin/
sh zkServer.sh start # 启动
sh zkServer.sh stop # 停止
```

- 删除压缩文件
```
sudo rm /usr/local/zookeeper-3.4.11.tar.gz
```

# 安装kafka
- 下载 
```
http://mirror.bit.edu.cn/apache/kafka/1.0.0/kafka_2.11-1.0.0.tgz 
```

- 解压安装
```
sudo cp ~/Downloads/kafka_2.11-1.0.0.tgz /usr/local/
cd /usr/local/
sudo tar -zxf kafka_2.11-1.0.0.tgz 
sudo chown -R alex kafka_2.11-1.0.0
sudo chgrp -R admin kafka_2.11-1.0.0
```
- 启动服务
启动前必须先启动zookeeper，启动后不要关闭终端窗口
```
cd /usr/local/kafka_2.11-1.0.0/bin/
sh kafka-server-start.sh config/server.properties
```
如果zookeeper不在本地，需要修改servier.properties中的zookeeper配置
> zookeeper.connect=localhost:2181  
改为实际的地址即可

- 创建主题
新开一个终端窗口
```
cd /usr/local/kafka_2.11-1.0.0/bin/
sh kafka-topics.sh --create --topic kafkatopic --replication-factor 1 --partitions 1 --zookeeper localhost:2181
```

- 创建生产者，并发送消息
新开一个终端窗口
```
cd /usr/local/kafka_2.11-1.0.0/bin/
sh kafka-console-producer.sh --broker-list localhost:9092 --sync --topic kafkatopic 
```
执行后输入3个消息
11  
22  
33  

- 创建消费者接收消息
```
cd /usr/local/kafka_2.11-1.0.0/bin/
sh kafka-console-consumer.sh --zookeeper localhost:2181 --topic kafkatopic --from-beginning
```
此时能够正常收到11、22、33的消息说明服务全部正常

- 查看所有主题列表
```
cd /usr/local/kafka_2.11-1.0.0/bin/
sh kafka-topics.sh --list --zookeeper localhost:2181
```
此时可以看到刚才创建的主题kafkatopic

参考文章：
http://nekomiao.me/2016/11/20/kafka/  
https://segmentfault.com/a/1190000006035868

