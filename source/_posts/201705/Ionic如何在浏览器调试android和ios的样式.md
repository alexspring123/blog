---
title: Ionic如何在浏览器调试android和ios的样式
date: 2017-05-24 16:42:34
tags: 
- ionic
---

在开发Ionic时（保留ionic1和ionic2），可以通过如下方式在浏览器中快速切换android和ios的显示样式
在浏览器的URL(http://localhost:8100)后面增加ionicplatform参数即可
### ios样式
```
http://localhost:8100/?ionicplatform=ios
```

<!--more-->

### android样式
```
http://localhost:8100/?ionicplatform=android
```

### 通过CLI更改样式
ioinc serve命令中有一个“--platform”参数（简写为 -t），可以达到上面的效果；
比如通过下面命令启动后，浏览器的url是http://localhost:8100/?ionicplatform=ios
```
ionic serve -t ios
```