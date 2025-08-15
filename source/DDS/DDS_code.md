# DDS编程实践

## 1 Cyclone DDS C API 使用的关键注意点

---

### **1. 数据类型与序列初始化**

* 对 `.idl` 生成的 C 类型，如果字段是序列（`sequence`）或字符串（`string`），必须用 **对应的初始化函数**：

  ```c
  demo_Data__init(&msg);              // 初始化单个结构体
  demo_Data__seq_init(&seq, length); // 初始化序列
  ```
* 使用结束后，必须调用 **对应的释放函数**：

  ```c
  demo_Data__fini(&msg);
  demo_Data__seq_fini(&seq);
  ```
* 初始化前，内存最好先清零（例如 `memset` 或静态分配），防止 `__fini` 时访问野指针。

---

### **2. 参与者 / 主题 / 发布者 / 订阅者 创建**

* 创建 DDS 实体要严格按层次：

  1. `dds_create_participant`
  2. `dds_create_topic`
  3. `dds_create_publisher` / `dds_create_subscriber`（可选）
  4. `dds_create_writer` / `dds_create_reader`
* 每一步都需要检查返回值是否为负数（负数表示错误码）：

  ```c
  if (participant < 0) {
      fprintf(stderr, "create participant failed: %s\n", dds_strretcode(-participant));
      return -1;
  }
  ```

---

### **3. QoS 配置**

* 如果需要配置 QoS（可靠性、历史深度等），一定要在 `dds_create_writer/reader` 前设置：

  ```c
  dds_qos_t *qos = dds_create_qos();
  dds_qset_reliability(qos, DDS_RELIABILITY_RELIABLE, DDS_SECS(1));
  dds_qset_history(qos, DDS_HISTORY_KEEP_LAST, 10);
  writer = dds_create_writer(participant, topic, qos, NULL);
  dds_delete_qos(qos);
  ```

---

### **4. 写 / 读 数据**

* **写**：

  ```c
  if (dds_write(writer, &msg) < 0) {
      fprintf(stderr, "write failed\n");
  }
  ```
* **读**：

  * 如果是阻塞读：`dds_read` / `dds_take`
  * 如果需要等待数据：`dds_waitset_wait`
  * 返回值大于 0 表示读到的样本数，小于 0 表示错误。

---

### **5. 清理资源**

* 程序退出时，按反向顺序销毁实体：

  ```c
  dds_delete(participant);
  ```
* 如果使用了动态分配的序列或字符串，必须先调用 `__fini`。

---

### **6. 链接时常见问题**

* 如果报 **undefined reference**：

  1. 确认 `.c` 文件用 `idlc` 生成的序列化代码已经加入编译。
  2. 链接时要加上：

     ```cmake
     target_link_libraries(subscriber PRIVATE
         CycloneDDS::ddsc
         demo__dds__types   # idlc 生成的 CMake target
     )
     ```
  3. 如果是手动编译，需要 `-lddsc` 并包含生成的 `.c`。

---

### **7. 防段错误关键点**

* 不初始化序列就访问，会导致段错误。
* 销毁对象前重复释放，会段错误。
* 从 DDS 读取的结构体如果带序列/字符串，需要 `__fini`，否则会内存泄漏。
* 不要直接 `free` IDL 生成的结构体里的 `string` 或 `sequence`，必须用 `__fini`。

## 2 测试结果

ddsperf pub size 1k

