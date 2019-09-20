---
title: docker build报错的排查方法
date: 2019-09-19 23:41:15
tags: docker
---

我们在执行docker build时有时候会报错``ERROR: Job failed: exit status 1``。此文章介绍此类问题排查方法。
<!-- more -->

下面以我们的git-runner上执行的项目编译为例，在github上看到的pip流水线日志如下。
```
Running with gitlab-runner 11.10.1 (1f513601)
  on myrunner b9EXohmS
Using Shell executor...
Running on rms_33_236...
Reinitialized existing Git repository in /home/gitlab-runner/builds/b9EXohmS/0/lining/reconciliation/.git/
Fetching changes...
Checking out 1e37d353 as develop...
Skipping Git submodules setup
$ sudo docker build --build-arg env=test --rm -t rec-server:test .
Sending build context to Docker daemon  611.2MB

Step 1/11 : FROM mydockerhub.com/jiangyue/java8 as build-stage
 ---> 50c577d3ba9d
Step 2/11 : WORKDIR /app
 ---> Using cache
 ---> df94caba27c4
Step 3/11 : COPY . /app/
 ---> 6aaf552518eb
Step 4/11 : RUN export http_proxy=http://10.4.33.235:8888     && export https_proxy=http://10.4.33.235:8888     && ./gradlew clean build --refresh-dependencies     && ./gradlew uploadArchives
 ---> Running in b6fb0da561d5
 .........
 # 此处省略若干日志
 .........

> Task :channels:rec-channels-server:test

com.jy.rec.channel.tmall.TmallChannelTest > testImportFile_zip FAILED
    java.lang.AssertionError at TmallChannelTest.java:160

3 tests completed, 1 failed

> Task :channels:rec-channels-server:test FAILED

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':channels:rec-channels-server:test'.
> There were failing tests. See the report at: file:///app/channels/rec-channels-server/build/reports/tests/test/index.html

* Try:
Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output. Run with --scan to get full insights.

* Get more help at https://help.gradle.org

BUILD FAILED in 1m 12s69 actionable tasks: 50 executed, 19 up-to-date

The command '/bin/sh -c export http_proxy=http://10.4.33.235:8888     && export https_proxy=http://10.4.33.235:8888     && ./gradlew clean build --refresh-dependencies     && ./gradlew uploadArchives' returned a non-zero code: 1
ERROR: Job failed: exit status 1
```
从日志可以看到执行到了在执行``Step 4``步骤时报错了，此时我们可以临时进入``Step 3``的Image（``6aaf552518eb``）内部：
```bash
[root@localhost ~]# docker run -it 6aaf552518eb /bin/bash
```
进入到内部后手工执行``Step 4``的命令，此时会打印出详细的日志。
```bash
root@c248a457ae79:/app/# export http_proxy=http://10.4.33.235:8888 && export https_proxy=http://10.4.33.235:8888 && ./gradlew clean build --refresh-dependencies && ./gradlew uploadArchives
```
此后就是我们正常的问题排查了，这里不再赘述。