# CMake

## 一个展示

新建一个 main.c

```C
#include<stdio.h>

int main(){
    printf("hello");
    return 0;
}
```

编写 CMakeLists.txt：

```cmake
#cmake最低版本需求，不加入此行会受到警告信息
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
PROJECT(HELLO) #项目名称
#把当前目录(.)下所有源代码文件和头文件加入变量SRC_LIST
AUX_SOURCE_DIRECTORY(. SRC_LIST)
#生成应用程序 hello (在windows下会自动生成hello.exe)
ADD_EXECUTABLE(hello ${SRC_LIST})
```

新建一个 build 文件夹使目录如下：

```
[root@artist test01]# tree
.
├── build
├── CMakeLists.txt
└── main.c
```

进入 build 文件夹中：

```shell
[root@artist build]# cmake ..
-- The C compiler identification is GNU 4.8.5
-- The CXX compiler identification is GNU 4.8.5
-- Check for working C compiler: /usr/bin/cc
-- Check for working C compiler: /usr/bin/cc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/c++
-- Check for working CXX compiler: /usr/bin/c++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Configuring done
-- Generating done
-- Build files have been written to: /home/artist/Documents/test01/build
```

之后：

```shell
[root@artist build]# ls
CMakeCache.txt  CMakeFiles  cmake_install.cmake  Makefile
```

之后 make：

```shell
[root@artist build]# make
Scanning dependencies of target hello
[100%] Building C object CMakeFiles/hello.dir/main.c.o
Linking C executable hello
[100%] Built target hello
```

查看：

```shell
[root@artist build]# ls
CMakeCache.txt  CMakeFiles  cmake_install.cmake  hello  Makefile
```

多出了一个 `hello` 可执行文件，我们用 `./hello` 执行：

```shell
[root@artist build]# ./hello 
hello
```



## 第一个小工程

结构如下：

```
[root@artist test02]# tree
.
├── build
├── CMakeLists.txt
├── main.c
├── testFunc.c
└── testFunc.h
```

main.c：

```c
#include<stdio.h>
#include "testFunc.h"
int main(void){
    func(100);
    return 0;
}
```

testFunc.c:

```c
#include <stdio.h>
#include "testFunc.h"
void func(int data){
    printf("data is %d\n", data);
}
```

testfunc.h:

```c
#ifndef _TEST_FUNC_H_
#define _TEST_FUNC_H_
void func(int data);
#endif
```

CMakeLists.txt:

```cmake
cmake_minimum_required (VERSION 2.8)

project (demo)

aux_source_directory(. SRC_LIST)

add_executable(main ${SRC_LIST}) --> 如果这里的“main”写为“run”，最后生成的可执行文件就是run。
```

进入 `build/` 后 cmake && make:

```c
$ cmake ..
$ make
$ ls
CMakeCache.txt  CMakeFiles  cmake_install.cmake  main  Makefile
$ ./main
data is 100
```



## 第二个多目录小工程

正规一点来说，一般会把源文件放到src目录下，把头文件放入到include文件下，生成的对象文件放入到build目录下，最终输出的elf文件会放到bin目录下，这样整个结构更加清晰。我们重新组织一下：

```shell
[root@artist test03]# tree
.
├── bin
├── build
├── CMakeLists.txt
├── include
│   ├── testFunc1.h
│   └── testFunc.h
└── src
    ├── CMakeLists.txt
    ├── main.c
    ├── testFunc1.c
    └── testFunc.c

```

其中，最外层的CMakeLists.txt:

```cmake
cmake_minimum_required (VERSION 2.8)

project (demo)

add_subdirectory (src)
```

这里出现一个新的命令add_subdirectory()，这个命令可以向当前工程添加存放源文件的子目录，并可以指定中间二进制和目标二进制的存放位置。这里指定src目录下存放了源文件，当执行cmake时，就会进入src目录下去找src目录下的CMakeLists.txt，所以在src目录下也建立一个CMakeLists.txt，内容如下：

```cmake
aux_source_directory (. SRC_LIST)

include_directories (../include)

add_executable (main ${SRC_LIST})

set (EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)
```

这里又出现一个新的命令set，是用于定义变量的，EXECUTABLE_OUT_PATH 和 PROJECT_SOURCE_DIR 是 CMake 自带的预定义变量，其意义如下，

- EXECUTABLE_OUTPUT_PATH ：目标二进制可执行文件的存放位置
- PROJECT_SOURCE_DIR：工程的根目录

所以，这里set的意思是把存放elf文件的位置设置为工程根目录下的bin目录。

其他代码，testFunc1.h:

