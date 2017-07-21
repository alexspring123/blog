---
title: spring容器事件
date: 2017-07-21 14:07:18
tags:
- Spring
---

# 前言
在使用spring的过程中，一般很少直接使用BeanFactory示例作为容器，更多的是使用ApplicationContext示例作为容器。
ApplicationContext容器提供观察者模式的时间机制
- ApplicationEvent：事件
- ApplicationListener：时间监听
- ApplicationContext：容器
应用程序只需要创建一个event并发布到容器中，Listener就会监听到此事件并进行处理。
此篇文章我们就来详细讨论一下Spring事件的各种用法。

<!--more-->

# 自定义事件
借助spring提供的事件模型，我们可以很方便的定义、发布和监听自定义事件。

## 事件对象
自定义的事件对象需要实现ApplicationEvent接口（spring4.2版本后可以不实现，将在下面介绍）
比如我们定义一个MyEvent事件对象，其中text属性模拟事件属性
``` java
/**
 * 自定义事件
 */
public class MyEvent extends ApplicationEvent {

  private String text; //事件内容

  public MyEvent(Object source) {
    super(source);
  }

  public MyEvent(Object source, String text) {
    super(source);
    this.text = text;
  }

  public String getText() {
    return text;
  }

  public void setText(String text) {
    this.text = text;
  }
}
```

## 发布事件
我们只要通过ApplicationContext的publishEvent方法就可以发布一个自定义消息。
``` java
/**
 * 容器
 */
@Configuration
@ComponentScan
public class Application {

  public static void main(String[] args) {
    ApplicationContext ctx = new AnnotationConfigApplicationContext(Application.class);

    //新建事件
    MyEvent myEvent = new MyEvent("myEvent", "我是自定义事件的内容");

    //向容器发布时间
    ctx.publishEvent(myEvent);
  }
}
```
## 事件监听
我们可以通过实现ApplicationListener接口来创建监听
``` java
/**
 * 自定义事件监听
 */
@Component
public class MyEventListener implements ApplicationListener<MyEvent> {

  @Override
  public void onApplicationEvent(MyEvent event) {
    System.out.println("监听到自定义事件：" + event.getText());
  }
}
```
当然也可以使用更古老的方式监听，这种写法逻辑不清晰，个人不推荐
``` java
/**
 * 事件监听
 */
@Component
public class MyEventListener2 implements ApplicationListener {
  @Override
  public void onApplicationEvent(ApplicationEvent event) {
    if (event instanceof MyEvent) {
      MyEvent myEvent = (MyEvent) event;
      System.out.println("监听到自定义事件：" + myEvent.getText());
    }
  }
}
```
## 执行结果
运行Application的main函数后控制台输出
```
监听到自定义事件：我是自定义事件的内容
```

# spring内置的事件
Spring内置的ApplicationEvent有

| 事件 | 说明 |
|:---|:----------|
|ContextClosedEvent|当ApplicationContext被关闭时触发该事件。容器被关闭时，其管理的所有单例Bean都被销毁。|
|ContextRefreshedEvent|当ApplicationContext初始化或者刷新时触发该事件|
|ContextStartedEvent|容器启动时发布|
|ContextStoppedEvent|当容器调用ConfigurableApplicationContext的Stop()方法停止容器时触发该事件|
|PayloadApplicationEvent|在spring4.2中新引入的事件，大部分由spring内部使用；spring4.2之后向容器中发布的事件，不再强制要求继承自ApplicationEvent，当发布一个非ApplicationEvent对象时，spring会自动包装成PayloadApplicationEvent。|

## 事件监听
### ContextRefreshedEvent事件监听器
``` java
/**
 * 容器初始化及Bean刷新事件监听
 */
@Component
public class ContextRefreshedEventListener implements ApplicationListener<ContextRefreshedEvent> {
  @Override
  public void onApplicationEvent(ContextRefreshedEvent event) {
    System.out.println("监听到ContextRefreshedEvent事件");
  }
}
```
### ContextStartedEvent事件监听器
``` java
/**
 * 容器启动事件监听
 */
@Component
public class ContextStartedEventListener implements ApplicationListener<ContextStartedEvent> {
  @Override
  public void onApplicationEvent(ContextStartedEvent event) {
    System.out.println("监听到ContextStartedEvent事件");
  }
}
```
### ContextClosedEvent事件监听器
``` java
/**
 * 容器关闭事件监听
 */
@Component
public class ContextClosedEventListener implements ApplicationListener<ContextClosedEvent> {
  @Override
  public void onApplicationEvent(ContextClosedEvent event) {
    System.out.println("监听到ContextClosedEvent事件");
  }
}
```
### ContextStoppedEvent事件监听器
``` java
/**
 * 容器停止事件监听
 */
@Component
public class ContextStoppedEventListener implements ApplicationListener<ContextStoppedEvent> {
  @Override
  public void onApplicationEvent(ContextStoppedEvent event) {
    System.out.println("监听到ContextStoppedEvent事件");
  }
}
```

## 发布事件
编写容器，其中ApplicationContext更强制设置为AnnotationConfigApplicationContext类型。
``` java
/**
 * 容器
 */
@Configuration
@ComponentScan
public class Application {

  public static void main(String[] args) {
    AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(Application.class);

    ctx.start();

    MyEvent myEvent = new MyEvent("myEvent", "我是自定义事件的内容");  //新建事件
    ctx.publishEvent(myEvent); //向容器发布时间

    ctx.stop();
    ctx.close();
  }
}
```

## 执行结果
```
监听到ContextRefreshedEvent事件
监听到ContextStartedEvent事件
监听到自定义事件：我是自定义事件的内容
监听到ContextStoppedEvent事件
监听到ContextClosedEvent事件
```

