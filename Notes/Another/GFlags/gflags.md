# Gflags

## gflags 安装

```shell
git clone https://github.com/gflags/gflags.git
cd gflags/
mkdir build
cd build/
cmake ..
make
make install
```

## gflags 支持以下格式

- DEFINE_bool: boolean
- DEFINE_int32: 32-bit integer
- DEFINE_int64: 64-bit integer
- DEFINE_uint64: unsigned 64-bit integer
- DEFINE_double: double
- DEFINE_string: C++ string

## 定义后使用，初始化参数

```c++
google::ParseCommandLineFlags(&argc, &argv, true);
// 第三个参数：表示把识别的参数从argc/argv中删除
```

`argc`和`argv`就是 main 的入口参数，因为这个函数会改变他们的值，所以都是以指针传入。例如，test_argv.cpp：

```c++
#include <iostream>

using namespace std;

int main(int argc, char* argv[]){
	cout << argc << endl;
	int len = sizeof(argv);
	for(int i = 0; i<len; i++){
		cout << argv[i] << endl;
	}
	return 0;
}
```

运行结果：

```c++
[root@artist test_gflags]# g++ -o test test_argv.cpp
[root@artist test_gflags]# ./test asdf dfsf sdfsdf sdfsdf
5
./test
asdf
dfsf
sdfsdf
sdfsdf
```

第三个参数被称为`remove_flags`。如果它是`true`,`ParseCommandLineFlags`会从`argv`中移除标识和它们的参数，相应减少`argc`的值。然后 argv 只保留命令行参数。

相反，`remove_flags`是`false`,`ParseCommandLineFlags`会保留`argc`不变，但将会重新调整它们的顺序，使得标识再前面。

注：`./sample --big_menu=false arg1`中`big_menu`是标识，`false`是它的参数，`arg1`是命令行参数。

例如，`test_argv.cpp`：

```c++
#include <iostream>
#include <gflags/gflags.h>

using namespace std;

DEFINE_string(attachment, "thi is attachment", "Carry this along with requests");

int main(int argc, char* argv[]){

    google::ParseCommandLineFlags(&argc, &argv, false);
    cout << "attachment: " << FLAGS_attachment << endl; 
    cout << argc << endl;
    int len = sizeof(argv);
    for(int i = 0; i<len; i++){
        cout << argv[i] << endl;
    }
    return 0;
}
```

运行结果：

```shell
[root@artist test_gflags]# ./test -attachment=123
attachment: 123
2
./test
-attachment=123
```

但将第三个参数改为true： `google::ParseCommandLineFlags(&argc, &argv, true);`，运行结果为：

```shell
[root@artist test_gflags]# ./test -attachment=123
attachment: 123
1
./test
```

可以看到，`argc`和`argv`的值发生了改变。

## 运行时的参数

一般使用flag的原因是为了能在命令行指定一个非默认值。以 foo.cc 为例，可能的用法是：

```shell
app_containing_foo --nobig_menu -languages="chinese,japanese,korean" ...
```

执行 `ParseCommandLineFlags` 会设置 `FLAGS_big_menu = false` ， `FLAGS_languages = "chinese,japanese,korean"` 。

注意这种在名字前面加“no”的设置布尔flag为false的语法。

设置“languages”flag的方法有：

```shell
app_containing_foo --languages="chinese,japanese,korean"
app_containing_foo -languages="chinese,japanese,korean"
app_containing_foo --languages "chinese,japanese,korean"
app_containing_foo -languages "chinese,japanese,korean"
```

布尔flag稍有不同：

```shell
app_containing_foo --big_menu
app_containing_foo --nobig_menu
app_containing_foo --big_menu=true
app_containing_foo --big_menu=false

# 还包括以上这些的单短线的变种
```

建议只使用一种形式：非布尔flag， `--variable=value` ；布尔flag， `--variable/--novariable` 。保持一致性有一定的好处。

在命令行使用未定义的flag会在执行时失败。如果需要允许未定义的flag，可以使用 `--undefok` 来去掉报错。



## 多文件中使用 gflags 参数（使用DECLARE）

若需要在其它文件中使用gflags的变量，可以使用宏定义声明下：DECLARE_xxx(变量名)，之后在代码中便可以使用FLAGS_XXX格式使用命令行的参数了。

> 可以在任何源文件中定义flag，但是每个只能定义一次。如果需要在多处使用，那么在一个文件中 `DEFINE` ，在其他文件中 `DECLARE` 。比较好的方法是在 .cc 文件中 `DEFINE` ，在 .h 文件中 `DECLARE` ，这样包含头文件即可使用flag了。
>
> 注意： `DEFINE_foo` 和 `DECLARE_foo` 是全局命名空间的。
>
> 注意：`DECLARE_*`要在`ParseCommandLineFlags()`前。

