---
title: Python内存数据库/引擎
date: 2019-10-20 12:33:26
tags:
  - Python
  - 内存数据库
  - 内存数据引擎
categories:
  - 数据库
---

## 初探

（备注：本文是之前在博客园中发表的文章，因为老博客不再维护，把有价值的博文转移到这里。）

在平时的开发工作中，我们可能会有这样的需求：我们希望有一个内存数据库或者数据引擎，用比较 Pythonic 的方式进行数据库的操作（比如说插入和查询）。

举个具体的例子，分别向数据库 db 中插入两条数据，"a=1, b=1" 和 "a=1, b=2", 然后想查询 a=1 的数据可能会使用这样的语句 db.query(a=1)，结果就是返回前面插入的两条数据； 如果想查询 a=1, b=2 的数据，就使用这样的语句 db.query(a=1, b=2)，结果就返回前面的第二条数据。

<!--more-->

那么是否拥有实现上述需求的现成的第三方库呢？几经查找，发现 PyDbLite 能够满足这样的需求。其实，PyDbLite 和 Python 自带的 SQLite 均支持内存数据库模式，只是前者是 Pythonic 的用法，而后者则是典型的 SQL 用法。
他们具体的用法是这样的：

### PyDbLite

```python
import pydblite
# 使用内存数据库
pydb = pydblite.Base(':memory:')
# 创建a,b,c三个字段
pydb.create('a', 'b', 'c')
# 为字段a,b创建索引
pydb.create_index('a', 'b')
# 插入一条数据
pydb.insert(a=-1, b=0, c=1)
# 查询符合特定要求的数据
results = pydb(a=-1, b=0)
```

### SQLite

```python
import sqlite3
# 使用内存数据库
con = sqlite3.connect(':memory:')
# 创建a,b,c三个字段
cur = con.cursor()
cur.execute('create table test (a char(256), b char(256), c char(256));')
# 为字段a,b创建索引
cur.execute('create index a_index on test(a)')
cur.execute('create index b_index on test(b)')
# 插入一条数据
cur.execute('insert into test values(?, ?, ?)', (-1,0,1))
# 查询符合特定要求的数据
cur.execute('select * from test where a=? and b=?',(-1, 0))
```

## pydblite 和 sqlite 的性能

毫无疑问，pydblite 的使用方式非常地 Pythonic，但是它的效率如何呢？由于我们主要关心的是数据插入和查询速度，所以不妨仅对这两项做一个对比。写一个简单的测试脚本：

```python
import time
count = 100000

def timeit(func):
    def wrapper(*args, **kws):
        t = time.time()
        func(*args)
        print time.time() - t, kws['des']
    return wrapper

@timeit
def test_insert(mdb, des=''):
    for i in xrange(count):
        mdb.insert(a=i-1, b=i, c=i+1)

@timeit
def test_query_object(mdb, des=''):
    for i in xrange(count):
        c = mdb(a=i-1, b=i)

@timeit
def test_sqlite_insert(cur, des=''):
    for i in xrange(count):
        cur.execute('insert into test values(?, ?, ?)', (i-1, i, i+1))

@timeit
def test_sqlite_query(cur, des=''):
    for i in xrange(count):
        cur.execute('select * from test where a=? and b=?', (i-1, i))

print '-------pydblite--------'
import pydblite
pydb = pydblite.Base(':memory:')
pydb.create('a', 'b', 'c')
pydb.create_index('a', 'b')
test_insert(pydb, des='insert')
test_query_object(pydb, des='query, object call')


print '-------sqlite3--------'
import sqlite3
con = sqlite3.connect(':memory:')
cur = con.cursor()
cur.execute('create table test (a char(256), b char(256), c char(256));')
cur.execute('create index a_index on test(a)')
cur.execute('create index b_index on test(b)')
test_sqlite_insert(cur, des='insert')
test_sqlite_query(cur, des='query')
```

在创建索引的情况下，10w 次的插入和查询的时间如下：

```bash
-------pydblite--------
1.14199995995 insert
0.308000087738 query, object call
-------sqlite3--------
0.411999940872 insert
0.30999994278 query
```

在未创建索引的情况（把创建索引的测试语句注释掉）下，1w 次的插入和查询时间如下：

```bash
-------pydblite--------
0.0989999771118 insert
5.15300011635 query, object call
-------sqlite3--------
0.0169999599457 insert
7.43400001526 query
```

我们不难得出如下结论：

sqlite 的插入速度是 pydblite 的 3-5 倍；而在建立索引的情况下，sqlite 的查询速度和 pydblite 相当；在未建立索引的情况下，sqlite 的查询速度比 pydblite 慢 1.5 倍左右。