```shell
[5405] participant jp6:5405: new (self)
[5405] participant jp6:5397: new
[5405] 1.000  430k/s   0n |@---__......._____............|   0%   1m
[5405] 1.000  rss:8.5MB vcsw:3818 ivcsw:86 recv:6%+1% pub:53%+27%
[5405] 2.000  441k/s   0n |@---_._......_____............|   0% 275u
[5405] 2.000  rss:10.2MB vcsw:2288 ivcsw:91 recv:6%+2% pub:50%+33%
[5405] 3.000  441k/s   0n |@---_........_____............|   0% 290u
[5405] 3.000  rss:10.4MB vcsw:2430 ivcsw:83 recv:4%+3% pub:51%+31%
[5405] 4.000  451k/s   0n |@---_........_____............|   0% 263u
[5405] 4.000  rss:10.4MB vcsw:2238 ivcsw:89 recv:5%+3% pub:50%+33%
[5405] 5.000  439k/s   0n |@---_........_____............|   0% 613u
[5405] 5.000  rss:10.4MB vcsw:2412 ivcsw:81 recv:6%+2% pub:50%+32%
[5405] 6.000  452k/s   0n |@---_........_____............|   0% 293u
[5405] 6.000  rss:10.4MB vcsw:2256 ivcsw:99 recv:4%+3% pub:49%+35%
[5405] 7.000  442k/s   0n |@---_........_____............|   0% 289u
[5405] 7.000  rss:10.5MB vcsw:2433 ivcsw:74 recv:6%+3% pub:55%+28%
[5405] 8.000  436k/s   0n |@---_........_____............|   0% 377u
[5405] 8.000  rss:10.5MB vcsw:2279 ivcsw:88 recv:2%+4% pub:48%+34%
[5405] 9.000  436k/s   0n |@---_........_____............|   0% 486u
[5405] 9.000  rss:10.5MB vcsw:2397 ivcsw:84 recv:6%+3% pub:45%+37%
[5405] 10.000  444k/s   0n |@---_._......_____............|   0% 349u
[5405] 10.000  rss:10.5MB vcsw:2267 ivcsw:83 recv:5%+2% pub:53%+31%
[5405] 11.000  423k/s   0n |@---_._......____.............|   0% 233u
[5405] 11.000  rss:10.5MB vcsw:2279 ivcsw:89 recv:6%+3% pub:50%+33%
[5405] 12.000  482k/s   0n |@---_........____.............|   0% 279u
[5405] 12.000  rss:10.5MB vcsw:2118 ivcsw:92 recv:4%+3% pub:53%+30%
[5405] 13.000  456k/s   0n |@---_........_____............|   0% 455u
[5405] 13.000  rss:10.5MB vcsw:2332 ivcsw:107 recv:6%+2% pub:52%+31%
[5405] 14.000  437k/s   0n |@---___......_____............|   0% 330u
[5405] 14.000  rss:10.5MB vcsw:3066 ivcsw:85 ddsperf:0%+1% recv:8%+2% pub:52%+31%
[5405] 15.000  342k/s   0n |@_---___...._____.............|   0% 332u
[5405] 15.000  rss:10.5MB vcsw:6878 ivcsw:98 ddsperf:1%+0% recv:15%+5% pub:58%+27%
[5405] 16.000  352k/s   0n |@_---___...._____.............|   0% 334u
[5405] 16.000  rss:10.5MB vcsw:5404 ivcsw:74 recv:15%+7% pub:58%+27%
[5405] 17.000  350k/s   0n |@_-_-___...._____.............|   0% 333u
[5405] 17.000  rss:10.5MB vcsw:5378 ivcsw:80 recv:16%+6% pub:60%+25%
```

ddsperf -Qrss:1 sub

