---
title: 使用spring生产消费Kafka消息
p: /201711/使用spring生产消费Kafka消息.md
date: 2017-11-10 16:04:00
tags:
- kafka
---
此处时间spring-boot集成kafka的案例。

<!--more-->
新建工程，添加spring-boot和spring-kafka依赖  
注意其中的spring-kafka版本需要和spring-boot对应。
```
compile("org.springframework.boot:spring-boot-starter-web:1.5.8.RELEASE")
compile("org.springframework.kafka:spring-kafka:1.1.7.RELEASE")
```