# PayloadApplicationEvent用法
Spring4.2版本优化了自定义事件类的写法，不再强制要求实现ApplicationEvent接口，定义一个普通的java类，然后通过容器发布。容器会自动将此对象包装成PayloadApplicationEvent事件，然后通过监听此事件获取原始对象。

## 事件对象
编写一个普通的java对象作为事件对象
``` java
/**
 * 未实现ApplicationEvent的事件对象
 */
public class NormalEvent {
  private String text;

  public NormalEvent(String text) {
    this.text = text;
  }

  public String getText() {
    return text;
  }

  public void setText(String text) {
    this.text = text;
  }
}
```

## 事件监听器
注意，此处监听了PayloadApplicationEvent事件，然后从此事件中获取被包装的原始对象
``` java
/**
 * PayloadApplicationEvent事件监听
 */
@Component
public class NormalEventListener implements ApplicationListener<PayloadApplicationEvent> {
  @Override
  public void onApplicationEvent(PayloadApplicationEvent event) {
    if (event.getPayload() instanceof NormalEvent) {
      NormalEvent normalEvent = (NormalEvent) event.getPayload();
      System.out.println("监听到自定义事件：" + normalEvent.getText());
    }
  }
}
```

# @EventListener用法
Spring4.2还增加了@EventListener注解。
通过此注解监听器不再需要实现ApplicationListener接口，给普通的方法增加@EventListener注解，spring会自动注册一个ApplicationListener来匹配方法签名。

## 发布事件
可以看到，我们发布的是一个未实现ApplicationEvent的普通java对象
``` java
/**
 * 容器
 */
@Configuration
@ComponentScan
public class Application {

  public static void main(String[] args) {
    ApplicationContext ctx = new AnnotationConfigApplicationContext(Application.class);
   
    ctx.publishEvent(new NormalEvent("我是一个事件，但是并未实现ApplicationEvent接口")); 
  }
}
```

## 事件监听
``` java
/**
 * 使用EventListener注解的监听器
 */
@Component
public class NormalEventListener2 {

  @EventListener
  public void handelNormalEvent(NormalEvent normalEvent) {
    System.out.println("监听到自定义事件：" + normalEvent.getText());
  }
}
```
## 执行结果
```
监听到自定义事件：我是一个事件，但是并未实现ApplicationEvent接口
```
从上面可以看出来，从Spring4.2后，事件不再需要实现ApplicationEvent接口，监听器也不再需要实现ApplicationListener接口，通过简单自动包装事件对象和@EventListener注解，大大简化了事件的实现。


## 带条件的监听器
@EventListener注解，可以通过classes属性指定监听的消息类型（可以多个），还可以通过condition属性增加监听条件（SpELg表达式），例如下面
``` java
/**
 * 使用EventListener注解的带条件的监听器
 */
@Component
public class NormalEventListener3 {

  @EventListener(classes = {NormalEvent.class}, condition = "#normalEvent.text==\"test\"")
  public void handelNormalEvent(NormalEvent normalEvent) {
    System.out.println("监听到自定义事件：" + normalEvent.getText());
  }
}
```
``` java
/**
 * 容器
 */
@Configuration
@ComponentScan
public class Application {

  public static void main(String[] args) {
    ApplicationContext ctx = new AnnotationConfigApplicationContext(Application.class);

    ctx.publishEvent(new NormalEvent("我是一个事件，但是并未实现ApplicationEvent接口")); 
    ctx.publishEvent(new NormalEvent("test")); 
  }
}
```
执行结果
```
监听到自定义事件：test
```
从结果可以看出，只有第二个发布的事件被监听到了，通过这个功能，我们可以方便的监听符合条件的事件。

## @EventListener注解方法返回非null
对于任何一个使用@EventListener注解的方法，允许定一个非void的返回类型。如果返回一个非null值，Spring将此结果作为一个新事件发布到容器。

### 容器
``` java
/**
 * 容器
 */
@Configuration
@ComponentScan
public class Application {

  public static void main(String[] args) {
    AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(Application.class);

    ctx.publishEvent(new NormalEvent("我是一个事件，但是并未实现ApplicationEvent接口"));
  }
}

```

### 监听器
``` java
/**
 * 使用EventListener注解带返回值
 */
@Component
public class NormalEventListener4 {

  @EventListener
  public NormalEvent handelNormalEvent(NormalEvent normalEvent) {
    System.out.println("NormalEventListener4监听到自定义事件：" + normalEvent.getText());

    if (Objects.equals(normalEvent.getText(), "我是NormalEventListener4的自动发布的事件"))
      return null;
    else
      return new NormalEvent("我是NormalEventListener4的自动发布的事件");
  }
}
```

### 执行结果
```
NormalEventListener4监听到自定义事件：我是一个事件，但是并未实现ApplicationEvent接口
NormalEventListener4监听到自定义事件：我是NormalEventListener4的自动发布的事件
```
## @TransactionalEventListener注解
使用此注解，可以指定只有当外部事务完成后，再执行监听器。

# 注意点
由于Spring的事件处理是单线程的，如果一个事件被发布，在所有监听者处理完成前，该进程将被阻塞。
因此对于耗时的监听处理逻辑需要小心处理。如果碰到这样耗时的处理，可以考虑使用@Anyc注解来启动单独线程进行处理；对于@Anyc注解的用法，将来单独开文章解释。

参考文章：
https://projects.spring.io/spring-framework/
http://blog.csdn.net/xiejx618/article/details/44600369
http://blog.csdn.net/chenssy/article/details/8220089