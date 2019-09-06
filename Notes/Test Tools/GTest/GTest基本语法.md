# GTest基本语法

## 一个最简单的测试

```
.
├── Add.cpp
├── Add.h
├── libgtest.a
└── testAdd.cc
```

Add.h：

```c++
#ifndef EXAMPLE_ADD_H
#define EXAMPLE_ADD_H

class Add{
public:
    int add(int a, int b);
};

#endif // EXAMPLE_ADD_H
```

Add.cpp：

```c++
#include <iostream>
#include "Add.h"

int Add::add(int a, int b){
    return a+b;
}
```

testAdd.cpp：

```c++
#include <gtest/gtest.h>
#include "Add.h"

TEST(Add, test0)
{
    Add a;
    EXPECT_EQ(a.add(2, 3), 5);
    //SERT_STREQ("1","1");
}

int main(int argc, char *argv[])
{
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
```

执行：

```shell
g++ -std=c++11 -o run Add.cpp testAdd.cpp -lpthread libgtest.a
```

上面的测试代码`testAdd.cpp`中我们使用了`TEST`这个宏，它有两个参数，官方的对这两个参数的解释为：[TestCaseName，TestName]，而我对这两个参数的定义是：[TestSuiteName，TestCaseName]。

对检查点的检查，我们上面使用到了`EXPECT_EQ`这个宏，这个宏用来比较两个数字是否相等。Google还包装了一系列`EXPECT_*` 和`ASSERT_*`的宏，而EXPECT系列和ASSERT系列的区别是：

1. `EXPECT_*`  失败时，案例继续往下执行。

2. `ASSERT_*` 失败时，直接在当前函数中返回，当前函数中`ASSERT_*`后面的语句将不会执行。 



## 断言

```c++
// 布尔值检查
ASSERT_TRUE(condition);
```

```c++
// 数值型相等
ASSERT_EQ(expected, actual);	EXPECT_EQ(expected, actual);	expected == actual

ASSERT_NE(val1, val2);	EXPECT_NE(val1, val2);	val1 != val2

ASSERT_LT(val1, val2);	EXPECT_LT(val1, val2);	val1 < val2

ASSERT_LE(val1, val2);	EXPECT_LE(val1, val2);	val1 <= val2

ASSERT_GT(val1, val2);	EXPECT_GT(val1, val2);	val1 > val2

ASSERT_GE(val1, val2);	EXPECT_GE(val1, val2);	val1 >= val2
```

```c++
// 字符串检查
ASSERT_STREQ(expected_str, actual_str);	EXPECT_STREQ(expected_str, actual_str);	the two C strings have the same content // 除了支持 char* 外，还支持 wchar_t*。

ASSERT_STRNE(str1, str2);	EXPECT_STRNE(str1, str2);	the two C strings have different content // 除了支持 char* 外，还支持 wchar_t*。

ASSERT_STRCASEEQ(expected_str, actual_str);	EXPECT_STRCASEEQ(expected_str, actual_str);	the two C strings have the same content, ignoring case // 不支持 wchar_t*。
    
ASSERT_STRCASENE(str1, str2);	EXPECT_STRCASENE(str1, str2);	the two C strings have different content, ignoring case // 不支持 wchar_t*。

```

```c++
// 异常检查
ASSERT_THROW(statement, exception_type);	EXPECT_THROW(statement, exception_type); // statement throws an exception of the given type

ASSERT_ANY_THROW(statement);	EXPECT_ANY_THROW(statement); // statement throws an exception of any type

ASSERT_NO_THROW(statement);	EXPECT_NO_THROW(statement); // statement doesn't throw any exception

```

```c++
// 显示参数
ASSERT_PRED1(pred1, val1);	EXPECT_PRED1(pred1, val1);

ASSERT_PRED2(pred2, val1, val2);	EXPECT_PRED2(pred2, val1, val2);

```

例如：

```c++
bool MutuallyPrime(int m, int n)
{
    return Foo(m , n) > 1;
}

TEST(PredicateAssertionTest, Demo)
{
    int m = 5, n = 6;
    EXPECT_PRED2(MutuallyPrime, m, n);
}
```