```shell
[5397] participant jp6:5397: new (self)
[5397] 4.000  rss:6.6MB vcsw:2 ivcsw:0 ddsperf:0%+1%
[5397] participant jp6:5405: new
[5397] 10.000  size 1024 total 341424 lost 0 delta 341424 lost 0 rate 341.37 kS/s 2796.49 Mb/s (34.14 kS/s 279.65 Mb/s)
[5397] 10.000  rss:6.6MB vcsw:12783 ivcsw:7 tev:0%+1% recv:49%+13%
[5397] 11.000  size 1024 total 789117 lost 0 delta 447693 lost 0 rate 447.70 kS/s 3667.52 Mb/s (78.91 kS/s 646.45 Mb/s)
[5397] 11.000  rss:6.6MB vcsw:18477 ivcsw:1 ddsperf:1%+0% recv:59%+20%
[5397] 12.000  size 1024 total 1226484 lost 0 delta 437367 lost 0 rate 437.44 kS/s 3583.51 Mb/s (122.67 kS/s 1004.90 Mb/s)
[5397] 12.000  rss:6.6MB vcsw:19109 ivcsw:3 tev:0%+1% recv:61%+15%
[5397] 13.000  size 1024 total 1680385 lost 0 delta 453901 lost 0 rate 453.90 kS/s 3718.37 Mb/s (168.04 kS/s 1376.58 Mb/s)
[5397] 13.000  rss:6.6MB vcsw:18966 ivcsw:3 tev:1%+1% recv:63%+17%
[5397] 14.000  size 1024 total 2114601 lost 0 delta 434216 lost 0 rate 434.21 kS/s 3557.08 Mb/s (211.46 kS/s 1732.27 Mb/s)
[5397] 14.000  rss:6.6MB vcsw:18270 ivcsw:7 recv:57%+20%
[5397] 15.000  size 1024 total 2573918 lost 0 delta 459317 lost 0 rate 459.32 kS/s 3762.74 Mb/s (257.39 kS/s 2108.56 Mb/s)
[5397] 15.000  rss:6.6MB vcsw:18611 ivcsw:2 tev:0%+1% recv:64%+16%
[5397] 16.000  size 1024 total 3008850 lost 0 delta 434932 lost 0 rate 434.93 kS/s 3562.95 Mb/s (300.88 kS/s 2464.84 Mb/s)
[5397] 16.000  rss:6.6MB vcsw:17317 ivcsw:3 tev:0%+1% recv:59%+18%
[5397] 17.000  size 1024 total 3448873 lost 0 delta 440023 lost 0 rate 440.02 kS/s 3604.68 Mb/s (344.89 kS/s 2825.32 Mb/s)
[5397] 17.000  rss:6.6MB vcsw:18689 ivcsw:0 tev:1%+1% recv:60%+18%
[5397] 18.000  size 1024 total 3881077 lost 0 delta 432204 lost 0 rate 432.20 kS/s 3540.62 Mb/s (388.11 kS/s 3179.38 Mb/s)
[5397] 18.000  rss:6.6MB vcsw:16711 ivcsw:1 tev:0%+1% recv:56%+22%
[5397] 19.000  size 1024 total 4321808 lost 0 delta 440731 lost 0 rate 440.73 kS/s 3610.47 Mb/s (432.18 kS/s 3540.42 Mb/s)
[5397] 19.000  rss:6.6MB vcsw:17679 ivcsw:13 recv:58%+19%
[5397] 20.000  size 1024 total 4747332 lost 0 delta 425524 lost 0 rate 425.52 kS/s 3485.90 Mb/s (440.59 kS/s 3609.33 Mb/s)
[5397] 20.000  rss:6.6MB vcsw:15297 ivcsw:3 tev:0%+1% recv:57%+20%
[5397] 21.000  size 1024 total 5220557 lost 0 delta 473225 lost 0 rate 473.22 kS/s 3876.65 Mb/s (443.14 kS/s 3630.23 Mb/s)
[5397] 21.000  rss:6.6MB vcsw:17776 ivcsw:4 ddsperf:0%+1% tev:0%+1% recv:60%+22%
[5397] 22.000  size 1024 total 5680226 lost 0 delta 459669 lost 0 rate 459.67 kS/s 3765.61 Mb/s (445.37 kS/s 3648.51 Mb/s)
[5397] 22.000  rss:6.6MB vcsw:18248 ivcsw:3 recv:59%+21%
[5397] 23.000  size 1024 total 6131298 lost 0 delta 451072 lost 0 rate 451.08 kS/s 3695.22 Mb/s (445.10 kS/s 3646.22 Mb/s)
[5397] 23.000  rss:6.6MB vcsw:19029 ivcsw:4 tev:0%+1% recv:64%+14%
[5397] 24.000  size 1024 total 6479195 lost 0 delta 347897 lost 0 rate 347.90 kS/s 2849.96 Mb/s (436.46 kS/s 3575.46 Mb/s)
[5397] 24.000  rss:6.6MB vcsw:14514 ivcsw:18 tev:1%+0% recv:54%+22%
[5397] 25.000  size 1024 total 6828983 lost 0 delta 349788 lost 0 rate 349.78 kS/s 2865.44 Mb/s (425.50 kS/s 3485.72 Mb/s)
[5397] 25.000  rss:6.6MB vcsw:14254 ivcsw:4 tev:0%+1% recv:64%+12%
[5397] 26.000  size 1024 total 7178755 lost 0 delta 349772 lost 0 rate 349.77 kS/s 2865.33 Mb/s (416.99 kS/s 3415.99 Mb/s)
[5397] 26.000  rss:6.6MB vcsw:13719 ivcsw:1 recv:59%+17%
[5397] 27.000  size 1024 total 7534500 lost 0 delta 355745 lost 0 rate 355.75 kS/s 2914.27 Mb/s (408.56 kS/s 3346.95 Mb/s)
[5397] 27.000  rss:6.6MB vcsw:13414 ivcsw:1 tev:1%+1% recv:56%+21%
[5397] participant jp6:5405: gone
[5397] 28.000  size 1024 total 7582011 lost 0 delta 47511 lost 0 rate 47.50 kS/s 389.12 Mb/s (370.01 kS/s 3031.11 Mb/s)
[5397] 28.000  rss:6.6MB vcsw:1774 ivcsw:3 recv:7%+3%
```

