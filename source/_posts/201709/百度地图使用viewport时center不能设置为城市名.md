---
title: 百度地图使用viewport时center不能设置为城市名
p: /201709
date: 2017-09-15 09:23:37
tags:
- 百度地图
- angular
---

百度地图添加一批覆盖物后，可以通过设置viewport使地图自动调整显示级别和中心点，从而达到使指定的一批点都显示在屏幕中并达到最佳级别。  
今天在使用viewport时发现地图中心点不能设置为城市名称，不知道是地图bug还是设计就是如此。再次记录一下。

<!--more-->
# 地图中心点设置为坐标时使用viewport
地图中心点设置为坐标时，viewport能够正常工作，代码如下：
```typescript
    this.map = new this.BMap.Map("myMap", { enableMapClick: false });
    this.map.centerAndZoom(new this.BMap.Point(121.029953, 32.036895), 17);

     // 新覆盖物数组
    this.lamps.forEach(lamp => {
      let marker = this.createMarker(lamp);
      this.map.addOverlay(marker);
    });

    // 刷新界面后，自动跳转缩放比例，保证所有覆盖物都在视窗中
    let bounds: Array<any> = [];
    this.lamps.forEach(lamp => {
      bounds.push(this.getPoint(lamp));
    });
    this.map.setViewport(bounds);

    // 设置覆盖物聚合的最小缩放比例
    if (markers && markers.length > 0)
      var markerClusterer = new this.BMapLib.MarkerClusterer(this.map, { markers: markers, maxZoom: 14 });
```
运行程序后，达到了我们预期效果，地图自动调整了中心点和缩放级别。  
this.lamps是业务数据，每个lamp中包含坐标数据，此处没有列出取值逻辑  
this.createMarker是创建覆盖物函数，此处没有列出具体逻辑  
this.getPoint是根据业务数据点创建地图的Point对象，此处没有列出具体逻辑  

既然设置了viewport后会自动调整中心点，那centerAndZoom方法就可以不设置缩放级别和中心点，可以写成
```typescript
    this.map.centerAndZoom(new this.BMap.Point(121.029953, 32.036895));
```
或
```typescript
    this.map.centerAndZoom());
```
**注意：如果没有业务数据时，viewport中没有bound点，需要设置中心点和缩放级别，否则地图会显示空白**

# 地图中心点设置为城市名称时使用viewport
如果我们没有业务数据时，希望设置中心点为指定的城市
```typescript
    this.map = new this.BMap.Map("myMap", { enableMapClick: false });
    this.map.centerAndZoom('南通市',17);

    // 新覆盖物数组
    this.lamps.forEach(lamp => {
      let marker = this.createMarker(lamp);
      this.map.addOverlay(marker);
    });

    // 刷新界面后，自动跳转缩放比例，保证所有覆盖物都在视窗中
    let bounds: Array<any> = [];
    this.lamps.forEach(lamp => {
      bounds.push(this.getPoint(lamp));
    });
    this.map.setViewport(bounds);

    // 设置覆盖物聚合的最小缩放比例
    if (markers && markers.length > 0)
      var markerClusterer = new this.BMapLib.MarkerClusterer(this.map, { markers: markers, maxZoom: 14 });
```
此时运行程序发现地图闪了一下，最终地图显示的中心点是南通市政府，而地图级别为17。并没有达到我们想要的viewport的效果。  
*注意观察会发现，viewport生效了（地图自动调整到viewport指定的点并更改了级别），但是立即又刷新了地图*

如果我们将centerAndZoom方法改为
```typescript
    this.map.centerAndZoom('南通市');
```
运行程序，viewport生效了了一半，中心点还是南通市政府，但是缩放级别自动调整了，是所有点都在页面上。

# 补充
上面列子中用到了点聚合
```typescript
if (markers && markers.length > 0)
    var markerClusterer = new this.BMapLib.MarkerClusterer(this.map, { markers: markers, maxZoom: 14 });
```
此处一定要加markers判断，否则当markers为空时，会报错
> ERROR TypeError: Cannot read property 'lng' of null

# 结论
百度地图使用viewport功能时  
- 如果viewport中存在点，地图中心点必须设置成坐标或者不设置
- 如果viewport中没有点时，地图中心点必须可以设置成坐标或城市名称