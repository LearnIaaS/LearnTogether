# Make



## 最简单的

首先要知道：

```
.o 是目标代码文件
.out 是可执行文件
```

现在你有一个最简单的 hello.c 文件：

```c++
#include<iostream>
using namespace std;
int main(){
	cout << "hello world" << endl;
	return 0;
}
```

shell命令：

```shell
% g++ hello.cpp
```

产生一个`a.out`文件，运行

```shell
% ./a.out
```

结果：

```
hello world
```

或者你也可以：

```
% make hello
```

显示：

```shell
[root@artist test01]# make hello
g++     hello.cpp   -o hello
```

此时产生一个新文件 `hello`，如下：

```shell
[root@artist test02]# ls
hello  hello.cpp
```

可直接运行：

```shell
% ./hello
```

结果：

```
hello world
```

### 第一个Makefile

在当前文件下新建一个 `Makefile` 文件，内容如下：

```
hello:
```

结果如下：

```
[root@artist test02]# tree
.
├── hello.cpp
└── Makefile

0 directories, 2 files
```

随后执行：

```
% make
```

效果如下：

```
[root@artist test02]# make
g++     hello.cpp   -o hello
```

此时：

```
[root@artist test02]# tree
.
├── hello
├── hello.cpp
└── Makefile

0 directories, 3 files
```

运行 `./hello` 即可。

`make` 之后再 `make` 时，如果系统发现已经有了 `hello` 这个文件，就不会再重新编译，想要删掉之前的文件，可以使用 `make clean`，这样编写 `Makefile`：

```
hello:

clean:
	$(RM) hello
```

执行时是这样：

```
[root@artist test02]# make clean
rm -f hello
```

再次 `make` 即可。



## 当你有引用的文件时

Hello.h：

```c++
class Hello{
public:
	Hello();
	int Display();
};
```

Hello.cpp：

```c++
#include<iostream>
#include "Hello.h"
using namespace std;

Hello::Hello(){}

int Hello::Display(){
	cout << "Hello, again!\n" << endl;
	return 0;
}
```

main.cpp：

```c++
#include <iostream>
#include "Hello.h"

int main(){
	Hello theHello;
	theHello.Display();
	return 0;
}
```

这时你直接编译 `main.cpp` 是不行的：

```shell
[root@artist test01]# g++ main.cpp
/tmp/cc3eYQDq.o: In function `main':
main.cpp:(.text+0x10): undefined reference to `Hello::Hello()'
main.cpp:(.text+0x1c): undefined reference to `Hello::Display()'
collect2: error: ld returned 1 exit status
```

需要先生成 `.o` 文件：

```shell
% g++ -c Hello.cpp -o Hello.o
% g++ -c main.cpp -o main.o
% g++ main.o Hello.o -o main
```

之后才能有可执行的 `main`。

<font color=red>注：</font>

```
-c 将 xx.cpp 编译为 xx.o 文件
-o 将 xx.o 和 xx.o 连接为可执行文件 yy
```

上面的几步也可以简写成：

```
% g++ -c Hello.cpp
% g++ -c main.cpp
% g++ main.o Hello.o -o main
```

### 第二个Makefile

```
main:main.o Hello.o
	g++ main.o Hello.o -o main
Hello.o:Hello.cpp
	g++ -c Hello.cpp
main.o:main.cpp
	g++ -c main.cpp -o main.o
```

运行前结构：

```shell
[root@artist test01]# tree
.
├── Hello.cpp
├── Hello.h
├── main.cpp
└── Makefile

0 directories, 4 files
```

运行效果：

```shell
[root@artist test01]# make
g++ -c main.cpp -o main.o
g++ -c Hello.cpp
g++ main.o Hello.o -o main
[root@artist test01]# tree
.
├── Hello.cpp
├── Hello.h
├── Hello.o
├── main
├── main.cpp
├── main.o
└── Makefile

0 directories, 7 files
```

补充 make clean：

```
main:main.o Hello.o
	g++ main.o Hello.o -o main
Hello.o:Hello.cpp
	g++ -c Hello.cpp
main.o:main.cpp
	g++ -c main.cpp -o main.o
	
clean:
	$(RM) main main.o Hello.o
```



## 好了让我们进入Make

一个例子：

```makefile
cc = g++
prom = main
source = Hello.cpp main.cpp

$(prom):$(source)
	$(cc) $(source) -o $(prom)

clean:
	$(RM) main $(source)
```

注意，任何命令行前面都必须有一个 `tab` 符号。`$( )` 表示引用定义好的变量，所以 `$(cc) $(source) -o $(prom)` 就等于 `g++ Hello.cpp main.cpp -o main` 。

实际运行效果：

```shell
[root@artist test01]# make clean
rm -f main Hello.o main.o
[root@artist test01]# make
g++ Hello.cpp main.cpp -o main
[root@artist test01]# ls
Hello.cpp  Hello.h  main  main.cpp  Makefile
[root@artist test01]# 
```

一个模版：

```makefile
cc = gcc
prom = calc
deps = $(shell find ./ -name "*.h" )
src = $(shell find ./ -name "*.cpp")
obj = $(src:%.cpp=%.o)

$(prom): $(obj)
    $(cc) -o $(prom) $(obj)

%.o: %.c $(deps)
    $(cc) -c $< -o $@

clean:
    rm -rf $(obj) $(prom)
```

来解释一下：

* 这里用到了几个特殊的*宏*。首先是 `%.o:%.cpp`，这是一个模式规则，表示所有的 `.o` 目标都依赖于他的同名的 `.cpp` 文件（当然还有deps例列出的头文件）。
* 再用命令的部分 `$<` 个 `$@`，其中 `$<` 代表的是依赖关系表中的第一项（如果我们想引用的是整个关系表，那么就应该使用 `$^`），具体到这里其实就是指 `%.cpp`。而 `$@` 代表的是当前语句的目标，即 `%.o`。
* `$(src:%cpp=%.o)` 则是一个字符串替换函数，他会将 src 中所有的 `.cpp` 字符串替换成 `.o`，实际上就等于列出所有 `.cpp` 文件要编译的结果。