CycloneDDS 已经在用 Iceoryx 共享内存，性能和内存占用都符合预期：

---

### 1. **共享内存传输已生效**

* 在 pub 端 RSS 稳定在 10.5 MB 左右，sub 端稳定在 6.6 MB，没有随着消息数量线性增长 → 说明消息数据没有频繁复制，走的是 Iceoryx 的零拷贝路径。
* `lost 0` 也确认了传输过程中没有丢包。

---

### 2. **吞吐量表现**

* pub 端（前几秒）稳定在 **440 kS/s**（约 3.6 Gb/s），sub 端收到的速率基本一致。
* 当 `-Qrss:1` 限制订阅者 RSS 时，Iceoryx 会控制共享内存段数量，减少缓存积压，这样后期的速率会因为回收和同步的延迟有轻微波动（比如 24 秒处降到 347 kS/s）。

---

### 3. **CPU 占用模式**

* pub 端 `pub:50%+33%` 表示发送线程 CPU 占用和系统调用/内核态占用。
* sub 端 `recv:60%+18%` 表示接收线程占用较高，这也是因为订阅端需要频繁从共享内存读取元数据，并进行 DDS 层的处理。
* 这里已经很接近单核处理的极限了，如果想进一步提速，需要：

  * 增加并行读写线程
  * 或者提升 CycloneDDS/Iceoryx 配置参数（比如最大 chunk 数、I/O 线程数）

---

### 4. **验证 Iceoryx 配置是否最佳**

可以在 CycloneDDS 的配置文件里明确开启 Iceoryx 支持，并调大共享内存池参数，例如：

```xml
<CycloneDDS>
  <Domain>
    <SharedMemory>
      <Enable>true</Enable>
      <Iceoryx>
        <Enable>true</Enable>
        <SegmentSize>256M</SegmentSize>
        <MaxNumberOfChunks>8192</MaxNumberOfChunks>
      </Iceoryx>
    </SharedMemory>
  </Domain>
</CycloneDDS>
```

这样在长时间高负载 pub/sub 时，避免因为默认 pool 太小导致吞吐波动。

---

### 5. ** `-Qrss:1` 会影响曲线**

* 这个参数是 `ddsperf` 的 QoS 内存限制测试选项，会强制订阅端在超过 1 MB RSS 时进行历史样本丢弃或回收。
* 所以后面看到 sub 端速率会出现周期性下降，pub 端 CPU 上的 `recv` 占用上升，就是在做样本释放和重分配。

### 6. 下一步计划

做**纯性能极限测试**，去掉 `-Qrss:1`，让 Iceoryx 自由分配内存；
做**资源限制场景测试**，保留这个参数就能模拟嵌入式场景下的内存压力。

