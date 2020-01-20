---
title: Airflow 探究
date: 2019-10-23 13:03:03
tags:
  - Python
  - Airflow
  - DevOps
categories:
  - DevOps
  - Airflow
---

## 介绍

Airflow 是一个以**编程**方式进行**编写、调度和监控工作流**的平台。
一旦工作流通过代码来定义，它们会变得更加易于维护、版本化、可测试，以及可协作。
使用 Airflow 以**有向无环图 (DAGs)**的形式编写任务的工作流。Airflow 调度器在满足指定的依赖项的同时，在一组 worker 上执行任务。丰富的命令行实用程序使得通过 DAG 执行复杂的任务变得容易。而通过丰富的界面，用户可以轻松地可视化生产中运行的流水线、监视进度，并在需要时排除故障。

<!--more-->

### 设计原则

- 动态性：Airflow 流水线（pipeline）配置为代码（Python），并允许动态生成，进而允许编写动态实例化流水线的代码
- 可扩展性：能轻松定义自己的操作器（opertators）、执行器，并可扩展库，以使其符合适合当前环境的抽象级别
- 优雅性：Airflow 流水线精简而清晰。Airflow 的核心使用强大的 Jinja 模板引擎对配置脚本进行参数化
- 可伸缩性：Airflow 具有模块化体系结构，并使用消息队列来协调任意数量的 worker。

### 组件

Airflow 由以下组件组成：

- 配置文件：配置诸如“Web 服务器在哪里运行”、“使用何种 Executor”、“配置相关 RabbitMQ/Redis”、DAGs 位置等
- 元数据库（MySQL 或 Postgre）:存放 DAGs、DAG run、任务、变量等内容
- DAGs（Directed Acyclic Graphs，有向无环图）：用来定义工作流，包含任务定义及依赖信息。其中的任务就是用户实际要去执行的内容
- 调度器：负责触发每个 DAG 的 DAG 实例和工作实例，也负责调用 Executor（可以是 Local、Celery 或 Sequential）
- Broker（Redis 或 RabbitMQ）：对 Celery Executor 来说，broker 是必须的，用来在 executor 和 worker 之间传递消息
- Worker 节点：实际执行任务和返回任务结果的工作进程
- Web 服务器：提供 Airflow 的界面，用户可以访问它来查看 DAGs、状态、重新运行、创建变量、配置连接等

### 更多内容

GitHub：https://github.com/apache/incubator-airflow
官方文档：https://airflow.incubator.apache.org

## 使用

### 安装和启动

我们可以通过 pip 或者 docker 来获取 Airflow 并运行，然后访问 http://localhost:8080。

#### 通过 pip

