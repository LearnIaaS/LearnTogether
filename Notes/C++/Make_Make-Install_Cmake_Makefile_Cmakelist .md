
# make make install

**configure**
<font color='red'>这一步一般用来生成Makefile</font>，为下一步的编译做准备，你可以通过在configure后加上参数来对安装进行控制，比如代码：<u>./configure --prefix=/usr上面的意思是将谇软件安装在/usr下面</u>，执行文件就会安装在/usr/bin，同时一些软件的配置文件你可以通过指定--sys-config=参数进行设定。有一些软件还可以加上--with, --enable, --without, --disable等参数对编译加以控制，你可以通过允许./configure --help查看详细的说明帮助。

**make**
这一步就是编译，大多数的源代码包都经过这一步进行编译，如果在make过程中出现error，可以向开发者提交bugreport(一般在install里有提交地址)，或者你的系统少了一些依赖库等。make的作用是开始进行源代码编译，以及一些功能的提供，这些功能由它的Makefile设置文件提供相磁的功能。

make是Linux开发套件里面自动化编译的一个控制程序，他通过借助Makefile里面编写的编译规范进行自动化调用gcc、ld以及某些需要的程序进行编译的程序。

**make install**
进行安装（当然有些软件需要先运行make check或make test来进行一些测试）。如果原始代码编译无误，且执行结果正确，<font color='red'>便可以把程序安装至系统预设的可执行文件存放路径</font>。如果用bin_PROGRAMS宏的话，<u>程序会被安装至/usr/local/bin这个目录</u>，或者库文件拷贝到相应的目录下

**make clean**
可以清除编译产生的可执行文件及目标文件。


# Makefile
## 简介

