# Git

如果要把本地的内容 push 到远程仓库上，先要再 GitHub 上添加 .ssh 密钥。

找到本地 .ssh 密钥，我的位置如下：

```
C:\Users\ArtistQiu\.ssh
```

![.ssh文件位置](\img\001.jpg)

```shell
$ git add -A
$ git commit -m "what are u saying?"
$ git push -u LearnTogether master

$ git remote add origin https://github.com/LearnIaaS/LearnTogether.git
$ git push -u origin master
```



