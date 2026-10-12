# C/C++ 头文件说明

- **stdio.h** 标准输入输出库，用于C语言的输入输出操作。提供了常用的I/O函数，如`printf`、`scanf`、`fopen`、`fclose`等
```c
# 使用`printf`函数输出消息
printf("Hello, World!\n");
```
- **sys/types.h** 定义了系统数据类型，如`pid_t`、`off_t`、`uid_t`等。这些类型在系统调用和C标准库函数中广泛使用。
- **sys/stat.h** 定义了与文件属性相关的结构和常量，并提供了获取和修改文件属性的函数，如`stat`、`fstat`、`chmod`、`mkdir`等
```c
# 获取文件属性
struct stat fileStat;
if(stat("example.txt",&fileStat) == 0) {
    printf("File size: %lld bytes\n", (long long)fileStat.st_size);
}
```
- **fcntl.h** 提供了文件控制操作的常量和函数，例如`open`、`fcntl`。这些函数用于文件描述符的操作，如打开文件、设置文件描述符的属性等
```c
# 打开一个文件
int fd = open("example.txt", O_RDONLY);
if(fd != -1) {
    // File opened successfully
    close(fd);
}
```
- **pthread.h** POSIX线程库，提供了多线程编程的支持。包含线程的创建、终止、同步（如互斥锁、条件变量）等函数
```c
# 创建一个线程
void* threadFunc(void* arg) {
    printf("Hello from thread!\n");
    return NULL;
}

pthread_t thread;
pthread_create(&thread, NULL, threadFunc, NULL);
pthread_join(thread, NULL);
```
- **ctime** 提供了与时间相关的函数和类型，例如获取当前时间、计算时间差、格式化时间等。常用函数包括`time`、`difftime`、`clock`、`localtime`、`strftime`等
```c
# 获取时间并格式化输出
time_t now = time(NULL);
struct tm* now_tm = localtime(&now);
printf("Current time: %s", asctime(now_tm));
```
- **cstdlib** 包含了通用的实用函数，如动态内存管理、随机数生成、环境变量、程序退出等。常用函数包括`malloc`、`free`、`rand`、`srand`、`getenv`、`exit` 等
```c
# 动态分配内存
int* array = (int*)malloc(10 * sizeof(int));
if(array != NULL) {
    // Use the array
    free(array);
}
```
- **unistd.h** 提供了POSIX标准定义的系统调用接口，例如文件操作、进程控制、信号处理、线程、IPC（进程间通信）等。常用函数包括`read`、`write`、`close`、`fork`、`exec`、`pipe`等。
```c
# 获取进程ID
pid_t pid = getpid();
printf("Current process ID: %d\n", pid);
```