# Git

如果要把本地的内容 push 到远程仓库上，先要再 GitHub 上添加 .ssh 密钥。

打开 GitHub 账号，进入 setting，设置 ssh：

![](https://github.com/LearnIaaS/LearnTogether/blob/master/Notes/Programes%20Skill/img/002.jpg)

![](https://github.com/LearnIaaS/LearnTogether/blob/master/Notes/Programes%20Skill/img/003.jpg)

![](https://github.com/LearnIaaS/LearnTogether/blob/master/Notes/Programes%20Skill/img/004.jpg)

找到本地 .ssh 密钥，我的位置如下：

```
C:\Users\ArtistQiu\.ssh
```

![.ssh文件位置](https://github.com/LearnIaaS/LearnTogether/blob/master/Notes/Programes%20Skill/img/001.jpg)

打开 `id_rsa.pub` ，将文件中的内容复制粘贴到 Key 中即可。

之后将仓库克隆到本地：

```shell
$ git clone git@github.com:LearnIaaS/LearnTogether.git
```

当你再本地修改之后，push 的步骤：

```shell
$ git add -A # 添加所有修改的内容。
$ git commit -m "what are u saying?" # 提交。
$ git push # 推送。
```

效果如图：



