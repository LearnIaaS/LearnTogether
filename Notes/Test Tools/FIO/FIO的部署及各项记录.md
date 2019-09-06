

# FIO

## 安装

```shell
mkdir /mnt/nas0/

# 自动安装：
yum -y install libaio-devel
yum -y install fio
yum -y install epel-release
yum -y install python-pip
pip install --upgrade pip
pip install configparser

# 手动安装：
wget http://brick.kernel.dk/snaps/fio-3.12.tar.gz
tar -zxvf fio-3.12.tar.gz
cd fio-3.12/
./configure
make
make install
yum -y install epel-release
yum -y install python-pip
pip install configparser
```

## 一个命令

```shell
fio -ioengine=libaio -direct=1 -sync=1 -thread=1 -numjobs=1 -iodepth=1 -runtime=60 -bs=4M -size=500m -rw=write -time_based=1 -group_reporting -name=test1 -filename=/mnt/nas0/file9 -group_reporting=1
```

-thread=1 是否和 -thread 一样？同样，-group_reporting。

## 常用参数

```shell
-ioengine=libaio  # io 引擎使用 libaio 方式。
-direct=1  # 测试过程绕过机器自带的 buffer，使测试结果更真实。
-sync=1  # 使用 sync 来进行 buffered 写。对于多数引擎，这意味着使用 O_SYNC。
-thread  # fio 默认会使用 fork() 创建 job，如果这个选项设置的话，fio 将使用 pthread_create 来创建线程。（是否写成 -thread=1 也可以？那么如果写成 -thread=0是否代表默认使用 fork() 创建 job？）
-numjobs=1  # 线程数。
-iodepth=1  # 队列深度。
-runtime=60  # fio 测试中每一个 job 的运行时间，本例为60秒。
-bs=4M  # I/O block 大小，默认是4k。
-size=500m  # 指定 job 处理的文件的大小。
-rw=write  # I/O模式：顺序读(read)，随机读(randread)，顺序写(write)，随机写(randwrite)，混合随机读写模式。
-time_based=1  # 如果在runtime指定的时间还没到时文件就被读写完成，将继续重复直到runtime时间结束。
-group_reporting  # 关于显示结果的，汇总每个进程的信息。
-name=test1
-filename=/mnt/nas0/file9  # 指定文件(设备)的名称。可以通过冒号分割同时指定多个文件，如 filename=/dev/sda:/dev/sdb


-directory  # 设置filename 的路径前缀。在后面的基准测试中，采用这种方式来指定设备。
-timeout  # 是指 fio 的运行时间。若只有一个 job，那么 timeout 和 runtime 一样。
-output  # output=filename，fio 执行的结果将重定向到filename指定的位置。
-output-format  # output-format=normal，terse，json。fio执行的结果以什么格式显示（默认normal）。
-section  # section=sec, 如果jobfile中存在多个测试，但只想运行其中某几个的时候，类似如：fio --section=test2 jobfile。
-bsrange=512-2048  # 提定数据块的大小范围。
-rwmixwrite=30  # 在混合读写的模式下，写占30%。
-lockmem=1G  # 只使用1g内存进行测试。
-nrfiles=8  # 每个进程生成文件的数量。
```

## 输出结果

