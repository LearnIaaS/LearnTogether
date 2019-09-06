# NFS 文件系统

## 什么是NFS

NFS是Network File System的缩写及网络文件系统。

主要功能是通过局域网络让不同的主机系统之间可以共享文件或目录。

NFS系统和Windows网络共享、网络驱动器类似, 只不过windows用于局域网, NFS用于企业集群架构中, 如果是大型网站, 会用到更复杂的分布式文件系统FastDFS,glusterfs,HDFS

## 使用标准 nfs 系统

服务端和客户端必须软件nfs-utils，如果你没有安装，那么：

```shell
$ yum -y install nfs-utils
```

之后你要创建一个用于共享的文件夹：

```shell
$ mkdir mnt/nfs
```

随后修改 `/etc/exports`文件：

```shell
$ vim /etc/exports

/mnt/nfs *(rw,sync) # 共享的文件夹 *代表所有IP rw代表可读可写 sync代表资料同步写入到内存与硬盘中
```

依次重启服务端rpcbind、nfs服务：

```shell
$ systemctl restart rpcbind
$ systemctl restart nfs
```

 配置服务端防火墙：

```shell
[root@Geeklp-NFS-Server ~]# firewall-cmd --add-service=nfs --permanent
success
[root@Geeklp-NFS-Server ~]# firewall-cmd --reload
success
```

这里服务端完成以后就可以启动客户端了：

```shell
$ systemctl start nfs
$ mount -t nfs 192.168.194.143:/mnt/nfs /mnt/nfs # 192.168.194.143是服务器的IP地址
```

随后查看挂载情况：

```shell
$ df -h
[root@artist nfs]# df -h
Filesystem                Size  Used Avail Use% Mounted on
/dev/mapper/centos-root    25G   20G  5.0G  80% /
devtmpfs                  4.1G     0  4.1G   0% /dev
tmpfs                     4.1G     0  4.1G   0% /dev/shm
tmpfs                     4.1G   13M  4.1G   1% /run
tmpfs                     4.1G     0  4.1G   0% /sys/fs/cgroup
/dev/sda1                 397M  274M  124M  69% /boot
tmpfs                     838M   12K  838M   1% /run/user/42
tmpfs                     838M     0  838M   0% /run/user/0
192.168.194.143:/mnt/nfs   23G  4.0G   20G  18% /mnt/nfs # <-----注意这里，是服务器端的
```

这样，在服务器端的 /mnt/nfs 文件夹中进行操作，客户端就也能同时看到。但是，客户端只是挂载到服务器端，操作的仍然是服务器端的硬盘，并不在自己的硬盘上读写。

重启：

```shell
$ service nfs-server restart
```

停止：

```shell
$ service nfs stop
```

注意，如果出现权限错误：

```
[root@artist mnt]# touch nfs/hello.txt
touch: cannot touch ‘nfs/hello.txt’: Permission denied
```

那是因为文件夹本身也有权限问题。在主机将文件夹 `chmod 777 xxx` 就行了。

## 参考

[Linux环境下NFS服务的安装与配置](https://blog.csdn.net/solaraceboy/article/details/78743563)