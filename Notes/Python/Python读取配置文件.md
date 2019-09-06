# Python 读取配置文件

首先 pip 的安装：

```
 $ yum install -y python-pip
```

python 使用自带的 configparser 模块用来读取配置文件，配置文件的形式类似 windows 中的 `ini` 文件。

```
$ pip install configparser
```

一个示例，config.ini：

```ini
[Mysql-Database]
host=localhost
user=root
password=123456
db=test
charset=utf8

[Email]
host = https://mail.qq.com
address = 123123123@qq.com
password = 123456
```

readconfig.py：

```python
#!/usr/bin/python
import configparser

cf = configparser.ConfigParser()
# 读取配置文件，如果写文件的绝对路径，就可以不用os模块：
cf.read("/home/artist/Documents/test06/config.ini")

# 获取文件中所有的section(一个配置文件中可以有多个配置，如数据库相关的配置，
# 邮箱相关的配置，每个section由[]包裹，即[section]），并以列表的形式返回。
secs = cf.sections()

print(secs)

# 获取某个section名为Mysql-Database所对应的键：
options = cf.options("Mysql-Database")
print(options)

# 获取section名为Mysql-Database所对应的全部键值对:
items = cf.items("Mysql-Database")
print(items)

# # 获取[Mysql-Database]中host对应的值:
host = cf.get("Mysql-Database", "host")
print(host)

```

输出结果为：

```
[u'Mysql-Database', u'Email']
[u'host', u'user', u'password', u'db', u'charset']
[(u'host', u'localhost'), (u'user', u'root'), (u'password', u'123456'), (u'db', u'test'), (u'charset', u'utf8')]
localhost
```