通过 pip 方式获取到的 Airflow 所使用的默认数据库为 Python 自带的 sqlite3，如需使用其他数据库（如 MySQL、PostgreSQL）详见官方文档的[安装说明](http://airflow.apache.org/installation.html)。

```python
# 指定Airflow的home目录，默认为~/airflow
export AIRFLOW_HOME=~/airflow

# 通过pip安装apache-airflow
pip install apache-airflow
# 安装kubernete插件，否则后续运行会一直报错
pip install airflow['kubernetes'] kubernetes

# 初始化数据库
airflow initdb

# 启动web服务器，默认端口为8080
airflow webserver -p 8080

# 启动调度器
airflow scheduler​
```

#### 通过 docker

目前尚没有 Airflow 官方的 docker 版，而开源社区里有几个用户各自自发地维护了 docker 版的 airflow，其中比较出名的有 https://github.com/puckel/docker-airflow。

```python
# 获取airflow镜像
docker pull puckel/docker-airflow

# 启动web服务器，映射端口为8080
docker run -d -p 8080:8080 puckel/docker-airflow webserver
```

### DAG

为了更好的说明如何使用 DAG 来定义工作流，本文将使用官网的[一个例子](http://airflow.apache.org/tutorial.html#example-pipeline-definition)进行说明。

#### 任务流程图

{% asset_img 1.png %}

假定有一个任务叫 print_date，用以输出日期。当它执行完后，会同时执行两个名为 templated 和 sleep 的任务，而：

- templated 任务用于循环输出日期和参数
- sleep 任务用于休眠一段时间

#### DAG 定义文件

Airflow 直接使用 Python 脚本来编写 DAG 定义文件，上述任务流程写成 DAG 定义文件如下：

```python
"""
Code that goes along with the Airflow tutorial located at:
https://github.com/apache/incubator-airflow/blob/master/airflow/example_dags/tutorial.py
"""
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta


##########################################
# 初始化DAG
##########################################
# 用作整个流程的默认参数
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2018, 11, 20),
    'email': ['airflow@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    # 'queue': 'bash_queue',
    # 'pool': 'backfill',
    # 'priority_weight': 10,
    # 'end_date': datetime(2018, 11, 20),
}

# 我们需要一个DAG对象，用来组合各个任务。第一个参数为表示其唯一身份的ID，
# 第二个参数是一组调度相关的配置
# 第三个参数表示每天调度一次,也可以用crontab的语法描述时间间隔，如'0 0 * * *'
dag = DAG('tutorial', default_args=default_args, schedule_interval=timedelta(1))

##########################################
# 初始化任务
##########################################
# t1即为print_date任务，task_id为任务的唯一标识符
# 使用bash命令date来打印日期
t1 = BashOperator(
    task_id='print_date',
    bash_command='date',
    dag=dag)

# t2即为sleep任务
# 使用bash命令sleep 5来休眠5秒，重试3次
t2 = BashOperator(
    task_id='sleep',
    bash_command='sleep 5',
    retries=3,
    dag=dag)

# Jinja模板，{{变量名}}均会被Airflow替换成真实值，如{{ ds }}被替换成真实的日期
# {% for i in range(5) %}表示循环5次执行
# 更多关于宏的说明详见 https://airflow.incubator.apache.org/code.html#macros
templated_command = """
    {% for i in range(5) %}
        echo "{{ ds }}"
        echo "{{ macros.ds_add(ds, 7)}}"
        echo "{{ params.my_param }}"
    {% endfor %}
"""

# t3为templated任务
t3 = BashOperator(
    task_id='templated',
    bash_command=templated_command,
    params={'my_param': 'Parameter I passed in'},
    dag=dag)

##########################################
# 配置任务之间的依赖
##########################################
# 将t2的上游设置为t1
t2.set_upstream(t1)
# 将t3的上游设置为t1
t3.set_upstream(t1)​
```

乍看整个文件会有些复杂，但是总的来说，Airflow 仅把此 Python 脚本作为工作流的配置文件，所以并不会出现任何的业务逻辑。
DAG 定义文件大致分为三块：

- 配置参数，进而初始化 dag 对象
- 初始化一些任务
- 配置这些任务彼此间的依赖关系
  所以整体上看配置过程是简单明了的。不过，DAG 定义文件中涉及到 DAG、Operator、Task 等概念，只有了解这些，才能轻松地进行配置。我们将在 2.3 节中重点介绍。

#### 调度器

在 2.1 节中也介绍过，通过以下命令可以启动调度器：

```bash
airflow scheduler
```

只有启动了调度器，任务才可以被调度，进而分配到某个工作进程中执行。

关于调度执行时间需要特别注意，在上述 DAG 定义文件的示例中：

- start_date 表示作业开始调度时间
- schedule_interval 表示调度周期，它有多种表达方式：
  - 使用 datetime.timedelta 对象，如 timedelta(1)表示每天
  - 使用和[cron 完全相同的语法](https://en.wikipedia.org/wiki/Cron#CRON_expression)，如'\* \* \* \* \*'表示每分钟
  - 使用[预置的 cron](http://airflow.apache.org/scheduler.html#dag-runs)，如'@once', '@hourly'等

当新配置的 DAG 生效后，第一次真正调度的时间为从开始调度时间开始，一个调度周期末端时刻。比如 start_date 为 2018-11-11，schedule_interval 为一天，那么将在 2018-11-11T23:59 后马上执行 DAG。

#### 测试

**运行脚本**
假定上述 DAG 定义文件名为 tutorial.py，存放于~/airflow/dags（没有则新建）下，那么执行：

```bash
python ~/airflow/dags/tutorial.py
```

如果没有抛出任何异常，说明 DAG 文件没有大的问题，可以进入下一步。
**命令行元数据验证**

```bash
# 输出激活的DAGs
airflow list_dags

# 输出DAG ID为"tutorial"的所有任务
airflow list_tasks tutorial

# 输出任务层级
airflow list_tasks tutorial --tree
```

**进行测试**
注意最后一个参数为执行时间，填写当天日期即可。

```bash
# 命令行: command subcommand dag_id task_id date

# 测试print_date任务
airflow test tutorial print_date 2018-11-20

# 测试sleep任务
airflow test tutorial sleep 2018-11-20

# 测试templated任务
airflow test tutorial templated 2018-11-20​
```

airflow test 命令会在本地运行任务实例，并将日志输出到标准输出。无需担心任务间的依赖，也不会将任务状态同步至数据库。
比如上述 print_date 任务的部分关键测试输出如下：

```bash
[2018-11-20 17:53:45,512] {bash_operator.py:81} INFO - Running command: date
[2018-11-20 17:53:45,517] {bash_operator.py:90} INFO - Output:
[2018-11-20 17:53:45,521] {bash_operator.py:94} INFO - Tue Nov 20 17:53:45 UTC 2018
[2018-11-20 17:53:45,521] {bash_operator.py:97} INFO - Command exited with return code 0
```

### 核心概念

#### DAGs

在 Airflow 中，DAG 或者说有向无环图是若干个任务的集合，这些任务以某种方式组织，展现了彼此间的联系和依赖。因此，DAG 描述了一个工作流的过程。
DAG 并不关心里面的任务做了什么事情，而是关心：

- 任务在特定的时间开始
- 若干任务以正确的顺序进行
- 对未期望的情况有正确的处理

DAG 定义文件需存放在 DAG_FOLDER 目录（通过~/airflow/airflow.cfg 进行配置）下，Airflow 会执行该目录下的每个 py 文件，来动态地生成 DAG 对象。

**作用域（Scope）**

Airflow 将加载它可以从 DAG 文件导入的任何 DAG 对象。，也就意味着 DAG 必须出现在 globals()中。
在下面的示例中，只会加载 dag_1：

```python
dag_1 = DAG('this_dag_will_be_discovered')

def my_function():
    dag_2 = DAG('but_this_dag_will_not')

my_function()​
```

不过有时这么用也有它的意义。比如在函数中使用 SubDagOperator 来定义子 dag。

**默认参数（Default Arguments）**

默认参数需传入 DAG 的 default_args 中，进而会应用到所有的操作器上。这样，当许多操作器需要共同参数时，通过这种方式就方便了许多。

```python
default_args = {
    'start_date': datetime(2016, 1, 1),
    'owner': 'Airflow'
}

dag = DAG('my_dag', default_args=default_args)
op = DummyOperator(task_id='dummy', dag=dag)
print(op.owner) # Airflow​
```

**上下文管理器（Conext Manager）**
DAG 可以当做上下文管理器来使用，这样一来，作用域内的操作器会自动地赋值 dag。

```python
with DAG('my_dag', start_date=datetime(2016, 1, 1)) as dag:
    op = DummyOperator('op')

op.dag is dag # True，这里的操作器op就被自动地赋值上了dag​
```

#### 操作器（Operator）

Operator 用来描述工作流中单个任务的内容，即做什么。它通常（但并非总是）是原子的，这意味着其可以独立运行，而不需要与其他 Operator 共享资源，因此可能在两台完全不同的机器上运行。
通常来说，如果两个 Operator 需要共享信息，如文件名或少量数据，应该考虑将它们组合到一个操作器中。如果没法避免，则可以使用 Airflow 提供的名为 XCom 的特性来进行操作器间的通信。
Airflow 内置了很多的操作器来完成常见任务，包括：

- BashOperator - 执行 bash 命令
- PythonOperator - 调用任意的 Python 函数
- EmailOperator - 发送邮件
- SimpleHttpOperator - 发送 HTTP 请求
- MySqlOperator, SqliteOperator, PostgresOperator, MsSqlOperator, OracleOperator, JdbcOperator 等 - 执行 SQL 命令
- Sensor - 等待一个特定的时间、文件、数据库行、S3 key 等

除了这些常用的，还有特定的操作器，如 DockerOperator、HiveOperator、S3FileTransformOperator、PrestoToMysqlOperator、SlackOperator 等
[airflow/contrib](https://github.com/apache/airflow/tree/master/airflow/contrib)目录中包含了更多由社区构建的操作器，允许用户更轻松地向平台添加新功能，但不保证质量。

**DAG 赋值（DAG Assignment）**
操作器无需立即赋值 DAG。 但是，一旦为操作器赋值 DAG，就无法转移或取消。 在创建操作器时，通过延迟赋值或甚至从其他操作器推导，可以显式地完成 DAG 赋值。

```python
dag = DAG('my_dag', start_date=datetime(2018, 1, 1))

# 显示地设置DAG
explicit_op = DummyOperator(task_id='op1', dag=dag)

# 延迟设置DAG
deferred_op = DummyOperator(task_id='op2')
deferred_op.dag = dag

# DAG推导赋值（和链接的操作器，也就是例子中的deferred_op，必须是在同一个DAG中）
inferred_op = DummyOperator(task_id='op3')
inferred_op.set_upstream(deferred_op)​
```

**位移组合（Bitshift Composition）**
通常使用 set_upstream()和 set_downstream()方法设置操作器间的依赖关系。 在 Airflow 1.8 及以后，可以通过 Python 位移操作符">>"和"<<"来达到相同的目的。
以下四个语句在功能上都是等价的：

```python
op1 >> op2
op1.set_downstream(op2)

op2 << op1
op2.set_upstream(op1)
```

op1 >> op2 表示先运行 op1，再 op2 运行。
我们还可以组成多个操作器。要注意的是链式从左到右执行，并且始终返回最右边的对象。 例如：

```python
op1 >> op2 >> op3 << op4
```

表示两个任务分支：一个是依次运行 op1、op2、op3，一个是依次运行 op4、op3。与之等价的语句如下：

```python
op1.set_downstream(op2)
op2.set_downstream(op3)
op3.set_upstream(op4)
```

为了方便，位移操作符还可以用于 DAG，比如：

```python
dag >> op1 >> op2
```

等价于：

```python
op1.dag = dag
op1.set_downstream(op2)
```

结合**上下文管理器**和**位移组合**，我们就可以编写出如下例子：

```python
with DAG('my_dag', start_date=datetime(2016, 1, 1)) as dag:
    (
        DummyOperator(task_id='dummy_1')
        >> BashOperator(
            task_id='bash_1',
            bash_command='echo "HELLO!"')
        >> PythonOperator(
            task_id='python_1',
            python_callable=lambda: print("GOODBYE!"))
    )​
```

本示例表示依次执行 DummyOperator、BashOperator、PythonOperator。

#### 任务（Tasks）

一旦操作器被实例化，它就被称作“任务”。 由于在实例化操作器时指定了特定的值，从而形成了参数化的任务，而这样的任务便成了 DAG 中的一个节点。

#### 任务实例（Task Instances）

任务实例表示任务的特定运行时，其特点在于 dag、任务和时间点的组合。 任务实例也有状态，如“运行”、“成功”、“失败”、“跳过”、“重试”等。

#### 工作流（Workflows）

上述概念可以定义如下：

- DAG: 描述工作应该进行的顺序
- Operator: 某些工作的模板
- Task: Operator 的参数化实例
- Task Instance:一个任务的运行时，它被赋值了 DAG，且有与 DAG 的特定运行相关联的状态

而工作流，就是组合 DAG、Operators 来创建多个 TaskInstance 。

## 测试数据

### 任务执行时间

本测试创建了 3 个相同的任务（下文用 t1、t2、t3 指代），任务内容是使用 PythonOperator 执行一个 Python 函数，将时间写入到文件中，核心代码如下：

```python
# 定义默认参数
default_args = {
    'owner': 'airflow',  # 拥有者名称
    'start_date': datetime(2018, 11, 27, 23, 1),  # 第一次开始执行的时间，为格林威治时间
    'retries': 1,  # 失败重试次数
    'retry_delay': timedelta(seconds=5)  # 失败重试间隔
}

# 定义DAG
dag = DAG(
    dag_id='hello_world',  # dag_id
    default_args=default_args,  # 指定默认参数
    # schedule_interval="00, *, *, *, *"  # 执行周期，依次是分，时，天，月，年，此处表示每个整点执行
    schedule_interval=timedelta(minutes=1)  # 执行周期，表示每分钟执行一次
)

def hello_world_1():
    current_time = str(datetime.today())
    with open('/tmp/hello_world_1.txt', 'a') as f:
        f.write('%s\n' % current_time)

t1 = PythonOperator(
    task_id='hello_world_1',  # task_id
    python_callable=hello_world_1,  # 指定要执行的函数
    dag=dag,  # 指定归属的dag
)​
```

任务依赖关系如下：

{% asset_img 2.png %}

当使用 SequentialExecutor 时，Airflow Scheduler 为不同配置时执行 dag 中每个任务的时间统计如下：

{% asset_img 3.png %}

从上述数据可以看出：

- 对于周期性 dag 来说，实际调度时间不准确，基本上晚于计划时间一个周期甚至更久
- 调度并不意味着真正要执行任务，真正执行时间晚于调度时间约 4 秒
- 整个任务执行时间较长，t1、t2、t3 使用 PythonOperator 将日期输出到文件中，毫秒级就可以完成。但是从结果看，整个时间要持续 1-3 秒左右

### 加载 DAG 的方式

Airflow 会不断加载 dags 目录下的 dag 文件，scheduler 加载 dag 文件的相关日志如下：

{% asset_img 4.png %}

从中可以看出：

- Airflow 会依次加载 dag 中的所有 dag 文件，待所有文件加载好后，重头开始，如此循环往复
- 每次都是新开一个进程加载一个 dag 文件
- 加载一个 dag 文件的时间大概在 3-4s 左右

## 部署架构

### 单机部署

{% asset_img 5.png %}

在该场景中：

- Repo 指代元数据库（如 MySQL、Postgre 等），存放 DAGs、DAG run、任务、变量等内容
- WebServer 展现 DAGs 及其状态指标（数据从 Repo 中获取）
- Scheduler 读取 DAGs，将其信息存放至 Repo。它也负责启动 Executor
- Executor 读取调度间隔信息，在 Repo 中创建 DAGs 和任务的实例
- Worker 读取任务实例并运行任务，将状态写回 Repo

### Worker 分布式部署

{% asset_img 6.png %}

分布式部署和单机部署最大的区别在于 Executor 和 Wroker 的变化。这种场景下，我们一般使用 Celery Worker 作为 worker，所以 Executor 也会使用 Celery Executor。而 Celery 需要使用像 RabbitMQ 这样的 broker 作为消息传递：

- RabbitMQ 是 Celery Executor 存放任务实例的分布式消息服务，而 Worker 就是从此读取消息来执行任务
- Executor 会被配置为 Celery Executor（在 airflow.cfg 中配置），并且指向 RabbitMQ Broker
- Worker 被安装在不同的节点上，它们从 RabbitMQ Broker 中读取任务，并执行，最终将结果写入 Backend（就是图中的 Repo，可以是 MySQL 等数据库）

### Airflow 高可用+Worker 分布式部署

{% asset_img 7.png %}

我们主要说明上图左侧的 Airflow 高可用的架构，图中绿色部分为的主实例(实例 1)，红色为备实例（实例 2）：

- 实例 1 和实例 2 均会启动并运行，实例 1 首先在元数据库（Repo）的表中声明为主实例
- 主实例（实例 1）会包含实际的 DAGs；备实例（实例 2）会包含 PrimaryServerPoller（Counterpart Poller） DAG，PrimaryServerPoller 会不断地向主实例的调度器拉取数据
- 假设主实例（实例 1）挂掉，则 PrimaryServerPoller 会检测到，然后：
  - 实例 2 在元数据库（Repo）的表中声明为主实例
  - 将实例 1 中 DAGs 文件夹中所有 DAGs 移出，并把 PrimaryServerPoller DAG 移入
  - 将实例 2 中 DAGs 文件夹中 PrimaryServerPoller DAG 移出，并把所有的 DAGs 移入
- 由此，实例 1、2 的身份对调

## 参考

- [Airflow 官方文档](https://airflow.incubator.apache.org/start.html)
- [Guide to Apache Airflow](http://clairvoyantsoft.com/assets/whitepapers/GuideToApacheAirflow.pdf)
- [浅谈调度工具——Airflow](https://www.jianshu.com/p/e878bbc9ead2)
- [理解 Apache Airflow 的关键概念](https://juejin.im/post/5b7ba247e51d4538d42ab6a0)
- [工作流管理平台 Airflow 入门](https://www.jianshu.com/p/56fe5a271c14)

<div align=center>
![](/images/wechatPublicAccount.png)
</div>