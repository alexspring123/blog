---
title: 如何获取中国所有IP以及类型信息
tags: 
- 爬虫
---

## IP分配概述
全球IP地址由[IANA](https://www.iana.org)(Internet Assigned Numbers Authority)管理。IANA再将分配权限下发给5个不同的分支[机构](https://www.iana.org/numbers)
- [AFRINIC](http://www.afrinic.net/) 负责非洲区域
- [APNIC](http://www.apnic.net/) 亚洲/太平洋区域
- [ARIN](https://www.arin.net/) 加拿大、美国和部分加勒比区域
- [LACNIC](http://www.lacnic.net/) 拉丁美洲和部分加勒比区域
- [RIPE NCC](https://www.ripe.net/) 欧洲、中东和中亚区域

<!--more-->

## 分配给中国的IP
中国的IP是由APNIC机构管理的。
我们可以通过APNIC的如下地址 http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest 查看APNIC最新已分配的IP清单(未分配的IP可以通过legacy-apnic-latest这个文件查看)  
打开的文件内容如下：
```
2|apnic|20170525|51743|19830613|20170524|+1000
apnic|*|asn|*|7756|summary
apnic|*|ipv4|*|37477|summary
apnic|*|ipv6|*|6510|summary
apnic|JP|asn|173|1|20020801|allocated
apnic|NZ|asn|681|1|20020801|allocated
apnic|AU|asn|1221|1|20000131|allocated
apnic|JP|asn|1233|1|20020801|allocated
apnic|KR|asn|1237|1|20020801|allocated
apnic|SG|asn|1250|1|20020801|allocated
.....
```
文件格式的说明[格式说明](ftp://ftp.apnic.net/pub/apnic/stats/apnic/README.TXT)
```
格式:
registry|cc|type|start|value|date|status[|extensions...]

说明:
    registry    分配的机构，如果是APNIC机构，则为apnic
    cc        	分配给的国家
    type      	IP类型，取值为asn、ipv4或ipv6
    start     	IP范围的起始地址
    value     	IP范围的长度
    date      	分配的日期，格式为YYYYMMDD
    status    	分配的类型，取值为allocated或assigned
    extensions 	未定义的扩展.
```
知道这个格式后我们就可以编写脚本定期同步了。
可以通过如下脚本筛选出中国的IP
```
cat delegated-apnic-latest | awk -F '|' '/CN/&&/ipv4/ {print $4 "/" 32-log($5)/log(2)}'|cat >ip.txt
```

## IP知识
### IPV4表示方法
ipv4用32位二进制表示，每4位一组中间用"."隔开，每组用十进制表示
比如255.255.255.255的二进制形式是
> 11111111.11111111.11111111.11111111

### ipv4子网掩码(subnet mask)
百度知道对于子网掩码的解释
> 子网掩码(subnet mask)又叫网络掩码、地址掩码、子网络遮罩，它是一种用来指明一个IP地址的哪些位标识的是主机所在的子网，以及哪些位标识的是主机的位掩码。子网掩码不能单独存在，它必须结合IP地址一起使用。子网掩码只有一个作用，就是将某个IP地址划分成网络地址和主机地址两部分。
子网掩码是一个32位地址，用于屏蔽IP地址的一部分以区别网络标识和主机标识，并说明该IP地址是在局域网上，还是在远程网上。  

例如：子网掩码255.255.255.0的二进制形式为
> 11111111.11111111.11111111.00000000  

为1的位标示是子网标示，为0的位标示内网地址，那么上面的子网掩码表示后8位为内网地址，也就是最多有256个内网地址；

因为都是用最后几位标示内网地址，因此就可以理解为什么掩码地址都是255.255.255.0或者255.255.254.0了吧

### IPV6表示方法
百度知道解释
>IPv6的128位地址通常写成8组，每组为四个十六进制数的形式。比如：AD80:0000:0000:0000:ABAA:0000:00C2:0002 是一个合法的IPv6地址。这个地址比较长，看起来不方便也不易于书写。零压缩法可以用来缩减其长度。如果几个连续段位的值都是0，那么这些0就可以简单的以::来表示，上述地址就可写成AD80::ABAA:0000:00C2:0002。这里要注意的是只能简化连续的段位的0，其前后的0都要保留，比如AD80的最后的这个0，不能被简化。还有这个只能用一次，在上例中的ABAA后面的0000就不能再次简化。当然也可以在AAAA后面使用::，这样的话前面的12个0就不能压缩了。这个限制的目的是为了能准确还原被压缩的0，不然就无法确定每个::代表了多少个0。例如，下面是一些合法的IPv6地址：
CDCD:910A:2222:5498:8475:1111:3900:2020
1030::C9B4:FF12:48AA:1A2B
2000:0:0:0:0:0:0:1
同时前导的零可以省略，因此2001:0DB8:02de::0e13等价于2001:DB8:2de::e13

关于IPV6与ipv4的互换，可参考[百度知道](http://baike.baidu.com/link?url=HS8qWStrQkZpG5IzBV9fpIzT939--6ZasXI6vN4Oh2BQxTFPpGX8qsNwCskLGQnxzxOQEuxTHuWyhEP7mMQRTda3agUFRsxHk-4f40OHyjS)



参考文章：
http://ahhqlrg.blog.163.com/blog/static/105928805201561033936351/