```shell
test1: (g=0): rw=write, bs=(R) 4096KiB-4096KiB, (W) 4096KiB-4096KiB, (T) 4096KiB-4096KiB, ioengine=libaio, iodepth=1
fio-3.1
Starting 1 thread
test1: Laying out IO file (1 file / 500MiB)
Jobs: 1 (f=1): [W(1)][100.0%][r=0KiB/s,w=48.0MiB/s][r=0,w=12 IOPS][eta 00m:00s]
test1: (groupid=0, jobs=1): err= 0: pid=20878: Tue Aug 20 09:43:17 2019
  write: IOPS=13, BW=53.2MiB/s (55.8MB/s)(3196MiB/60022msec)
    slat (usec): min=1021, max=395897, avg=20245.70, stdev=50555.33
    clat (usec): min=540, max=1327.4k, avg=54863.34, stdev=66029.15
     lat (msec): min=29, max=1328, avg=75.11, stdev=73.43
    clat percentiles (usec):
     |  1.00th=[    660],  5.00th=[   1057], 10.00th=[   2180],
     | 20.00th=[  35914], 30.00th=[  38011], 40.00th=[  39060],
     | 50.00th=[  40633], 60.00th=[  41681], 70.00th=[  43254],
     | 80.00th=[  55313], 90.00th=[ 121111], 95.00th=[ 166724],
     | 99.00th=[ 229639], 99.50th=[ 287310], 99.90th=[1333789],
     | 99.95th=[1333789], 99.99th=[1333789]
   bw (  KiB/s): min= 7506, max=90112, per=55.16%, avg=30078.32, stdev=18555.15, samples=117
   iops        : min=    1, max=   22, avg= 6.88, stdev= 4.68, samples=117
  lat (usec)   : 750=2.25%, 1000=2.25%
  lat (msec)   : 2=5.13%, 4=1.75%, 10=0.63%, 20=0.88%, 50=65.08%
  lat (msec)   : 100=8.89%, 250=12.27%, 500=0.75%, 2000=0.13%
  cpu          : usr=0.69%, sys=26.43%, ctx=821, majf=0, minf=3
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=0,799,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=53.2MiB/s (55.8MB/s), 53.2MiB/s-53.2MiB/s (55.8MB/s-55.8MB/s), io=3196MiB (3351MB), run=60022-60022msec

Disk stats (read/write):
    dm-0: ios=0/7190, merge=0/0, ticks=0/237006, in_queue=237372, util=98.80%, aggrios=0/7198, aggrmerge=0/2, aggrticks=0/239451, aggrin_queue=225887, aggrutil=98.77%
  sda: ios=0/7198, merge=0/2, ticks=0/239451, in_queue=225887, util=98.77%

```

## 输出结果说明

```shell
write: IOPS=13, BW=53.2MiB/s (55.8MB/s)(3196MiB/60022msec)
# 输出总的 IOPS，BW，也就是每秒 IO 操作数和带宽。

slat (usec): min=1021, max=395897, avg=20245.70, stdev=50555.33
# slat 意为 submission latency，即IO提交延时。
# usec 意为“微秒”；nsec 意为“纳秒”；msec 意为“毫秒”。
# 该行统计 IO 生成到提交到内核之间的延时，min 为所有最小延时，max 为最大延时。

clat (usec): min=540, max=1327.4k, avg=54863.34, stdev=66029.15
# clat 意为 completion latency，即IO完成延时。
# 该行统计IO完成需要多少延时。

clat percentiles (usec):
     |  1.00th=[    660],  5.00th=[   1057], 10.00th=[   2180],
     | 20.00th=[  35914], 30.00th=[  38011], 40.00th=[  39060],
     | 50.00th=[  40633], 60.00th=[  41681], 70.00th=[  43254],
     | 80.00th=[  55313], 90.00th=[ 121111], 95.00th=[ 166724],
     | 99.00th=[ 229639], 99.50th=[ 287310], 99.90th=[1333789],
     | 99.95th=[1333789], 99.99th=[1333789]
# 统计本次测试IO延时的比重。
# 30.00th=[ 38011]，表示 38011 msec 以下延时的IO操作占所有IO操作的 30%。
# 50.00th=[ 40633]，表示 40633 msec 以下延时的IO操作占所有IO操作的 50%。
```

## 使用配置参数的方式启用 fio

配置文件 `fio.conf`：

```shell
[global]
ioengine=libaio
direct=1
thread=1
norandommap=1
randrepeat=0
runtime=60
ramp_time=6
size=500M
directory=/mnt/nas0

[read4k-rand]
stonewall
group_reporting
bs=4k
rw=randread
numjobs=8
iodepth=32

[read64k-seq]
stonewall
group_reporting
bs=64k
rw=read
numjobs=4
iodepth=8

```

执行：

