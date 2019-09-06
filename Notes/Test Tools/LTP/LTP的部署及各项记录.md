# LTP

## 安装

```shell
#!/bin/bash

set -x

yum -y install gcc gcc-c++ bzip2 wget
yum -y install epel-release
yum -y install cmake3
ln -s /usr/bin/cmake3 /usr/bin/cmake
wget https://github.com/linux-test-project/ltp/releases/download/20190517/ltp-full-20190517.tar.bz2

tar -xjf ltp-full-20190517.tar.bz2

cd ltp-full-20190517/

./configure
make
make install
```

`/opt/ltp/testcases/bin` 中带有“key”的都不能通过，先放到一个文件夹中。之后运行：

```
/opt/ltp/runltp -p -q -l ltp.log -o ltp.out -f syscalls -d /mnt/nas0
```

在 `/opt/ltp/output` 文件夹中查看输出结果`ltp.out`。

## LTP的使用

进入 `/opt/ltp` 目录：

```
cd /opt/ltp
```

文件列表如下：

```
bin  IDcheck.sh  runltp  runtest  scenario_groups  share  testcases  testscripts  ver_linux  Version
```

最常用的就是 `runltp` 脚本，它可用于执行 LTP 中绝大部分的测试（default set of tests，但是不包括 networktests 及 diskio 测试。

```shell
$ /opt/ltp/runltp -p -q -l ltp.log -o ltp.out -f syscalls -d /mnt/nas0
```

执行 `./runltp` 的一些选项参数如下：

```shell
    -a EMAIL_TO     EMAIL all your Reports to this E-mail Address
    -c NUM_PROCS    Run LTP under additional background CPU load
                    [NUM_PROCS = no. of processes creating the CPU Load by spinning over sqrt()
                                 (Defaults to 1 when value)]
    -C FAILCMDFILE  Command file with all failed test cases.
    -d TMPDIR       Directory where temporary files will be created.
    -D NUM_PROCS,NUM_FILES,NUM_BYTES,CLEAN_FLAG
                    Run LTP under additional background Load on Secondary Storage (Seperate by comma)
                    [NUM_PROCS   = no. of processes creating Storage Load by spinning over write()]
                    [NUM_FILES   = Write() to these many files (Defaults to 1 when value 0 or undefined)]
                    [NUM_BYTES   = write these many bytes (defaults to 1GB, when value 0 or undefined)]
                    [CLEAN_FLAG  = unlink file to which random data written, when value 1]
    -e              Prints the date of the current LTP release
    -f CMDFILES     Execute user defined list of testcases (separate with ',')
                    执行用户定义的测试用例列表
    -g HTMLFILE     Create an additional HTML output format
    -h              Help. Prints all available options.
    -i NUM_PROCS    Run LTP under additional background Load on IO Bus
                    [NUM_PROCS   = no. of processes creating IO Bus Load by spinning over sync()]
    -l LOGFILE      Log results of test in a logfile.
    -m NUM_PROCS,CHUNKS,BYTES,HANGUP_FLAG
                    Run LTP under additional background Load on Main memory (Seperate by comma)
                    [NUM_PROCS   = no. of processes creating main Memory Load by spinning over malloc()]
                    [CHUNKS      = malloc these many chunks (default is 1 when value 0 or undefined)]
                    [BYTES       = malloc CHUNKS of BYTES bytes (default is 256MB when value 0 or undefined) ]
                    [HANGUP_FLAG = hang in a sleep loop after memory allocated, when value 1]
    -N              Run all the networking tests.
    -n              Run LTP with network traffic in background.
    -o OUTPUTFILE   Redirect test output to a file.
    -p              Human readable format logfiles.
    -q              Print less verbose output to screen.
    -r LTPROOT      Fully qualified path where testsuite is installed.
    -s PATTERN      Only run test cases which match PATTERN.
    -t DURATION     Execute the testsuite for given duration. Examples:
                      -t 60s = 60 seconds
                      -t 45m = 45 minutes
                      -t 24h = 24 hours
                      -t 2d  = 2 days
    -T REPETITION   Execute the testsuite for REPETITION no. of times
    -v              Print more verbose output to screen.                   
    -w CMDFILEADDR  Uses wget to get the user's list of testcases.
    -x INSTANCES    Run multiple instances of this testsuite.
```

部分参数说明：