例如，gflagdef.h：

```c++
#ifndef _GFLAG_DEF_H_
#define _GFLAG_DEF_H_
#include <gflags/gflags.h>

DECLARE_int32(port); // <----注意！这里只能使用 DECLARE 而非 DEFINE。
DECLARE_string(host);
DECLARE_bool(sign);

#endif
```

gflagdef.cpp：

```c++
#include <gflags/gflags.h>
DEFINE_int32(port, 9001, "The server port");
DEFINE_string(host, "127.0.0.1", "listen port");
DEFINE_bool(sign, true, "switch mode");
```

main.cpp：

```c++
#include <iostream>
#include "gflagdef.h"
using namespace std;
int main(int argc, char** argv) {
    google::ParseCommandLineFlags(&argc, &argv, true); // <-- 这条语句进行赋值。
    cout << "host = " << FLAGS_host << endl;
    cout << "port = " << FLAGS_port << endl;
    if (FLAGS_sign) {
        cout << "sign is true ..." << endl;
    }   
    else {
        cout << "sign is false ..." << endl;
    }   
    google::ShutDownCommandLineFlags();
    return 0;
}
```

编译：

```shell
 g++ -std=c++11 -o run gflagdef.cpp main.cpp -lgflags -lpthread
```

运行效果：

```shell
[root@artist test_gflags]# ./run
host = 127.0.0.1
port = 9001
sign is true ...
[root@artist test_gflags]# ./run -host=122.122.122.122
host = 122.122.122.122
port = 9001
sign is true ...
```

使用`DECLEAR_*`相当于做了`extern FLAGS_big_menu`。

## RegisterFlagValidator: 验证flag值

你可能想给定义的flag注册一个验证函数。这样当flag从命令行解析，或者值被修改（通过调用 `SetCommandLineOption()` ），验证函数都会被调用。验证函数应该在flag值有效时返回true，否则返回false。如果对新设置的值返回false，flag保持当前值；如果对默认值返回false， `ParseCommandLineFlags` 会失败。

```c++
static bool ValidatePort(const char* flagname, int32 value) {
   if (value > 0 && value < 32768)   // value is ok
     return true;
   printf("Invalid value for --%s: %d\n", flagname, (int)value);
   return false;
}
DEFINE_int32(port, 0, "What port to listen on");
static const bool port_dummy = RegisterFlagValidator(&FLAGS_port, &ValidatePort);
```

在全局初始化时注册（ `DEFINE` 之后），这样就在解析命令行之前执行。

## 定制自己的 help 和 version 信息

- version信息：使用google::SetVersionString(const std::string& usage)设定，使用google::VersionString访问
- help信息：使用google::SetUsageMessage(const std::string& usage)设定，使用google::ProgramUsage访问
- 注意：google::SetUsageMessage和google::SetVersionString必须在google::ParseCommandLineFlags之前执行

​     一般在main函数的头几行编写这些信息。

## 使用文件配置参数ss'd's

myflags:

```ini
--attachment=123
--number=abc
```

运行语句：

```shell
./test --flagfile=myflags
```

相当于：

```shell
./test --attachment=123 --number=abc
```

使用文件配置可以在配置文件中嵌套文件，例如将 myflags 更改为：

```ini
--attachment=123
--number=001
--flagfile=secondflags
```

增加一个 secondflags：

```ini
--second=999
```

运行 `./test --flagfile=myflags`相当于：

```ini
./test --attachment=123 --number=abc --second=999
```

注意：配置文件中不能有空格。



## 所有特殊 flag

```
用于打印信息：

--help	显示所有文件的所有flag，按文件、名称排序，显示flag名、默认值和帮助
--helpfull	和 --help 相同，显示全部flag
--helpshort	只显示执行文件中包含的flag，通常是 main() 所在文件
--helpxml	类似 --help，但输出为xml
--helpon=FILE	只显示定义在 FILE.* 中得flag
--helpmatch=S	只显示定义在 *S*.* 中的flag
--helppackage	显示和 main() 在相同目录的文件中的flag
--version	打印执行文件的版本信息
```

```
忽略无定义未使用的flag：

--undefok=flagname,flagname,...
```