```shell
fio fio.conf
```

还可以输出为 json 格式：

```shell
fio --output-format=json fio.conf
```

## 通过 python脚本运行 fio 并读取相关信息

配置文件 `config.con`（该文件名不能更改）：

```ini
[FIO]
ioengine=libaio
direct=1
sync=1
thread=1
numjobs=1
iodepth=1
runtime=60
bs=4M
size=500M
rw=write
time_based=1
name=test1
filename=/mnt/nas0/file1
```

run_fio.py

```python
#!/usr/bin/python

import json
import os
import sys

conf = os.path.abspath('.')
conf = conf + "/config.conf"
comand = "fio --output-format=json " + conf + " > ./result.json"
print comand
print "running..."
result = os.system(comand)
print "success"

f = file('result.json')
test = json.load(f)

jobs = test['jobs']
jobs = jobs[0]

read = jobs['read']
bw = read['bw']
iops = read['iops']
slat_ns = read['slat_ns']
clat_ns = read['clat_ns']

write = jobs['write']
bw_write = write['bw']
iops_write = write['iops']
slat_ns_write = write['slat_ns']
clat_ns_write = write['clat_ns']

usr_cpu = jobs['usr_cpu']
sys_cpu = jobs['sys_cpu']
ctx = jobs['ctx']
majf = jobs['majf']
minf = jobs['minf']
iodepth_level = jobs['iodepth_level']

print "run success:"
print
print "read:"
print "IOPS={a}, BW={b}MiB/s".format(a=iops, b=bw) 
print "slat(usec):min={a}, max={b}, mean={c}, stddev={d}"\
		.format(a=slat_ns['min'], b=slat_ns['max'], \
		c=slat_ns['mean'], d=slat_ns['stddev'])
print "clat(nsec):min={a}, max={b}, mean={c}, stddev={d}"\
		.format(a=clat_ns['min'], b=clat_ns['max'], \
		c=clat_ns['mean'], d=clat_ns['stddev'])
print
print "write:"
print "IOPS={a}, BW={b}MiB/s".format(a=iops_write, b=bw_write) 
print "slat(usec):min={a}, max={b}, mean={c}, stddev={d}"\
		.format(a=slat_ns_write['min'], b=slat_ns_write['max'], \
		c=slat_ns_write['mean'], d=slat_ns_write['stddev'])
print "clat(nsec):min={a}, max={b}, mean={c}, stddev={d}"\
		.format(a=clat_ns_write['min'], b=clat_ns_write['max'], \
		c=clat_ns_write['mean'], d=clat_ns_write['stddev'])
print
print "cpu:"
print "usr={a}%, sys={b}%, ctx={c}, majf={d}, minf={e}"\
		.format(a=usr_cpu, b=sys_cpu, c=ctx, d=majf, e=minf)
print
print "IO depths:"
t_1=iodepth_level['1']
t_2=iodepth_level['2']
t_3=iodepth_level['4']
t_4=iodepth_level['8']
t_5=iodepth_level['16']
t_6=iodepth_level['32']
t_7=iodepth_level['>=64']
print "1={a}%, 2={b}%, 4={c}%, 8={d}%, 16={e}%, 32={f}%, >=64={g}%"\
		.format(a=t_1, b=t_2, c=t_3, d=t_4, e=t_5, f=t_6, g=t_7)

```

运行结果：

```shell
[root@artist test]# ./run_fio.py
fio --ioengine=libaio --direct=1 --sync=1 --thread=1 --numjobs=1 --iodepth=1 --runtime=60 --bs=4M --size=500M --rw=write --time_based=1 --name=test1 --filename=/mnt/nas0/file1 --output-format=json
running...
fio success
run success:
read:
IOPS=0.0, BW=0MiB/s
slat(usec):min=0, max=0, mean=0.0, stddev=0.0
clat(nsec):min=0, max=0, mean=0.0, stddev=0.0
cpu:
usr=0.109879%, sys=4.410149%, ctx=919, majf=0, minf=9
IO depths:
1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
```