当失败时，返回错误信息：

```shell
error: MutuallyPrime(m, n) evaluates to false, where
m evaluates to 5
n evaluates to 6
```

就能看到哪个参数时函数失败了。

还可以自定义输出格式，通过如下：

```c++
ASSERT_PRED_FORMAT1(pred_format1, val1);  EXPECT_PRED_FORMAT1(pred_format1, val1);

ASSERT_PRED_FORMAT2(pred_format2, val1, val2);	EXPECT_PRED_FORMAT2(pred_format2, val1, val2);
```

示例：

```c++
testing::AssertionResult AssertFoo(const char* m_expr, const char* n_expr, const char* k_expr, int m, int n, int k) {
    if (Foo(m, n) == k)
        return testing::AssertionSuccess();
    testing::Message msg;
    msg << m_expr << " 和 " << n_expr << " 的最大公约数应该是：" << Foo(m, n) << " 而不是：" << k_expr;
    return testing::AssertionFailure(msg);
}

TEST(AssertFooTest, HandleFail)
{
    EXPECT_PRED_FORMAT3(AssertFoo, 3, 6, 2);
}
```

错误信息返回：

```
error: 3 和 6 的最大公约数应该是：3 而不是：2
```

```c++
// 浮点型检查
ASSERT_FLOAT_EQ(expected, actual);	EXPECT_FLOAT_EQ(expected, actual);

ASSERT_DOUBLE_EQ(expected, actual);	EXPECT_DOUBLE_EQ(expected, actual);
```

```c++
// 允许一定误差的比较
ASSERT_NEAR(val1, val2, abs_error);	EXPECT_NEAR(val1, val2, abs_error); // the difference between val1 and val2 doesn't exceed the given absolute error
```

```c++
// 类型检查
template <typename T> class FooType {
public:
    void Bar() { testing::StaticAssertTypeEq<int, T>(); }
};

TEST(TypeAssertionTest, Demo)
{
    FooType<bool> fooType;
    fooType.Bar();
}
```



## 事件机制

gtest提供了多种事件机制，非常方便我们在案例之前或之后做一些操作。总结一下gtest的事件一共有3种：

1. 全局的，所有案例执行前后。

2. TestSuite级别的，在某一批案例中第一个案例前，最后一个案例执行后。

3. TestCase级别的，每个TestCase前后。

### 全局事件

要实现全局事件，必须写一个类，继承testing::Environment类，实现里面的SetUp和TearDown方法。

1. SetUp()方法在所有案例执行前执行

2. TearDown()方法在所有案例执行后执行

```c++
#include <iostream>
#include <gtest/gtest.h>

class FooEnvironment : public testing::Environment{ // 注意这里。
public:
    virtual void SetUp(){
        std::cout << "----测试开始----" << std::endl;
    }
    virtual void TearDown(){
        std::cout << "----测试结束----" << std::endl;
    }
};

TEST(TESTNo, test01){
    int a = 1;
    int b = 1;
    EXPECT_EQ(a, b);
}

TEST(TESTNo2, test02){
    int a = 2;
    int b = 2;
    EXPECT_EQ(a, b);
}

int main(int argc, char* argv[])
{
    testing::AddGlobalTestEnvironment(new FooEnvironment); // 注意这里。
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
```

输出效果：

```
[==========] Running 2 tests from 2 test suites.
[----------] Global test environment set-up.
----测试开始----
[----------] 1 test from TESTNo
[ RUN      ] TESTNo.test01
[       OK ] TESTNo.test01 (0 ms)
[----------] 1 test from TESTNo (0 ms total)

[----------] 1 test from TESTNo2
[ RUN      ] TESTNo2.test02
[       OK ] TESTNo2.test02 (0 ms)
[----------] 1 test from TESTNo2 (0 ms total)

[----------] Global test environment tear-down
----测试结束----
[==========] 2 tests from 2 test suites ran. (0 ms total)
[  PASSED  ] 2 tests.
```

