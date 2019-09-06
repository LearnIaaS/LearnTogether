# Git

如果要把本地的内容 push 到远程仓库上，先要再 GitHub 上添加 .ssh 密钥。

打开 GitHub 账号，进入 setting，设置 ssh：

![Settings_图1](img\002.jpg)

![New SSH key_图2](img\003.jpg)

![Add SSH key_图3](img\004.jpg)

找到本地 .ssh 密钥，我的位置如下：

```
C:\Users\ArtistQiu\.ssh
```

![.ssh 位置_图4](img\004.jpg)

打开 `id_rsa.pub` ，将文件中的内容复制粘贴到 Key 中即可。

之后在某个你想要下载的本地位置鼠标右键，选择 `git bash here`，打开 git 命令行：

![打开 Git Bash Here_图5](img\006.jpg)

 将仓库克隆到本地：

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

![效果_图6](img\005.jpg)

## 图片补充

Settings_图1：

![Settings](https://github.com/LearnIaaS/LearnTogether/blob/master/Notes/Programes%20Skill/img/002.jpg)

New SSH key_图2：

![New SSH key](https://github.com/LearnIaaS/LearnTogether/blob/master/Notes/Programes%20Skill/img/003.jpg)

Add SSH key_图3：

![Add SSH key](https://github.com/LearnIaaS/LearnTogether/blob/master/Notes/Programes%20Skill/img/004.jpg)

.ssh 位置_图4：

![.ssh 位置](https://github.com/LearnIaaS/LearnTogether/blob/master/Notes/Programes%20Skill/img/001.jpg)

打开 Git Bash Here_图5：

![打开 Git Bash Here](https://github.com/LearnIaaS/LearnTogether/blob/master/Notes/Programes%20Skill/img/006.jpg)

效果_图6：

![效果](https://github.com/LearnIaaS/LearnTogether/blob/master/Notes/Programes%20Skill/img/005.jpg)