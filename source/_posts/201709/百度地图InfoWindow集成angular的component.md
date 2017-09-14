---
title: 百度地图InfoWindow集成angular的component
p: /201709/百度地图InfoWindow集成angular的component.md
date: 2017-09-14 13:11:57
tags:
---

百度地图提供了InfoWindow的功能，可以很方便的在地图上显示信息框。但是当信息框的内容很复杂时，使用原生方法创建信息框就比较麻烦。此文章介绍用angular4的component来开发InfoWindow功能。  
你可能会问，为什么不用angular的dialog组件呢？  
其实是可以的，只是体验会差一下。地图的InfoWindow会跟随覆盖物的位置，当对话框超出窗口时，地图会自动移动使InfoWindow显示在当前页面范围内。普通的dialog组件实现跟随效果会比较复杂。

<!--more-->

# 原生的InfoWindow
百度地图官方[Demo](http://lbsyun.baidu.com/jsdemo.htm?a#d0_1)中有关于原始InfoWindow的用法，如下：
```js
var opts = {
	  width : 200,     // 信息窗口宽度
	  height: 100,     // 信息窗口高度
	  title : "海底捞王府井店" , // 信息窗口标题
	  enableMessage:true,//设置允许信息窗发送短息
	  message:"亲耐滴，晚上一起吃个饭吧？戳下面的链接看下地址喔~"
	}
	var infoWindow = new BMap.InfoWindow("地址：北京市东城区王府井大街88号乐天银泰百货八层", opts);  // 创建信息窗口对象 
	marker.addEventListener("click", function(){          
		map.openInfoWindow(infoWindow,point); //开启信息窗口
	});
```
其中InfoWindow的第一个构造函数传入了一个string字符串，第二个是窗口选项，设置了窗口大小以及标题等。  
其实[InfoWindow](http://lbsyun.baidu.com/cms/jsapi/class/jsapi_reference.html#a3b7)的构造函数第一个参数还可以是一个Element  
> InfoWindow(content: String | HTMLElement, opts: InfoWindowOptions)

但是如果要在js中动态构建复杂的Element是相当麻烦的。我们希望将InfoWindow内容的构造独立出来。这就是下面要介绍的使用angular的component来实现InfoWindow的方案。

# 使用angular的component实现InfoWindow
此方案很简单，因为InfoWindow可以接受HTMLElement作为内容，那么我们就想办法动态构造一个component，然后获取此componet的Element，并传递给InfoWindow。

## 定义组件
我们创建一个普通的angular组件，用来作为InfoWindow的内容组件。
```typescript
@Component({
  selector: 'app-map-dialog',
  templateUrl: './map.dialog.html',
  styleUrls: ['./map.dialog.css']
})
export class MapDialogComponent implements OnInit {
  lamp: Lamp;  // 业务数据对象

  constructor() {  }

  ngOnInit(): void {}

  // 设置业务对象，供父组件使用
  setLamp(lamp: Lamp): void {
    this.lamp = lamp;
  }
}
```
组件页面代码，具体逻辑没有显示
```html
<div>
  {{lamp.code}}
</div>
```
上面只是演示，实际中div内容会比较复杂。

## 动态创建组件
在上一步我们定义好了组件，现在需要在父组件中动态创建MapDialogComponent组件。  
angular提供了[动态加载组件的方案](https://angular.cn/guide/dynamic-component-loader#动态组件加载器)。使用ComponentFactoryResolver来动态创建一个componet，使用ViewContainerRef来动态创建一个视图。  

在使用之前我们需要在父组件MapComponent的构造函数中注入ComponentFactoryResolver和ViewContainerRef
```typescript
  constructor(private componentFactoryResolver: ComponentFactoryResolver,
    private viewContainer: ViewContainerRef) {
  }
```
父组件中添加动态创建MapDialogComponent的方法
```typescript
  private createDialog(dialogComponent: { new(): MapDialogComponent }): ComponentRef<MapDialogComponent> {
    let dialogComponentFactory =
      this.componentFactoryResolver.resolveComponentFactory(dialogComponent);
    let dialogComponentRef = this.viewContainer.createComponent(dialogComponentFactory);
    return dialogComponentRef;
  }
```
在创建地图覆盖物时添加click事件。其中的lamp是业务数据
```typescript
  private createMarker(lamp: Lamp): any {
    let point = this.getPoint(lamp);
    let icon = this.getIcon(this.map.getZoom(), lamp);
    let marker = new this.BMap.Marker(point, { icon: icon });
    marker.addEventListener('click', e => this.openDialog(lamp, e.target));
    return marker;
  }
```
实现覆盖物的click事件
```
private openDialog(lamp: Lamp, marker): void {
    let point = this.getPoint(lamp);
    let options = { width: 500, height: 320 };
    let dialog = this.createDialog(MapDialogComponent);
    dialog.instance.setLamp(lamp);
    var infoWindow = new this.BMap.InfoWindow(dialog.location.nativeElement, options);
    this.map.openInfoWindow(infoWindow, point);
  }
```
createDialog函数创建了一个新的MapDialogComponent组件dialog。  
dialog.instance.setLamp方法传入业务数据lamp。  
dialog.location.nativeElement获取dialog中组件的Element。  

到此我们就完成了InfoWindow的内容替换工作。

## 不完美的地方
1. 父组件传递业务数据给MapDialogComponent组件时，是通过dialog.instance.setLamp(lamp)实现的，最好能够通过@Input参数传入
2. 这样每次创建覆盖物是都新建一个MapDialogComponent组件，不知道有没有内存泄漏的问题

如果哪位大牛知道这2个问题，请联系我（QQ：112924481）。