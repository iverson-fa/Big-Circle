# CMake

## 一、单元测试 gtest

官方文档

- [CMake Tutorial](https://cmake.org/cmake/help/latest/guide/tutorial/index.html)
- [Modern Cmake 简体中文版](https://modern-cmake-cn.github.io/Modern-CMake-zh_CN/)
- [Googletest Primer](https://google.github.io/googletest/primer.html)
- [GoogleTest User’s Guide](https://google.github.io/googletest/)
- [source code](https://github.com/google/googletest)

**单元测试（Unit Testing）**，一般指对软件中的最小可测试单元进行检查和验证。最小可测试单元可以是指一个函数、一次调用过程、一个类等，不同的语言可能有不同的测试方法。

对于C/C++语言，单元测试一般是针对一个函数而言，单元测试的目的就是**检测目标函数在所有可能的输入下，函数的执行过程和输出是否符合预期**。可以说，单元测试是颗粒度最小的测试，对于软件开发而言，保证每个小的函数执行正确，才能保证利用这些小模块组合起来的系统能够正常工作。

和测试相关的另外一个重要概念是**测试用例(Test Case)**。百度百科给的定义是，测试用例是对一项特定的软件产品进行测试任务的描述，体现测试方案、方法、技术和策略，包括测试目标、测试环境、输入数据、测试步骤、预期结果、测试脚本等。

这个定义是比较广泛的，对于单元测试来说，就是测试在不同输入下，目标函数（模块）的预期执行过程和输出（返回值），每个不同的情形可以有一个或多个测试用例。**编写测试用例需要尽量覆盖所有输入情况（尤其是边界值、特殊值、异常值）**

`Google Test`是Google开源的一个跨平台的C++单元测试框架，简称`gtest`，它提供了非常丰富的测试断言、判断宏，极大方便开发者编写测试用例的流程，也是很多开源项目使用的测试框架。

### **1 将gtest源码加入项目**

`gtest`是一个开源的框架，代码位于github仓库：**[google/googletest](https://link.zhihu.com/?target=https%3A//github.com/google/googletest)**，本文介绍直接将`gtest`加入到项目中，通过`CMake`编译使用。

首先在项目根目录新建一个`third_party`目录，下载源码的最新release版本，并解压：

```text
➜ # mkdir third_party
➜ # cd third_party
➜ # wget https://codeload.github.com/google/googletest/zip/refs/tags/release-1.10.0
➜ # unzip googletest-release-1.10.0.zip
```

### **2 将gtest添加为子模块**

修改项目根目录的`CMakeLists.txt`文件，使用上一篇文章介绍的命令`add_subdirectory`，在开启单元测试时，添加`gtest`为子模块，并将对应头文件路径添加进来：

```text
enable_testing()
add_subdirectory(third_party/googletest-release-1.10.0)
include_directories(third_party/googletest-release-1.10.0/googletest/include)
```

此时执行命令：

```text
➜ # cmake -B cmake-build
➜ # cmake --build cmake-build
```

可以看到构建目录下多了一个目录`cmake-build/third_party/googletest-release-1.10.0`，并且`gtest`编译生成了4个新的库文件（`gtest`子模块的编译目标，位于目录`cmake-build/lib`下）：

1. libgtest.a
2. libgtest_main.a
3. libgmock.a
4. libgmock_main.a

其中`libgtest.a`提供单元测试相关的功能，`libgtest_main.a`提供单元测试的主入口，只有链接该库，测试用例就会编译成可执行文件；两个`mock`库也是类似的，主要提供数据库交互，网络连接等方面的模拟测试，这不是本文的重点。

此时就可以在链接其他目标时直接使用`gtest`的这4个编译目标（target）。

### **3 编写测试用例**

接下来直接修改先前的两个测试用例源文件，实现相同的测试功能：

1. test/c/test_add.c
2. test/c/test_minus.c

因为使用的是C++测试框架，所以上述两个源文件修改为`.cc`后缀。

在源文件中include头文件`gtest/gtest.h`，使用`gtest`测试用例定义宏来定义测试用例：

```text
TEST(test_case_name, test_name) {}
```

一个`test_case_name`下面可以包含多个不同（`test_name`）的测试。

`test/c/test_add.cc`内容为：

```text
#include "gtest/gtest.h"
#include "math/add.h"

TEST(TestAddInt, test_add_int_1) {
  int res = add_int(10, 24);
  EXPECT_EQ(res, 34);
}
```

`test/c/test_minus.cc`内容为：

```text
#include "gtest/gtest.h"
#include "math/minus.h"

TEST(TestMinusInt, test_minus_int_1) {
  int res = minus_int(40, 96);
  EXPECT_EQ(res, -56);
}
```

显而易见，测试用例的代码量比之前少了很多，而且更加可读，更加专业。

这里使用了一个判断值相等的断言`EXPECT_EQ`，`gtest`中的断言分成两大类：

1. **`ASSERT_\*`系列：如果检测失败就直接退出**当前函数
2. **`EXPECT_\*`系列：如果检测失败发出提示，并继续**往下执行

`gtest`有很多类似的宏用来判断数值的关系、判断条件的真假、判断字符串的关系。 对于**条件判断**可以使用：

```text
ASSERT_TRUE(condition);  // 判断条件是否为真
ASSERT_FALSE(condition); // 判断条件是否为假
```

对于**数值比较**可以使用：

```text
ASSERT_EQ(val1, val2); // 判断是否相等
ASSERT_NE(val1, val2); // 判断是否不相等
ASSERT_LT(val1, val2); // 判断是否小于
ASSERT_LE(val1, val2); // 判断是否小于等于
ASSERT_GT(val1, val2); // 判断是否大于
ASSERT_GE(val1, val2); // 判断是否大于等于
```

对于**字符串比较**可以使用：

```text
ASSERT_STREQ(str1,str2); // 判断字符串是否相等
ASSERT_STRNE(str1,str2); // 判断字符串是否不相等
ASSERT_STRCASEEQ(str1,str2); // 判断字符串是否相等，忽视大小写
ASSERT_STRCASENE(str1,str2); // 判断字符串是否不相等，忽视大小写
```

### **4 添加测试用例**

书写好测试用例源文件后，需要修改项目根目录的`CMakeLists.txt`：

```text
enable_testing()
add_subdirectory(third_party/googletest-release-1.10.0)
include_directories(third_party/googletest-release-1.10.0/googletest/include)
set(GTEST_LIB gtest gtest_main)

add_executable(test_add test/c/test_add.cc)
add_executable(test_minus test/c/test_minus.cc)
target_link_libraries(test_add math gtest gtest_main)
target_link_libraries(test_minus math gtest gtest_main)

add_test(NAME test_add COMMAND test_add)
add_test(NAME test_minus COMMAND test_minus)
```

对于一个单元测试来说，添加的步骤为：

1. 使用`add_executable`添加测试目标
2. 使用`target_link_libraries`为测试目标添加依赖`gtest`和`gtest_main`
3. 使用`add_test`添加到项目，以便可以使用`ctest`命令执行测试

需要注意的不同就是，依旧将单元测试的源文件编译为可执行文件，并且链接的时候链接了`gtest`和`gtest_main`。必须要链接`gtest_main`库，才能给单元测试添加main函数主入口，否则在链接的时候将会报错。

### **5 运行测试**

在构建编译完成后，进入构建目录，使用`ctest`命令执行测试即可。 常用的命令为：

```text
make test CTEST_OUTPUT_ON_FAILURE=TRUE GTEST_COLOR=TRUE
# 或者
GTEST_COLOR=TRUE ctest --output-on-failure
```

指定`--output-on-failure`或者设置`CTEST_OUTPUT_ON_FAILURE`变量为`TRUE`，让单元测试失败时输出具体信息，而`GTEST_COLOR`设置为`TRUE`可以让输出带有颜色，可以在详细输出模式下（-VV）更快找到错误的输出（如果有失败的测试）。