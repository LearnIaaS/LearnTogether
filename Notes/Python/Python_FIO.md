# Python_FIO

## 当你想要在 python 中使用 shell 命令时

你要` import os`：

```python
#!/usr/bin/python
import os # <-- 引用 os

vals = os.system('ls')
print vals # <-- 这里返回的是 `os.system('ls')`语句是否成功。成功返回 0。
```

运行结果：

```powershell
[root@artist test06]# ./test.py
config.ini  readconfig.py  test.py
0
```

现在，我们想运行这个：

```shell
$ fio --filename=/mnt/nas0/file2 --runtime=60 --bs=4M --size=500M --rw=write --name=test2
```

一个不完全版本：

```python
#!/usr/bin/python

import os
import configparser

# $ fio --filename=/mnt/nas0/file2 --runtime=60 --bs=4M --size=500M --rw=write --name=test2

config = configparser.ConfigParser()
config.read("/home/artist/Documents/test07/config.ini")

filename = config.get("FIO", "filename")
runtime = config.get("FIO", "runtime")
bs = config.get("FIO", "bs")
size = config.get("FIO", "size")
rw = config.get("FIO", "rw")
name = config.get("FIO", "name")

print(filename)
print(runtime)
print(bs)
print(size)
print(rw)
print(name)

command = "fio --filename=/mnt/nas0/file2 --runtime=60 --bs=4M --size=500M --rw=write --name=test2"
command2 = "fio --filename=" + filename + " --runtime=" + runtime + " --bs=" + bs + " --size=" + size + " --rw=" + rw + " --name=" + name + " --output-format=json";
command3 = " > ./result.txt"
print(command2 + command3)

result = os.system(command2 + " > ./result.txt")
if result == 0:
    print("success")
else:
    print("error")
```

下面的任务是，要使用 json 数据格式。

```python
#!/usr/bin/python
import json
data={
    'name':'AWQA',
    'shares':100,
    'price':542.33
}
json_str=json.dumps(data)
print(type(json_str))
print(json_str)
data1=json.loads(json_str)
print(type(data1))
print(data1)
```

输出结果：

```shell
<type 'str'>
{"price": 542.33, "name": "AWQA", "shares": 100}
<type 'dict'>
{u'price': 542.33, u'name': u'AWQA', u'shares': 100}
```

好了一个读取 FIO 输出 json 的简单代码：

```python
#!/usr/bin/python

import json

f = file('result.json') # 读取文件。
test = json.load(f) # 将 json 格式的文件转换为 dict。

jobs = test['jobs']
jobs = jobs[0] # "jobs":[{...}]，所以 jobs 是一个列表，列表里面装了个 dict。
read = jobs['read']
bw = read['bw']
iops = read['iops']
slat_ns = read['slat_ns']
clat_ns = read['clat_ns']

usr_cpu = jobs['usr_cpu']
sys_cpu = jobs['sys_cpu']
ctx = jobs['ctx']
majf = jobs['majf']
minf = jobs['minf']
iodepth_level = jobs['iodepth_level']

print(bw)
print(iops)
print(slat_ns)
print(clat_ns)

print(usr_cpu)
print(sys_cpu)
print(ctx)
print(majf)
print(minf)
print(iodepth_level)
```

输出结果：

```
0
0.0
{u'max': 0, u'mean': 0.0, u'stddev': 0.0, u'min': 0}
{u'max': 0, u'mean': 0.0, u'percentile': {u'70.000000': 0, u'5.000000': 0, u'50.000000': 0, u'99.990000': 0, u'30.000000': 0, u'10.000000': 0, u'99.000000': 0, u'0.00': 0, u'90.000000': 0, u'95.000000': 0, u'60.000000': 0, u'40.000000': 0, u'20.000000': 0, u'99.900000': 0, u'99.950000': 0, u'1.000000': 0, u'99.500000': 0, u'80.000000': 0}, u'stddev': 0.0, u'min': 0}
0.35828
99.661624
8
0
26
{u'16': 0.0, u'32': 0.0, u'1': 100.0, u'2': 0.0, u'4': 0.0, u'>=64': 0.0, u'8': 0.0}

```

## 将 json 格式的内容转变为一句 str

```python
#!/usr/bin/python

import json
import os
import configparser

cf = configparser.ConfigParser()
cf.read("/home/artist/Documents/test08/config.ini")

dic = cf.items("FIO")
cmd = "";

for item in dic:
	command = item[0].encode('unicode-escape').decode('string_escape')
	value = item[1].encode('unicode-escape').decode('string_escape')
	result = " --" + command + "=" + value
	cmd = cmd + result

print cmd

```

输出结果：

```shell
[root@artist test08]# ./testjson.py
 --filename=/mnt/nas0/file2 --runtime=60 --bs=4M --size=500M --rw=write --name=test2
```















## 草稿纸

[Python - 解析（fio）json输出](http://cn.voidcc.com/question/p-fqbsqpxg-ug.html)

