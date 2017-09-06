---
title: 矿工(二)-java程序注册成windows系统服务
date: 2016-12-12 17:44:37
tags:
- java
- 矿工
- windows系统服务
---
这是“矿工”工具系列的第二篇，我们将原来的客户端命名为“矿场”，“矿场”是“矿工”的容器，一个“矿场”可以包含0到N个“矿工”；
“矿场”安装在客户端机器上，负责定时启动“矿工”；本文章主要记录“矿场”定时启动矿工的技术选型，并核心介绍了java service wrapper的使用方法；

<!--more-->

# 备选方案
+ windows计划任务，定时通过bat脚本调用java程序；优点：实现简单，java程序不需要处理调度；缺点：实施有一定要求，无法远程更新调度频率；
+ windows注册表，开机启动java程序；优点：完全由java控制调度频率，可以完成更新频率；缺点：实施有一定要求；
+ windows服务，开机启动java程序；优点：完全由java控制调度频率，可以完成更新频率；缺点：实施简单，直接解压文件执行即可；
最终选择windows服务的方案；

# java service wrapper注册windows服务
这里选择了{% link java service wrapper https://wrapper.tanukisoftware.com/doc/english/download.jsp %}工具来实现windows服务的注册；

## 服务内容代码
### 服务代码入口
{% codeblock main.java lang:java %}
package com.alex.test;

public class Main {
  private static Service service = null;

  public static void main(String[] args) {
    System.out.println("启动服务...");

    service = new Service();
    Thread thread = new Thread(service);
    try {
      thread.setDaemon(false);  // 将服务线程设定为用户线程，以避免StartService方法结束后线程退出
      if (thread.isDaemon()) {
        System.out.println("成功设定线程为用户线程！");
      }
      thread.start();
    } catch (SecurityException e) {
      System.out.println("线程类型设定失败！");
    }

    System.out.println("服务启动成功");
  }

  public static void StopService(String[] args) {
    System.out.println("停止服务");
    service.setRunning(false);
  }
}
{% endcodeblock %}

### 服务执行类
{% codeblock service.java lang:java %}
package com.alex.test;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public class Service implements Runnable {
  private boolean running = true;

  public synchronized boolean isRunning() {
    return running;
  }

  public synchronized void setRunning(boolean running) {
    this.running = running;
  }

  @Override
  public void run() {
    System.out.println("服务线程开始运行");

    while (isRunning()) {
      DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
      System.out.println("当前时间" + df.format(new Date()));
      try {
        // 执行数据同步过程 todo
        Thread.sleep(1000 * 5);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    }
    System.out.println("服务线程结束运行");
  }
}
{% endcodeblock %}

### 下载java service wrapper
到 {% link java service wrapper官网 https://wrapper.tanukisoftware.com/doc/english/download.jsp %}下载最新的稳定版本；
分为个人版本、标注版本和社区版本，其中社区版本是免费；
这里我下载了社区版本，注意区分是32位还是64位；
下载后解压文件，假设解压后的目录为 D:/wrapper-windows-x86-32-3.5.30；


### 配置
1. 创建目录D:/miner，作为我们程序的主目录，并在miner目录下创建 bin、lib、log和conf目录；
2. 将服务入库和实现类打包成jar（miner.jar），并复制到D:/miner/bin目录下；
3. 从wrapper目录复制如下文件到miner
{% codeblock %}
copy D:/wrapper-windows-x86-32-3.5.30/bin/wrapper.exe D:/miner

copy D:/wrapper-windows-x86-32-3.5.30/lib/wrapper.jar D:/miner/lib
copy D:/wrapper-windows-x86-32-3.5.30/lib/wrapper.dll D:/miner/lib

copy D:/wrapper-windows-x86-32-3.5.30/src/bin/app.bat.in D:/miner/app.bat
copy D:/wrapper-windows-x86-32-3.5.30/src/bin/InstallApp-NT.bat.in D:/miner/InstallApp-NT.bat
copy D:/wrapper-windows-x86-32-3.5.30/src/bin/UninstallApp-NT.bat.in D:/miner/UninstallApp-NT.bat

copy D:/wrapper-windows-x86-32-3.5.30/conf/wrapper.conf D:/miner/conf
{% endcodeblock %}
4. 修改配置文件位置，使用记事本打开D:/miner/app.bat、D:/miner/InstallApp-NT.bat和D:/miner/UninstallApp-NT.bat，分别修改配置文件路径:
将
{% codeblock %}
set _WRAPPER_CONF_DEFAULT="../conf/%_WRAPPER_BASE%.conf"
{% endcodeblock %}
修改为
{% codeblock %}
set _WRAPPER_CONF_DEFAULT="conf/wrapper.conf"
{% endcodeblock %}
5. 修改wrapper.conf，用记事本打开D:/miner/conf/wrapper.conf
找到如下内容
{% codeblock %}
# needed starting from 1，依赖的jar，如果有多个可以写成多行，注意需要修改后面的顺序（从1开始的正整数）
wrapper.java.classpath.1=../lib/wrapper.jar

# Java Library Path (location of Wrapper.DLL or libwrapper.so)，wrapper.dll所在的目录
wrapper.java.libray.path.1=../lib
...
# Log file to use for  wrapper output logging
wrapper.logfile=../logs/wrapper.logs
...
# Title to use when running as a console
wrapper.console.title=@app.long.name@
...
# Name of the service ， 安装后的服务名
wrapper.name=@app.name@

# Display name of the service，安装后显示的服务名
wrapper.displayname=@app.long.name@

# Description of the service，安装后的服务描述
wrapper.description=@app.description@
...
# Application parameters. Add parameters as needed starting from 1，服务程序的主类
wrapper.app.parameter.1=<YourMainClass>

{% endcodeblock %}
修改为
{% codeblock %}
wrapper.java.classpath.1=lib/wrapper.jar
wrapper.java.libray.path.1=lib
wrapper.logfile=log/wrapper.logs
wrapper.console.title=miner server
wrapper.name=miner server
wrapper.displayname=miner server
wrapper.description=miner server
wrapper.app.parameter.1=com.alex.test.Main
{% endcodeblock %}

6. 运行程序
双击D:/miner/App.bat，如果正常，表示配置成功；App.bat只会执行一次我们的com.alex.test.Main类；

7. 注册windows服务
双击D:/miner/InstallApp-NT.bat，将程序注册成windows服务，默认是自动启动，重启电脑将看到我们的Main被执行了；

8. 删除windows服务
双击D:/miner/UninstallApp-NT.bat，将删除先前安装的windows服务；

9. 查看程序运行日志
进入D:/miner/log目录，里面就是我们程序运行的日志；

上面只是简单介绍了java service wrapper的使用方法，详细的使用和配置信息，请参见{% link java service wrapper https://wrapper.tanukisoftware.com/doc/english/download.jsp %}的官网文档；