```
其他：

--fromenv=foo,bar 表示从环境变量中读取 foo 和 bar flag。需要在环境中预先设置对应的值：
export FLAGS_foo=xxx; export FLAGS_bar=yyy   # sh
setenv FLAGS_foo xxx; setenv FLAGS_bar yyy   # tcsh

--tryfromenv 和 --fromenv 类似，区别是在环境变量中没有定义 FLAGS_foo 时， --tryfromenv=foo 不会导致失败，这时会使用定义时指定的默认值。但是应用中没有定义 foo 仍会导致失败。

```

注意在flagfile中很多类型的错误会被忽略掉，比如不能识别的flag，没有指定值的flag。

一般形式的flagfile要复杂一些。写成一组文件名，每行一个，后面加上一组flag，每行一个的形式，可以有多组。文件名可以使用通配符（ `*` 和 `?` ），只有当前可执行模块名和其中一个文件名匹配时才会处理文件名后的flag。flagfile可以直接以一组flag开始，这时这些flag对应到当前可执行模块。

以 `#` 开头的行作为注释被忽略，前导空白和空行也都会被忽略。

flagfile中还可以使用 `--flagfile` flag来包含另一个flagfile。

flag会按顺序执行。从命令行开始，遇到flagfile时，执行文件，执行完再继续命令行中后面的flag。

## 其他一些细节

除以上的方法，还可以直接通过API来读取flag，以及它的默认值和帮助等信息。 `FlagSaver` 可以用来修改flag和自动撤销修改。还有一些读取 `argv` 的方法， `SetUsageMessage()` 和 `SetVersionString` 等等。可以参考 gflags.h。

如果加上：

```
#define STRIP_FLAG_HELP 1    // this must go before the #include!
#include <gflags/gflags.h>
```

可以去掉帮助信息。

-----

# 草稿纸

# 1 

因为总是报 google 的错，于是在 yum 上卸载了 gflags，重新安装。语句：

```shell
yum remove -y gflags-devel.x86_64
```

## 2

代码 `foo.cpp`：

```c++
#include <gflags/gflags.h>
#include <iostream>

DEFINE_string(attachment, "a", "Carry this along with requests");

//using namespace google;

int main(int argc, char* argv[]){
	
    //google::InitGoogleLogging(argv[0]); 
    //GFLAGS_NS::ParseCommandLineFlags(&argc, &argv, true);
    google::ParseCommandLineFlags(&argc, &argv, true);
    std::cout << "--------------------------------------" << std::endl;
    std::cout << FLAGS_attachment << std::endl;
    std::cout << "--------------------------------------" << std::endl;
    return 0;
}
```

编译：

```shell
g++ -std=c++11 -o run foo.cpp -lgflags
```

报错：