```
-p: 人为指定日志格式,保证日志为可读格式                       
-l: 记录测试日志的文件
-d: 指定临时存储目录,默认为/tmp
-o: 直接打印测试输出到/tmp/ltpscreen.20111207
-t: 指定测试的持续时间
	-t 60s = 60 seconds
	-t 45m = 45 minutes
	-t 24h = 24 hours
	-t 2d  = 2 days
```

更具体的参数说明：

| 参数                                       | 意义                                                         |
| ------------------------------------------ | ------------------------------------------------------------ |
| -a EMAIL_TO                                | 发送所有的报告到指定的邮箱                                   |
| -c NUM_PROCS                               | 添加后台测试CPU的进程数，默认1                               |
| -C FAILCMDFILE                             | 失败案例存储文件                                             |
| -d IMPDIR                                  | 临时存储目录，默认/tmp                                       |
| -D NUM_PROCS,NUM_FILES,NUM_BYTES,CLEAN_FLA | run LTP under additional background Load on Secondary Storage (Seperate by comma) [NUM_PROCS = no. of processes creating Storage Load by spinning over write()] [NUM_FILES = Write() to these many files (Defaults to 1 when value 0 or undefined)] [NUM_BYTES = write these many bytes (defaults to 1GB, when value 0 or undefined)] [CLEAN_FLAG = unlink file to which random data written， when value 1] |
| -e                                         | 输出目前LTP版本的日期                                        |
| -f CMDFILES                                | 执行用户自定义的测试案例，用“ ，”隔开（CMDFILES指runtest内的驱动程序） |
| -g HTMLFILE                                | 添加html格式的输出文件HTMLFILE                               |
| -h                                         | 帮助信息                                                     |
| -i NUM_PROCS                               | 添加后台测试IO bus总线的进程数                               |
| -l LOGFILE                                 | 记录测试日志的文件                                           |
| `-m NUM_PROCS,CHUNKS,BYTES,HANGUP_FLAG`    | run LTP under additional background Load on Main memory (Seperate by comma) [NUM_PROCS = no. of processes creating main Memory Load by spinning over malloc()] [CHUNKS = malloc these many chunks (default is 1 when value 0 or undefined)] [BYTES = malloc CHUNKS of BYTES bytes (default is 256MB when value 0 or undefined) ] [HANGUP_FLAG = hang in a sleep loop after memory allocated， when value 1] |
| -N                                         | 添加所有的网络测试                                           |
| -n                                         | 添加后台测试网络传输                                         |
| -o OUTPUTFILE                              | 直接打印测试输出到OUTPUTFILE                                 |
| -p                                         | 人为指定日志格式                                             |
| -q                                         | 打印少的测试输出到屏幕                                       |
| -r LTPROOT                                 |                                                              |
| -s PATTERN                                 | 匹配PATTERN执行测试案例                                      |
| -t DURATION                                | 给定测试执行时间设置（s，m，h，d）                           |
| -T REPETITION                              | 重复执行测试案例                                             |
| -v                                         | 打印多的测试输出到屏幕                                       |
| -w CMDFILEADDR                             | 使用wget下载用户测试案例集合。                               |
| -x INSTALL                                 | 并行执行多个测试场景                                         |

运行结果截取一段如下：

