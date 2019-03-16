---
title: Ubuntu下添加开机启动脚本
p: /201903/Ubuntu下添加开机启动脚本.md
date: 2019-03-16 10:03:17
tags:
- ubuntu
---

Ubuntu开机之后会执行/etc/rc.local文件中的脚本，本文中介绍如何在rc.local中配置开机启动脚本。
<!--more-->

# 编写执行脚本
首先我们需要编写一个需要执行的shell脚本，例如（/home/alex/test.sh），内容如下
```shell
#!/bin/sh
echo '开始执行。。'

# 需要执行接功能放在此处。。

echo '执行结束'
```

然后修改文件属性为可执行（这一步千万不能忘，很多朋友会忘记修改权限）
```shell
sudo chmod +x /home/alex/test.sh
```

# 添加到rc.local
执行``sudo vim /etc/rc.local``，将自己的脚本执行添加进去，需要添加在exit 0前面
```
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

sh /home/alex/test.sh

exit 0
```

# reboot后未执行的问题
这个问题主要是Ubuntu默认的dash的问题。
```shell
#ls -al /bin/sh 
lrwxrwxrwx 1 root root 4 2009-12-11 06:04 /bin/sh -> dash
#ls -al /bin/dash
-rwxr-xr-x 1 root root 92132 2009-09-21 07:49 /bin/dash
```
可以看出Ubuntu默认将/bin/sh链接到/bin/dash，而/etc/rc.local脚本中用的正是/bin/sh，导致出错，可以将/etc/rc.local的命令改成更加兼容的模式，或者直接将/bin/sh链接到/bin/bash。
```shell
/usr/bin/mystar >& /dev/null &         # dash报错，bash和csh不会报错
/usr/bin/mystar > /dev/null 2>&1     # dash兼容
```

其实，从 Ubuntu 6.10开始，Ubuntu就将先前默认的bash shell 更换成了dash shell，其表现为 /bin/sh 链接倒了/bin/dash而不是传统的/bin/bash。Ubuntu dgy是第一个将dash作为默认shell来发行的版本，这似乎是受了debian的影响。wiki 里面有官方的解释，https://wiki.ubuntu.com/DashAsBinSh，主要原因是dash更小，运行更快，还与POSIX兼容。但目前存在的问题是，由于shell的更换，致使很多脚本出错，毕竟现在的很多脚本不是100%POSIX兼容。

将默认的shell改成bash的方法: 
- 方法1：在终端执行``sudo dpkg-reconfigure dash``，然后选择 no.
- 方法2：重新进行软链接:
```shell
sudo rm /bin/sh
sudo ln -s /bin/bash /bin/sh
```

参考文章：
- https://blog.csdn.net/myweishanli/article/details/23794731