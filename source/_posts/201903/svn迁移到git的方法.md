---
title: svn迁移到git的方法
p: /201903/svn迁移到git的方法.md
date: 2019-03-14 15:50:17
tags:
- git
- svn
---

svn在使用过程中经常碰到不稳定的情况，而且不能离线比对文件，因此我们需要迁移到git上。本片文章记录切换的详细过程。
<!--more-->

# 创建用户映射表
手工新建一个users.txt文件（可以叫其他名称），用来记录svn用户名与git用户的对应关系。
```
user1 = First Last Name <email@address.com>
user2 = First Last Name <email@address.com>
```
左边是svn用户名，右边是git的用户。

这个文件主要用于svn迁移到git时保留提交历史使用。（会将svn中提交用户名转换成git的用户）

上面的文件如果一个一个手工操作会比较麻烦，可以通过该命令可以获得 SVN 作者的列表(本方法要求主机上安装了grep，sort 和 perl.)：
```shell
$ svn log ^/ --xml | grep -P "^<author" | sort -u | \
      perl -pe 's/<author>(.*?)<\/author>/$1 = /' > users.txt
```
 上面生成的users.txt中包含了svn的用户清单，此时只需要手工补充右边的git用户。

 如果users.txt文件中有用户缺失，后面的 SVN 命令将会停止。不过你可以更新用户映射然后接着再来（类似断点续传）。

 # 拉取svn仓库
 ```shell
 $ git svn clone --stdlayout --no-metadata -A users.txt svn://hostname/path dest_dir-tmp
 ```
 这个命令将会在``dest_dir-tmp``新建一个 Git repo，并开始从 SVN 中拉取代码。请注意 “--stdlayout” 参数表示你的项目在 SVN 中是常见的 “trunk/branches/tags” 目录结构，如果不是，那你需要使用 --tags, --branches, --trunk 参数（请通过 git svn help 自行了解）。

再后面的参数是 SVN 的地址，一些常见协议都是支持的 : svn://, http://, https://. 注意这个 URL 应该指向项目的 base repository，例如 http://svn.mycompany.com/myrepo/repository. 不要指到了 /trunk, /tag 或 /branches 里。

如果出现用户名没找到，更新你的 users.txt 文件，然后
```shell
$ cd dest_dir-tmp
$ git svn fetch
```
如果你的项目非常大，你可能需要重复上面的命令好几次，直到所有的 SVN commit 都被抓下来了。

完成后，Git 将会 checkout SVN 的 trunk 到一个新的 Git branch，而其他的 SVN branch 将会设为 Git remote，你可以查看所有的 SVN branch：
```shell
$ git branch -r
```
如果你想在你的 Git repo 中保留其他的 remote branch，你需要手动创建本地 branch。否则，SVN 的 branch 将不会在最后被 clone。
```shell
$ git checkout -b local_branch remote_branch
```
SVN tags 被当作 branch 导入了，你需要创建本地 branch，打一个 tag，然后删掉那个 branch，这样才会在 Git 中生成 tag。例如 SVN tag “v1”:
```shell
$ git checkout -b tag_v1 remotes/tags/v1
$ git checkout master
$ git tag v1 tag_v1
$ git branch -D tag_v1
```
把上面的 GIT-SVN repo Clone 到一个全新的干净 git repo:
```shell
$ git clone dest_dir-tmp dest_dir
$ rm -rf dest_dir-tmp
$ cd dest_dir
```
之前从 remote branch 创建的本地 branch 又会在新 clone 的 repo 中成为 remote branch，于是对每个 branch 再做一次：
```shell
$ git checkout -b local_branch origin/remote_branch
```
最后，从干净的 Git repo 中删掉 remote （指向我们刚刚已经删掉的 temp repo）
```shell
$ git remote rm origin
```
这样一个全新 Git repo 就已经从 SVN 迁移好了.

如果你用的是macOS或linux系统，上面对于clone下来的svn项目处理过程可以简单使用官方的2条命令   
1. 要把标签变成合适的 Git 标签
```shell
$ git for-each-ref refs/remotes/tags | cut -d / -f 4- | grep -v @ | while read tagname; do git tag "$tagname" "tags/$tagname"; git branch -r -d "tags/$tagname"; done
```
该命令将原本以 tag/ 开头的远程分支的索引变成真正的（轻巧的）标签
2. 把 ``refs/remotes`` 下面剩下的索引变成本地分支
```shell
$ git for-each-ref refs/remotes | cut -d / -f 3- | grep -v @ | while read branchname; do git branch "$branchname" "refs/remotes/$branchname"; git branch -r -d "$branchname"; done
```

# 推送git到远程库
将本地的 Git repo push 到远程仓库（我这里用的是 GitLab）：
```shell
$ git remote add origin git@git.udev.hk:udba/udba.git
$ git push -u origin master
```
push 所有的 branch：
```shell
$ git push origin --all
```
push 所有的 tag：
```shell
git push origin --tags
```

# 碰到的问题
## git svn clone报错
macOS中执行``git svn clone --stdlayout --no-metadata -A users.txt http://10.129.209.194/svn/hd123 hd123``命令时报错如下
```
Can't locate SVN/Core.pm in @INC (you may need to install the SVN::Core module) (@INC contains: /usr/local/git/lib/perl5/site_perl/5.18.2/darwin-thread-multi-2level /usr/local/git/lib/perl5/site_perl/5.18.2 /usr/local/git/lib/perl5/site_perl /Library/Perl/5.18/darwin-thread-multi-2level /Library/Perl/5.18 /Network/Library/Perl/5.18/darwin-thread-multi-2level /Network/Library/Perl/5.18 /Library/Perl/Updates/5.18.2 /System/Library/Perl/5.18/darwin-thread-multi-2level /System/Library/Perl/5.18 /System/Library/Perl/Extras/5.18/darwin-thread-multi-2level /System/Library/Perl/Extras/5.18 .) at /usr/local/git/lib/perl5/site_perl/Git/SVN/Utils.pm line 6.
BEGIN failed--compilation aborted at /usr/local/git/lib/perl5/site_perl/Git/SVN/Utils.pm line 6.
Compilation failed in require at /usr/local/git/lib/perl5/site_perl/Git/SVN.pm line 25.
BEGIN failed--compilation aborted at /usr/local/git/lib/perl5/site_perl/Git/SVN.pm line 32.
Compilation failed in require at /usr/local/git/libexec/git-core/git-svn line 21.
BEGIN failed--compilation aborted at /usr/local/git/libexec/git-core/git-svn line 21.
```
解决办法：重装git 和 SVN
```shell
$ brew reinstall git
$ brew reinstall subversion
```

## 下载代码过程中报Connection timed out
解决办法：
```shell
$ cd hd123
$ git svn featch
```
过程中中断的都可以通过上面命令继续下载，特别是大的仓库经常会需要多次fetch才能下载完成。



参考文章：
- https://www.lovelucy.info/codebase-from-svn-to-git-migration-keep-commit-history.html
- https://git-scm.com/book/zh/v1/Git-%E4%B8%8E%E5%85%B6%E4%BB%96%E7%B3%BB%E7%BB%9F-%E8%BF%81%E7%A7%BB%E5%88%B0-Git
- https://cloud.tencent.com/developer/article/1098891







