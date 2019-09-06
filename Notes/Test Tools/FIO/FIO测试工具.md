# FIO测试工具

## 安装

可以直接现在 yum 中安装： 

```shell
$ yum install fio
```

如果不行你再：

先在 `http://brick.kernel.dk/snaps/fio-3.12.tar.gz` 下载了 `fi0-3.12.tar.gz`，但是无法 make，于是重新进入官网 `http://freshmeat.net/projects/fio/ `j 下载了 `fio-2.1.10.tar.gz`。安装其他依赖包：

```shell
$ yum install -y libaio-devel
$ yum install -y gtk2
$ yum install -y gtk2-devel
```

在目录中：

```shell
$ ./configure --enable-gfio
$ make
$ make install
```



## 基本使用

帅哥提供的测试命令：

```shell
$ fio --ioengine=libaio --direct=1 --sync=1 --thread=1 --numjobs=1 --iodepth=1 --runtime=60 --bs=4M --size=500m --rw=write --time_based=1 --group_reporting --name=test1 --filename=/mnt/nas0/file1
```

我写的一个超级简单的：

```shell
$ fio --filename=/mnt/nas0/file2 --runtime=60 --bs=4M --size=500M --rw=write --name=test2 --output-format=json
```

结果如下：

```shell
test: (g=0): rw=write, bs=(R) 4096KiB-4096KiB, (W) 4096KiB-4096KiB, (T) 4096KiB-4096KiB, ioengine=psync, iodepth=1
fio-3.1
Starting 1 process
test: Laying out IO file (1 file / 500MiB)
Jobs: 1 (f=1): [W(1)][100.0%][r=0KiB/s,w=32.6MiB/s][r=0,w=8 IOPS][eta 00m:00s] 
test: (groupid=0, jobs=1): err= 0: pid=13890: Fri Aug  2 15:28:34 2019
  write: IOPS=15, BW=61.2MiB/s (64.2MB/s)(500MiB/8164msec)
    clat (msec): min=28, max=155, avg=65.00, stdev=36.58
     lat (msec): min=28, max=155, avg=65.30, stdev=36.60
    clat percentiles (msec):
     |  1.00th=[   33],  5.00th=[   34], 10.00th=[   34], 20.00th=[   37],
     | 30.00th=[   39], 40.00th=[   41], 50.00th=[   44], 60.00th=[   49],
     | 70.00th=[   92], 80.00th=[  106], 90.00th=[  124], 95.00th=[  138],
     | 99.00th=[  144], 99.50th=[  155], 99.90th=[  155], 99.95th=[  155],
     | 99.99th=[  155]
   bw (  KiB/s): min=32507, max=114688, per=99.59%, avg=62455.56, stdev=28924.08, samples=16
   iops        : min=    7, max=   28, avg=14.94, stdev= 7.32, samples=16
  lat (msec)   : 50=61.60%, 100=15.20%, 250=23.20%
  cpu          : usr=0.28%, sys=99.71%, ctx=38, majf=0, minf=27
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=0,125,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=61.2MiB/s (64.2MB/s), 61.2MiB/s-61.2MiB/s (64.2MB/s-64.2MB/s), io=500MiB (524MB), run=8164-8164msec

Disk stats (read/write):
    dm-0: ios=0/1011, merge=0/0, ticks=0/21463, in_queue=21493, util=55.43%, aggrios=0/1018, aggrmerge=0/2, aggrticks=0/21564, aggrin_queue=21562, aggrutil=55.27%
  sda: ios=0/1018, merge=0/2, ticks=0/21564, in_queue=21562, util=55.27%
```

我们主要关注 bw 和 iops结果

* bw：磁盘的吞吐量，这个是顺序读写考察的重点
* iops：磁盘的每秒读写次数，这个是随机读写考察的重点

网上的一个参数说明：

```shell
filename=/dev/sdb1   #测试文件名称，通常选择需要测试的盘的data目录
direct=1             #测试过程绕过机器自带的buffer。使测试结果更真实
rw=randwrite         #测试随机写的I/O
rw=randrw            #测试随机写和读的I/O
bs=16k               #单次io的块文件大小为16k
bsrange=512-2048     #同上，提定数据块的大小范围
size=5G              #本次的测试文件大小为5g，以每次4k的io进行测试
numjobs=30           #本次的测试线程为30个
runtime=1000         #测试时间1000秒，如果不写则一直将5g文件分4k每次写完为止
ioengine=psync       #io引擎使用psync方式
rwmixwrite=30        #在混合读写的模式下，写占30%
group_reporting      #关于显示结果的，汇总每个进程的信息

lockmem=1G           #只使用1g内存进行测试
zero_buffers         #用0初始化系统buffer
nrfiles=8            #每个进程生成文件的数量

#顺序读
fio -filename=/dev/sda -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=16k -size=200G -numjobs=30 -runtime=1000 -group_reporting -name=mytest

#顺序写
fio -filename=/dev/sda -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=16k -size=200G -numjobs=30 -runtime=1000 -group_reporting -name=mytest

#随机读
fio -filename=/dev/sda -direct=1 -iodepth 1 -thread -rw=randread -ioengine=psync -bs=16k -size=200G -numjobs=30 -runtime=1000 -group_reporting -name=mytest

#随机写
fio -filename=/dev/sda -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=psync -bs=16k -size=200G -numjobs=30 -runtime=1000 -group_reporting -name=mytest

#混合随机读写
fio -filename=/dev/sda -direct=1 -iodepth 1 -thread -rw=randrw -rwmixread=70 -ioengine=psync -bs=16k -size=200G -numjobs=30 -runtime=100 -group_reporting -name=mytest -ioscheduler=noop

```

## 使用文件格式进行测试

```ini
[global]
ioengine=libaio
direct=1
thread=1
norandommap=1
randrepeat=0
runtime=60
ramp_time=6
size=1g
directory=/path/to/test # 注意，这里要换成你的文件写入地址。

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

[write4k-rand]
stonewall
group_reporting
bs=4k
rw=randwrite
numjobs=2
iodepth=4

[write64k-seq]
stonewall
group_reporting
bs=64k
rw=write
numjobs=2
iodepth=4

```

之后：

```shell
fio fio.conf
```

## 参考

[【详细齐全】FIO使用方法 及参数解析（文章末尾）](https://blog.csdn.net/pansaky/article/details/83689110)

