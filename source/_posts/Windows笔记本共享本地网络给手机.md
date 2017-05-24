---
title: Windows通过承载网络共享WIFI
tags: windows
---

# 无线承载网络
无线承载网络（Wireless Hosted Network）是Windows7和安装有WLAN服务的Windows Server 2008 R2中一项新增的WLAN特性。
通过此特性，Windows计算机能通过一块物理无线网卡以客户端身份连接到（由物理设备提供的）硬AP，同时又能作为软AP，允许其它设备与自己连接。

<!--more-->

为了不让有些人叫板说：“这是个伪技巧，XP，vista里也可以实现无线共享啊”，所以我特此申明，XP，vista里利用传统的临时无线网（即Ad Hoc模式）来实现的。
临时无线网（即Ad Hoc模式）是一种点对点网络搜索，类似于有线网中的“双机互联”，虽然也能实现互联网共享，但主要用于两个设备临时互联，并且有的设备（如采用Android系统的设备）并不支持连接到临时无线网。
还有一个很严重的问题，由于一块无线网卡只能连接到一个无线网络，因此如果通过无线网卡连接到 Internet，就不能再使用这个无线网卡建立临时网络，共享 Internet 了。
而无线承载网络的原理就不一样了。它是通过把物理网卡虚拟一块虚拟网卡，从而模拟软AP的功能。所以当你物理网卡连在真正的无线路由时，可以通过模拟的软AP（软路由）供其他电脑上网

# 开启无线承载网络
## 检查系统驱动是否支持无线承载网络
打开windows的cmd窗口，执行下面命令
```
netsh wlan show drivers
```
找到“支持的承载网络”项，如果值时“是”则表示支持承载网络，“否”时表示不支持。

## 启用并设置虚拟WIFI网卡
打开windows的cmd窗口（注意必须使用管理员权限运行cmd），执行如下命令
```
netsh wlan set hostednetwork mode=allow ssid=alex-notebook key=alex888888 keyusage=persistent
```
其中：
- Mode：是否启用虚拟Wifi网卡，改为disallow则为禁用，虚拟网卡即会消失
- ssid：表示虚拟网卡的名称
- Key：指定无线网络的密码。该密码用于对无线网进行安全的WPA2加密，能够很好的防止被蹭网
- keyusage：设置为persistent，表示持久化，重启机器后保留虚拟WIFI；设置为temporary，则重启机器后需要重新设置WIFI网络；默认值为temporary
以上参数可单独使用，例如只使用 mode=disallow 可以直接禁用虚拟Wifi网卡

# 共享本地网络
为了与其他计算机或设备共享已连接的互联网，我们需要启用“Internet连接共享”功能。
打开“网络和网络共享中心”窗口——“更改适配器设置”，右键单击已连接到Internet的网络连接，选择“属性”，切换到“共享”选项卡，选中其中的复选框，并选择允许其共享Internet的网络连接在这里即我们的虚拟Wifi网卡

# 打开无线网络
在cmd窗口中执行下面命令打开无线网络
```
netsh wlan start hostednetwork
```

# 关闭无线网络
在cmd窗口中执行下面命令打开无线网络
```
netsh wlan stop hostednetwork
```

# 删除无线网络
在cmd窗口中执行下面命令打开无线网络
```
 netsh wlan set hostednetwork mode=disallow
```

# 使用中碰到的问题及解决方法
## 承载网络的虚适配器不见了
今天中午睡完午觉起来发现手机连不上承载网络了，运行了netsh wlan start hostednetwork命令报下面错误
```
无法启动承载网络。
组或资源的状态不是执行请求操作的正确状态。
```
进一步排查发现我的承载网络的虚拟网卡适配器在控制面板->网络和 Internet->网络连接中不见了；
此时重新执行
```
netsh wlan set hostednetwork mode=allow ssid=alex-notebook key=alex888888 keyusage=persistent
```
发现还是没有看到虚拟网卡适配器

然后baidu后先禁用了无线网卡，然后再启用，承载网络适配器神奇的出现了,运行netsh wlan start hostednetwork后恢复正常；
又可以上网啦！！！


参考
http://www.hejiwei.com/?p=337