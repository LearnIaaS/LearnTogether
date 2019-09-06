# Python 基本语法

## 主程序

```python
if __name__ == '__main__':
    print 123
```

`__name__`指示模块应该如何被加载：

- 如果模块是被导入，`__name__`的值是模块名字
- 如果模块是直接执行，`__name__`的值是`__main__`

## 输出

格式化方法 1：

```python
num = 3.90
name = "qiu"
print "the num is {a}, the name is {b}".format(a=num, b=name)
```

格式化方法 2：

```python
num = 3.90
name = "qiu"
print "the num is %f, the name is %s" % (num, name)
- %d,i 十进制整数或长整数
- %f 浮点数
- %s 字符串
```

注意，print 函数将在行尾自动加一个换行，如不需要，在最后一个元素后面添加逗号：

```python
print "123",
```

## 一些操作符

```python
x ** b  # x 的 b 次方
```

```
str1 = u"hello world"
type(str1)
```

## 调用函数和引用函数对象

```python
def printName():
    "test function"
    print "hello world"

if __name__ == "__main__":
    printName()
    print printName.__doc__

# 输出结果：
# hello world
# test function
```

## 适用于所有序列的操作和方法

```
# s[i] 索引
# s[i:j] 切片

str1 = "abcde"
print str1[0:3] # 也可以写成 str[:3]。
print str1[0:-3] # 0 到倒数第三个。
```



## 命名惯例

- 以单一下划线开始（`_X`）不会被 from module import * 导入
- 前后下划线（`__X__`）是系统定义的变量名，对 python 解释器有特殊的意义
- 以两个下划线开头（`__X`）是类的本地变量

## 将 unicode 转换为 str

```python
a = a.encode('unicode-escape').decode('string_escape')
```

## 获得当前路径

```python
path = os.path.abspath('.')
```

## dict

### 常见方法

D.clear()                              #移除D中的所有项 
D.copy()                               #返回D的副本 
D.fromkeys(seq[,val])                  #返回从seq 中获得的键和被设置为val的值的字典。可做类方法调用 
D.get(key[,default])                   #如果D[key]存在，将其返回；否则返回给定的默认值None 
D.has_key(key)                         #检查D是否有给定键key 
D.items()                              #返回表示D项的(键，值)对列表 
D.iteritems()                          #从D.items()返回的(键，值)对中返回一个可迭代的对象 
D.iterkeys()                           #从D的键中返回一个可迭代对象 
D.itervalues()                         #从D的值中返回一个可迭代对象 
D.keys()                               #返回D键的列表 
D.pop(key[,d])                         #移除并且返回对应给定键key或给定的默认值D的值 
D.popitem()                            #从D中移除任意一项，并将其作为(键，值)对返回 
D.setdefault(key[,default])            #如果D[key]存在则将其返回；否则返回默认值None 
D.update(other)                        #将other中的每一项加入到D中。 
D.values()                             #返回D中值的列表

### 五种创建方法

```python
>>> D1 = {'name':'Bob','age':40}  
```

```python
>>> D2 = {}  
>>> D2['name'] = 'Bob'  
>>> D2['age']  =  40  
>>> D2  
{'age': 40, 'name': 'Bob'} 
```

```python
>>> D3 = dict(name='Bob',age=45)  
>>> D3  
{'age': 45, 'name': 'Bob'} 
```

```python
>>> D4 = dict([('name','Bob'),('age',40)])  
>>> D4  
{'age': 40, 'name': 'Bob'} 

或

>>> D = dict(zip(('name','bob'),('age',40)))  
>>> D  
{'bob': 40, 'name': 'age'}  
```

```python
>>> D5 = dict.fromkeys(['A','B'],0)  
>>> D5  
{'A': 0, 'B': 0}  

或

>>> D3 = dict.fromkeys(['A','B'])  
>>> D3  
{'A': None, 'B': None}  
```

### 遍历

```python
>>> D = {'x':1, 'y':2, 'z':3}
>>> for key in D:  
    print key, '=>', D[key] # <--------------- 注意这里的用法： 打印输出
y => 2  
x => 1  
z => 3  
```

```python
>>> for key, value in D.items(): # <--------------- 注意这里的用法： D.items()
    print key, '=>', value     
y => 2  
x => 1  
z => 3  
```

```python
>>> for key in D.iterkeys(): # <--------------- 注意这里的用法： D.itemskeys()
    print key, '=>', D[key]    
y => 2  
x => 1  
z => 3  
```

```python
>>> for value in D.values(): # <--------------- 注意这里的用法： D.values()
    print value   
2  
1  
3  
```

```python
>>> for key, value in D.iteritems(): # <--------------- 注意这里的用法： D.iteritems()
    print key, '=>', value  
      
y => 2  
x => 1  
z => 3  
```

**Note：**用 `D.iteritems()`, `D.iterkeys()` 的方法要比没有 `iter` 的快的多。

## tupe

元组和列表类似，元组使用的是小括号，列表是中括号，但是元组不像列表那样可以增删改；如果列表中存在列表或字符串，那么可以对其进行修改。

创建一个元组，只需要括号中添加元素，元素用逗号隔开即可；

### 创建

```python
tuple1 = (1,2,3,4,5)
```

### 读取

```python

>>> tuple1=(1,2,3,4,5)
>>> tuple1[0]
1
>>> tuple1[1]
2
```

```python
>>> tuple1
(1, 2, 3, 4, 5, [-1, 2, 3, 4, 5])
>>> print "tuple1:",tuple1[1:4]
tuple1: (2, 3, 4)

```

### 修改

```python
>>> tuple1=(1,2,3,4,5,[1,2,3,4,5])
>>> tuple1[5][0]=-1
>>> print tuple1
(1, 2, 3, 4, 5, [-1, 2, 3, 4, 5])
```

## list

list 中的元素类型可以不同。

### 创建

```python
list_stu=[1,2,3,4,'123']
```

### 增加元素

```python
list_stu.append('胡歌')
```

```python
list_stu.insert(2, '关之琳')
```

### 修改元素

```
list_stu[0] = 1199
```

### 查看元素

```
list_stu[1]
```

### 删除元素

```python
list_stu.pop() # 默认删除最后一个元素，如果指定下标，删除指定元素。
```

```python
del list_stu[0] # 删除指定元素。
```

```python
del list_stu[1:3] # 删除下标1到3的元素，含头不含尾。
```

```python
list_stu.clear() # 清空整个list。
```

## 字符串操作

```python
str3 = str1 + str2  # 字符串链接
nPos = sStr1.index(sStr2)  # 查找字符串，< 0 未找到。
print cmp("map","bus")  # 字符串比较，字典比较。输出 1，表示第一个“小”。

s = 'ab,cde,fgh,ijk'  # 字符串分割。
print(s.split(','))

delimiter = ','  # 字符串链接。
mylist = ['Brazil', 'Russia', 'India', 'China']
print delimiter.join(mylist)  # Brazil,Russia,India,China

s.strip()  # 删掉 chrs 开头和结尾的空白。
```

