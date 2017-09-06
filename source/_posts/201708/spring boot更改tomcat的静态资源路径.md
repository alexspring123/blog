---
title: spring boot更改tomcat的静态资源路径
date: 2017-08-17 10:12:00
tags:
- Spring
---

需求：开发中需要在新增商品界面上传一些图片，然后在查看界面显示；
我做的是一个小项目，没有独立的文件服务器，因此就想着放在tomcat服务器上，然后通过url进行访问；最简单的就是存放在项目部署目录的webapp下的static目录，但是tomcat的部署目录在版本维护是经常更新，因此放在tomcat目录里面是不合适的。因此想着放在tomcat外面的固定目录，然后通过tomcat的docRoot进行虚拟目录映射，说干就干。。。

<!--more-->

# 独立tomcat的解决办法
独立的tomcat非常简单，只需要在$tomcat/conf/server.xml中</Host>之前添加一行
``` xml
<Context path="/upload" docBase="E:\photo\upload" reloadable="true"/>
```
path：为浏览器访问的url路径
docBase：url映射的实际位置

比如在E:\photo\upload目录下有个a.png图片，那么在浏览器中访问http://localhost:8080/webapp/upload/a.png 就可以访问到图片了（其中webapp是我的项目名称）


# spring boot内嵌tomcat的解决办法
通过代码设置DocRoot
``` java
@Component
public class CustomizationBean implements EmbeddedServletContainerCustomizer {

  @Override
  public void customize(ConfigurableEmbeddedServletContainer container) {
    container.setDocumentRoot(new File("E:\photo\upload"));
  }
}
```
比如在E:\photo\upload目录下有个a.png图片，那么在浏览器中访问http://localhost:8080/webapp/a.png 就可以访问到图片了（其中webapp是我的项目名称）
