---
title: 使用 Python 玩转 WMI
date: 2019-10-20 12:42:03
tags:
  - Python
  - Windows
  - WMI
categories:
  - Windows
  - WMI
---

（备注：本文是之前在博客园中发表的文章，因为老博客不再维护，把有价值的博文转移到这里。）

最近在网上搜索 Python 和 WMI 相关资料时，发现大部分文章都千篇一律，并且基本上只说了很基础的使用，并未深入说明如何使用 WMI。本文打算更进一步，让我们使用 Python 玩转 WMI。

<!--more-->

## 什么是 WMI

具体请看微软官网对 [WMI](https://docs.microsoft.com/zh-cn/windows/win32/wmisdk/wmi-start-page) 的介绍。这里简单说明下，WMI 的全称是 Windows Management Instrumentation，即 Windows 管理规范。它是 Windows 操作系统上管理数据和操作的基础设施。我们可以使用 WMI 脚本或者应用自动化管理任务等。

从 [Using WMI](https://docs.microsoft.com/zh-cn/windows/win32/wmisdk/using-wmi) 可以知道 WMI 支持如下语言：

| Application language                                                                                              |                                                                                                                                                                                                                                                 Topic                                                                                                                                                                                                                                                 |
| ----------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| Scripts written in Microsoft ActiveX script hosting, including Visual Basic Scripting Edition (VBScript) and Perl | [Scripting API for WMI](https://docs.microsoft.com/zh-cn/windows/win32/wmisdk/scripting-api-for-wmi).<br/>Start with [Creating a WMI Script](https://docs.microsoft.com/zh-cn/windows/win32/wmisdk/creating-a-wmi-script).<br/>For script code examples, see [WMI Tasks for Scripts and Applications](https://docs.microsoft.com/zh-cn/windows/win32/wmisdk/wmi-tasks-for-scripts-and-applications) and the TechNet [ScriptCenter](http://go.microsoft.com/fwlink/p/?linkid=46710) Script Repository. |
| Windows PowerShell                                                                                                |                                                                                            [Getting Started with Windows PowerShell](https://docs.microsoft.com/zh-cn/powershell/scripting/getting-started/getting-started-with-windows-powershell?view=powershell-6)<br/>WMI PowerShell Cmdlets, such as [Get-WmiObject](https://docs.microsoft.com/en-us/previous-versions//dd315295%28v=technet.10%29).                                                                                            |
| Visual Basic applications                                                                                         |                                                                                                                                                                                                 [Scripting API for WMI](https://docs.microsoft.com/zh-cn/windows/win32/wmisdk/scripting-api-for-wmi).                                                                                                                                                                                                 |
| Active Server Pages                                                                                               |                                                                                                                       [Scripting API for WMI](https://docs.microsoft.com/zh-cn/windows/win32/wmisdk/scripting-api-for-wmi).<br/>Start with [Creating Active Server Pages for WMI](https://docs.microsoft.com/zh-cn/windows/win32/wmisdk/creating-active-server-pages-for-wmi).                                                                                                                        |
| C++ applications                                                                                                  |                                                        [COM API for WMI](https://docs.microsoft.com/zh-cn/windows/win32/wmisdk/com-api-for-wmi).<br/>Start with [Creating a WMI Application Using C++](https://docs.microsoft.com/zh-cn/windows/win32/wmisdk/creating-a-wmi-application-using-c-) and [WMI C++ Application Examples](https://docs.microsoft.com/zh-cn/windows/win32/wmisdk/wmi-c---application-examples) (contains examples).                                                         |
| .NET Framework applications written in C#, Visual Basic .NET, or J#                                               |                                                                                     Classes in the [Microsoft.Management.Infrastructure](https://docs.microsoft.com/en-us/previous-versions//hh872326%28v=vs.85%29) namespace. (The System.Management namespace is no longer supported). For more information, see [WMI .NET Overview](https://docs.microsoft.com/en-us/previous-versions/bb404655%28v=vs.90%29).                                                                                     |

很遗憾，WMI 并不原生支持 Python。不过没有关系，它支持 VB，而 Python 中的两个第三方库 wmi 和 win32com，均能以类似 VB 的用法来使用。那么接下来，我们来讲讲如何使用。

## 使用 WMI

### 使用 wmi 库操作 WMI

以下是一个遍历所有进程，所有服务的示例：

```python
import wmi
c = wmi.WMI ()
# 遍历进程
for process in c.Win32_Process ():
    print process.ProcessId, process.Name

# 遍历服务
for service in c.Win32_Service ():
    print service.ProcessId, service.Name
```

可以看到，使用起来非常简单。但是有两个问题：一是 wmi 库实在是太慢了，能不能快点？二是如何知道例子中 process 和 service 有哪些属性（比如 ProcessId 等）？由于 wmi 库是动态生成底层执行语句，用 dir(process)这种方式是获取不到 ProcessId 这种属性的。

针对第一个问题，我们可以使用 win32com 这个库来解决，它相较于 wmi 的速度快了很多。而第二个问题，先卖个关子，后文会有介绍。

### 使用 win32com 库操作 WMI

win32com 能模仿 VB 的行为，想了解如何使用 win32com 来操作 WMI，最直接的方式是了解如何使用 VB 来操作 WMI。在微软的官网上提供了很多现成的例子：WMI Tasks: Processes， WMI Tasks: Services。

其中一个例子关于进程是这样的：

```vb
strComputer = "."
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colProcesses = objWMIService.ExecQuery("Select * from Win32_Process")
For Each objProcess in colProcesses

    Wscript.Echo "Process: " & objProcess.Name
    sngProcessTime = (CSng(objProcess.KernelModeTime) + CSng(objProcess.UserModeTime)) / 10000000
    Wscript.Echo "Processor Time: " & sngProcessTime
    Wscript.Echo "Process ID: " & objProcess.ProcessID
    Wscript.Echo "Working Set Size: " & objProcess.WorkingSetSize
    Wscript.Echo "Page File Size: " & objProcess.PageFileUsage
    Wscript.Echo "Page Faults: " & objProcess.PageFaults
Next
```

它做了这样一件事：首先通过 GetObject 连接到 Win32_Process 所在的名称空间，然后执行 WQL 语句（类似 SQL 的查询语句）查到所有的进程，再把每一个进程的相关信息打印出来。WQL 的具体用法请见官网，这里不详细介绍。

那么用 win32com 就可以这么写（例子中打印的属性为了简便，就不像上面那么多啦）：

```python
from win32com.client import GetObject

wmi = GetObject('winmgmts:/root/cimv2')
# wmi = GetObject('winmgmts:') #更简单的写法
processes = wmi.ExecQuery('Select * from Win32_Process')
for process in processes:
    print(process.ProcessID, process.Name)
```

看上去，VB 和 win32com 的用法非常接近！那么当我们想要使用 win32com 对 WMI 进行操作时，就可以参考微软官网上 VB 的例子，然后比葫芦画瓢写出 Python 版的代码。

上例中，我们使用了查询函数 ExecQuery 来查询符合条件的内容，不过如果我们仅仅是想要获得所有的数据，而没有特定的限定条件，就可以使用更简单的方式——InstancesOf，那么就可以写成下面这样：

```python
from win32com.client import GetObject

wmi = GetObject('winmgmts:/root/cimv2')
processes = wmi.InstancesOf('Win32_Process')
for process in processes:
    print(process.ProcessID, process.Name)
```

有读者可能会问，我们怎么知道自己想要了解的内容在哪个名称空间，我们应该获取哪个实例，又该获取实例中的哪些属性呢？

## WMI 的名称空间

使用下面的脚本可以获得当前计算机上的名称空间：

```python
from win32com.client import GetObject
import pywintypes

def enum_namespace(name):
    try:
        wmi = GetObject('winmgmts:/' + name)
        namespaces = wmi.InstancesOf('__Namespace')
        for namespace in namespaces:
            enum_namespace('{name}/{subname}'.format(name=name,
                                                     subname=namespace.Name))
    except pywintypes.com_error:
        print(name, 'limit of authority')
    else:
        print(name)
enum_namespace('root')
```

获得的内容大概是这样的(...表示省略了一些输出内容)：

```bash
root
root/subscription
root/subscription/ms_409
root/DEFAULT
root/DEFAULT/ms_409
root/CIMV2
root/CIMV2/Security
...
root/Cli
root/Cli/MS_409
root/SECURITY
...
root/WMI
root/WMI/ms_409
root/directory
root/directory/LDAP
root/directory/LDAP/ms_409
root/Interop
root/Interop/ms_409
root/ServiceModel
root/SecurityCenter
root/MSAPPS12
root/Microsoft
...
```

通用的名称空间的简单介绍：

root 是名称空间层次结构的最高级。

CIMV2 名称空间存放着和系统管理域相关（比如计算机以及它们的操作系统）的对象。

DEFAULT 名称空间存放着默认被创建而不指定名称空间的类。

directory 目录服务的通用名称空间，WMI 创建了名为 LDAP 的子名称空间。

SECURITY 用来支持 Windows 9x 计算机上的 WMI 的名称空间。

WMI 使用 Windows Driver Model providers 的类所在的名称空间。这是为了避免和 CIMV2 名称空间中类名冲突。

其中，root/CIMV2 可以说是最为基本和常用的名称空间了。它的作用主要是提供关于计算机、磁盘、外围设备、文件、文件夹、文件系统、网络组件、操作系统、打印机、进程、安全性、服务、共享、SAM 用户及组，以及更多资源的信息；管理 Windows 事件日志，如读取、备份、清除、复制、删除、监视、重命名、压缩、解压缩和更改事件日志设置。

## 类/实例和属性/值

了解了名称空间的获取，每个名称空间的主要功能，那么如何获取特定名称空间下所有的类，以及它们的属性和值呢？

Windows 提供了一个 WMI 测试器，使得查询这些内容变得尤为方便。按下"win+R"，输入 wbemtest，从而打开 WMI 测试器。打开后的界面如下：

{% asset_img 1.png %}

点击“连接”，输入想要查询的名称空间，再点击“连接”即可连到特定名称空间。

然后点击“枚举类”，在弹出的界面中选择“递归”，然后点击“确定”，就会得到这个名称空间下所有的类：

{% asset_img 2.png %}
{% asset_img 3.png %}

从上图可以看到，之前举例中提到的 Win32_Process 位列其中，我们不妨双击它，看看关于它的具体内容：

{% asset_img 4.png %}

我们可以很容易地找到 Win32_Process 的属性和方法。除了使用 wbemtest 查看特定名称空间下的所有类，我们还可以在 WMI/MI/OMI Providers 中找到所有的类。我们依次在这个页面中点击 CIMWin32, Win32, Power Management Events，Win32 Provider，Operating System Classes，Win32_Process 最终找到 Win32_Process 的属性和方法：

{% asset_img 5.png %}

对比上面两张图，里面的方法都是一致的。

那么如何获得实例和它的值呢？我们继续在刚刚打开的 wbemtest 界面中点击右边的“实例”按钮，就会显示所有的进程实例。双击某个具体的实例，然后在弹出的界面中点击右侧的“显示 MOF”按钮就会显示这个实例中具体属性的值。

{% asset_img 6.png %}
{% asset_img 7.png %}

通过上述定位名称空间、类、属性的方法，我们就可以愉快地使用 Python 来玩耍 WMI。

## 实战，以 IIS 为例

了解了这么多内容，咱们就拿个对象练练手。现在有这么个需求，我们想要获取 IIS 的版本号以及它所有的站点名称，怎么办？

在微软官网上比较容易的找到 IIS WMI 的说明，根据直觉，我们要查询的信息可能会是在类名中包含 setting 的类中，那么看起来比较有可能的有 IIsSetting (WMI), IIsWebServerSetting (WMI), IIsWebInfoSetting (WMI)。

对这些类都分别看一看，发现 IIsSetting 中提供了一个例子：

```vb
o = getobj("winmgmts:/root/microsoftiisv2")
nodes = o.ExecQuery("select * from IIsWebServerSetting where name='w3svc/1'")
e = new Enumerator(nodes)
for(; ! e.atEnd(); e.moveNext()) {
  WScript.Echo(e.item().Name + " (" + e.item().Path_.Class + ")")
}
// The output should be:
//   w3svc/1 (IIsWebServerSetting)

nodes = o.ExecQuery("select * from
IIsSetting where name='w3svc/1'")
e = new Enumerator(nodes)
for(; ! e.atEnd(); e.moveNext()) {
  WScript.Echo(e.item().Name + " (" + e.item().Path_.Class + ")")
}
// The output should be:
//   w3svc/1 (IIsIPSecuritySetting)
//   w3svc/1 (IIsWebServerSetting)
```

从这个例子中，我们可以知道 iis 的名称空间是‘/root/microsoftiisv2’，然后我们可以直接在这个空间中查询各种相关类，比如说“IIsWebServerSetting”。

结合 wbemtest 和 IIS 管理器，我们可以看出 IIsWebServerSetting 实例中的 ServerComment 属性值和网站名称一致：

{% asset_img 8.png %}

而版本信息则在类名包含 setting 的类中无法找到，那再去类名包含 info 的类中瞧一瞧。果然，在 IIsWebInfo (WMI)中找到了 MajorIIsVersionNumber 和 MinorIIsVersionNumber 属性，分别表示大版本和小版本。那么我们就能比较轻松地写出下面的 Python 代码来获得版本和站点名称：

```python
# coding:utf-8
from win32com.client import GetObject

wmi = GetObject('winmgmts:/root/microsoftiisv2')
# 版本
webinfo = wmi.execquery('select * from IIsWebInfo ')[0]
version = '{major}.{min}'.format(major=webinfo.MajorIIsVersionNumber,
                                 min=webinfo.MinorIIsVersionNumber)
print(version)

# 站点名称
websettings = wmi.execquery('select * from IIsWebServerSetting ')
websites = ' | '.join(setting.ServerComment for setting in websettings)
print(websites)
```

## 总结

使用 Python 操作 WMI，最大的难点并不在于如何编写 Python 语句，而在于如果获知想要查询的内容在哪个名称空间以及对应的类和属性。而这些内容则需要查阅官方文档以及使用 wbemtest 进行探索。获得了这些必要的信息后，再去编写 Python 代码就是一件非常轻松的事情。

<div align=center>
![](/images/wechatPublicAccount.png)
</div>