## 优化

我们的目标非常明确，使用 Pythonic 的内存数据库，提高插入和查询效率，而不考虑持久化。那么能否既拥有 pydblite 的 pythonic 的使用方式，又同时具备 pydblite 和 sqlite 中插入和查询速度快的那一方的速度？针对我们的目标，看看能否对 pydblite 做一些优化。

阅读 pydblite 的源码，首先映入眼帘的是对 python2 和 3 做了一个简单的区分。给外部调用的 Base 基于\_BasePy2 或者\_BasePy3，它们仅仅是在**iter**上有细微差异，最终调用的是\_Base 这个类。

```python
class _BasePy2(_Base):

    def __iter__(self):
        """Iteration on the records"""
        return iter(self.records.itervalues())


class _BasePy3(_Base):

    def __iter__(self):
        """Iteration on the records"""
        return iter(self.records.values())

if sys.version_info[0] == 2:
    Base = _BasePy2
else:
    Base = _BasePy3
```

然后看下\_Base 的构造函数，做了简单的初始化文件的操作，由于我们就是使用内存数据库，所以文件相关的内容完全可以抛弃。

```python
class _Base(object):

    def __init__(self, path, protocol=pickle.HIGHEST_PROTOCOL, save_to_file=True,
                 sqlite_compat=False):
        """protocol as defined in pickle / pickle.
        Defaults to the highest protocol available.
        For maximum compatibility use protocol = 0

        """
        self.path = path
        """The path of the database in the file system"""
        self.name = os.path.splitext(os.path.basename(path))[0]
        """The basename of the path, stripped of its extension"""
        self.protocol = protocol
        self.mode = None
        if path == ":memory:":
            save_to_file = False
        self.save_to_file = save_to_file
        self.sqlite_compat = sqlite_compat
        self.fields = []
        """The list of the fields (does not include the internal
        fields __id__ and __version__)"""
        # if base exists, get field names
        if save_to_file and self.exists():
            if protocol == 0:
                _in = open(self.path)  # don't specify binary mode !
            else:
                _in = open(self.path, 'rb')
            self.fields = pickle.load(_in)
```

紧接着比较重要的是 create（创建字段）、create_index（创建索引）两个函数：

```python
    def create(self, *fields, **kw):
        """
        Create a new base with specified field names.

        Args:
            - \*fields (str): The field names to create.
            - mode (str): the mode used when creating the database.

        - if mode = 'create' : create a new base (the default value)
        - if mode = 'open' : open the existing base, ignore the fields
        - if mode = 'override' : erase the existing base and create a
          new one with the specified fields

        Returns:
            - the database (self).
        """
        self.mode = kw.get("mode", 'create')
        if self.save_to_file and os.path.exists(self.path):
            if not os.path.isfile(self.path):
                raise IOError("%s exists and is not a file" % self.path)
            elif self.mode is 'create':
                raise IOError("Base %s already exists" % self.path)
            elif self.mode == "open":
                return self.open()
            elif self.mode == "override":
                os.remove(self.path)
            else:
                raise ValueError("Invalid value given for 'open': '%s'" % open)

        self.fields = []
        self.default_values = {}
        for field in fields:
            if type(field) is dict:
                self.fields.append(field["name"])
                self.default_values[field["name"]] = field.get("default", None)
            elif type(field) is tuple:
                self.fields.append(field[0])
                self.default_values[field[0]] = field[1]
            else:
                self.fields.append(field)
                self.default_values[field] = None

        self.records = {}
        self.next_id = 0
        self.indices = {}
        self.commit()
        return self

    def create_index(self, *fields):
        """
        Create an index on the specified field names

        An index on a field is a mapping between the values taken by the field
        and the sorted list of the ids of the records whose field is equal to
        this value

        For each indexed field, an attribute of self is created, an instance
        of the class Index (see above). Its name it the field name, with the
        prefix _ to avoid name conflicts

        Args:
            - fields (list): the fields to index
        """
        reset = False
        for f in fields:
            if f not in self.fields:
                raise NameError("%s is not a field name %s" % (f, self.fields))
            # initialize the indices
            if self.mode == "open" and f in self.indices:
                continue
            reset = True
            self.indices[f] = {}
            for _id, record in self.records.items():
                # use bisect to quickly insert the id in the list
                bisect.insort(self.indices[f].setdefault(record[f], []), _id)
            # create a new attribute of self, used to find the records
            # by this index
            setattr(self, '_' + f, Index(self, f))
        if reset:
            self.commit()
```

