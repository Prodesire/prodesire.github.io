---
title: Windows 2003上 SaltStack/Salt 和 psutil 可能存在的问题及解决
date: 2019-10-20 11:57:55
tags:
  - Python
  - Salt
  - SaltStack
  - Windows
  - DevOps
categories:
  - DevOps
  - SaltStack
---

（备注：本文是之前在博客园中发表的文章，因为老博客不再维护，把有价值的博文转移到这里。）

之前把 salt 安装在 windows 2003 上，发现无法启动，随之而来的是一个有一个的坑，让我们一起逐个排查。

<!--more-->

## 问题一（salt 无法启动）

salt 无法启动，错误结果如图：

{% asset_img 1.png %}

### 解决

这种错误完全无厘头呀，本着相信 salt 的原则，我们看看 python 能不能正常启动，由此产生新的问题。

## 问题二（python 无法启动）

启动 C:\salt\bin\python，发现仍旧无法启动。这就奇怪了，我有理由相信这可能是 salt 自带的 python 的问题。那么从 Python 的官网下载个新包 Python2.7.12 看看，安装后发现官网的 Python 启动正常。莫非是初始化了一些环境变量？回过头来再去看 salt 中的 python 能不能用，奇迹般地好了~

### 解决

重新安装一次官网的 Python，然后再启动 salt 中的 python 试试。

原因在于，这台 windows 2003 原来装过 python，但可能因为后来卸载不彻底，以及中间各种软件安装影响了一些环境变量，导致 salt 中 python 无法正常启动。

## 问题三（缺少 MSCVCR100.dll）

既然 python 启动问题已经搞定，那就再去启动 salt-minion 吧。这次开启 debug 模式，看看能否正常启动，启动不了也会有详细信息。执行 C:\salt\salt-minion-debug.bat，结果没过多久报了这个错：

{% asset_img 2.png %}

### 解决

既然 windows 2003 这位老先生明确告诉我们缺少了 MSVCR100.dll 这个动态链接库，那就找到它吧。这个库是 vc++2010 里的，所以从微软的官网下载 Microsoft Visual C++ 2010 可再发行组件包 (x86)， 安装完毕后，再启动 salt-minion 就不会报错了。

## 问题四（psutil 中 ‘from . import \_psutil_windows as cext’ 报错）

由于项目中用到 psutil，自然想到要检验下 salt 自带的 python 第三方 psutil 能否正常使用，结果很遗憾：

{% asset_img 3.png %}

这是什么鬼？不能导入的原因太模糊了吧，dll 导入失败？！哪个 dll？

去报错相应的目录下看看吧，也就是 C:\salt\bin\lib\site-packages\psutil\下，发现要导入的\_psutil_windows 包其实是\_psutil_windows.pyd 这个链接库。导入这个链接库失败，那么就看看这个链接库到底链接了什么东西。

使用 [dependency walker](http://dependencywalker.com/) 去瞅瞅，发现是这样的问题：

{% asset_img 4.png %}

### 解决

把缺失的这两个 dll（msvcr90.dll, msjava.dll）补上？补上后仍然有问题，看下文。

## 问题五（At least one module has an unresolved import ...）

补上两个 dll 后，还显示一个错误：

{% asset_img 5.png %}

根据图片中的显示，大概是 iphlpapi.dll 和 kernel32.dll 的导入或被导入出现了问题。但是这两个是系统的呀，能奈之何？

先不管这个错误，尝试运行下 python，然后 import psutil，看看会不会报错：

{% asset_img 6.png %}

看来还是老错误，无法避免。

会不会是 salt 预装的 psutil 有问题？去 C:\salt\bin\scripts\下，pip uninstall psutil 卸载掉再重装试试，结果还是不行。

这就非常奇怪，突发奇想该不会是高版本的 psutil 不支持低版本的系统导致的吧？于是再次卸载掉 psutil，装了个 1.x 版本试验了下，结果可以了。

### 解决

安装一个低版本的 psutil 试试，注意你用到的 psutil 的功能在低版本中可能不存在。

## 问题六（salt 模块依赖的 wmi 可以用吗？）

从 [salt 官网](https://docs.saltstack.com/en/latest/topics/installation/windows.html)上看到关于 windows 2003 这样的描述：

{% asset_img 7.png %}

貌似是 wmi 需要额外安装。

那就先看看 wmi 能不能正常导入吧：

很好，wmi 库可以正常导入，项目要用到的 wmic（第一次在 cmd 中输入，会自动安装）也能正常使用，皆大欢喜。

{% asset_img 8.png %}

## 总结

在低版本的系统上，可能会有各种各样想不到的坑。再次做个记录留作备忘，也给将来可能踩坑的同学借鉴经验。

<div align=center>
![](/images/wechatPublicAccount.png)
</div>
