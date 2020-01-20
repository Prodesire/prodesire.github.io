---
title: Python 壹周刊 007
date: 2020-01-08 17:07:57
tags:
  - Python
  - 壹周刊
categories:
  - Python
  - 壹周刊
photos:
  - /images/pyweekly.png
---

## 新鲜事儿

[Python 2 已退休](https://pythonclock.org/?2020)

[老爹 Guido van Rossum 退出 Python 指导委员会](https://www.python.org/dev/peps/pep-8101/)

<!--more-->

## 好文共赏

[Python 类型注解](https://kunigami.blog/2019/12/26/python-type-hints/)

本文将全面介绍 mypy，通过许多示例演示了这种类型检查器的语法和功能。

[Flask8 规则](http://www.flake8rules.com/)

Flake8 中的所有规则的说明和示例。

[在 Python 中使用 Rust 变得简单](https://blog.nicco.io/2020/01/01/rust-in-python-made-easy)

对于需要性能提升的计算密集型任务，可以由 Rust 来实现逻辑，然后在 Python 中调用。本文将介绍如何实现这个过程。

[借助 NASA 图片和 Python 制作月亮视频](https://nicholasfarrow.com/Creating-a-Moon-Animation-Using-NASA-Images-and-Python/)

手把手教你如果通过 Python 和数张 NASA 的月亮图片制作月亮视频。

[让 Python 程序闪电般迅速](https://martinheinz.dev/blog/13)

讨厌 Python 的人总是说，他们不想使用它的原因之一是它很慢。 嗯，特定的程序（无论使用何种编程语言）是快还是慢，很大程度上取决于编写该程序的开发人员以及编写优化的快速的程序的技能和能力。 因此，让我们证明一些人是错误的，让我们看看如何改善 Python 程序的性能并使它们真正更快！

[如何将 Flask 与 gevent 一起使用（uWSGI 和 Gunicorn 版本）](https://iximiuz.com/en/posts/flask-gevent-tutorial/)

创建异步 Flask 应用程序，并在 Nginx 反向代理后面使用 uWSGI 或 Gunicorn 来运行它。

[使用 Jupyter 开发机器人](https://medium.com/@wolfv/robot-development-with-jupyter-ddae16d4e688)

这篇文章展示了 Jupyter 生态系统中可用的工具，在 Jupyter Notebooks 中构建高级可视化并使用 Voilá 转换为独立的 Web 应用程序，以及如何将这些应用程序部署到机器人云中。

[我没有感受到 async 的压力](https://lucumr.pocoo.org/2020/1/1/async-pressure/)

如今异步风靡一时，异步 Python、异步 Rust、Go、Node、.NET，选择您喜欢的生态系统，它有些异步操作。这种异步操作的工作原理在很大程度上取决于语言的生态系统和运行时，但总体而言，它具有一些不错的好处。这使事情变得非常简单：异步等待（await）可能需要一些时间才能完成的操作。它是如此简单，以至于创造了无数新的方法来“打击”人。我要讨论的是在系统超载之前您还没有意识到自己可能采坑的情况，也就是背压管理。在协议设计中，的一个相关术语叫做流量控制。

[Python 之禅的思考](https://orbifold.xyz/zen-of-python.html)

[Python 计时器功能：监视代码的三种方法](https://realpython.com/python-timer/)

了解如何使用 Python 计时器功能来监视程序的运行速度。您将使用类、上下文管理器和装饰器来测量程序的运行时间。 您将了解每种方法的优点以及在特定情况下可以使用的方法。

[开源迁移的困扰](https://lucumr.pocoo.org/2019/12/28/open-source-migrates/)

Flask 的创建者介绍了 Python 2 到 3 的迁移以及 Python 社区如何处理过渡。有趣的内容！

## 赞视频

[Python 老爹在牛津联盟的访谈](https://www.youtube.com/watch?v=7kn7NtlV6g0)

[Numba 让 Python 快上 1000 倍!](https://www.youtube.com/watch?v=x58W9A2lnQc)

在此视频中，我介绍了您需要了解的有关 Numba 的最低要求，Numba 是针对 Python 和 Numpy 子集的即时编译器。 该视频的前半部分做了基本介绍，并着重介绍了人们在使用 Numba 时常犯的一些错误。后半部分提出了一个现实世界中的模拟问题，在单线程和多线程情况下，使用 Numba 最多可加速 1000 倍。最后给出一个“阅读清单”作为结尾，以了解有关 Numba 的更多信息。

## 酷开源

[Saleor](https://github.com/mirumee/saleor)

使用 Python、GraphQL、Django 和 ReactJS 构建的模块化、高性能的电子商务网站。

[Peewee](https://github.com/coleifer/peewee)

一个小巧、富有表现力的 ORM —— 支持 PostgreSQL、MySQL 和 SQLite。

[Poetry](https://github.com/python-poetry/poetry)

让 Python 的依赖项管理和打包变得容易。

[django-split-settings](https://github.com/sobolevn/django-split-settings)

将 Django 设置分散到多个文件和目录中，能够轻松覆盖和修改设置。

[GINO](https://github.com/python-gino/gino)

GINO 递归定义为 GINO Is Not ORM，是一个基于 asyncio 和 SQLAlchemy core 的轻量级异步 Python ORM 框架，目前（2020 年初）仅支持 asyncpg 一种引擎。

[QuTiP](https://github.com/qutip/qutip)

Python 中的量子工具箱。

[ObsPy](https://github.com/obspy/obspy)

用于处理地震数据的 Python 框架。

[Kornia](https://github.com/kornia/kornia)

PyTorch 的开源可区分计算机视觉库。

[Typer](https://github.com/tiangolo/typer)

基于 Python 类型注解的 CLI 库，能够简单地创建 CLI 程序。

[klaxon](https://github.com/knowsuchagency/klaxon)

从终端或 Python 程序中发送 Mac OS 通知。

[ffmpeg-python](https://github.com/kkroening/ffmpeg-python)

FFmpeg 的 Python 绑定，支持复杂的过滤

[Traffic-Signal-Violation-Detection-System](https://github.com/anmspro/Traffic-Signal-Violation-Detection-System)

使用 YOLOv3 和 Tkinter 实现的基于计算机视觉的交通信号违规检测系统。

[pylightxl](https://github.com/PydPiper/pylightxl)

轻量级、零依赖、最简功能的 excel 读/写 Python 库。

[XSS Finder](https://github.com/haroonawanofficial/XSS-Finder)

大型、高级的跨站点脚本扫描程序。

[Magic Wormhole](https://github.com/warner/magic-wormhole)

安全地将内容从一台计算机转移到另一台计算机上。

<div align=center>
![](/images/wechatPublicAccount.png)
</div>
