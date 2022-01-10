# Python3

## 1 开始 Python 之旅

python 解释器，第一行 `#! /usr/bin/env python3` 是告诉 shell 使用 Python 解释器执行代码，赋予执行权限后可以使用 `./` 的方式运行 py 文件，否则应该使用 `python3 x.py` 命令。

建议遵守以下约定：

- 使用 4 个空格来缩进
- 永远不要混用空格和制表符
- 在函数之间空一行
- 在类之间空两行
- 字典，列表，元组以及参数列表中，在 `,` 后添加一个空格。对于字典，`:` 后面也添加一个空格
- 在赋值运算符和比较运算符周围要有空格（参数列表中除外），但是括号里则不加空格：`a = f(1, 2) + g(3, 4)`

## 2 变量和数据类型

可以通过如下指令获取关键字：

```shell
$ python3
$ help()
$ keywords
```

```python
# keywords
False               def                 if                  raise
None                del                 import              return
True                elif                in                  try
and                 else                is                  while
as                  except              lambda              with
assert              finally             nonlocal            yield
break               for                 not
class               from                or
continue            global              pass
```

```python
#!/usr/bin/env python3
amount = float(input("Enter amount: "))  # 输入数额
inrate = float(input("Enter Interest rate: "))  # 输入利率
period = int(input("Enter period: "))  # 输入期限
value = 0
year = 1
while year <= period:
    value = amount + (inrate * amount)
    # 字符串格式化，大括号和其中的字符会被替换成传入 str.format() 的参数，也即 year 和 value。
    # {:.2f} 的意思是替换为 2 位精度的浮点数。
    print("Year {} Rs. {:.2f}".format(year, value))
    amount = value
    year = year + 1
```

用逗号创建元组，在赋值语句的右边创建一个元组，成为**元组封装（_tuple packing_）**，赋值语句的左边是**元组拆封 （_tuple unpacking_）**。

## 3 运算符和表达式

`divmod(num1, num2)` 返回一个元组，这个元组包含两个值，第一个是 num1 和 num2 相整除得到的值，第二个是 num1 和 num2 求余得到的值，然后我们用 `*` 运算符拆封这个元组，得到这两个值。

```python
#!/usr/bin/env python3
days = int(input("Enter days: "))
print("Months = {} Days = {}".format(*divmod(days, 30)))
```

**关系运算符**

| Operator | Meaning                     |
| -------- | --------------------------- |
| <        | Is less than                |
| <=       | Is less than or equal to    |
| >        | Is greater than             |
| >=       | Is greater than or equal to |
| ==       | Is equal to                 |
| !=       | Is not equal to             |

**逻辑运算符**

逻辑运算符的优先级又低于关系运算符，在它们之中，`not` 具有最高的优先级，`or` 优先级最低，所以 `A and not B or C` 等于 `(A and (notB)) or C`。当然，括号也可以用于比较表达式。

```python
>>> 5 and 4   # 首先判断5，肯定为true，那么最终的结果就取决于 and 后面那个的布尔值，4 的布尔值为 true，这样就可以确定整个表达式的值为 true 了，所以返回 4
4
>>> 0 and 4   # 首先判断0，因为 0 的布尔值为 false，那么不管 and 后面那个的布尔值是什么，整个表达式的布尔值都应该为 false 了，这个时候就不需要判断 4 了，直接返回最先确定结果的那个数也就是0
0
>>> False or 3 or 0
3
>>> 2 > 1 and not 3 > 5 or 4
True
```

**类型转换**

| 类型转换函数    | 转换路径         |
| --------------- | ---------------- |
| `float(string)` | 字符串 -> 浮点值 |
| `int(string)`   | 字符串 -> 整数值 |
| `str(integer)`  | 整数值 -> 字符串 |
| `str(float)`    | 浮点值 -> 字符串 |

## 4 if-else

`elif` 是 `else if` 的缩写。

## 5 循环

默认情况下，`print()` 除了打印提供的字符串之外，还会打印一个换行符，所以每调用一次 `print()` 就会换一次行。可以通过 `print()` 的另一个参数 `end` 来替换这个换行符。

```python
#!/usr/bin/env python3
a, b = 0, 1
while b < 100:
    print(b, end=' ')
    a, b = b, a + b
print()
```

