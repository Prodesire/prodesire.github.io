---
title: Python 壹周刊 004
date: 2019-12-10 20:00:00
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

[两个恶意 Python 库被发现窃取 SSH 和 GPG 密钥](https://www.zdnet.com/article/two-malicious-python-libraries-removed-from-pypi/)

通过相似字母来让假库和真库看起来一样，以误导使用者。安装库时务必小心检查。

<!-- more -->

[Netflix 开源了用于数据科学项目管理的 Python 库 —— Metaflow](https://metaflow.org/)

Metaflow 是 Netflix 机器学习基础架构的关键部件，主要用于加速数据科学工作流的构建和部署，Netflix 希望通过开源 Metaflow 简化机器学习项目从原型阶段到生产阶段的过程，进而提高数据科学家的工作效率。

[Mozilla 和 Chan Zuckerberg Initiative 支持 pip](https://pyfound.blogspot.com/2019/12/moss-czi-support-pip.html)

Python 软件基金会（Python Software Foundation）将获得 407,000 美元，以支持 2020 年的 pip 改进工作。这项基础性的变革性工作将使 Python 开发人员和用户专注于他们正在构建和使用的工具，而不是对依赖冲突进行故障排查。让我们期待一下吧~

## 好文共赏

[框架模式](https://blog.startifact.com/posts/framework-patterns.html)

有很多方法可以配置框架，而每种方法都有其自身的权衡。 这篇文章描述了 N 种框架配置模式，提供了简短的示例和并权衡点。非常值得一看。

[端到端机器学习：从数据收集到部署](https://ahmedbesbes.com/end-to-end-ml.html)

文章列出完成构建和部署机器学习应用程序的必要步骤。 从数据收集到部署，将会是一段令人兴奋且有趣的旅程。

[高性能 Python](https://strangemachines.io/articles/performant-python)

简单几行代码，你也能写出高性能的 Python 程序。

[有关如何练习 Python 的一些有用技巧](https://dev.to/duomly/a-few-useful-tips-on-how-to-practice-python-5a9)

文章提出了诸如选择合适的环境、编写和改进代码、分析源码、成为社区一部分等等技巧来帮助你提升 Python 技能。

[适用于 Python 开发人员的开发人员工具和框架](https://dev.to/steelwolf180/developer-tools-frameworks-for-a-python-developer-5919)

文章列出的工具和框架可以说是 Python 开发人员必备的了。

[使用 OpenCV 进行车辆检测、追踪和速度估算](https://www.pyimagesearch.com/2019/12/02/opencv-vehicle-detection-tracking-and-speed-estimation/)

你将学习如何使用 OpenCV 和深度学习来检测视频流中的车辆，对其进行跟踪，并应用速度估算来检测行驶中的车辆的 MPH/KPH。

[Excel vs Python：如何进行常见的数据分析任务](https://www.dataquest.io/blog/excel-vs-python/)

Excel 和 Python 有什么区别？ 在本教程中，我们将通过比较如何在两个平台上执行基本的分析任务进行比较。

[使用 Elasticsearch、Logstash、Kibana（ELK）+ Filebeat 实现 Django 的集中式日志记录](https://binaroid.com/blog/django-centralised-logging-using-elasticsearch-logstash-kibana-elk-filebeat)

在本教程中，我们将学习如何将应用程序日志从 Django 应用程序推送到 Elasticsearch 存储，并能够在 Kibana Web 工具中以可读的方式显示它。本文的主要目的是使用 Elastic 提供的另一个工具（Filebeat ）在 Django 服务器和 ELK 栈（Elasticsearch、Kibana 和 Logstash）之间建立连接。 我们还将简要介绍所有前面的步骤，例如日志记录背后的原因，在 Django 中配置日志记录以及安装 ELK 栈。

[使用 Python 构建 Windows 快捷方式](https://pbpython.com/windows-shortcut.html)

作者花了太多时间试图在多台 Windows 计算机上正确设置快捷方式，以至于要自动化创建链接。 本文将讨论如何使用 Python 创建自定义 Windows 快捷方式来启动 conda 环境。

## 赞视频

[通过 gmaps 玩转谷歌地图](https://www.youtube.com/watch?v=5sEm7RcRF_g&feature=youtu.be)

使用 jupyter 演示，手把手教你如何玩转谷歌地图

[量子计算机编程](https://www.youtube.com/watch?v=aPCZcv-5qfA)

使用 IBM 免费的基于云的量子机器和 Qiskit，对量子计算机编程进行实用的入门介绍。

[Django 3.0 都有哪些新功能](https://www.youtube.com/watch?v=_BBNVFirvTY)

Django 刚刚发布了新的主要版本 Django 3.0。 它对你有何影响？什么是 ASGI？ 让视频中的小哥哥告诉你

[Python 字节码入门教程](https://www.youtube.com/watch?v=mE0oR9NQefw)

这是一种很好的逐步深入 CPython（事实上的 Python 参考实现）内部的方法。 如果你想了解有关 Python 的更多信息，请花 10 分钟！

[PyCon 瑞典 2019 视频](https://www.youtube.com/playlist?list=PLQYPYhKQVTvetDJZFGY8RfYlPBLQmbt-T)

## 酷开源

[Assembly](https://mardix.github.io/assembly/)

一个基于 Flask 的 Pythonic 且面向对象的 Web 框架。

[emoji_trends](https://github.com/enric1994/emoji_trends)

Twitter 上的 emoji 是如何被使用的。

[lightbus](https://github.com/adamcharnock/lightbus/)

Python 3 的 RPC & 事件框架。

[cuSignal ](https://github.com/rapidsai/cusignal)

cuSignal 使用 CuPy（GPU 加速的 NumPy）和自定义的 Numba CUDA 内核来加速流行的 SciPy Signal 库。

[friendly-traceback](https://github.com/aroberge/friendly-traceback)

面向 Python 初学者：用更易于理解的东西（可以翻译成多种语言）代替标准回溯。

[pytasking](https://github.com/TokenChingy/pytasking)

一个简单的 Python 3.5+多任务库。

[Whatsapp-Net](https://github.com/OfirKP/Whatsapp-Net)

根据 WhatsApp 组数据生成网络连接图。

[gensim](https://github.com/RaRe-Technologies/gensim)

用于主题建模、文档索引和相似性检索的 Python 库。

[micropython](https://github.com/micropython/micropython)

适用于微控制器和受限系统的精简高效的 Python 实现 。

[prophet](https://github.com/facebook/prophet)

为具有多季节性、线性或非线性增长的时间序列数据生成高质量的预测。

[tqdm](https://github.com/tqdm/tqdm)

适用于 Python 和 CLI 的快速、可扩展的进度栏。

[keyring](https://github.com/jaraco/keyring)

提供了一种从 Python 访问系统密钥环服务的简便方法。

<div align=center>
![](/images/wechatPublicAccount.png)
</div>
