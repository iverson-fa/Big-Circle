# C++高频面试题：智能指针、多态、虚函数、STL原理

[原文参考](https://mp.weixin.qq.com/s/Xhd7OB8Vzvngd6i4CzGeng)

在C++面试中，智能指针、多态、虚函数及STL原理是贯穿各职级的核心考点，直接决定面试官对候选人基础功底与工程能力的评判。这四大知识点紧密关联，覆盖内存管理、面向对象核心及标准库底层逻辑，是区分“会用”与“精通”C++的关键。

- **智能指针** 是内存安全的核心工具，其底层实现、循环引用问题及 `unique_ptr`、`shared_ptr`、`weak_ptr` 的适用场景是面试必问内容，直接体现对内存泄漏的防控意识。
- **多态与虚函数** 相辅相成，虚函数表机制、动态绑定原理及纯虚函数设计意义，是理解面向对象三大特性的核心，也是架构设计面试的高频切入点。
- **STL原理** 聚焦 `vector`、`list`、`map` 等容器的底层结构、迭代器实现及算法效率，反映候选人的性能优化认知。

掌握这四大考点，既能应对基础问答，也能在项目场景题中展现严谨逻辑，为面试加分。

## 一、智能指针实现原理

在C++98里，标准库提供一个 `std::auto_ptr` 的实现，以应对C++需要程序员自己管理内存资源广泛存在的问题，诸如野指针，内存泄漏，内存重复释放等。

智能指针的基本需求：
* **自动析构**：这是最核心的特征，紧随其后的 `unique_ptr`、`shared_ptr` 这些进阶版的指针封装类型无不立足于此。
* **具有基本指针类型的行为特征**：支持引用、解引用，运算符 `*`、`->`。

### 1.1 基础实现（仅自动析构）
```cpp
template <class T>
class MyAutoPtr {
public:
    MyAutoPtr(T *ptr): _ptr(ptr) { }
    ~MyAutoPtr() {
        delete _ptr;
    }
    T *_ptr; // 公开成员，不安全
};
```
**使用示例与问题**：
```cpp
MyAutoPtr<int> p(new int(5)); // 可以自动释放
std::cout << *p._ptr << std::endl; // 必须暴露 _ptr，不安全
// 若不小心 delete p._ptr，析构时会重复释放，导致错误。
```

### 1.2 改进版（隐藏指针，重载运算符）
```cpp
template <class T>
class MyAutoPtr {
public:
    MyAutoPtr(T *ptr): _ptr(ptr) { }
    ~MyAutoPtr() {
        delete _ptr;
    }
    T operator*() {
        return *get();
    }
    T *operator->() {
        return get();
    }
    T *get() {
        return _ptr;
    }
private:
    T *_ptr; // 变为私有
};
```

### 1.3 处理复制与赋值
智能指针的复制和赋值需要小心处理，避免重复释放。
```cpp
template <class T>
class MyAutoPtr {
public:
    // ... 其他成员同上 ...

    // 拷贝构造函数（转移所有权）
    MyAutoPtr(MyAutoPtr &other) {
        T* tmp_p = _ptr;
        _ptr = nullptr;
        tmp_p = other.get(); // 交出控制权
    }

    // 赋值运算符重载（转移所有权）
    MyAutoPtr& operator=(MyAutoPtr &right) {
        if (right.get() != _ptr)
            delete _ptr;
        _ptr = right.get();
        return *this;
    }
};
```
标准库中的 `auto_ptr` 抽象了两个关键操作：
* `T* release();`：交出内存控制权。
* `void reset(T* _Ptr = 0);`：重置指针指向。

这其实是C++11移动语义的雏形，隐含了资源转移的概念。

### 1.4 `auto_ptr` 的缺陷
1. **复制导致原指针失效**：
   ```cpp
   std::auto_ptr<Data> p(new Data(100, 200));
   std::auto_ptr<Data> q = p; // p的所有权转移给q
   std::cout << p->a << std::endl; // 错误！p._ptr 已被置为nullptr
   ```
2. **不能管理数组**：因为它使用 `delete` 而非 `delete[]`。
3. **不能用于标准库容器**：因为其特殊的“复制即转移”语义与容器要求的深拷贝行为冲突。

由于这些缺陷，**C++11已明确禁止使用 `auto_ptr`**。

### 1.5 C++11的改进：`unique_ptr` 与 `shared_ptr`
* **`unique_ptr`**：
  * 如其名，**禁止拷贝和赋值**，确保独占所有权。
  * 通过禁用拷贝构造函数和赋值运算符实现：
    ```cpp
    unique_ptr(const _Myt&) = delete;
    _Myt& operator=(const _Myt&) = delete;
    ```
  * 但可以通过 `std::move` **转移所有权**：
    ```cpp
    std::unique_ptr<int> q(new int(10));
    std::unique_ptr<int> p = std::move(q); // 正确：所有权转移
    ```
* **`shared_ptr`**：
  * 允许多个指针共享同一块内存。
  * 通过**引用计数**技术实现：复制时计数加1，析构时减1，计数为0时释放内存。

## 二、智能指针的计数器何时改变？
智能指针（特指 `shared_ptr`）的引用计数器在以下情况发生变化：

| 场景 | 计数器变化 |
| :--- | :--- |
| **初始化** | 新创建 `shared_ptr` 时，计数器初始化为 **1**。 |
| **拷贝构造函数** | 用一个 `shared_ptr` 初始化另一个时，计数器 **加1**。 |
| **赋值运算符重载** | 将一个 `shared_ptr` 赋值给另一个已存在的 `shared_ptr` 时：<br>1. 原左值指针的计数器 **减1**（若减至0则释放资源）。<br>2. 右值指针的计数器 **加1**。 |
| **析构/释放** | `shared_ptr` 离开作用域被销毁时，计数器 **减1**。当计数器减至 **0**，自动释放所管理的资源。 |

## 三、智能指针和管理的对象分别在哪个区？
| 部分 | 所在内存区域 | 说明 |
| :--- | :--- | :--- |
| **智能指针对象本身** | **栈区**（自动存储区） | 作为局部变量时，在栈上创建，离开作用域时自动销毁。 |
| **被管理的对象（资源）** | **堆区**（自由存储区） | 通过 `new` 操作符分配，由智能指针在适当时机（如引用计数为0时）调用 `delete` 释放。 |

## 四、面向对象的特性：多态原理
**多态**是面向对象编程的重要特性，它允许使用**基类的指针或引用**来调用**派生类对象**的方法，实现了**动态绑定**。

其原理核心：
1. 在基类中将函数声明为 **`virtual`（虚函数）**。
2. 在派生类中对该函数进行 **覆盖（`override`）**。
3. 当通过基类指针/引用调用该虚函数时，实际调用哪个版本取决于**运行时对象的实际类型**，而非指针的静态类型。

## 五、虚函数的实现机制
虚函数的实现依赖于 **虚函数表（vtable）** 和 **虚指针（vptr）**。

1. **虚函数表（vtable）**：
   * 编译器为每个**包含虚函数的类**生成一个虚函数表。
   * 该表是一个存储该类**所有虚函数地址**的数组。
2. **虚指针（vptr）**：
   * 编译器在包含虚函数的类的**每个对象中**添加一个隐藏的指针成员，即 `vptr`。
   * `vptr` 指向该对象所属类的 `vtable`。
3. **动态绑定过程**：
   * 当通过基类指针调用虚函数时，程序会：
       1. 通过对象内的 `vptr` 找到对应的 `vtable`。
       2. 在 `vtable` 中找到该虚函数的地址。
       3. 调用该地址指向的函数（派生类覆盖后的版本）。

**代码示例**：
```cpp
class Base {
public:
    virtual void display() {
        cout << "This is the base class." << endl;
    }
};

class Derived : public Base {
public:
    void display() override { // 覆盖基类中的display()方法
        cout << "This is the derived class." << endl;
    }
};

int main() {
    Base* ptr = new Derived(); // 基类指针指向派生类对象
    ptr->display(); // 输出: "This is the derived class."
    delete ptr;
    return 0;
}
```

## 六、多态和继承在什么情况下使用？

| 特性 | 适用场景 | 目的与优势 |
| :--- | :--- | :--- |
| **继承** | 1. 新类是现有类的特殊化（“是一个”关系）。<br>2. 需要**代码重用**，从基类继承通用属性和方法。<br>3. 建立清晰的**类层次结构**。 | 1. 避免重复编码，提高效率。<br>2. 建立逻辑关系，使代码更易理解。 |
| **多态** | 1. 处理**不同类型对象**，但希望使用**统一接口**。<br>2. 程序需要在运行时决定调用哪个类的方法。<br>3. 设计**框架或库**，允许用户通过派生类扩展功能。 | 1. 增强代码**灵活性和可扩展性**。<br>2. **解耦**接口与实现，降低模块间依赖性。 |

**核心关系**：多态通常建立在继承的基础上（通过虚函数覆盖），但也可以借助接口（纯虚类）实现。

## 七、面向对象的其他重要方法（除多态和继承）
除了**继承**和**多态**，**封装**是面向对象的第三大核心特性。此外，还有以下重要概念和方法：

| 概念/方法 | 核心思想 | 作用与益处 |
| :--- | :--- | :--- |
| **封装** | 将数据和操作数据的方法捆绑在类内，对外隐藏实现细节，仅暴露接口。 | 提高安全性、可维护性，使代码更模块化。 |
| **抽象** | 定义抽象类或接口，提取共同特征和行为，隐藏复杂细节。 | 帮助建立模型，支持代码重用和扩展。 |
| **组合** | 一个类将其他类的对象作为其成员变量（“有一个”关系）。 | 构建复杂对象，实现功能复用，比继承更灵活、耦合度低。 |
| **接口** | 定义一组纯虚函数，形成契约。类通过实现接口来提供特定功能。 | 实现多态，规范类行为，支持松耦合设计。 |
| **设计原则**<br>（如SRP, OCP, DIP） | 单一职责、开放-封闭、依赖倒置等指导高质量代码设计的原则。 | 提高代码的可读性、可维护性、可测试性和可扩展性。 |

## 八、C++内存分布。什么样的数据在栈区，什么样的在堆区

在C++中，栈区主要存储函数的参数值、局部变量、函数的返回地址等。这些数据在函数调用时自动分配，并在函数返回时自动释放，管理方式为自动管理。与栈区不同，堆区用于存储动态分配的内存，比如通过`new`或`malloc`申请的内存，这类内存需要程序员手动管理其生命周期。

这两种内存区域主要有以下区别：
- **栈区**：内存分配和释放由编译器自动完成，效率高但空间有限，通常用于存储函数调用过程中的临时数据。当栈空间耗尽时会发生栈溢出。
- **堆区**：内存分配和释放由程序员控制，空间较大但管理不当容易产生内存泄漏或碎片，通常用于存储生命周期不确定或较大的数据对象。

对于智能指针而言，其对象本身通常位于栈区，是一个局部变量；而智能指针所管理的资源（即通过`new`创建的对象）则位于堆区。智能指针利用栈对象在离开作用域时自动调用析构函数的特性，在析构函数中释放堆区的资源，从而实现自动内存管理。

除了栈区和堆区，C++程序的内存布局还包括：
- **全局/静态存储区**：存储全局变量和静态变量，在程序启动时分配，程序结束时释放。
- **常量存储区**：存储字符串常量和其它常量数据，这部分内存通常只读。
- **代码区**：存储程序的二进制指令代码。

了解这些内存区域的特性对于编写高效、安全的C++代码至关重要。特别是在使用指针和动态内存时，需要清楚所操作数据的内存位置及其生命周期。

## 九、STL原理剖析

STL（Standard Template Library，标准模板库）是C++最重要的组成部分之一，提供了一套通用的模板类和函数，实现了常见的数据结构和算法。STL的六大组件包括容器（Containers）、算法（Algorithms）、迭代器（Iterators）、仿函数（Functors）、适配器（Adapters）和空间配置器（Allocator）。

### 9.1 容器底层实现

#### vector
```cpp
template <class T, class Alloc = allocator<T>>
class vector {
protected:
    T* start;           // 指向数组头
    T* finish;          // 指向最后一个元素的下一个位置
    T* end_of_storage;  // 指向分配内存的末尾
};
```
vector采用动态数组实现，支持随机访问，在尾部插入和删除元素效率高（O(1)），但在中间或头部插入/删除需要移动后续元素（O(n)）。当容量不足时，vector会重新分配更大的内存（通常扩大到原来的1.5或2倍），并将原有元素拷贝到新空间。

#### list
```cpp
struct _ListNode_base {
    _ListNode_base* prev;
    _ListNode_base* next;
};

template <class T>
struct _ListNode : public _ListNode_base {
    T data;
};
```
list采用双向链表实现，插入和删除操作只需修改相邻节点的指针（O(1)），但不支持随机访问。每个节点除了存储数据外，还需要存储指向前后节点的指针，因此内存开销较大。

#### map/set
基于红黑树（一种自平衡二叉查找树）实现：
```cpp
template <class Key, class T, class Compare = less<Key>>
class map {
private:
    typedef _Rb_tree<Key, pair<const Key, T>, Compare> rep_type;
    rep_type t;  // 红黑树
};
```
红黑树确保查找、插入、删除的时间复杂度均为O(log n)，同时保持元素有序。红黑树的特性包括：
1. 每个节点是红色或黑色
2. 根节点是黑色
3. 所有叶子节点（NIL）是黑色
4. 红色节点的子节点必须是黑色
5. 从任一节点到其每个叶子的所有路径包含相同数量的黑色节点

#### unordered_map/unordered_set
基于哈希表实现，采用链地址法解决哈希冲突：
```cpp
template <class Key, class T, class Hash = hash<Key>>
class unordered_map {
private:
    vector<list<pair<Key, T>>> buckets;  // 桶数组
    size_t element_count;                // 元素数量
};
```
平均查找时间为O(1)，最坏情况下为O(n)。性能受哈希函数质量和负载因子影响。

### 9.2 迭代器与算法

迭代器是连接容器和算法的桥梁，提供统一的访问接口。STL算法不直接操作容器，而是通过迭代器访问和操作元素。

```cpp
// 迭代器分类
struct input_iterator_tag {};        // 输入迭代器
struct output_iterator_tag {};       // 输出迭代器
struct forward_iterator_tag {};      // 前向迭代器
struct bidirectional_iterator_tag {};// 双向迭代器
struct random_access_iterator_tag {};// 随机访问迭代器

// 算法示例：find
template <class InputIterator, class T>
InputIterator find(InputIterator first, InputIterator last, const T& value) {
    while (first != last && *first != value)
        ++first;
    return first;
}
```

### 9.3 空间配置器（Allocator）

STL默认使用std::allocator，其关键函数包括：
```cpp
template <class T>
class allocator {
public:
    T* allocate(size_t n);      // 分配内存
    void deallocate(T* p, size_t n);  // 释放内存
    void construct(T* p, const T& val);  // 构造对象
    void destroy(T* p);         // 析构对象
};
```

一些STL实现（如SGI STL）采用了两级配置器：
- 第一级直接使用malloc/free处理大块内存请求
- 第二级维护内存池处理小块内存，提高效率

## 十、C++11/14/17新特性

### 10.1 智能指针增强

C++11引入了一套完整的智能指针：

```cpp
// 创建方式
auto sp1 = make_shared<int>(42);      // 推荐
auto up1 = make_unique<int>(42);      // C++14

// weak_ptr解决循环引用
class B; class A {
    shared_ptr<B> b_ptr;
};
class B {
    weak_ptr<A> a_ptr;  // 使用weak_ptr打破循环
};
```

### 10.2 移动语义与右值引用

```cpp
// 移动构造函数
class MyString {
public:
    MyString(MyString&& other) noexcept
        : data(other.data), size(other.size) {
        other.data = nullptr;
        other.size = 0;
    }

private:
    char* data;
    size_t size;
};

// 完美转发
template<typename T>
void wrapper(T&& arg) {
    process(std::forward<T>(arg));
}
```

### 10.3 Lambda表达式

```cpp
// 基本语法
auto lambda = [capture-list](params) -> ret-type {
    // 函数体
};

// 示例
vector<int> nums = {1, 2, 3, 4, 5};
sort(nums.begin(), nums.end(),
     [](int a, int b) { return a > b; });
```

### 10.4 自动类型推导

```cpp
auto i = 42;            // int
auto d = 3.14;          // double
auto& ref = i;          // int&

// decltype类型推导
decltype(i) j = i * 2;  // int
```

### 10.5 并发支持

```cpp
#include <thread>
#include <mutex>
#include <future>

// 线程
std::thread t([](){ /* 任务 */ });
t.join();

// 互斥锁
std::mutex mtx;
std::lock_guard<std::mutex> lock(mtx);

// 异步任务
auto future = std::async(std::launch::async, [](){
    return compute();
});
int result = future.get();
```

## 十一、设计模式在C++中的应用

### 11.1 单例模式（Singleton）

```cpp
class Singleton {
public:
    static Singleton& getInstance() {
        static Singleton instance;  // C++11保证线程安全
        return instance;
    }

    // 删除拷贝构造函数和赋值运算符
    Singleton(const Singleton&) = delete;
    Singleton& operator=(const Singleton&) = delete;

private:
    Singleton() = default;
    ~Singleton() = default;
};
```

### 11.2 工厂模式（Factory）

```cpp
class Product {
public:
    virtual void operation() = 0;
    virtual ~Product() = default;
};

class ConcreteProduct : public Product {
public:
    void operation() override {
        // 具体实现
    }
};

class Factory {
public:
    static unique_ptr<Product> createProduct() {
        return make_unique<ConcreteProduct>();
    }
};
```

### 11.3 观察者模式（Observer）

```cpp
class Observer {
public:
    virtual void update(const string& message) = 0;
    virtual ~Observer() = default;
};

class Subject {
private:
    vector<Observer*> observers;

public:
    void attach(Observer* obs) {
        observers.push_back(obs);
    }

    void notify(const string& message) {
        for (auto obs : observers) {
            obs->update(message);
        }
    }
};
```

## 十二、性能优化与调试技巧

### 12.1 性能优化

1. **减少拷贝**：使用移动语义、引用传递
2. **内存局部性**：连续内存访问（如vector）比链表访问快
3. **内联函数**：小函数使用inline
4. **预分配内存**：vector的reserve，unordered_map的reserve
5. **算法选择**：根据数据规模和操作类型选择合适算法

### 12.2 调试技巧

```cpp
// 使用assert进行调试断言
#include <cassert>
void process(int* ptr) {
    assert(ptr != nullptr);
    // ...
}

// 自定义内存调试
#ifdef DEBUG
#define new new(__FILE__, __LINE__)
void* operator new(size_t size, const char* file, int line) {
    // 记录分配信息
    return malloc(size);
}
#endif
```

### 12.3 内存泄漏检测

```cpp
// 简单内存跟踪
class MemoryTracker {
    static map<void*, pair<size_t, string>> allocations;

public:
    static void* allocate(size_t size, const string& info) {
        void* ptr = malloc(size);
        allocations[ptr] = {size, info};
        return ptr;
    }

    static void deallocate(void* ptr) {
        allocations.erase(ptr);
        free(ptr);
    }

    static void report() {
        for (const auto& [ptr, info] : allocations) {
            cout << "Leak: " << info.second
                 << ", size: " << info.first << endl;
        }
    }
};
```

## 十三、面试常见问题与回答策略

### 13.1 基础概念类问题

**Q: const和constexpr的区别？**
A: const表示"只读"，可以是运行时常量；constexpr表示"编译期常量"，必须在编译时就能确定值。

**Q: 虚函数和纯虚函数的区别？**
A: 虚函数可以有实现，派生类可以选择是否覆盖；纯虚函数没有实现（`=0`），包含纯虚函数的类是抽象类，不能实例化。

### 13.2 实现原理类问题

**Q: 如何实现一个简单的vector？**
A: 需要考虑动态数组、容量管理、迭代器、异常安全等问题。关键点包括：
- 使用三个指针管理内存
- 容量不足时按策略扩容
- 提供基本的迭代器支持
- 保证异常安全（strong exception safety）

**Q: 如何设计一个线程安全的单例模式？**
A: C++11后可以使用局部静态变量（线程安全）；C++11前可以使用双检查锁定模式，但要注意内存屏障问题。

### 13.3 场景设计类问题

**Q: 设计一个对象池（Object Pool）**
A: 需要考虑：
- 预分配一定数量的对象
- 提供获取和归还接口
- 线程安全
- 避免内存碎片

```cpp
template<typename T>
class ObjectPool {
private:
    queue<unique_ptr<T>> pool;
    mutex mtx;

public:
    unique_ptr<T> acquire() {
        lock_guard<mutex> lock(mtx);
        if (pool.empty()) {
            return make_unique<T>();
        }
        auto obj = move(pool.front());
        pool.pop();
        return obj;
    }

    void release(unique_ptr<T> obj) {
        lock_guard<mutex> lock(mtx);
        pool.push(move(obj));
    }
};
```

## 总结

C++面试考察的核心不仅是语法知识，更重要的是：
1. **理解底层原理**：知道特性为什么这样设计
2. **工程实践能力**：能写出安全、高效、可维护的代码
3. **问题解决能力**：面对具体场景能选择合适的技术方案
4. **持续学习能力**：了解现代C++的发展和新特性

建议的学习路径：
1. 掌握C++核心语言特性（OOP、模板、异常等）
2. 深入理解STL实现原理
3. 学习现代C++新特性（C++11/14/17/20）
4. 实践项目开发，积累工程经验
5. 参与开源项目，学习优秀代码

记住：面试不仅是考察知识储备，更是考察思考过程和解决问题的能力。在回答问题时，可以展示自己的分析思路和权衡考虑，这往往比直接给出正确答案更有价值。