```c
#ifndef _TEST_FUNC1_H_
#define _TEST_FUNC1_H_

void func1(int data);
#endif
```

testFunc1.c:

```c
#include <stdio.h>
#include "testFunc1.h"

void func1(int data){
    printf("data is %d\n", data);
}
```

main.c:

```c
#include <stdio.h>

#include "testFunc.h"
#include "testFunc1.h"

int main(void){
    func(100);
    func1(200);
    return 0;
}
```

我们进入 build 文件夹中 `cmake .. && make`，结果图类似于（删除了一些细节文件）：

```
[root@artist test03]# tree
.
├── bin
│   └── main
├── build
│   ├── CMakeCache.txt
│   ├── CMakeFiles
│   ├── cmake_install.cmake
│   ├── Makefile
│   └── src
├── CMakeLists.txt
├── include
│   ├── testFunc1.h
│   └── testFunc.h
└── src
    ├── CMakeLists.txt
    ├── main.c
    ├── testFunc1.c
    └── testFunc.c

```

可以看到，最后的执行文件在 `bin` 目录中，是`main`。



## 动态库和静态库的编译设置

结构如下：

```
[root@artist test04]# tree
.
├── build
├── CMakeLists.txt
├── lib
└── lib_testFunc
    ├── CMakeLists.txt
    ├── testFunc.c
    └── testFunc.h
```

外层的 `CMakeLists.txt` 内容如下：

```cmake
cmake_minimum_required (VERSION 2.8)

project (demo)

add_subdirectory (lib_testFunc)
```

`lib_testFunc` 中的 `CMakeLists.txt` 内容如下：

```cmake
aux_source_directory (. SRC_LIST)

add_library (testFunc_shared SHARED ${SRC_LIST})
add_library (testFunc_static STATIC ${SRC_LIST})

set_target_properties (testFunc_shared PROPERTIES OUTPUT_NAME "testFunc")
set_target_properties (testFunc_static PROPERTIES OUTPUT_NAME "testFunc")

set (LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib)
```

这里又出现了新的命令和预定义变量，

- add_library: 生成动态库或静态库(第1个参数指定库的名字；第2个参数决定是动态还是静态，如果没有就默认静态；第3个参数指定生成库的源文件)
- set_target_properties: 设置输出的名称，还有其它功能，如设置库的版本号等等
- LIBRARY_OUTPUT_PATH: 库文件的默认输出路径，这里设置为工程目录下的lib目录

进入 build 文件夹中 `$ cmake .. && make` 后可在 lib 文件夹中看到动态库和静态库：

```shell
[root@artist lib]# ls
libtestFunc.a  libtestFunc.so
```

**既然我们已经生成了库，那么就进行链接测试下：**

把build里的文件都删除，然后在在工程目录下新建src目录和bin目录，在src目录下添加一个main.c和一个CMakeLists.txt，整体结构如下：

```
[root@artist test04]# tree
.
├── build
├── CMakeLists.txt
├── lib
│   ├── libtestFunc.a
│   └── libtestFunc.so
├── lib_testFunc
│   ├── CMakeLists.txt
│   ├── testFunc.c
│   └── testFunc.h
└── src
    ├── CMakeLists.txt
    └── main.c
```

修改最外层 `CMakeLists.txt` ：

```cmake
cmake_minimum_required (VERSION 2.8)
project (demo)
add_subdirectory (lib_testFunc)
add_subdirectory (src)
```

src 中的 `CMakeLists.txt` 如下：

```cmake
include_directories (../lib_testFunc)
link_directories (${PROJECT_SOURCE_DIR}/lib)
add_executable (main ${SRC_LIST})
target_link_libraries (main testFunc)
set (EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)
```

这里出现2个新的命令，

- link_directories: 添加非标准的共享库搜索路径
- target_link_libraries: 把目标文件与库文件进行链接

`main.c` 如下：

```c
#include <stdio.h>

#include "testFunc.h"

int main(void)
{
    func(100);
    return 0;
}
```

进入 build 文件夹 `$ cmake .. && make`，此时结构如下（删除细节文件）：

```
.
├── bin
│   └── main
├── build
│   ├── CMakeCache.txt
│   ├── CMakeFiles
│   ├── cmake_install.cmake
│   ├── lib_testFunc
│   ├── Makefile
│   └── src
├── CMakeLists.txt
├── lib
│   ├── libtestFunc.a
│   └── libtestFunc.so
├── lib_testFunc
│   ├── CMakeLists.txt
│   ├── testFunc.c
│   └── testFunc.h
└── src
    ├── CMakeLists.txt
    └── main.c
```

进入 bin 文件夹，执行：

```shell
[root@artist bin]# ./main 
data is 100
```

