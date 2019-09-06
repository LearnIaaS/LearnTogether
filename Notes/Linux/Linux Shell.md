# Linux Bash

## 数组操作

```shell
my_array=(A B "C" D)

或者也可以：
array_name[0]=value0
array_name[1]=value1
array_name[2]=value2

读取元素：
${array_name[0]}
${array_name[1]}

读取所有元素：
echo "数组的元素为: ${my_array[*]}"
echo "数组的元素为: ${my_array[@]}"

获取数组的长度
echo "数组元素个数为: ${#my_array[*]}"
echo "数组元素个数为: ${#my_array[@]}"
```

循环操作素组：

```shell
ARRAY=("one" "two" "three")
for j in ${ARRAY[@]};
do
echo $j --> 注意这里不能写成 ${j}
done
```

## 一些基本操作

| 按键         | 效果                        |
| ------------ | --------------------------- |
| ctrl + r     | 查找之前的语句              |
| ctrl + u / k | 将光标之前 / 之后的命令删除 |
| ctrl + a / e | 将光标移动到最前 / 后       |

## 反单引号 `

返单引号的作用为命令替换，例如：

```
A=`ls -l`
```

把 `ls -l` 的结果赋给 A。

## 变量的使用与设置

* 变量的使用 `echo`：

```
$ echo ${PATH}
```

```
$ myName=qiu
$ echo ${myName}
qiu

""内可以加括号，$可以保持原有值，如：
$ myName="this is $PATH"
$ echo ${myName}
this is /usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/artist/.local/bin:/home/artist/bin

若该变量需要在其他子程序执行，则需要用 export 来使其变为环境变量：
$ export PATH

取消变量的方法：
$ unset  myName
```

* 上一个执行命令的返回值：

```
$ echo $SHELL
$ echo $?
0 -----------> 返回 0 说明
```

* read 读取变量

```
read [-pt] variable
-p:后面可以跟提示符
-t：后面跟等待秒数

$ read -p "Please keyin your name:" -t 30 name
> Please keyin your name:（等待输入...）
```

* declear，typeset

```
declare [-aixr] variable
-a：数组
-i：整型
-x：环境变量
-r：只读类型，不可更改

$ sum=100+200
$ echo ${sum}
100+200 -----------> 因为是文本所以直接显示出来
$ declare -i sum=100+200
$ echo ${sum}
300
```

* 注意：bash 环境中的数值运算只能是整型。

## 通配符与特殊符号

| 符号 | 意义                                      |
| ---- | ----------------------------------------- |
| *    | 0个到无穷任意字符                         |
| ?    | 一定有一个任意字符                        |
| []   | 例如 [abc]，一定有一个a、b、c中的一个字符 |
| [-]  | 例如 [0-9]j，代表0和9之间的所有字符       |
| [^]  | 非                                        |

## 数据流重定向

* 标准输入（stdin）：代码为0，使用 < 或 <<；
* 标准输出（stdout）：代码为1，使用 > 或 >>；
* 标准错误输出（stderr）：代码为2，使用 2> 或 2>>。

```
$ ll / > ~/rootfile -----------> 在 ~ 目录下建立了rootfile，将本来输出到屏幕的信息写到了 rootfile 文件中。
```

```
键盘输入：
$ cat > catfile
testing
cat file test -----------> 这里按下 ctrl + d 退出
```

```
标准输入，将原本需要由键盘输入的内容，改由文件内容来替换。
$ cat > catfile < ~/.baschrc
$ cat catfile
# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi
本来应该键盘输入，因为有了 < 结果由 ~/.baschrc 输入了。
```

```
<< 可以终止一次输入，而不用按 ctrl + d
$ cat > catfile << "eof"
> this is a test
> OK now stop
> eof -----------> 输入到这里立刻结束，而不用等着按 ctrl + d
$ cat catfile
this is a test
OK now stop -----------> 注意此处结束，后面无 eof。
```

## 判断语句

| 语句           | 效果                                |
| -------------- | ----------------------------------- |
| cmd 1 ; cmd 2  | 无论 cmd1 执行是否成功，都执行 cmd2 |
| cmd1 && cmd2   | 若 cmd1 成功，则执行 cmd2           |
| cmd1 \|\| cmd2 | 若 cmd1 失败，则执行 cmd2           |

例：

```
$ ls /tmp/abc || mkdir /tmp/abc
```

* Linux 命令都是从左往右执行。

## 管道命令

* cut、grep

```
$ echo ${PATH} | cut -d ":" -f 3,5 --> -d 后跟分割符号，-f 代表取哪几个。
```

```
$ export | cut -c 12- --> -c 取固定区间信息。这句话表示，取每行结果的第12个字符到最后一个字符。
```

