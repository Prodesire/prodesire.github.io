---
title: 图表即代码：使用 Diagrams 制作云系统架构原型图
date: 2020-02-16 13:50:07
tags:
  - Python
  - Diagrams
categories:
  - Python
---

## 一、前言

昨天发现了一款非常不错的云系统架构原型图制作库 [Diagrams](https://github.com/mingrammer/diagrams "Diagrams")，通过它，我们便可以使用代码的方式绘制诸如阿里云、AWS、Azure、K8S 等系统架构原型图。

相比于在 UI 上对各种图标进行拖拽和调整，这种方式更符合我们程序员的使用习惯。

本文不仅要介绍下这个库，也想说说我是如何参与到这个库中以支持阿里云资源。

## 二、安装

`Diagrams` 使用 [Graphviz](https://www.graphviz.org/ "Graphviz") 来渲染图表，在安装 `diagrams` 之前需要先[安装 Graphviz](https://graphviz.gitlab.io/download/ "安装 Graphviz")。

> macOS 用户（如果使用 [Homebrew](https://brew.sh/)）可以使用 `brew install graphviz` 的方式来安装 `Graphviz`。

安装 `diagrams` 的方式有多种，通过 `pip`、`pipenv` 和 `poetry` 均可：

```shell script
# 使用 pip (pip3)
$ pip install diagrams

# 使用 pipenv
$ pipenv install diagrams

# 使用 poetry
$ poetry add diagrams
```

<!--more-->

## 三、快速开始

```python
# diagram.py
from diagrams import Diagram
from diagrams.alibabacloud.network import SLB
from diagrams.alibabacloud.compute import ECS
from diagrams.alibabacloud.database import RDS

with Diagram("Web Service", show=False):
    SLB("lb") >> ECS("web") >> RDS("userdb")
```

执行后，就能生成如下架构图：

```shell script
$ python diagram.py
```

{% asset_img 1.jpg %}

## 四、指南

`Diagrams` 库非常容易掌握，我们仅需要掌握三个概念就能轻松绘制云系统架构图：

- `Diagram`：这是表示图的最主要的对象，代表一个架构图
- `Node`：表示一个节点或系统组件，比如`快速开始`中的`SLB`、`ECS`和`RDS`都是架构图中的节点
- `Cluster`：表示集群或分组，可将多个节点放到一个集群中

### 4.1 图 Diagram

使用 `Diagram` 类来创建图环境上下文，使用 `with` 语法来使用这个上下文。`Diagram` 的第一个参数是会被用作架构图的名称以及输出的图片文件名（转换为小写+下划线）。

```python
from diagrams import Diagram
from diagrams.aws.compute import EC2

with Diagram("Simple Diagram"):
    EC2("web")
```

运行上述代码，会生成一个包含 `EC2` 节点的架构图，并存放在当前的 `simple_diagram.png` 中。

`Diagram` 类还支持如下参数：

- `outformat`：指定输出图片的类型，默认是 `png`，可以是 `png`、`jpg`、`svg` 和 `pdf`
- `show`：指定是否显示图片，默认是 `False`
- `graph_attr`、`node_attr` 和 `edge_attr`：指定 `Graphviz` 属性选项，用来控制图、点、线的样式，详情查看 [参考链接](https://www.graphviz.org/doc/info/attrs.html "参考链接")

### 4.2 节点 Node

目前，`Diagrams` 支持五类云资源节点，分别是 `AWS`、`Azure`、`AlibabaCloud`、`GCP` 和 `K8S`。

节点之间的关系使用操作符来表示，分别是：

- `>>`：左节点指向右节点
- `<<`：右节点指向左节点
- `-`：节点互相连接，没有方向

以下是一个例子：

```python
from diagrams import Diagram
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB
from diagrams.aws.storage import S3

with Diagram("Web Services", show=False):
    ELB("lb") >> EC2("web") >> RDS("userdb") >> S3("store")
    ELB("lb") >> EC2("web") >> RDS("userdb") << EC2("stat")
    (ELB("lb") >> EC2("web")) - EC2("web") >> RDS("userdb")
```

{% asset_img 2.jpg %}

`Diagrams` 不仅支持单个节点的关系建立，还支持一组节点和其他节点的关系建立，使用 `list` 来表示一组节点。示例如下：

```python
from diagrams import Diagram
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB

with Diagram("Grouped Workers", show=False, direction="TB"):
    ELB("lb") >> [EC2("worker1"),
                  EC2("worker2"),
                  EC2("worker3"),
                  EC2("worker4"),
                  EC2("worker5")] >> RDS("events")
```

{% asset_img 3.jpg %}

### 4.3 集群/组 Cluster

当我们需要在架构图上表示几个节点属于一个集群时，就要用到 `Cluster`。和 `Diagram` 的使用方式类似，它也是一个上下文管理器，使用 `with` 语法。
示例如下：

```python
from diagrams import Cluster, Diagram
from diagrams.aws.compute import ECS
from diagrams.aws.database import RDS
from diagrams.aws.network import Route53

with Diagram("Simple Web Service with DB Cluster", show=False):
    dns = Route53("dns")
    web = ECS("service")

    with Cluster("DB Cluster"):
        db_master = RDS("master")
        db_master - [RDS("slave1"),
                     RDS("slave2")]

    dns >> web >> db_master
```

{% asset_img 4.jpg %}

`Diagrams` 还支持嵌套集群，只需嵌套使用 `with Cluster()` 即可：

```python
from diagrams import Cluster, Diagram
from diagrams.aws.compute import ECS, EKS, Lambda
from diagrams.aws.database import Redshift
from diagrams.aws.integration import SQS
from diagrams.aws.storage import S3

with Diagram("Event Processing", show=False):
    source = EKS("k8s source")

    with Cluster("Event Flows"):
        with Cluster("Event Workers"):
            workers = [ECS("worker1"),
                       ECS("worker2"),
                       ECS("worker3")]

        queue = SQS("event queue")

        with Cluster("Processing"):
            handlers = [Lambda("proc1"),
                        Lambda("proc2"),
                        Lambda("proc3")]

    store = S3("events store")
    dw = Redshift("analytics")

    source >> workers >> queue >> handlers
    handlers >> store
    handlers >> dw
```

{% asset_img 5.jpg %}

## 五、我是如何贡献代码

看到 `Diagrams` 库时，我感到很兴奋。我们画示意图无外乎两种，一种是通过`UI`来画，一种是通过`DSL`来制作。在流程图、时序图方面，[PlantUML](https://plantuml.com/zh/ "PlantUML") 是我很喜欢的 `DSL`，然而在云系统架构图方面，过去确实没发现相关的库，直到看到了 `Diagrams`。

在我看到 `Diagrams` 时，它还只是支持 `AWS`、`Azure`、`GCP` 和 `K8S`，我心想怎么能没有`阿里云`呢？这么好的库我岂不是用不了了。既然如此，不如自己动手，丰衣足食吧。阅读 `Diagrams` 的代码，会发现写的还真不错，代码清晰简单，还提供了完善的脚手架。

对于它所支持的云供应商（比如 `AWS`），当我们想更新里面的资源时，只需要在 `resources/aws` 文件夹中更新资源图片，然后执行 `./autogen.sh` 即可。`./autogen.sh` 会对 `resources/` 做这么几件事：

- 将特定云供应商的 `svg` 图片转换为 `png`
- 将特定云供应商的图片调整为圆角图片
- 自动生成节点类代码
- 自动生成文档
- 使用 `black` 格式化自动生成的代码

对于它所不支持的云供应商（比如 `AlibabaCloud`），则要先修改脚手架和配置文件以支持新的云供应商，然后遵循上面的方法即可。具体改动内容可见 [此 PR](https://github.com/mingrammer/diagrams/pull/19 "Diagrams 支持阿里云 PR")。

参与一个开源项目其实就是这么简单，当你发现满足不了你的需求时，就阅读它的源码以了解实现原理，然后再自己动手实现需求，最后就是向作者提个 PR。

<div align=center>
![](/images/wechatPublicAccount.png)
</div>