[参照网址](https://www.cnblogs.com/owlman/p/5514724.html)
在文件夹`./CodingExample/Makefile`文件夹下有示例

实现软件的自动化build.。通过一种被称之为target概念来检查文件之间的依赖关系。主要用它来编译代码，生成结果代码，然后把结果代码链接起来生成*可执行文件*或者*库文件*

##主要版本

- GNU make。Linux系统
- BSD make.
- Microsoft make. window系统

###从一个简单的例子看起

比如有四个源文件main.c getch.c getop.c stack.c和一个头文件calc.h需要编译

1. 最简单的makefile文件：
  ```C++
  calc: main.c getch.c getop.c stack.c
    gcc -o calc main.c getch.c stack.c
  ```
  这是最基本的Makefile语句包括三个部分：
  - *目标（target）*:冒号之前的calc,被认为是这条语句所要处理的对象。具体到这来就是我们编译的这个程序calc。
  - *依赖关系表*：即calc冒号之后的main.c getch.c getop.c stack.c,也就是编译calc所需要的文件，只要其中一个文件发生变化，就会触发下面的gcc编译命令。
  - *命令部分*：gcc -o ...部分

  <font color = 'red'>请注意:</font>第二行的gcc命令之前必须加一个tab缩进。语法规定Makefile中任何命令之前都必须加一个tab缩进，否则make就会报错。

  2. 解决效率问题

   ```C++
   cc = gcc
   prom = calc
   source = main.c getch.c getop.c statck.c

   $(prom):$(source)
    $(cc): -o $(prom) &(source)

   ```
   上面定义了cc prom source三个常量，类似于字符串替换，这样方便书写与更改

   3. 需要解决一个问题：只修改了一个文件时就要重新编译的问题。而且如果修改了calc.h文件，make就无法察觉到了，所以：*有必要为头文件专门设置一个常量，并且加入依赖关系表中*。

   考虑到编译过程是：<font color = 'red'>y源文件被变异成目标文件，然后再由目标文件连接成可执行文件</font>。利用这一点调整一下文件之间的依赖关系：

   ```C++
   cc = gcc
   prom = calc
   deps = calc.h #这里增加了头文件的变量（常量）
   obj = main.o getch.o getop.o stack.o #目标文件

   $(prom): $(obj)
    $(cc) -o $(prom) $(obj)

   main.o: main.c $(deps)
    $(cc) -c mainc

    getch.o: getch.c $(deps)
      $(cc) -c getch.c

    getop.o: getop.c $(deps)
      $(cc) -c getop.c

    stack.o: stack.c $(deps)
      $(cc) -c stack.c
   ```
这样上面的问题解决了，但是代码变的非常啰嗦。观察发现所有的.c文件都会被编译成相同名称的.o文件，利用这个特点可以**进一步简化**：
```C++
cc = gcc
prom = calc
deps = calc.h #这里增加了头文件的变量（常量）
obj = main.o getch.o getop.o stack.o #目标文件

$(prom): $(obj)
  $(cc) -o $(prom) $(obj)

%.o: %.c $(deps)     #就是讲所有的.c文件编译成目标文件.o文件
  &(cc) -c $< -o $@

```
这里用到了几个特殊的*宏*。首先是%.o:%.c,这是一个模式规则，表示所有的.o目标都依赖于他的同名的.c文件（当然还有deps例列出的头文件）。再用命令的部分$<个$@，其中$<代表的是依赖关系表中的第一项（如果我们想引用的是整个关系表，那么就应该使用$^），具体到这里其实就是指%.c。而$@代表的是当前语句的目标，即%.o

<font color = 'red'>至此，一个简单的makefile维护一个小型的工程是没有什么问题了</font>,还可以进一步增加上面项目的可扩展型，用到一些*伪目标和函数规则了*。例如增加自动清理编译结果的功能就可以为其定义一个带伪目标的规则：
```C++
cc = gcc
prom = calc
deps = calc.h
obj = main.o getch.o getop.o stack.o

$(prom): $(obj)
    $(cc) -o $(prom) $(obj)

%.o: %.c $(deps)
    $(cc) -c $< -o $@

clean:  #清理功能
    rm -rf $(obj) $(prom)
```
有了最后一行，当执行*make clean*,就可以删除工程生成的所有的编译文件。

3. 如果需要往工程中添加.c或者.h，利用makefile的函数:
```C++
cc = gcc
prom = calc
deps = $(shell find ./ -name "*.h" )
src = $(shell find ./ -name "*.c")
obj = $(src:%.c=%.o)

$(prom): $(obj)
    $(cc) -o $(prom) $(obj)

%.o: %.c $(deps)
    $(cc) -c $< -o $@

clean:
    rm -rf $(obj) $(prom)
```
其中，shell函数主要用于执行shell命令。而$(src:%c=%.o)则是一个字符串替换函数，他会将src中所有的.c字符串替换成.o，实际上就等于列出所有.c文件要编译的结果。有了这个设定，无论我们今后在该工程中加入多少.c和.h文件，makefile都能自动将其纳入工程中来。

到这来，欧了，以后**就用最后一个模板**。

# Cmake

## 1. 概述

CmakeList.txt是Cmake的配置文件,[参见网址](https://blog.csdn.net/xierhacker/article/details/79445339)

在文件夹`./CodingExample/CMakeLists`文件夹下有示例

CMake 是一个跨平台的安装（编译）工具，可以用简单的预计描述所有的平台的安装（编译的过程）。他能够输出各种各样的makefile或者project文件，能测试编译器所支持的C++特性，类似UNIX下的automake。<u>只是Cmake的组态档取名为CMakeList.txt</u>。CMake并不直接构建出最终的软件，而是产生标准的构建档（如Unix的makefile或者Windows Visual C++的Projects/workspaces）, 然后再依一般的构建方式使用。这使得熟悉某个集成开发环境（IDE）的开发者可以用标准的方式构建他的软件，这种可以使用各平台的原生建构系统的能力是Cmake和SCons等其他类似系统的区别之处。

Cmake的特点：

1. **开放源代码**，使用类BSD许可发布。[Licensing CMake](http://cmake.org/HTML/Copyright.html)。

2. **跨平台**，并可以生成<font color = 'red'>native编译配置文件</font>,在Linux/Unix平台生成makefile,在苹果平台，可以生成xcode,在Windows生成MSVC的工程文件。
3. **能够管理大型项目**。
4. **简化编译构建过程和编译过程**，Cmake的工具链非常简单：cmake+make。
5. **高效率**
6. **可扩展**。可以为cmake编写特定功能的模块，扩充cmake功能。

<u>在Liunx平台下使用CMake生成Makefile</u>斌编译的流程如下：

1. 编写CMake配置文件CMakeList.txt。
2. 执行命令cmake PATH 或者ccmake PATH生成Makefile。其中PATH 是CMakeList所在的目录。
3. 执行make命令进行编译。

## 2. 简单例子Hello World

比如我现在项目目录叫做HelloWorld,其中建立两个文件,分别是main.cpp 和 CMakeLists.txt(注意文件名大小写)：

main.cpp文件中就是非常简单的输出Hello world的代码了,如下:

```C++
//main.cpp
#include <iostream>
int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
```
CmakeLists.txt 文件内容：

```C++
cmake_minimum_required(VERSION 3.9)
project(HelloWorld)

set(CMAKE_CXX_STANDARD 11)

add_executable(HelloWorld main.cpp)
```
在这个目录运行：

```C++
cmake .
```
注意命令后面的点号，代表本目录

输出大概是这个样子：
```C++
-- The C compiler identification is GNU 5.4.0
-- The CXX compiler identification is GNU 5.4.0
-- Check for working C compiler: /usr/bin/cc
-- Check for working C compiler: /usr/bin/cc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: /usr/bin/c++
-- Check for working CXX compiler: /usr/bin/c++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Configuring done
-- Generating done
-- Build files have been written to: /home/enningxie/xiekun/WorkSpace/LearningCMake/HelloWorld
---------------------
```
此时目录下会生成`CMakeFiles, CMakeCache.txt, cmake_install.cmake `等文件，并且生成了`Makefile`,只需要关注Makefile即可，其他不用管，以后也不用管

然后再make,大概会输出下面：
```C++
Scanning dependencies of target HelloWorld
[ 50%] Building CXX object CMakeFiles/HelloWorld.dir/main.cpp.o
[100%] Linking CXX executable HelloWorld
[100%] Built target HelloWorld
---------------------
```
如果你需要看到 make 构建的详细过程，可以使用 make VERBOSE=1 来进行构建。

此时目录下会生成`HelloWord`可执行文件，可以直接运行

## 3. 基本的用法解释

`CMakeList.txt`文件是cmake的构建定义文件，文件名是大小写相关的，如果工程存在多个目录，<u>需要确保每个 管理的目录都存在一个CMakeList.txt</u>。（关于多目录构建，需要继续再学习）

上面的例子里CMakeList.txt内容如下：
```C++
cmake_minimum_required(VERSION 3.9) #所需CMake的最低版本可以不用写，但是推荐写上
project(HelloWorld)

set(CMAKE_CXX_STANDARD 11)

add_executable(HelloWorld main.cpp)
```
所需CMake的最低版本可以不用写，但是推荐写上

*project(HelloWorld)指定项目名称*，文件夹名字（非可执行文件名字），更加详细的说，project的语法是：project(projectName [CXX][C][Java]),可以用这个指定定义工程名称，并可指定工程支持的语言（支持的语言列表可以忽略），默认是支持所有的语言的。

这个指令隐式的定义了cmake两个变量：
```C++
_BINARY_DIR
SOURCE_DIR
```
这里就是`HelloWorld_BINARY_DIR`和`HelloWord_SOURCE_DIR`。因为我采用的是内部编译，两个变量目前指的都是工程所在路径，后面需要学习外部编译，两者指代的内容有所不同。

同时Cmake系统也帮助我们预定义了PROJECT_BINARY_DIR和PROJECT_SOURCE_DIR变量，<u>他们的值分别跟HelloWorld_BINARY_DIR 与 HelloWorld_SOURCE_DIR 一致</u>。*为了统一起见，建议以后直接使用PROJECT_BINARY_DIR*，PROJECT_SOURCE_DIR，即使修改了工程的名称，也不会影响这两个变量。如果使用了<projectname>_SOURCE_DIR，如果修改工程名称，需要同时修改这些变量

*第三行`set(CMAKE_CXX_STANDARD 11)`*,这里是之后的编译选项设置为了C++11`

set指令的语法是：
```C++
set(VAR [VALUE][CACHE TYPE DOCSTRING [FORCE]])
```
现阶段，你只需要了解<font color = 'red'>set 指令可以用来<u>显示的定义变量</u>即可</font>。比如我们用到的是set(SRC_LIST main.c),如果有多个源文件，也可以定义成：set(SRC_LIST main.c t1.c t2.c)。

*最后一行add_executabule(HelloWorld main.cpp)*,这行的作用是将名为main.cpp的源文件编译成一个名称为HelloWorld的可执行文件。更加详细的用法是：
```C++
add_executable(executable_name ${SRC_LIST})
```
定义了这个工程会生成一个文件名为 executable_name 的可执行文件，<font color = 'red'>相关的源文件是<u> SRC_LIST 中定义的源文件列表</u></font>。

## 5. 内部构建和外部构建

实际上非常简单。没什么好讲的

## 4. cmake常用的参数

-DBUILD_SHARED_LIBS=
可以选择 ON 或者 OFF 选择默认是否编译成共享库，如果不指定则默认编译生成的库是静态库

-DCMAKE_INSTALL_PREFIX=
指定安装路径。UNIX 默认安装路径 /usr/local

## 6. 模板
[here](https://blog.csdn.net/u010122972/article/details/78216013)
```
cmake_minimum_required(VERSION 3.2.0)#版本。可以不加，建议加上

#project()#工程名，建议加上,这一行会引入两个变量XXX_BINARY_DIR (二进制文件保存路径)和 XXX_SOURCE_DIR(源代码保存路径)

add_definitions(-std=c++11)#确定编译语言，也可以用set(CMAKE_CXX_STANDARD 11),默认什么语言都支持
add_definitions(-g -o2)

#define cuda,opencv,cudnn，设定变量如darknet中代码编译需要define变量GPU，CUDNN，OPENCV等，则用该语句进行定义
ADD_DEFINITIONS( -DGPU -DCUDNN ) 

# use opencv
set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} "/usr/local/share/OpenCV")
find_package(OpenCV 3.2.0 REQUIRED)#令CMake搜索所有名为Find.cmake的文件
if(NOT OpenCV_FOUND)
  message(WARNING "OpenCV not found!")
else()
  include_directories(${OpenCV_INCLUDE_DIRS})
endif()

find_path(ROCKSDB_INCLUDE_PATH NAMES rocksdb/db.h)
find_library(ROCKSDB_LIB NAMES rocksdb)
if ((NOT ROCKSDB_INCLUDE_PATH) OR (NOT ROCKSDB_LIB))
    message(FATAL_ERROR "Fail to find rocksdb")
endif()

# CUDA path
include_directories(/usr/local/cuda-8.0/include/)
# headers
include_directories(${PROJECT_SOURCE_DIR}/include)

#sources，通过设定SRC变量，将源代码路径都给SRC，如果有多个，可以直接在后面继续添加，
set(SRC  ${PROJECT_SOURCE_DIR}/test.cpp)
#lib link
link_directories(${PROJECT_SOURCE_DIR})
#build so
add_executable(Test ${SRC})
target_link_libraries(Test ${OpenCV_LIBS})
target_link_libraries(Test -llianghao  -lpthread -lm -lstdc++)
```

** 基本用法解释**

1. .确定cmake最低版本需求
  ```
  cmake_minimum_required(VERSION 3.0.0)
  ```
2. 确定工程名
```
project(XXX)
```
这个不是必须，但是最好写一下，这一行会引入两个变量XXX_BINARY_DIR (二进制文件保存路径)和 XXX_SOURCE_DIR(源代码保存路径)

3. 添加需要的库
```
set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} "/usr/local/share/OpenCV")
find_package(OpenCV 3.2.0 REQUIRED)
```
find_package令CMake搜索所有名为Find.cmake的文件，3.2.0 REQUIRED给出需要的具体版本，以避免一台电脑安装了多个版本opencv而造成不必要的错误。通常情况下，通过设置CMAKE_PREFIX_PATH来设置CMake搜索路径，通常情况下不加也可以，但考虑到代码的可移植性，最好还是对搜索路径进行对应设置

4. 添加需要的头文件
```
include_directories(include)#将头文件所在路径写在括号内即可（上例中将头文件放在了include文件夹中
include_directories(${OpenCV_INCLUDE_DIRS})#而需要的一些库的头文件可以如2行变量的形式
include_directories(/usr/local/cuda-8.0/#include/)#也可以如3行直接给出库头文件所在的位置
```

5. 确定编译语言
以使用c++为例，可以用set来设定
```
set(CMAKE_CXX_STANDARD 11)
```
也可以通过add_definitions来设定
```
add_definitions(-std=c++11)
```

6. 设定变量
```
ADD_DEFINITIONS( -DGPU -DCUDNN )#如darknet中代码编译需要define变量GPU，CUDNN，OPENCV等，则用该语句进行定义
```

7. .添加源代码
```
set(SRC  ${PROJECT_SOURCE_DIR}/test.cpp)
```
通过设定SRC变量，将源代码路径都给SRC，如果有多个，可以直接在后面继续添加：
```
set(SRC 
    ${PROJECT_SOURCE_DIR}/src/detector.cpp
    ${PROJECT_SOURCE_DIR}/src/demo.cpp
    ${PROJECT_SOURCE_DIR}/test.cpp
)
```

8. 编译动态库并链接库文件
```
link_directories(${PROJECT_SOURCE_DIR})
add_library(plate_recognition SHARED ${SRC}) 
target_link_libraries(plate_recognition ${OpenCV_LIBS})
target_link_libraries(plate_recognition -llianghao  -lpthread -lm -lstdc++)
```
add_library为生成库文件，SHARED为生成动态库，STATIC为生成静态库，前面的plate_recognition为生成的文件名，如上生成的动态库为libplate_recognition.so，最后${SRC}为源文件路径。 
target_link_libraries为链接需要的库，plate_recognition为需要进行链接的文件名，后面接需要链接的库，如第三行链接了opencv。如果需要链接其他的动态库，-l后接去除lib前缀和.so后缀的名称，以链接liblianghao.so为例，-llianghao。

9. 生成可执行文件
```
link_directories(${PROJECT_SOURCE_DIR})
add_executable(Test ${SRC})
target_link_libraries(Test ${OpenCV_LIBS})
target_link_libraries(Test -llianghao  -lpthread -lm -lstdc++)
```
和8中只有第二行的区别，add_executable表示生成可执行文件，Test为生成的可执行文件名，后接源文件路径。

## 7.CmakeLists.txt文件其他语法
[here](https://blog.csdn.net/u011728480/article/details/81480668)

### 7.1 add_subdirectory
[here](https://www.cnblogs.com/qiumingcheng/p/8012128.html)
将指定的文件夹加到build任务列表中

### 7.2 编译选项CMAKE_CXX_FLAGS或CMAKE_C_FLAGS等
设置编译选项可以通过add_compile_options命令，也可以通过set命令修改CMAKE_CXX_FLAGS或CMAKE_C_FLAGS。 
add_compile_options命令添加的编译选项是针对所有编译器的(包括c和c++编译器)，而set命令设置CMAKE_C_FLAGS或CMAKE_CXX_FLAGS变量则是分别只针对c和c++编译器的
[here](https://blog.csdn.net/10km/article/details/51731959)

<font color ='red'>重要：</font>
```
CMAKE_INSTALL_PREFIX  #make install 的安装路径,和DESTINATION使用
CMAKE_BUILD_TYPE #生成的目标为debug或者release
CMAKE_C_FLAGS #gcc 的编译参数指定，这个非常好用，一般通过set 修改其值
CMAKE_CXX_FLAGS #g++ 和上面CMAKE_C_FLAGS 类似
CMAKE_CURRENT_SOURCE_DIR # 当前CMakeLists.txt所在的目录，主要用来定位某文件
CMAKE_CURRENT_BINARY_DIR # 当前CMakeLists.txt对应的编译时的目录

```

### 流控制语句

条件语句
```
if(xxx)
...
elseif(xx)
...
else()
...
endif()

#常见条件语句用法为:
# if (va)  va为bool型
# if （va MATCHES xxx） va 是string类型，如果va包含了xxx，则此句为真
```

循环语句
```
foreach(va va_lists)
...
endforeach()
```

在foreach中，va的值会依次被va_lists的值替换

#####macro 和 function
```
macro(name arg ...)
...
endmacro()
function(name arg ...)
...
endfunction()
```
宏和函数效果都类似，唯一区别为function中的变量为局部的。

#####install 指令（主要是生成Makefile中的install target）


INSTALL指令用于定义安装规则，安装的内容可以包括目标二进制、动态库、静态库以及 
文件、目录、脚本等。目标类型也就相对应的有三种，ARCHIVE特指静态库，LIBRARY特指动态库，RUNTIME 特指可执行目标二进制。
[here](https://blog.csdn.net/guoyajie1990/article/details/78138636)
语法
```
INSTALL(TARGETS targets...
        [[ARCHIVE|LIBRARY|RUNTIME]
                   [DESTINATION <dir>]
                   [PERMISSIONS permissions...]
                   [CONFIGURATIONS
        [Debug|Release|...]]
                   [COMPONENT <component>]
                   [OPTIONAL]
                ] [...])
```
参数中的TARGETS后面跟的就是我们通过ADD_EXECUTABLE或者ADD_LIBRARY定义的 
目标文件，可能是可执行二进制、动态库、静态库。

目标类型也就相对应的有三种，ARCHIVE特指静态库，LIBRARY特指动态库，RUNTIME 
特指可执行目标二进制。

DESTINATION定义了安装的路径，如果路径以/开头，那么指的是绝对路径，这时候 
CMAKE_INSTALL_PREFIX其实就无效了。如果你希望使用CMAKE_INSTALL_PREFIX来 
定义安装路径，就要写成相对路径，即不要以/开头，那么安装后的路径就是 
${CMAKE_INSTALL_PREFIX}/<DESTINATION定义的路径>
举个简单的例子：
```
INSTALL(TARGETS myrun mylib mystaticlib
       RUNTIME DESTINATION bin
       LIBRARY DESTINATION lib
       ARCHIVE DESTINATION libstatic
)
```
上面的例子会将： 
可执行二进制myrun安装到${CMAKE_INSTALL_PREFIX}/bin目录 
动态库libmylib安装到${CMAKE_INSTALL_PREFIX}/lib目录 
静态库libmystaticlib安装到${CMAKE_INSTALL_PREFIX}/libstatic目录 
特别注意的是你不需要关心TARGETS具体生成的路径，只需要写上TARGETS名称就可以 


**普通文件的安装**：
```
INSTALL(FILES files... DESTINATION <dir>
         [PERMISSIONS permissions...]
         [CONFIGURATIONS [Debug|Release|...]]
         [COMPONENT <component>]
         [RENAME <name>] [OPTIONAL])
可用于安装一般文件，并可以指定访问权限，文件名是此指令所在路径下的相对路径。
如果默认不定义权限PERMISSIONS，安装后的权限为,OWNER_WRITE,OWNER_READ,
GROUP_READ,和WORLD_READ，即644权限。
```
例子：
```
install(FILES flie DESTINATION dir_path) #执行make install时，把file拷贝到dir_path
install(PROGRAMS file DESTINATION dir_path) #执行make install时，把file拷贝到dir_path,并给予file可执行权限
INSTALL(TARGETS  ylib ylib_s
    #RUNTIME DESTINATION xxx
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)# 安装libylib.so到lib目录，安装libylib_s.a到lib目录，RUNTIME 是安装可执行文件到xxx目录，注意这个指令有个坑，我后面会说明这个问题。
```

**非目标文件的可执行程序安装(比如脚本之类)**
```
INSTALL(PROGRAMS files... DESTINATION <dir>
     [PERMISSIONS permissions...]
     [CONFIGURATIONS [Debug|Release|...]]
     [COMPONENT <component>]
     [RENAME <name>] [OPTIONAL])
```
跟上面的FILES指令使用方法一样，唯一的不同是安装后权限为: 
OWNER_EXECUTE, GROUP_EXECUTE, 和WORLD_EXECUTE，即755权限

**目录的安装**
```
INSTALL(DIRECTORY dirs... DESTINATION <dir>
     [FILE_PERMISSIONS permissions...]
     [DIRECTORY_PERMISSIONS permissions...]
     [USE_SOURCE_PERMISSIONS]
     [CONFIGURATIONS [Debug|Release|...]]
     [COMPONENT <component>]
     [[PATTERN <pattern> | REGEX <regex>]
      [EXCLUDE] [PERMISSIONS permissions...]] [...])
```
这里主要介绍其中的DIRECTORY、PATTERN以及PERMISSIONS参数。 
DIRECTORY后面连接的是所在Source目录的相对路径，但务必注意： 
abc和abc/有很大的区别。 
abc意味着abc这个目录会安装在目标路径下； 
abc/意味着abc这个目录的内容会被安装在目标路径下； 
如果目录名不以/结尾，那么这个目录将被安装为目标路径下的abc，如果目录名以/结尾， 
代表将这个目录中的内容安装到目标路径，但不包括这个目录本身。 
PATTERN用于使用正则表达式进行过滤， 
PERMISSIONS用于指定PATTERN过滤后的文件权限。

简单例子：
```
INSTALL(DIRECTORY icons scripts/ DESTINATION share/myproj
        PATTERN "CVS" EXCLUDE
        PATTERN "scripts/*"
        PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
        GROUP_EXECUTE GROUP_READ)
```
**安装时cmake脚本的执行**
```
INSTALL([[SCRIPT <file>] [CODE <code>]] [...])
SCRIPT参数用于在安装时调用cmake脚本文件（也就是<abc>.cmake文件）
CODE参数用于执行CMAKE指令，必须以双引号括起来。比如：
INSTALL(CODE "MESSAGE(\"Sample install message.\")"
```

#####一个关于install（）指令的深坑
```
INSTALL(TARGETS  ylib ylib_s
    #RUNTIME DESTINATION xxx
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
#对于RUNTIME  和 LIBRARY 两种目标，在安装时候，cmake会默认给你移除掉目标文件中的gcc的Wl,rpath的值，导致某些库找不到的错误。
以下变量会影响此坑，更详细的信息去查查别的资料，我这里就不详细说明了。
#set(CMAKE_SKIP_BUILD_RPATH FALSE)                
#set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)        
#set(CMAKE_INSTALL_RPATH "")                      
#set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)    
#set(CMAKE_SKIP_INSTALL_RPATH TRUE)
#set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

#set(CMAKE_SKIP_RPATH TRUE)
#set(CMAKE_SKIP_INSTALL_RPATH TRUE)
```

#####configure_file指令
```
configure_file(fileA fileB @ONLY)
#把fileA 复制并重命名为fileB,此时，fileA中的@var@的值会被替换为cmakelists.txt 中var的值。@ONLY是只转换@va@这种变量
```

####cross compile
2019/5/17更新
```
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_SYSROOT /home/X/hisi3531d/v600_toolchains/arm-hisiv600-linux/target)
set(CMAKE_STAGING_PREFIX /home/X/libwebsockets/_install)

set(tools /home/X/hisi3531d/v600_toolchains/arm-hisiv600-linux/target)
set(CMAKE_C_COMPILER ${tools}/bin/arm-hisiv600-linux-gcc)
set(CMAKE_CXX_COMPILER ${tools}/bin/arm-hisiv600-linux-g++)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
```
#####XXXConfig.cmake文件（cmake模块文件）编写以及引用
yLibConfig.cmake

```
find_path(yLib_INCLUDE_DIR NAMES ylib.h PATHS @CMAKE_INSTALL_PREFIX@/include) 

find_library(yLib_LIBRARY NAMES ylib PATHS @CMAKE_INSTALL_PREFIX@/lib) 
#find_library 会到@CMAKE_INSTALL_PREFIX@/lib目录查询libylib.so


set(yLib_FOUND TRUE) 
set(yLib_INCLUDE_DIRS ${yLib_INCLUDE_DIR}) 
set(yLib_LIBS ${yLib_LIBRARY}) 


mark_as_advanced(yLib_INCLUDE_DIRS yLib_LIBS )
```
XXX_INCLUDE_DIR
XXX_LIBRARY
XXX_FOUND
XXX_INCLUDE_DIRS
XXX_LIBS
以上变量最好都定义了，不然find_package可能会报错
.cmake 文件就是定义了相关include变量和lib变量，没有什么其他的东西

调用：
```
set(yLib_DIR "@CMAKE_INSTALL_PREFIX@/cmake")
#设置.cmake 的目录所在
find_package(yLib REQUIRED)
#find_package会导入.cmake 中的相关变量，完成相关模块的导入
```