可以看出，pydblite 在内存中维护了一个名为 records 的字典变量，用来存放一条条的数据。它的 key 是内部维护的 id，从 0 开始自增；而它的 value 则是用户插入的数据，为了后续查询和记录的方便，这里在每条数据中额外又加入了**id**和**version**。其次，内部维护的 indices 字典变量则是是个索引表，它的 key 是字段名，而 value 则是这样一个字典：其 key 是这个字段所有已知的值，value 是这个值所在的那条数据的 id。

举个例子，假设我们插入了“a=-1,b=0,c=1”和“a=0,b=1,c=2”两条数据，那么 records 和 indices 的内容会是这样的：

```python
# records
{0: {'__id__': 0, '__version__': 0, 'a': -1, 'b': 0, 'c': 1},
 1: {'__id__': 1, '__version__': 0, 'a': 0, 'b': 1, 'c': 2}}

# indices
{'a': {-1: [0], 0: [1]}, 'b': {0: [0], 1: [1]}}
```

比方说现在我们想查找 a=0 的数据，那么就会在 indices 中找 key 为'a'的 value，即{-1: set([0]), 0: set([1])}，然后在这里面找 key 为 0 的 value，即[1]，由此我们直到了我们想要的这条数据它的 id 是 1（也可能会有多个）；假设我们对数据还有其他要求比如 a=0,b=1，那么它会继续上述的查找过程，找到 a=0 和 b=1 分别对应的 ids，做交集，就得到了满足这两个条件的 ids，然后再到 records 里根据 ids 找到所有对应的数据。

明白了原理，我们再看看有什么可优化的地方：

数据结构，整体的 records 和 indeices 数据结构已经挺精简了，暂时不需要优化。其中的**version**可以不要，因为我们并不关注这个数据被修改了几次。其次是由于 indices 中最终的 ids 是个 list，在查询和插入的时候会比较慢，我们知道内部维护的 id 一定是唯一的，所以这里改成 set 会好一些。

python 语句，不难看出，整个\_Base 为了同时兼容 python2 和 python3，不得不使用了 2 和 3 都支持的语句，这就导致在部分语句上针对特定版本的 python 就会造成浪费或者说是性能开销。比如说，d 是个字典，那么为了同事兼容 python2 和 3，作者使用了类似与 for key in d.keys()这样的语句，在 python2 中，d.keys()会首先产生一个 list，用 d.iterkeys 是个更明智的方案。再如，作者会使用类似 set(d.keys()) - set([1])这样的语句，但是 python2 中，使用 d.viewkeys() - set([1])效率将会更高，因为它不需要将 list 转化成 set。

对特定版本 python 的优化语句就不一一举例，概括地说，从数据结构，python 语句以及是否需要某些功能等方面可以对 pydblite 做进一步的优化。前面只是说了 create 和 create_index 两个函数，包括 insert 和**call**的优化也十分类似。此外，用普通方法来代替魔法方法，也能稍微提升下效率，所以在后续的优化中将**call**改写为了 query。

优化后的代码，请见 MemLite。

## memlite、pydblite 和 sqlite 的性能

让我们在上文的测试代码中加入对 memlite 的测试：

```python
@timeit
def test_query_method(mdb, des=''):
    for i in xrange(count):
        c = mdb.query(a=i-1, b=i)

print '-------memlite-------'
import memlite
db = memlite.Base()
db.create('a', 'b', 'c')
db.create_index('a', 'b')
test_insert(db, des='insert')
test_query_method(db, des='query, method call')
```

在创建索引的情况下，10w 次的插入和查询的时间如下：

```bash
-------memlite-------
0.378000020981 insert
0.285000085831 query, method call
-------pydblite--------
1.3140001297 insert
0.309000015259 query, object call
-------sqlite3--------
0.414000034332 insert
0.3109998703 query
```

在未创建索引的情况（把创建索引的测试语句注释掉）下，1w 次的插入和查询时间如下：

```bash
-------memlite-------
0.0179998874664 insert
5.90199995041 query, method call
-------pydblite--------
0.0980000495911 insert
4.87400007248 query, object call
-------sqlite3--------
0.0170001983643 insert
7.42399978638 query
```

可以看出，在创建索引的情况下，memlite 的插入和查询性能在 sqlite 和 pydblite 之上；而在未创建索引的情况下，memlite 的插入性能和 sqlite 一样，好于 pydblite，memlite 的查询性能比 pydblite 稍差，但好于 sqlite。综合来看，memlite 即拥有 pydblite 的 pythonic 的使用方式，又拥有 pydblite 和 sqlite 中性能较高者的效率，符合预期的优化目标。

<div align=center>
![](/images/wechatPublicAccount.png)
</div>