```shell
tst_test.c:1096: INFO: Timeout per run is 0h 05m 00s
abort01.c:57: PASS: abort() dumped core
abort01.c:60: PASS: abort() raised SIGIOT

Summary:
passed   2
failed   0
skipped  0
warnings 0
tst_test.c:1096: INFO: Timeout per run is 0h 05m 00s
accept01.c:112: PASS: bad file descriptor successful: EBADF
accept01.c:112: PASS: fd is not socket successful: ENOTSOCK
accept01.c:112: PASS: invalid socket buffer successful: EINVAL
accept01.c:112: PASS: invalid salen successful: EINVAL
accept01.c:112: PASS: no queued connections successful: EINVAL
accept01.c:112: PASS: UDP accept successful: EOPNOTSUPP

Summary:
passed   6
failed   0
skipped  0
warnings 0
tst_test.c:1096: INFO: Timeout per run is 0h 05m 00s
accept4_01.c:157: PASS: Close-on-exec 0, nonblock 0
accept4_01.c:157: PASS: Close-on-exec 1, nonblock 0
accept4_01.c:157: PASS: Close-on-exec 0, nonblock 1
accept4_01.c:157: PASS: Close-on-exec 1, nonblock 1

Summary:
passed   4
failed   0
skipped  0
warnings 0
tst_test.c:1096: INFO: Timeout per run is 0h 05m 00s
access01.c:262: PASS: access(accessfile_rwx, F_OK) as root
access01.c:262: PASS: access(accessfile_rwx, F_OK) as nobody
access01.c:262: PASS: access(accessfile_rwx, X_OK) as root
access01.c:262: PASS: access(accessfile_rwx, X_OK) as nobody
access01.c:262: PASS: access(accessfile_rwx, W_OK) as root
access01.c:262: PASS: access(accessfile_rwx, W_OK) as nobody
access01.c:262: PASS: access(accessfile_rwx, R_OK) as root
access01.c:262: PASS: access(accessfile_rwx, R_OK) as nobody
access01.c:262: PASS: access(accessfile_rwx, R_OK|W_OK) as root
access01.c:262: PASS: access(accessfile_rwx, R_OK|W_OK) as nobody
access01.c:262: PASS: access(accessfile_rwx, R_OK|X_OK) as root
access01.c:262: PASS: access(accessfile_rwx, R_OK|X_OK) as nobody
access01.c:262: PASS: access(accessfile_rwx, W_OK|X_OK) as root
access01.c:262: PASS: access(accessfile_rwx, W_OK|X_OK) as nobody
access01.c:262: PASS: access(accessfile_rwx, R_OK|W_OK|X_OK) as root
access01.c:262: PASS: access(accessfile_rwx, R_OK|W_OK|X_OK) as nobody
access01.c:262: PASS: access(accessfile_x, X_OK) as root
access01.c:262: PASS: access(accessfile_x, X_OK) as nobody
access01.c:262: PASS: access(accessfile_w, W_OK) as root
access01.c:262: PASS: access(accessfile_w, W_OK) as nobody
access01.c:262: PASS: access(accessfile_r, R_OK) as root
access01.c:262: PASS: access(accessfile_r, R_OK) as nobody
access01.c:282: PASS: access(accessfile_r, X_OK) as root: EACCES
access01.c:282: PASS: access(accessfile_r, X_OK) as nobody: EACCES
access01.c:282: PASS: access(accessfile_r, W_OK) as nobody: EACCES
access01.c:282: PASS: access(accessfile_w, R_OK) as nobody: EACCES
access01.c:282: PASS: access(accessfile_w, X_OK) as root: EACCES
access01.c:282: PASS: access(accessfile_w, X_OK) as nobody: EACCES
access01.c:282: PASS: access(accessfile_x, R_OK) as nobody: EACCES
access01.c:282: PASS: access(accessfile_x, W_OK) as nobody: EACCES
access01.c:282: PASS: access(accessfile_r, W_OK|X_OK) as root: EACCES
access01.c:282: PASS: access(accessfile_r, W_OK|X_OK) as nobody: EACCES
access01.c:282: PASS: access(accessfile_r, R_OK|X_OK) as root: EACCES
```

这些测试能够在对应文件夹中找到源代码，例如，测试 `access01`，对应源代码位置 `/home/Documents/ltp-full-20190517/testcases/kernel/syscalls/access/access01.c`。

## 一些测试项目