**列表**

列表可以写作中括号之间的一列逗号分隔的值。列表的元素不必是同一类型：

```python
>>> a = [ 1, 342, 223, 'India', 'Fedora']
>>> a
[1, 342, 223, 'India', 'Fedora']
```

对于列表，这里的编号称为索引。通过索引来访问列表中的每一个值：

```python
>>> a[0]
1
>>> a[4]
'Fedora'
```

如果使用负数的索引，那将会从列表的末尾开始计数，像下面这样：

```python
>>> a[-1]
'Fedora'
```

可以把它切成不同的部分，这个操作称为切片，例子在下面给出：

```python
>>> a[0:-1]
[1, 342, 223, 'India']
>>> a[2:-2]
[223]
```

**切片并不会改变正在操作的列表**，切片操作返回其子列表，这意味着下面的切片操作返回列表一个新的（栈）拷贝副本：

```python
>>> a[:]
[1, 342, 223, 'India', 'Fedora']
```

切片的索引有非常有用的默认值；省略的第一个索引默认为零，省略的第二个索引默认为切片的索引的大小。如果是字符串，则为字符串大小。

```python
>>> a[:-2]
[1, 342, 223]
>>> a[-2:]
['India', 'Fedora']
```

**Python 中有关下标的集合都满足左闭右开原则**，切片中也是如此，也就是说集合左边界值能取到，右边界值不能取到。

对上面的列表， `a[0:5]` 用数学表达式可以写为 `[0,5)` ，其索引取值为 `0,1,2,3,4`，所以能将`a`中所有值获取到。 也可以用`a[:5]`, 效果是一样的。

而`a[-5:-1]`，因为左闭右开原则，其取值为 `-5,-4,-3,-2` 是不包含 `-1` 的。

为了取到最后一个值，你可以使用 `a[-5:]` ，它代表了取该列表最后 5 个值。

试图使用太大的索引会导致错误：

```python
>>> a[32]
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
IndexError: list index out of range
>>> a[-10]
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
IndexError: list index out of range
```

Python 能够优雅地处理那些没有意义的切片索引：一个过大的索引值(即大于列表实际长度)将被列表实际长度所代替，当上边界比下边界大时(即切片左值大于右值)就返回空列表:

```python
>>> a[2:32]
[223, 'India', 'Fedora']
>>> a[32:]
[]
```

切片操作还可以设置步长，就像下面这样：

```python
>>> a[1::2]
[342, 'India']
```

它的意思是，从切片索引 1 到列表末尾，每隔两个元素取值。

列表也支持连接这样的操作，它返回一个新的列表：

```python
>>> a + [36, 49, 64, 81, 100]
[1, 342, 223, 'India', 'Fedora', 36, 49, 64, 81, 100]
```

列表允许修改元素：

```python
>>> cubes = [1, 8, 27, 65, 125]
>>> cubes[3] = 64
>>> cubes
[1, 8, 27, 64, 125]
```

也可以对切片赋值，此操作可以改变列表的尺寸，或清空它：

```python
>>> letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g']
>>> letters
['a', 'b', 'c', 'd', 'e', 'f', 'g']
>>> # 替换某些值
>>> letters[2:5] = ['C', 'D', 'E']
>>> letters
['a', 'b', 'C', 'D', 'E', 'f', 'g']
>>> # 现在移除他们
>>> letters[2:5] = []
>>> letters
['a', 'b', 'f', 'g']
>>> # 通过替换所有元素为空列表来清空这个列表
>>> letters[:] = []
>>> letters
[]
```

严格来说，这里并不算真正的切片操作，只是上面代码中赋值运算符左边的这种操作与切片操作形式一样而已。

要检查某个值是否存在于列表中，可以这样做：

```python
>>> a = ['dafa', 'is', 'cool']
>>> 'cool' in a
True
>>> 'Linux' in a
False
```

这意味着我们可以将上面的语句使用在 `if` 子句中的表达式。通过内建函数 `len()` 我们可以获得列表的长度：

```python
>>> len(a)
3
```

如果你想要检查列表是否为空，请这样做：

```python
if list_name: # 列表不为空
    pass
else: # 列表为空
    pass
```

列表是允许嵌套的（创建一个包含其它列表的列表），例如：

