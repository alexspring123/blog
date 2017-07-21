---
title: java读取jar中manifast文件内容
tags:
---

分为2中情况：
# 获取jar文件引用
## 目标jar文件不在classpath中
```
JarFile jarFile = new JarFile("thefile.jar"); 
```
## 目标jar在classpath中
```
URL url = ClassLoader.getSystemResource(name); 
或者
InputStream stream = ClassLoader.getSystemResourceAsStream(name); 
```
这种方式不需要指定具体的jar文件名，可以读取到classpath中所有jar中的文件

# 获取文件
拿到jar文件引用后，就可以读取文件了
jarFile.enties方法返回所有enties枚举，通过每一个entry，你可以从它的manifest文件得到它的属性，任何认证信息，以及其他任何该entry的信息，如它的名字或者大小等
Enumeration enum = jarFile.entries(); 
　　 while (enum.hasMoreElements()) { 
　　　 process(enum.nextElement()); 
　　 } 
正如前面提到的，每一个entry是一个JarEntry。该类有getName，getSize，getCompressedSize等方法。 

例子：
public class JarDir { 
　　　　public static void main (String args[]) 
　　　　　　throws IOException { 
　　　　　if (args.length != 1) { 
　　　　　　System.out.println( 
　　　　　　　 "Please provide a JAR filename"); 
　　　　　　System.exit(-1); 
　　　　　} 
　　　　　JarFile jarFile = new JarFile(args[0]); 
　　　　　Enumeration enum = jarFile.entries(); 
　　　　　while (enum.hasMoreElements()) { 
　　　　　　process(enum.nextElement()); 
　　　　　} 
　　　　} 
　　
　　　　private static void process(Object obj) { 
　　　　　JarEntry entry = (JarEntry)obj; 
　　　　　String name = entry.getName(); 
　　　　　long size = entry.getSize(); 
　　　　　long compressedSize = entry.getCompressedSize(); 
　　　　　System.out.println( 
　　　　　　　name + "\t" + size + "\t" + compressedSize); 
　　　　} 
　　　} 

为了从JAR文件中真正读取一个指定的文件，你必须到其entry的InputStream。这和JarEntry不一样。这是因为JarEntry只是包含该entry的有关信息，但是并不实际包含该entry的内容。这和File和FileInputStream的区别有点儿相似。访问文件没有打开文件，它只是从目录中读取了该文件的信息。下面是如何得到entry的InputStream： 
InputStream input = jarFile.getInputStream(entry); 

当你有了输入流，你就可以像读取其他流一样读取它。在文本流中(text stream)，记得使用读取器(Reader)从流中取得字符。对于面向字节的流，如图片文件，直接读取就行了。 
下面的程序演示如何从JAR文件中读取文件。指定JAR文件的名称，要读取的文件的名称（打包JAR文件中的某一个文件）作为参数来调用该程序。要读取的文件应该有一个文本类型的。 



http://wenda.tianya.cn/question/1bb7148705d669f3
http://blog.csdn.net/leroy008/article/details/8239841
http://itmyhome.com/java-api/java/util/jar/package-use.html