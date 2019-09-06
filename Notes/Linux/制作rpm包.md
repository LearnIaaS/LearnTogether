制作rpm包
===

# 准备打包环境
```
$ yum install -y rpm-build
$ yum install -y rpmdevtools
$ yum install rpm-devel
```
执行如下命令来生成rpmbuild的工作目录：
```
rpmdev-setuptree
```
工作目录结构如下（目录 `~/rpmbuild/ `）：
```
[root@artist ~]# cd rpmbuild/
[root@artist rpmbuild]# tree
.
├── BUILD
├── RPMS
├── SOURCES
├── SPECS
└── SRPMS
```