```shell
./runltp –f commands(测试常规命令)

./runltp –f admin_tools(测试常用管理工具是否正常稳定运行)

./runltp –f dio(测试直接IO是否正常稳定)

./runltp –f  dma_thread_diotest(测试直接存储器访问线程直接IO是否正常稳定)

./runltp –f  fcntl-locktests(测试NFS网络文件系统锁是否正常稳定)

./runltp –f  filecaps(测试filecaps是否正常，预制条件:在/etc/sysctl.conf文件中加一行：CONFIG_SECURITY_FILE_CAPABILITIES=y后重启电脑)

./runltp –f fs(测试文件系统是否正常)

./runltp –f  fs_bind(测试fs_bind是否正常)

./runltp –f fs_ext4(测试fs_ext4是否正常)

./runltp –f fs_perms_simple(简单测试文件系统权限)

./runltp –f  fs_readonly(测试文件系统只读)

./runltp –f fsx(对文件系统进行压力测试)

./runltp –f hyperthreading(CPU超线程技术测试)

./runltp –f io(异步IO测试)

./runltp –f  io_cd(对CD光驱进行压力测试，预制条件:将光盘放入光驱)

-t:指定测试的持续时间

          -t 60s = 60 seconds

          -t 45m = 45 minutes

          -t 24h = 24 hours

          -t 2d  = 2 days

./runltp –f  io_floppy(对软盘进行压力测试)

预制条件:将软盘放入软驱中

./runltp –f  lvm.part1(测试文件系统MSDOS、Reiserfs、EXT2、NFS、Ram Disk、MINIX)

./runltp –f  math(数学库测试)

./runltp –f  nfs(nfs网络文件系统测试，预制条件:在本机配置nfs文件系统服务)

./runltp –f  lvm.part2(测试EXT3、JFS文件系统是否正常使用，预制条件:安装EXT3、JFS文件系统)

./runltp –f pipes(对管道进行压力测试)

./runltp –f syscalls(测试内核系统调用)

./runltp –f syscalls-ipc(进程间通信测试)

./runltp –f can(测试控制器区域网络的稳定性)

./runltp –f connectors(测试Netlink Connector的功能性及稳定性)

./runltp –f ipv6(测试IPv6环境下的基本网络功能)

./runltp –f ipv6_lib(IPv6环境网络开发共享库，预制条件:内核支持IPv6)

./runltp –f multicast（ 测试多播的稳定性）(预制条件：（1）设置环境变量export RHOST=<多播目标地址>（2）/root/.rhosts,/home/user/.rhosts 添加内容：多播目标主机地址，多播目标主机用户，有多少多播目标主机就写多少条。)

./runltp –f network_commands （ 测试ftp和ssh的稳定性，预制条件：开启ftp和ssh)

./runltp –f network_stress.whole（ 网络各个功能的压力性测试，预制条件：（1）部署一台服务器（2）服务器上运行的服务： ssh DNS http ftp）

./runltp –f nptl（ 测试本地POSIX线程库的稳定性，预制条件：内核支持POSIX本地线程库)

./runltp –f nw_under_ns（测试网络命名空间的稳定性）

./runltp –f power_management_tests（电源管理模块的稳定性，预制条件：内核版本2.6.31以上）

./runltp –f pty（测试虚拟终端稳定性，预制条件：内核支持VT console)

./runltp –f quickhit（测试系统调用的稳定性）

./runltp –f rpc 和 ./runltp –f rpc_test（测试远程过程调用稳定性，预制条件：内核支持远程过程调用)

./runltp –f scsi_debug.part1（测试SCSI的稳定性）

./runltp –f sctp（测试SCTP协议的稳定性，预制条件：内核支持SCTP协议)

./runltp –f tcp_cmds_expect（TCP命令的可用性和稳定性，预制条件：内核支持TCP/IP协议)

./runltp –f controllers（内核资源管理的稳定性测试，预制条件：内核版本必须等于或者高于2.6.24)

./runltp –f cap_bounds（POSIX功能绑定设置可用性，预制条件：内核版本2.6.25以上)

./runltp –f containers（命名空间资源稳定性）

./runltp –f cpuacct（测试不同cpu acctount控制器的特点）

./runltp –f cpuhotplug（测试cpu热插拔功能的稳定性）

./runltp –f crashme（测试crashme，预制条件：做测试前，先备份系统)

./runltp –f hugetlb（测试 hugetlb）

./runltp –f ima（测试ima）

./runltp –f ipc（测试ipc）

./runltp –f Kernel_misc（测试 Kernel_misc）

./runltp –f ltp-aiodio.part1（测试 ltp-aiodio.part1）

./runltp –f Ltp-aiodio.part2（测试 Ltp-aiodio.part2）

./runltp –f ltp-aiodio.part3（测试 ltp-aiodio.part3）

./runltp –f ltp-aiodio.part4（测试 ltp-aiodio.part4）

./runltp –f ltp-aio-stress.part1（测试 io stress）

./runltp –f ltp-aio-stress.part2（测试 io stress）

./runltp –f mm（测试mm）

./runltp –f modules（测试内核模块）

./runltp –f numa（测试非统一内存访问）

./runltp –f sched（测试调度压力）

./runltp –f securebits（测试securebits）

./runltp –f smack（smack安全模块测试）

./runltp –f timers（测试posix计时器）

./runltp –f tirpc_tests（测试Tirpc_tests）

./runltp –f tpm_tools（测试 tpm_tools）

./runltp –f tracing（跟踪测试）
```

