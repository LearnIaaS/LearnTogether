# Linux的一些语句

* 下载：

  ```
  $ yum install -y wget
  $ wget http://10.25.75.51/raptorstor/RaptorStor.tgz
  ```

* 解压：`$ tar -zxvf cmake.tar.gz`

  ```
  $ tar [-z|-j|-J] [-c|-v] [-f] filename --> 打包与压缩
  $ tar [-z|-j|-J] [-x|-v] [-f] [-c 目录] --> 解压缩
  -c 建立打包文件
  -x 解包或解压缩
  -z 通过 gzip 进行压缩/解压缩，文件类型最好为 .tar.gz
  -v 显示过程
  -f filename
  ```

* 查看所有用户：查看文件 `/etc/passwd`

* 查看挂载：`$ lsblk` 或 `$ df -h`

* 查找当前目录下的文件： `$ find . -name "dep*"` 或 `$ ll | grep raptor`

* 查看当前路径：`$ pwd`

* 查看 IP 信息：`$ ifconfig`

* 查看后台运行进程：`$ ps ax | grep raptor` 

* 结束一个进程：`$ kill -9 12343`（12343是进程号）

* 查看 RaptorStor 的版本：`$ rpm -qi raptorstor`

* 查看所有文件的大小 `du -sh * | sort -n`

* 查看 rpm 安装的软件：`$ rpm  -qa libfuse`

* 删除 rpm 安装的软件：`$ rmp -e libfuse`

* 更改文件的用户、组权限：`$ chown root:root tet.log`

* 更改文件权限：` chmod 777 filename`

* `umount -f /mnt/rfs0`



- 列出文件系统的整体磁盘使用量 `$ df -h`

- 查看文件系统的磁盘使用量（常用于查看目录所占磁盘空间）`$ du -h`

- 查看 inode 编号：`$ ll -i`

- 硬链接：`$ ln A B`，符号链接：`$ ln -s A B`

- 查看 UUID 等参数：`$ lsblk -f` 或 `$ lsblk`

- 将设备文件卸载：`$ umount -f A`

  

## Linux 的账号与用户组

- ID 账号在 /etc/passwd 中

- 查看电子邮件：`$ mail`，进入后：

  ```
  d 删除邮件，后跟序列号，例如：【d10】、【10-20】
  s 将邮件存储为文件，例如：【s 5 ~/mail.file】
  x或exit 不做任何操作而退出
  q 操作退出
  ```

  

## 环境变量

查看当前环境变量：`echo $PATH`

***\*设置:\**** 

\* 方法一：export PATH=PATH:/XXX 但是登出后就失效

\* 方法二：修改~/.bashrc或~/.bash_profile或系统级别的/etc/profile

​    \1. 在其中添加例如export PATH=/opt/ActivePython-2.7/bin:$PATH

​    \2. source .bashrc  (Source命令也称为“点命令”，也就是一个点符号（.）。source命令通常用于重新执行刚修改的初始化文件，使之立即生效，而不必注销并重新登录)