```shell
//usr/local/lib/libgflags.a(gflags.cc.o): In function `google::(anonymous namespace)::FlagRegistry::GlobalRegistry()':
gflags.cc:(.text+0x10a6): undefined reference to `pthread_rwlock_wrlock'
gflags.cc:(.text+0x10c6): undefined reference to `pthread_rwlock_unlock'
gflags.cc:(.text+0x1167): undefined reference to `pthread_rwlock_init'
gflags.cc:(.text+0x1180): undefined reference to `pthread_rwlock_init'
//usr/local/lib/libgflags.a(gflags.cc.o): In function `google::(anonymous namespace)::RegisterCommandLineFlag(char const*, char const*, char const*, google::(anonymous namespace)::FlagValue*, google::(anonymous namespace)::FlagValue*)':
gflags.cc:(.text+0x1426): undefined reference to `pthread_rwlock_wrlock'
gflags.cc:(.text+0x1446): undefined reference to `pthread_rwlock_unlock'
//usr/local/lib/libgflags.a(gflags.cc.o): In function `google::(anonymous namespace)::AddFlagValidator(void const*, bool (*)())':
gflags.cc:(.text+0x1644): undefined reference to `pthread_rwlock_unlock'
gflags.cc:(.text+0x165c): undefined reference to `pthread_rwlock_wrlock'
//usr/local/lib/libgflags.a(gflags.cc.o): In function `google::GetCommandLineOption(char const*, std::string*)':
gflags.cc:(.text+0x20ac): undefined reference to `pthread_rwlock_wrlock'
gflags.cc:(.text+0x20c4): undefined reference to `pthread_rwlock_unlock'
//usr/local/lib/libgflags.a(gflags.cc.o): In function `google::GetCommandLineFlagInfo(char const*, google::CommandLineFlagInfo*)':
gflags.cc:(.text+0x21d4): undefined reference to `pthread_rwlock_wrlock'
gflags.cc:(.text+0x21ec): undefined reference to `pthread_rwlock_unlock'
//usr/local/lib/libgflags.a(gflags.cc.o): In function `google::FlagSaver::FlagSaver()':
gflags.cc:(.text+0x24e5): undefined reference to `pthread_rwlock_unlock'
gflags.cc:(.text+0x24f6): undefined reference to `pthread_rwlock_wrlock'
//usr/local/lib/libgflags.a(gflags.cc.o): In function `google::FlagSaver::~FlagSaver()':
gflags.cc:(.text+0x266e): undefined reference to `pthread_rwlock_wrlock'
gflags.cc:(.text+0x2683): undefined reference to `pthread_rwlock_unlock'
//usr/local/lib/libgflags.a(gflags.cc.o): In function `google::ShutDownCommandLineFlags()':
gflags.cc:(.text+0x2f49): undefined reference to `pthread_rwlock_destroy'
//usr/local/lib/libgflags.a(gflags.cc.o): In function `google::SetCommandLineOptionWithMode(char const*, char const*, google::FlagSettingMode)':
gflags.cc:(.text+0x5a7c): undefined reference to `pthread_rwlock_wrlock'
gflags.cc:(.text+0x5a94): undefined reference to `pthread_rwlock_unlock'
//usr/local/lib/libgflags.a(gflags.cc.o): In function `google::ReadFlagsFromString(std::string const&, char const*, bool)':
gflags.cc:(.text+0x678d): undefined reference to `pthread_rwlock_unlock'
gflags.cc:(.text+0x67a4): undefined reference to `pthread_rwlock_unlock'
gflags.cc:(.text+0x67bb): undefined reference to `pthread_rwlock_wrlock'
gflags.cc:(.text+0x67d2): undefined reference to `pthread_rwlock_wrlock'
gflags.cc:(.text+0x67e8): undefined reference to `pthread_rwlock_unlock'
gflags.cc:(.text+0x67fd): undefined reference to `pthread_rwlock_wrlock'
//usr/local/lib/libgflags.a(gflags.cc.o): In function `google::ParseCommandLineFlagsInternal(int*, char***, bool, bool)':
gflags.cc:(.text+0x7771): undefined reference to `pthread_rwlock_unlock'
gflags.cc:(.text+0x7787): undefined reference to `pthread_rwlock_wrlock'
gflags.cc:(.text+0x779e): undefined reference to `pthread_rwlock_wrlock'
gflags.cc:(.text+0x77b9): undefined reference to `pthread_rwlock_unlock'
gflags.cc:(.text+0x77cf): undefined reference to `pthread_rwlock_wrlock'
gflags.cc:(.text+0x77e5): undefined reference to `pthread_rwlock_unlock'
//usr/local/lib/libgflags.a(gflags.cc.o): In function `google::GetAllFlags(std::vector<google::CommandLineFlagInfo, std::allocator<google::CommandLineFlagInfo> >*)':
gflags.cc:(.text+0xa598): undefined reference to `pthread_rwlock_unlock'
gflags.cc:(.text+0xa5b3): undefined reference to `pthread_rwlock_wrlock'
//usr/local/lib/libgflags.a(gflags.cc.o): In function `gflags_mutex_namespace::Mutex::~Mutex()':
gflags.cc:(.text._ZN22gflags_mutex_namespace5MutexD2Ev[_ZN22gflags_mutex_namespace5MutexD5Ev]+0x15): undefined reference to `pthread_rwlock_destroy'
//usr/local/lib/libgflags.a(gflags.cc.o): In function `gflags_mutex_namespace::Mutex::Unlock()':
gflags.cc:(.text._ZN22gflags_mutex_namespace5Mutex6UnlockEv[_ZN22gflags_mutex_namespace5Mutex6UnlockEv]+0x15): undefined reference to `pthread_rwlock_unlock'
collect2: error: ld returned 1 exit status
```

发现由许多 pthread 错误，于是后面加上：

```shell
g++ -std=c++11 -o run foo.cpp -lgflags -lpthread
```

编译成功。

这时再运行：

```shell
./run -attachment=123
```

结果为：

```
--------------------------------------
123
--------------------------------------
```

