---
title: 保留提交历史的git库迁移方法
p: /201711/保留提交历史的git库迁移方法.md
date: 2017-11-14 14:58:00
tags:
- git
---

原来个人项目的代码都托管在coding平台上， 但是今年coding对免费用户进行了限制，用户最多只能创建10个仓库。这不是要了我的命，我已经有接近20个仓库了。  
后来发现开源中国的码云平台对免费仓库没有限制，果断的进行迁移。  
此处记录如何保留提交历史，将git仓库从coding迁移到码云平台。

<!--more-->

# 码云自动同步
码云平台，有一个自动同步的功能，试用后发现无法同步，放弃此方案；

# 通过git命令
先从coding上clone最新的代码库并切换目录
```
git clone https://git.coding.net/{用户名}/shopinspection.git
cd shopinspection
```

在码云新建仓库，假设创建后的仓库地址为：https://gitee.com/{用户名}/shopinspection.git

在本地添加新的远程仓库
```
git remote add origin_mayun https://gitee.com/{用户名}/shopinspection.git
```

因为我的项目存master和develop分支，因此需要逐个提交到码云平台  
提交master分支
```
git checkout master
git push origin_mayun master
```

提交deelop分支
```
git checkout develop
git push origin_mayun develop
```

此时代码已经全部同步到码云平台了；

此时还需要将本地目录全部删除，然后重新从码云clone代码。当然也可以通过
```
git remote set-url origin https://gitee.com/{用户名}/shopinspection.git
```
等命令进行处理。  
但是个人认为直接删除重新clone更简单方便些。