```python
>>> a = ['a', 'b', 'c']
>>> n = [1, 2, 3]
>>> x = [a, n]
>>> x
[['a', 'b', 'c'], [1, 2, 3]]
>>> x[0]
['a', 'b', 'c']
>>> x[0][1]
'b'
```

**range()**

如果需要一个数值序列，内置函数  [range()](https://docs.python.org/3/library/stdtypes.html#range) 会很方便，它生成一个等差数列（并不是列表）。

```python
>>> for i in range(5):
...     print(i)
...
0
1
2
3
4
>>> range(1, 5)
range(1, 5)
>>> list(range(1, 5))
[1, 2, 3, 4]
>>> list(range(1, 15, 3))
[1, 4, 7, 10, 13]
>>> list(range(4, 15, 2))
[4, 6, 8, 10, 12, 14]
```

## 6 数据结构

主要介绍四种：列表、元组、集合和字典。

### 6.1 列表

```python
>>> a = [23, 45, 1, -3434, 43624356, 234]
>>> a.append(45)
>>> a
[23, 45, 1, -3434, 43624356, 234, 45]
```

首先建立了一个列表 `a`。然后调用列表的方法 `a.append(45)` 添加元素 `45` 到列表末尾。可以看到元素 45 已经添加到列表的末端了。有些时候我们需要将数据插入到列表的任何位置，这时我们可以使用列表的 `insert()` 方法。

```python
>>> a.insert(0, 1) # 在列表索引 0 位置添加元素 1
>>> a
[1, 23, 45, 1, -3434, 43624356, 234, 45]
>>> a.insert(0, 111) # 在列表索引 0 位置添加元素 111
>>> a
[111, 1, 23, 45, 1, -3434, 43624356, 234, 45]
```

列表方法 `count(s)` 会返回列表元素中 `s` 的数量。检查一下 `45` 这个元素在列表中出现了多少次。

```python
>>> a.count(45)
2
```

要在列表中移除任意指定值，需要使用 `remove()` 方法。

```python
>>> a.remove(234)
>>> a
[111, 1, 23, 45, 1, -3434, 43624356, 45]
```

现在我们反转整个列表。

```python
>>> a.reverse()
>>> a
[45, 43624356, -3434, 1, 45, 23, 1, 111]
```

怎样将一个列表的所有元素添加到另一个列表的末尾呢，可以使用列表的 `extend()` 方法。

```python
>>> b = [45, 56, 90]
>>> a.extend(b) # 添加 b 的元素而不是 b 本身
>>> a
[45, 43624356, -3434, 1, 45, 23, 1, 111, 45, 56, 90]
```

给列表排序，使用列表的 `sort()` 方法，排序的前提是列表的元素是可比较的。

```python
>>> a.sort()
>>> a
[-3434, 1, 1, 23, 45, 45, 45, 56, 90, 111, 43624356]
```

使用 `del` 关键字删除指定位置的列表元素。

```python
>>> del a[-1]
>>> a
[-3434, 1, 1, 23, 45, 45, 45, 56, 90, 111]
```

传入一个参数 i 即 `pop(i)` 会将第 i 个元素弹出。

```python
>>> a = [1, 2, 3, 4, 5]
>>> a.append(1)
>>> a
[1, 2, 3, 4, 5, 1]
>>> a.pop(0)
1
>>> a.pop(0)
2
>>> a
[3, 4, 5, 1]
```

**列表推倒式**

列表推导式为从序列中创建列表提供了一个简单的方法。如果没有列表推导式，一般都是这样创建列表的：通过将一些操作应用于序列的每个成员并通过返回的元素创建列表，或者通过满足特定条件的元素创建子序列。

假设创建一个 squares 列表，可以像下面这样创建。

```python
>>> squares = []
>>> for x in range(10):
...     squares.append(x**2)
...
>>> squares
[0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
```

注意这个 for 循环中的被创建（或被重写）的名为  `x` 的变量在循环完毕后依然存在。使用如下方法，可以计算 squares 的值而不会产生任何的副作用：。

```python
squares = list(map(lambda x: x**2, range(10)))
```

等价于下面的列表推导式。

```python
squares = [x**2 for x in range(10)]
```

上面这个方法更加简明且易读。

列表推导式由包含一个表达式的中括号组成，表达式后面跟随一个  for 子句，之后可以有零或多个  for 或  if 子句。结果是一个列表，由表达式依据其后面的 for 和  if 子句上下文计算而来的结果构成。

例如，如下的列表推导式结合两个列表的元素，如果元素之间不相等的话：

```python
>>> [(x, y) for x in [1,2,3] for y in [3,1,4] if x != y]
[(1, 3), (1, 4), (2, 3), (2, 1), (2, 4), (3, 1), (3, 4)]
```

等同于：

```python
>>> combs = []
>>> for x in [1,2,3]:
...     for y in [3,1,4]:
...         if x != y:
...             combs.append((x, y))
...
>>> combs
[(1, 3), (1, 4), (2, 3), (2, 1), (2, 4), (3, 1), (3, 4)]
```

值得注意的是在上面两个方法中的 for 和 if 语句的顺序。

列表推导式也可以嵌套。

```python
>>> a=[1,2,3]
>>> z = [x + 1 for x in [x ** 2 for x in a]]
>>> z
[2, 5, 10]
```

### 6.2 元组

元组是由数个逗号分割的值组成。

```python
>>> a = 'Fedora', 'ShiYanLou', 'Kubuntu', 'Pardus'
>>> a
('Fedora', 'ShiYanLou', 'Kubuntu', 'Pardus')
>>> a[1]
'ShiYanLou'
>>> for x in a:
...     print(x, end=' ')
...
Fedora ShiYanLou Kubuntu Pardus
```

可以对任何一个元组执行拆封操作并赋值给多个变量，就像下面这样：

```python
>>> divmod(15,2)
(7, 1)
>>> x, y = divmod(15,2)
>>> x
7
>>> y
1
```

元组是不可变类型，这意味着不能在元组内删除或添加或编辑任何值。如果尝试这些操作，将会出错：

```python
>>> a = (1, 2, 3, 4)
>>> del a[0]
Traceback (most recent call last):
File "<stdin>", line 1, in <module>
TypeError: 'tuple' object doesn't support item deletion
```

要创建只含有一个元素的元组，在值后面跟一个逗号。

```python
>>> a = (123)
>>> a
123
>>> type(a)
<class 'int'>
>>> a = (123, )
>>> b = 321,
>>> a
(123,)
>>> b
(321,)
>>> type(a)
<class 'tuple'>
>>> type(b)
<class 'tuple'>
```

通过内建函数 `type()` 你可以知道任意变量的数据类型。使用 `len()` 函数来查询任意序列类型数据的长度。

```python
>>> type(len)
<class 'builtin_function_or_method'>
```

### 6.3 集合

集合是一个无序不重复元素的集。基本功能包括关系测试和消除重复元素。集合对象还支持 union（联合），intersection（交），difference（差）和 symmetric difference（对称差集）等数学运算。

大括号或 set() 函数可以用来创建集合。注意：想要创建空集合，你必须使用 set() 而不是 {}。后者用于创建空字典，我们在下一节中介绍的一种数据结构。

下面是集合的常见操作：

```python
>>> basket = {'apple', 'orange', 'apple', 'pear', 'orange', 'banana'}
>>> print(basket)                      # 你可以看到重复的元素被去除
{'orange', 'banana', 'pear', 'apple'}
>>> 'orange' in basket
True
>>> 'crabgrass' in basket
False

>>> # 演示对两个单词中的字母进行集合操作
...
>>> a = set('abracadabra')
>>> b = set('alacazam')
>>> a                                  # a 去重后的字母
{'a', 'r', 'b', 'c', 'd'}
>>> a - b                              # a 有而 b 没有的字母
{'r', 'd', 'b'}
>>> a | b                              # 存在于 a 或 b 的字母
{'a', 'c', 'r', 'd', 'b', 'm', 'z', 'l'}
>>> a & b                              # a 和 b 都有的字母
{'a', 'c'}
>>> a ^ b                              # 存在于 a 或 b 但不同时存在的字母
{'r', 'd', 'b', 'm', 'z', 'l'}
```

从集合中添加或弹出元素：

```python
>>> a = {'a','e','h','g'}
>>> a.pop()  # pop 方法随机删除一个元素并打印
'h'
>>> a.add('c')
>>> a
{'c', 'e', 'g', 'a'}
```

### 6.3 字典

字典是无序的键值对（`key:value`）集合，同一个字典内的键必须是互不相同的。一对大括号 `{}` 创建一个空字典。初始化字典时，在大括号内放置一组逗号分隔的键：值对，这也是字典输出的方式。使用键来检索存储在字典中的数据。

```python
>>> data = {'kushal':'Fedora', 'kart_':'Debian', 'Jace':'Mac'}
>>> data
{'kushal': 'Fedora', 'Jace': 'Mac', 'kart_': 'Debian'}
>>> data['kart_']
'Debian'
```

创建新的键值对很简单：

```python
>>> data['parthan'] = 'Ubuntu'
>>> data
{'kushal': 'Fedora', 'Jace': 'Mac', 'kart_': 'Debian', 'parthan': 'Ubuntu'}
```

使用 `del` 关键字删除任意指定的键值对：

```python
>>> del data['kushal']
>>> data
{'Jace': 'Mac', 'kart_': 'Debian', 'parthan': 'Ubuntu'
```

使用 `in` 关键字查询指定的键是否存在于字典中。

```python
>>> 'ShiYanLou' in data
False
```

必须知道的是，字典中的键必须是不可变类型，比如你不能使用列表作为键。

`dict()` 可以从包含键值对的元组中创建字典。

```python
>>> dict((('Indian','Delhi'),('Bangladesh','Dhaka')))
{'Indian': 'Delhi', 'Bangladesh': 'Dhaka'}
```

如果想要遍历一个字典，使用字典的 `items()` 方法。

```python
>>> data
{'Kushal': 'Fedora', 'Jace': 'Mac', 'kart_': 'Debian', 'parthan': 'Ubuntu'}
>>> for x, y in data.items():
...     print("{} uses {}".format(x, y))
...
Kushal uses Fedora
Jace uses Mac
kart_ uses Debian
parthan uses Ubuntu
```

许多时候需要往字典中的元素添加数据，首先要判断这个元素是否存在，不存在则创建一个默认值。如果在循环里执行这个操作，每次迭代都需要判断一次，降低程序性能。

我们可以使用 `dict.setdefault(key, default)` 更有效率的完成这个事情。

```python
>>> data = {}
>>> data.setdefault('names', []).append('Ruby')
>>> data
{'names': ['Ruby']}
>>> data.setdefault('names', []).append('Python')
>>> data
{'names': ['Ruby', 'Python']}
>>> data.setdefault('names', []).append('C')
>>> data
{'names': ['Ruby', 'Python', 'C']}
```

试图索引一个不存在的键将会抛出一个 *keyError* 错误。我们可以使用 `dict.get(key, default)` 来索引键，如果键不存在，那么返回指定的 default 值。

```python
>>> data['foo']
Traceback (most recent call last):
File "<stdin>", line 1, in <module>
KeyError: 'foo'
>>> data.get('foo', 0)
0
```

如果想要在遍历列表（或任何序列类型）的同时获得元素索引值，可以使用 `enumerate()`。

```python
>>> for i, j in enumerate(['a', 'b', 'c']):
...     print(i, j)
...
0 a
1 b
2 c
```

需要同时遍历两个序列类型，可以使用 `zip()` 函数。

```python
>>> a = ['Pradeepto', 'Kushal']
>>> b = ['OpenSUSE', 'Fedora']
>>> for x, y in zip(a, b):
...     print("{} uses {}".format(x, y))
...
Pradeepto uses OpenSUSE
Kushal uses Fedora
```

矩阵乘积的例子：

```python
#!/usr/bin/env python3
n = int(input("Enter the value of n: "))
print("Enter values for the Matrix A")
a = []
for i in range(n):
    a.append([int(x) for x in input().split()])
print("Enter values for the Matrix B")
b = []
for i in range(n):
    b.append([int(x) for x in input().split()])
c = []
for i in range(n):
    c.append([a[i][j] * b[i][j] for j in range(n)])
print("After matrix multiplication")
print("-" * 7 * n)
for x in c:
    for y in x:
        print(str(y).rjust(5), end=' ')
    print()
print("-" * 7 * n)
```
