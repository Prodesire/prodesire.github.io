---
title: Python 命令行大乱斗
date: 2020-07-02 00:01:11
tags:
  - Python
  - 命令行
  - argparse
  - docopt
  - click
  - fire
  - typer
categories:
  - Python
  - 命令行
---

本文首发于 [凌云时刻公众号](https://mp.weixin.qq.com/s/szn0qm8_u6GTbVoW9GBP3Q)。

当你想实现一个命令行程序时，或许第一个想到的是用 Python 来实现。比如 CentOS 上大名鼎鼎的包管理工具 `yum` 就是基于 Python 实现的。

而 Python 的世界中有很多命令行库，每个库都各具特色。但我们往往不知道其背后的设计理念，也因此在选择时感到迷茫。这些库的作者为何在重复造轮子，他是从哪个角度来考虑，来让命令行库“演变”到一个新的更好用的形态。

为了能够更加直观地感受到命令行库的设计理念，在此之前，我们不妨设计一个名为 `calc` 的命令行程序，它能：

- 支持 `echo` 子命令，对输入的字符串做处理来输出
  - 若不提供任何选项，则输出原始内容
  - 若提供 `--lower` 选项，则输出小写字符串
  - 若提供 `--upper` 选项，则输出大写字符串
- 支持 `eval` 子命令，针对输入调用 Python 的 `eval` 函数，将结果输出（作为示例，我们不考虑安全性问题）

<!--more-->

## argparse

[argparse](https://docs.python.org/3/library/argparse.html) 作为 Python 的标准库，可能会是你想到第一个命令行库。

`argparse` 的设计理念就是提供给开发者最细粒度的控制。换句话说，你需要告诉它必不可少的细节，比如参数的类型是什么，处理参数的动作是怎样的。

在 `argparse` 的世界中，需要：

- 设置解析器，作为后续定义参数和解析命令行的基础。如果要实现子命令，则还要设置子解析器。
- 定义参数，包括名称、类型、动作、帮助等。其中的动作是指对于此参数的初步处理，是直接存下来，还是作为布尔值，亦或是追加到列表中等等
- 解析参数
- 根据参数编写业务逻辑

以下示例是基于 `argparse` 的 `calc` 程序：

```python
import argparse


def echo_text(args):
    if args.lower:
        print(args.text.lower())
    elif args.upper:
        print(args.text.upper())
    else:
        print(args.text)


def eval_expression(args):
    print(eval(args.expression))


# 1. 设置解析器
parser = argparse.ArgumentParser(description='Calculator Program.')
subparsers = parser.add_subparsers()

# 2. 定义参数
# 2.1 echo 子命令
# echo 子解析器
echo_parser = subparsers.add_parser(
    'echo', help='Echo input text in multiple forms')
# 添加位置参数 text
echo_parser.add_argument('text', help='Input text')
# --lower/--upper 互斥，需要设置互斥组
echo_group = echo_parser.add_mutually_exclusive_group()
# 添加选项参数 --lower/--upper，这里action的作用就是将之变为布尔变量
echo_parser.add_argument('--lower', action='store_true', help='Lower input text')
echo_parser.add_argument('--upper', action='store_true', help='Upper input text')
# 设置此命令的处理函数
echo_parser.set_defaults(handle=echo_text)

# eval 子解析器
eval_parser = subparsers.add_parser(
    'eval', help='Eval input expression and return result')
# 添加位置参数 expression
eval_parser.add_argument('expression', help='Expression to eval')
# 设置此命令的处理函数
eval_parser.set_defaults(handle=eval_expression)

# 3. 解析参数
args = parser.parse_args(['echo', '--upper', 'Hello, World'])
print(args)  # 结果：Namespace(lower=True, text='Hello, World', upper=False)
# args = parser.parse_args(['eval', '1+2*3'])
# print(args)  # 结果：Namespace(expression='1+2*3')

# 4. 业务逻辑处理
args.handle(args)
```

从上述示例可以看到，要实现子命令，对应地需要添加子解析器。然后最为关键的就是要定义参数，需要通过 `add_argument` 很明确地告诉 `argparse` 参数长什么样，需要怎么处理：

- 它是位置参数 `text`/`expression`，还是选项参数 `--lower`/`--upper`
- 若是选项参数，是否互斥
- 参数的是存成什么形式，比如 `action='store_true'` 表示存成布尔
- 子命令的响应函数

通过 `argparse` 实现的整个过程是很计算机思维的，且比较冗长。其优点是灵活，所有的功能都涵盖到了；但缺点则是将定义和处理割裂，尤其在程序功能复杂时会愈加凌乱和不直观，难以理解和维护。

## docopt

有人喜欢 `argparse` 这样命令式的写法，就会有人喜欢声明式的写法。而 [docopt](http://docopt.org/) 恰巧这就是这样一个命令行库。设计它的初衷就是对于熟悉命令行程序帮助信息的开发者来说，直接通过编写帮助信息来描述整个命令行参数定义的元信息会是更加简单快捷的方式。这种声明式的语法描述某种程度上会比过程式地定义参数来的更加简单和直观。

在 `docopt` 的世界中，需要：

- 定义接口描述/帮助信息，这一步是它的特色和重点
- 解析参数，获得一个字典
- 根据参数编写业务逻辑

以下示例是基于 `docopt` 的 `calc` 程序：

```python
# 1. 定义接口描述/帮助信息
"""Calculator Program.

Usage:
  calc echo [--lower | --upper] <text>
  calc eval <expression>

Commands:
  echo          Echo input text in multiple forms
  eval          Eval input expression and return result

Options:
  -h --help     Show help
  --lower       Lower input text
  --upper       Upper input text
"""
from docopt import docopt


def echo_text(args):
    if args['--lower']:
        print(args['<text>'].lower())
    elif args['--upper']:
        print(args['<text>'].upper())
    else:
        print(args['<text>'])


def eval_expression(args):
    print(eval(args['<expression>']))


# 2. 解析命令行
args = docopt(__doc__, argv=['echo', '--upper', 'Hello, World'])
# 结果：{'--lower': False, '--upper': True, '<expression>': None, '<text>': 'Hello, World', 'echo': True, 'eval': False}
print(args)

# 3. 业务逻辑
if args['echo']:
    echo_text(args)
elif args['eval']:
    eval_expression(args)
```

从上述示例可以看到，我们通过文档字符串 `__doc__` 定义了接口描述，这和 `argparse` 中 一系列参数定义的行为是等价的，然后 `docopt` 便会根据这个元信息把命令行参数转换为一个字典。业务逻辑中就需要对这个字典进行处理。

相比于 `argparse`：

- 对于较为复杂的命令，命令和参数元信息的定义上 `docopt` 会更加简单
- 在业务逻辑的处理上，`argparse` 在一些简单参数的处理上会更加便捷，且命令和处理函数之间可以方便路由（比如示例中的情形）；相对来说 `docopt` 转换为字典后就把所有处理交给业务逻辑的方式会更加复杂

## click

不论是 `argparse` 还是 `docopt`，元信息的定义和处理都是割裂开的。而命令行程序本质上是定义参数并对参数进行处理，而处理参数的逻辑一定是与所定义的参数有关联的。那可不可以用函数和装饰器来实现处理参数逻辑与定义参数的关联呢？[click](https://click.palletsprojects.com/en/7.x/) 正好就是以这种使用方式来设计的。

装饰器这样一个优雅的语法糖是元信息定义和处理逻辑之间的绝妙胶水，从而暗示了两者的路有关系。对比于前两个命令行库的路由实现着实优雅了不少。

在 `click` 的世界中：

- 通过装饰器定义命令和参数的元信息
- 使用此装饰器装饰处理函数

对，就是这么简单。

以下示例是基于 `click` 的 `calc` 程序：

```python
import sys
import click

sys.argv = ['calc', 'echo', '--upper', 'Hello, World']


@click.group(help='Calculator Program.')
def cli():
    pass

# 2. 定义参数
@cli.command(name='echo', help='Echo input text in multiple forms')
@click.argument('text')
@click.option('--lower', is_flag=True, help='Lower input text')
@click.option('--upper', is_flag=True, help='Upper input text')
# 1. 业务逻辑
def echo_text(text, lower, upper):
    if lower:
        print(text.lower())
    elif upper:
        print(text.upper())
    else:
        print(text)


@cli.command(name='eval', help='Eval input expression and return result')
@click.argument('expression')
def eval_expression(expression):
    print(eval(expression))


cli()
```

从上述示例可以看到，元信息定义和处理逻辑无缝绑定在一起，能够直观地看出对应的参数会如何处理，这个优势在有大量参数需要处理时显得尤为突出。在处理函数中，接收到不再是像 `argparse` 或 `docopt` 中的一个包含所有参数的变量，而是具体的参数变量，这让处理逻辑在参数使用上也变得更加简便。

此外，`click` 还内置了很多实用工具和增强能力，如参数自动补全、分页支持、颜色、进度条等功能，能够有效提升开发效率。

## fire

虽然前面三个库已经足够强大，但是仍然会有人认为不够简单。是否还有进一步简化的空间呢？如果只是定义函数，是否能让框架推测出参数元信息呢？理论上还真是可以。

[fire](https://github.com/google/python-fire) 用一种面向广义对象的方式来玩转命令行，这种对象可以是类、函数、字典、列表等，它更加灵活，也更加简单。你都不需要定义参数类型，`fire` 会根据输入和参数默认值来自动判断，这无疑进一步简化了实现过程。

在 `fire` 的世界中，定义 Python 对象就够了。

以下示例是基于 `fire` 的 `calc` 程序：

```python
import sys
import fire

sys.argv = ['calc', 'echo', '"Hello, World"', '--upper']

# 业务逻辑
# 类中有几个方法，就意味着命令行程序有几个同名命令
class Calc:
    # text 没有任何默认值，视为位置参数
    # lower/upper 有布尔类型的默认值，视为选项参数 --lower/--upper，
    # 且指定了为 True，不指定 False
    def echo(self, text, lower=False, upper=False):
        """Echo input text in multiple forms"""
        if lower:
            print(text.lower())
        elif upper:
            print(text.upper())
        else:
            print(text)

    def eval(self, expression):
        """Eval input expression and return result"""
        print(eval(expression))


fire.Fire(Calc)
```

从上面的示例可以看出，使用 `fire` 足够的简单，一切都是根据约定来进行推断，包括支持哪些命令，每个命令接受的什么参数和选项。这种方式可以说是足够的 Pythonic，相比于 `click`，`fire` 把命令行参数的定义和函数参数的定义融为了一体。通过它，我们真的就只用关注业务逻辑。

不过简单往往也意味着对于复杂需求的捉襟见肘。仅仅通过默认值来推导命令行参数所能表达的情况是有限的，比如互斥选项、位置参数的类型限定都无法通过框架来表达，而只能由业务逻辑去判断。

## typer

那么该如何在保持像 `fire` 这样简单实现的方式下，增强参数元信息的表达能力呢？既然默认参数的能力有限，那么如果使用 Python 3 的类型注解呢？

[typer](https://typer.tiangolo.com/) 站在 `click` 巨人的肩膀上，借助 Python 3 类型注解的特性，既满足了简单直观编写的需要，又达到了应对复杂场景的目的，可谓是现代化的命令行库。

在 `typer` 的世界中，也是直接编写业务逻辑，和 `fire` 稍稍不同的点是使用了类型注解和默认值来表达参数元信息定义。

以下示例是基于 `typer` 的 `calc` 程序：

```python
import sys
import typer

sys.argv = ['calc', 'echo', '"Hello, World"', '--upper']
cli = typer.Typer(help='Calculator Program.')


# 定义命令 echo，及处理函数
# text 无默认值，视为位置参数，类型为字符串
# lower/upper 类型为 bool，默认值为 False，视为选项 --lower/--upper，
# 且指定了为 True，不指定 False
@cli.command(name='echo')
def echo_text(text: str, lower: bool = False, upper: bool = False):
    """Echo input text in multiple forms"""
    if lower:
        print(text.lower())
    elif upper:
        print(text.upper())
    else:
        print(text)


# 定义命令 eval，及处理函数
# expression 无默认值，视为位置参数，类型为字符串
@cli.command(name='eval')
def eval_expression(expression: str):
    """Eval input expression and return result"""
    print(eval(expression))


cli()
```

从上面的示例可以看出，相比于 `click`，它免去了参数元信息的繁琐定义，取而代之的是类型注解；相比于 `fire`，它的元信息定义能力则大大增强，可以通过指定默认值为 `typer.Option` 或 `typer.Argument` 来进一步扩展参数和选项的语义。可以说是，`typer` 达到了简单与灵活的完美平衡。

## 横向对比

最后，我们横向对比下 `argparse`、`docopt`、`click`、`fire`、`typer` 库的各项功能和特点：

|                                                  | argpase                                                      | docopt                                          | click                                             | fire                       | typer                      |
| ------------------------------------------------ | :----------------------------------------------------------- | :---------------------------------------------- | :------------------------------------------------ | :------------------------- | :------------------------- |
| 使用步骤数                                       | 4 步                                                         | 3 步                                            | 2 步                                              | 1 步                       | 1 步                       |
| 使用步骤数                                       | 1. 设置解析器<br>2. 定义参数<br>3. 解析命令行<br>4. 业务逻辑 | 1. 定义接口描述<br>2. 解析命令行<br>3. 业务逻辑 | 1. 业务逻辑<br>2. 定义参数                        | 1. 业务逻辑                | 1 . 业务逻辑               |
| 选项参数<br>（如 `--sum`）                       | <font color=green>✔</font>                                   | <font color=green>✔</font>                      | <font color=green>✔</font>                        | <font color=green>✔</font> | <font color=green>✔</font> |
| 位置参数<br>（如 `X Y`）                         | <font color=green>✔</font>                                   | <font color=green>✔</font>                      | <font color=green>✔</font>                        | <font color=green>✔</font> | <font color=green>✔</font> |
| 参数默认值<br>                                   | <font color=green>✔</font>                                   | <font color=red>✘</font>                        | <font color=green>✔</font>                        | <font color=green>✔</font> | <font color=green>✔</font> |
| 互斥选项<br>（如 `--car` 和 `--bus` 只能二选一） | <font color=green>✔</font>                                   | <font color=green>✔</font>                      | <font color=yellow>✔</font><br>可通过第三方库支持 | <font color=red>✘</font>   | <font color=red>✘</font>   |
| 可变参数<br>（如指定多个 `--file`）              | <font color=green>✔</font>                                   | <font color=green>✔</font>                      | <font color=green>✔</font>                        | <font color=green>✔</font> | <font color=green>✔</font> |
| 嵌套/父子命令<br>                                | <font color=green>✔</font>                                   | <font color=green>✔</font>                      | <font color=green>✔</font>                        | <font color=green>✔</font> | <font color=green>✔</font> |
| 工具箱<br>                                       | <font color=red>✘</font>                                     | <font color=red>✘</font>                        | <font color=green>✔</font>                        | <font color=green>✔</font> | <font color=green>✔</font> |
| 链式命令调用<br>                                 | <font color=red>✘</font>                                     | <font color=red>✘</font>                        | <font color=red>✘</font>                          | <font color=green>✔</font> | <font color=red>✘</font>   |
| 类型约束                                         | <font color=green>✔</font>                                   | <font color=red>✘</font>                        | <font color=green>✔</font>                        | <font color=red>✘</font>   | <font color=green>✔</font> |

Python 的命令行库种类繁多、各具特色，它们并非是重复造轮子的产物，其背后的思想值得学习。结合横向对比的总结，可以选择出符合使用场景的库。如果几个库都符合，那么就选择你所偏爱的风格。

## 相关文章

- {% post_link Python-命令行之旅：初探-argparse %}
- {% post_link Python-命令行之旅：深入-argparse（一） %}
- {% post_link Python-命令行之旅：深入-argparse（二） %}
- {% post_link Python-命令行之旅：使用-argparse-实现-git-命令 %}
- {% post_link Python-命令行之旅：初探-docopt %}
- {% post_link Python-命令行之旅：深入-docopt %}
- {% post_link Python-命令行之旅：使用-docopt-实现-git-命令 %}
- {% post_link Python-命令行之旅：初探-click %}
- {% post_link Python-命令行之旅：深入-click（一） %}
- {% post_link Python-命令行之旅：深入-click（二） %}
- {% post_link Python-命令行之旅：深入-click（三） %}
- {% post_link Python-命令行之旅：深入-click（四） %}
- {% post_link Python-命令行之旅：使用-click-实现-git-命令 %}
- {% post_link Python-命令行之旅：初探-fire %}
- {% post_link Python-命令行之旅：深入-fire（一） %}
- {% post_link Python-命令行之旅：深入-fire（二） %}
- {% post_link Python-命令行之旅：使用-fire-实现-git-命令 %}
- {% post_link Python-命令行之旅：argparse、docopt、click-和-fire-总结篇 %}
- {% post_link Python-命令行大乱斗 %}

<div align=center>
![](/images/wechatPublicAccount.png)
</div>