* grep

```
$ last | grep root
$ last | grep -v root --> 只要没有root就取出
```

* sort、wc、uniq

```
$ cat /etc/passwd | sort
$ cat /etc/passwd | sort | uniq --> 相同的行只显示一行
$ cat /etc/passwd | wc --> 统计字、行、字符数
```

* 双向重定向 tee，将数据流同时分送到屏幕和文件中

```
$ last | tee last.list | cut -d " " -f1
```

# Linux Shell

## 一些基本例子

* 第一个 HelloWorld：

```shell
#!/bin/bash
# Program: This program shows "Hello world!"
# 20190806 ArtistQiu

echo -e "hello world! \a \n"
exit 0
```

* 输入和输出：

```shell
#!/bin/bash
# Program: This program shows your first and last name.
# 20190806 ArtistQiu

read -p "Please input your first name:" firstname
read -p "please input your last name:" lastname
echo -e "\nYour name is ${firstname}·${lastname}"

```

* 新建三个日期结尾的文件：

```
#!/bin/bash
# Program: Build three file

read -p "Please input your file name:" fileuser

filename=${fileuser:-"filename"}
date1=$(date --date='2 days ago' +%Y%m%d)
date2=$(date --date='1 days ago' +%Y%m%d)
date3=$(date +%Y%m%d)
file1=${filename}${date1}
file2=${filename}${date2}
file3=${filename}${date3}

touch "${file1}"
touch "${file2}"
touch "${file3}"

# 注：
# 字符串操作 ${var:-DEFAULT}，表示：若var没有被声明或变量为空，则以DEFAULT为其值。
```

*  数值的计算：**var=$((运算内容))**

```
#!/bin/bash
# Program: a cross b
# 20190806 ArtistQiu

read -p "input number a:" a
read -p "input number b:" b
total=$((${a}*${b})) --> 注意，不能写成 total = $((...))，不能有空格。
echo ${total}
```

如果你想计算小数点，可以通过 bc 这个命令：

```
$ echo "12.2*0.2" | bc
2.4
```

```shell
#!/bin/bash

read -p "the scale number(10-1000)?" checking
num=${checking:-"10"}
echo -e "Starting calculate..."
time echo "scale=${num};4*a(1)" | bc -lq

注：
4*a(1) 是 bc 提供的一个计算 pi 的函数

运行效果：
[root@artist testShell]# bash cal_pi.sh
> the scale number(10-1000)?10
Starting calculate...
3.1415926532

real    0m0.002s
user    0m0.001s
sys     0m0.002s
```



## 脚本的执行方式的差异

* 使用 bash、sh 执行，该脚本会使用一个新的 bash 环境来执行脚本的命令。当子进程完成后，在子进程内的各项变量或操作将会结束而不传回到父进程中。
* 利用 source 来执行脚本，将在父进程中执行。



## 善用判断式

* test

```shell
$ test -e /dmtsai && echo "exist" || echo "Not exist"
-e 查看文件是否存在
-f 查看是否为文件
-d 查看是否为目录
-r 是否可读
-w 是否可写
-x 是否可执行
-z 判断字符串是否为空，若为空，返回 true
-a 两边同时成立
-o 两边只要一个成立
 ! 相反状态
 
 -eq 两数相等
 -ne 两数不等
 -gt n1 大于 n2
 -lt n1 小于 n2
 -ge n1 大于等于 n2
 -le n1 小于等于 n2
```

```shell
#!/bin/bash

read -p "Input a filename:" filename
test -z ${filename} && echo "You must input a filename." && exit 0

test ! -e ${filename} && echo "The filename '${filename}' DO NOT exist" && exit 0

test -f ${filename} && filetype="regulare file"
test -d ${filename} && filetype="directory"
test -r ${filename} && perm="readable"
test -w ${filename} && perm="${perm} writable"
test -x ${filename} && perm="${perm} executable"

echo "The filename: ${filename} is a ${filetype}"
echo "And  the permissions for you are: ${perm}"
```

* 利用判断符号 [ ]

```
检查 ${HOME} 是否为空：
$ [ -z "${HOME}" ] ; echo $? --> 是空返回 0，不是空返回其他。

注意： [_内容_] 内容两边都有空格。
```

在使用判断符号 [ ] 时，需要注意：

	1. 中括号内的每个组建都需要有空格来分割。
 	2. 中括号内的变量，用双引号括起来。
 	3. 中括号内的常量，用单引号或双引号括起来。

```shell
#!/bin/bash

read -p "please input (Y/N):" yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo "OK" && exit 0
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "NO" && exit 0
echo "I dont know what you input." && exit 0
```

## Shell 默认变量

