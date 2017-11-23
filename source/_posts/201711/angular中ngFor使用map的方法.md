---
title: angular中ngFor使用map的方法
p: /201711/angular中ngFor使用map的方法.md
date: 2017-11-23 14:58:00
tags:
- angular
---

angular中ngFor无法直接使用map和map.keys，找到的解决办法是：
```
  roadGroupMap: Map<string, Array<string>> = new Map();

  get roadNames(): Array<string> {
    return Array.from(this.roadGroupMap.keys());
  }
```
然后在模板中使用
```
  *ngFor="let road of roadNames"
```

参考文章：
https://github.com/angular/angular/issues/2246


https://webcake.co/looping-over-maps-and-sets-in-angular-2s-ngfor/



