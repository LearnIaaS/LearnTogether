# 读取 fio_config 根据位置运行 fio

文档结果如图：

```shell
[root@artist raptor]# tree
..
├── config
│   └── config.conf
├── fio_config
│   └── fioconfig.conf # fio 配置文件
├── src
│   ├── run_all_py.py
│   └── run_fio.py # 脚本位置
└── suite
    ├── add
    │   ├── a.py
    │   └── readme.txt
    ├── base
    │   └── b.py
    └── normal
        └── c.py
```

配置文件 `fioconfig.conf`：

```ini
[global]
ioengine=libaio
direct=1
thread=1
sync=1
numjobs=1
iodepth=1
runtime=60
size=500m
time_based=1
directory=/mnt/nas0/

[4k_read]
name=4k_read
bs=4k
rw=write
filename=fio_test_4k_read

[4m_read]
name=4m_read
bs=4m
rw=write
filename=fio_test_4m_read

[1m_read]
name=4m_read
bs=4m
rw=write
filename=fio_test_1m_read
```

`run_fio.py`代码：

```python
#!/usr/bin/python

import os
import sys


def run_fio(conf, sections):
	"run fio according to section"
	comand = "fio" + sections + " " + conf
	os.system(comand)


if __name__ == '__main__':
	path = os.path.abspath(os.path.dirname(os.getcwd()))
	path = path + "/fio_config"
	conf = path + "/fioconfig.conf"
	sections = ""
	if len(sys.argv) <= 1:
		print "program is running all sections"
		run_fio(conf, sections)
		sys.exit()
	for section in sys.argv[1:]:
		sections = sections + " " + section
	# print sections # read comand`s args
	print "program is running accroding to args:",sections	
	run_fio(conf, sections)
```

运行效果：

- 在 `/src` 文件夹下，如果不带`section`参数直接运行，fio 将会运行 `fioconfig.conf` 配置文件中所有标签下的任务，其中 `[global]` 是全局参数配置，之下的如 `[4k_read]`、`[4m_read]`等才是真正的执行任务。例如：

  ```shell
  python run_fio.py
  ```

- 而如果带 section  参数，则将运行指定的任务，如：

  ```shell
  python run_fio.py --section=4k_read --section=1m_read
  ```

  程序此时将只运行`[4k_read]`和`[1m_read]`这两个任务。