pthread 相关介绍移步：[pthread 使用入门](https://www.jianshu.com/p/88fdd500cf44)

## 3

增加了 `-version` 和 `-help`：

```c++
#include <gflags/gflags.h>
#include <iostream>

using namespace google;

DEFINE_string(attachment, "a", "Carry this along with requests");

static std::string g_version;
static std::string g_help;

std::string& getVersion(){
		g_version = "0.1";
		return g_version;
	}

std::string& getHelp(){
		g_help = "help info";
		return g_help;
	}

int main(int argc, char* argv[]){
	google::SetVersionString(getVersion()); // <-----主要增加了这里。
	google::SetUsageMessage(getHelp()); // <-----主要增加了这里。
    ParseCommandLineFlags(&argc, &argv, true);
    std::cout << "--------------------------------------" << std::endl;
    std::cout << FLAGS_attachment << std::endl;
    std::cout << "--------------------------------------" << std::endl;
    return 0;
}
```

## gflas.h

```c++
#ifndef GFLAGS_GFLAGS_H_
#  error The internal header gflags_gflags.h may only be included by gflags.h
#endif

#ifndef GFLAGS_NS_GFLAGS_H_
#define GFLAGS_NS_GFLAGS_H_


namespace gflags {


using GFLAGS_NAMESPACE::int32;
using GFLAGS_NAMESPACE::uint32;
using GFLAGS_NAMESPACE::int64;
using GFLAGS_NAMESPACE::uint64;

using GFLAGS_NAMESPACE::RegisterFlagValidator;
using GFLAGS_NAMESPACE::CommandLineFlagInfo;
using GFLAGS_NAMESPACE::GetAllFlags;
using GFLAGS_NAMESPACE::ShowUsageWithFlags;
using GFLAGS_NAMESPACE::ShowUsageWithFlagsRestrict;
using GFLAGS_NAMESPACE::DescribeOneFlag;
using GFLAGS_NAMESPACE::SetArgv;
using GFLAGS_NAMESPACE::GetArgvs;
using GFLAGS_NAMESPACE::GetArgv;
using GFLAGS_NAMESPACE::GetArgv0;
using GFLAGS_NAMESPACE::GetArgvSum;
using GFLAGS_NAMESPACE::ProgramInvocationName;
using GFLAGS_NAMESPACE::ProgramInvocationShortName;
using GFLAGS_NAMESPACE::ProgramUsage;
using GFLAGS_NAMESPACE::VersionString;
using GFLAGS_NAMESPACE::GetCommandLineOption;
using GFLAGS_NAMESPACE::GetCommandLineFlagInfo;
using GFLAGS_NAMESPACE::GetCommandLineFlagInfoOrDie;
using GFLAGS_NAMESPACE::FlagSettingMode;
using GFLAGS_NAMESPACE::SET_FLAGS_VALUE;
using GFLAGS_NAMESPACE::SET_FLAG_IF_DEFAULT;
using GFLAGS_NAMESPACE::SET_FLAGS_DEFAULT;
using GFLAGS_NAMESPACE::SetCommandLineOption;
using GFLAGS_NAMESPACE::SetCommandLineOptionWithMode;
using GFLAGS_NAMESPACE::FlagSaver;
using GFLAGS_NAMESPACE::CommandlineFlagsIntoString;
using GFLAGS_NAMESPACE::ReadFlagsFromString;
using GFLAGS_NAMESPACE::AppendFlagsIntoFile;
using GFLAGS_NAMESPACE::ReadFromFlagsFile;
using GFLAGS_NAMESPACE::BoolFromEnv;
using GFLAGS_NAMESPACE::Int32FromEnv;
using GFLAGS_NAMESPACE::Uint32FromEnv;
using GFLAGS_NAMESPACE::Int64FromEnv;
using GFLAGS_NAMESPACE::Uint64FromEnv;
using GFLAGS_NAMESPACE::DoubleFromEnv;
using GFLAGS_NAMESPACE::StringFromEnv;
using GFLAGS_NAMESPACE::SetUsageMessage;
using GFLAGS_NAMESPACE::SetVersionString;
using GFLAGS_NAMESPACE::ParseCommandLineNonHelpFlags;
using GFLAGS_NAMESPACE::HandleCommandLineHelpFlags;
using GFLAGS_NAMESPACE::AllowCommandLineReparsing;
using GFLAGS_NAMESPACE::ReparseCommandLineNonHelpFlags;
using GFLAGS_NAMESPACE::ShutDownCommandLineFlags;
using GFLAGS_NAMESPACE::FlagRegisterer;

#ifndef SWIG
using GFLAGS_NAMESPACE::ParseCommandLineFlags;
#endif


} // namespace gflags


#endif  // GFLAGS_NS_GFLAGS_H_
```





## 参考

https://www.cnblogs.com/LyndonYoung/articles/7993223.html

https://www.cnblogs.com/fnlingnzb-learner/p/9541349.html

https://gflags.github.io/gflags/ （官方）

http://www.yeolar.com/note/2014/12/14/gflags/ （中文翻译）



## 问题

1. makefile
2. 
3. 
4. 