* $#   参数个数
* $@  将参数以独立的值列出来
* $*  将参数合并为一个字符串列出来
* ${0}  文件名
* ${1}  第一个参数 

```shell
#!/bin/bash

echo "The script name is: ==> ${0}"
echo "Total parameter number is ==> $#"
[ "$#" -lt 2 ] && echo "The number of parameter is less than 2. Stop here." && exit 0
echo "Your whole parameter is ==> '$@'"
echo "The 1st parameter ==> ${1}"
echo "The 2nd parameter ==> ${2}"

效果：
[root@artist testShell]# sh how_paras.sh artist musican philosopher
The script name is: ==> how_paras.sh
Total parameter number is ==> 3
Your whole parameter is ==> 'artist musican philosopher'
The 1st parameter ==> artist
The 2nd parameter ==> musican
```



## 条件判断

* && 代表 AND，|| 代表 or

```shell
[ "${yn}" == "Y" -o "${yn}" == "y" ]
可替换为：
[ "${yn}" == "Y" ] || [ "${yn}" == "y" ]
```

* if ... then

```shell
if [ 条件式1 ]; then
elif [ 条件式2 ]; then
else
fi
```



## function函数功能

```shell
#!/bin/bash

function printit(){
    echo -n "Your choice is "
}

echo "This program will print your selection!"
case ${1} in
"one")
    printit; echo ${1} | tr 'a-z' 'A-Z'
    ;;
"two")
    printit; echo ${1} | tr 'a-z' 'A-Z'
    ;;
"three")
    printit; echo ${1} | tr 'a-z' 'A-Z'
    ;;
*)
    echo "Usage ${0} {one|tow|three}"
    ;;
esac
```

## shell脚本的跟踪与调试

```shell
$ sh [-nvx] scripts.sh
-n：不要执行脚本，仅检查语法错误。
-v：执行脚本之前，先将脚本内容输出到屏幕上。
-x：仅将脚本内容输出到屏幕上。 --> 很有用哦~
```

## for循环

```shell
#!/bin/bash  

for((i=1;i<=10;i++));  
do   
echo $(expr $i \* 3 + 1);  
done 
```

```shell
#!/bin/bash  
  
for i in $(seq 1 10)  
do   
echo $(expr $i \* 3 + 1);  
done   
```

```shell
#!/bin/bash  
  
for i in {1..10}  
do  
echo $(expr $i \* 3 + 1);  
done  
```

```shell
#!/bin/bash  
  
for i in `ls`;  
do   
echo $i is file name\! ;  
done
--> 本脚本将输出该目录下的所有文件。
```



# 其他用到过的一些命令

## basename

basename 是去除目录后剩下的名字，例如；

```
shell>temp=/home/temp/1.test
shell>base=basename $temp
shell>echo $base
```


结果为：1.test

## awk

awk是一个强大的文本分析工具，相对于grep的查找，sed的编辑，awk在其对数据分析并生成报告时，显得尤为强大。简单来说awk就是把文件逐行的读入，以**空格**为默认分隔符将每行切片，切开的部分再进行各种分析处理。

```
1.命令行方式
awk [-F  field-separator]  'commands'  input-file(s)
其中，commands 是真正awk命令，[-F域分隔符]是可选的。 input-file(s) 是待处理的文件。
在awk中，文件的每一行中，由域分隔符分开的每一项称为一个域。通常，在不指名-F域分隔符的情况下，默认的域分隔符是空格。

2.shell脚本方式
将所有的awk命令插入一个文件，并使awk程序可执行，然后awk命令解释器作为脚本的首行，以便通过键入脚本名称来调用。
相当于shell脚本首行的：#!/bin/sh
可以换成：#!/bin/awk

3.将所有的awk命令插入一个单独文件，然后调用：
awk -f awk-script-file input-file(s)
其中，-f选项加载awk-script-file中的awk脚本，input-file(s)跟上面的是一样的。
```

入门实例：

```shell
[root@www ~]# last -n 5 <==仅取出前五行
root     pts/1   192.168.1.100  Tue Feb 10 11:21   still logged in
root     pts/1   192.168.1.100  Tue Feb 10 00:46 - 02:28  (01:41)
root     pts/1   192.168.1.100  Mon Feb  9 11:41 - 18:30  (06:48)
dmtsai   pts/1   192.168.1.100  Mon Feb  9 11:41 - 11:41  (00:00)
root     tty1                   Fri Sep  5 14:09 - 14:10  (00:01)
```

如果只是显示最近登录的5个帐号：

```shell
#last -n 5 | awk  '{print $1}'
root
root
root
dmtsai
root
```

## rpm

```
rpm -q samba //查询程序是否安装
rpm -e file.rpm  ＃[删除一个rpm包]--erase
-i, --install                     install package(s)
```

