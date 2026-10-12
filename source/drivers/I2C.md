# I2C 

## 1 I2C工具使用

- i2cdetect : 用来列举I2C bus 和挂载设备
- i2cdump : 显示I2C bus上所有寄存器值
- i2cset : 设置 I2C bus 上某个寄存器值
- i2cget : 获取 I2C bus上某个寄存器值
- i2ctransfer：用于扩展支持操作16位地址

### 1.1 i2cdetect

 i2cdetect用来列举I2C BUS和上面的所有设备

 i2cdetect还可用于查询I2C总线的功能（请参见选项-F）

```bash
i2cdetect [-y] [-a] [-q|-r] I2CBUS[FIRST LAST]
i2cdetect -F I2CBUS
i2cdetect -l
```

| 参数 | 描述                                                         |
| ---- | ------------------------------------------------------------ |
| -y   | 禁止交互模式。默认情况下i2cdetect执行时需等待用户确认，才执行命令。当使用此标志时 代表取消用户交互过程，直接执行命令。主要用于脚本 |
| -a   | 强制扫描非常规地址，不建议                                   |
| -q   | 使用SMBus“快速写入”命令进行探测（默认情况下，使用的命令是被认为是每个地址最安全的命令），不建议 |
| -r   | 使用SMBus“读字节”命令进行探测（默认情况下，使用的命令是被认为是每个地址最安全的命令）。不建议。 |
| -F   | 显示适配器实现的功能列表和退出                               |
| -l   | 显示安装总线的列表                                           |

I2CBUS：要扫描的I2C总线的编号或名称，并且应对应于i2cdetect -l 列出的总线之一

可选参数first和last限制扫描范围（默认值：从0x03到0x77）

```shell
# 示例
# I2C总线扫描
i2cdetect -l
# I2C设备查询
i2cdetect -y -r 0
```

### 1.2 i2cdump

  i2cdump用于检查通过I2C总线可见的寄存器

```bash
i2cdump [-f] [-y] [-r first-last]I2CBUS ADDRESS [MODE [BANK [BANKREG]]]
```

| 参数          | 描述                                                         |
| ------------- | ------------------------------------------------------------ |
| -f            | 即使设备忙，也强制访问设备                                   |
| -y            | 禁止交互模式                                                 |
| -r first-last | 限制正在访问的寄存器的范围。 此选项仅适用于模式b，w，c和W。对于模式W，第一个必须为偶数，最后一个必须为奇数 |

I2CBUS：要扫描的I2C总线的编号或名称

ADDRESS：i2c地址

```shell
# 示例
# 寄存器内容导出
i2cdump -y 0 0x50
```

### 1.3 i2cset

 i2cset设置I2C设备上某个寄存器的值

```bash
i2cset [-f] [-y] [-m MASK] [-r] I2CBUS CHIP-ADDRESS DATA-ADDRESS [VALUE] ... [MODE]
```

| 参数         | 描述                                             |
| ------------ | ------------------------------------------------ |
| -m mask      | 掩码参数                                         |
| -r           | 在写入之后立即读回值，并将结果与写入的值进行比较 |
| DATA-ADDRESS | 寄存器地址                                       |
| VALUE        | 设置寄存器值                                     |

```shell
# 示例
# 对总线0,设备0x70,寄存器0x00,设置值为0x0e
i2cset -f -y 0 0x70 0x00 0x0e
```

### 1.4 i2cget

读取I2C设备上某个寄存器的值

```bash
i2cget [-f] [-y] I2CBUS CHIP-ADDRESS [DATA-ADDRESS [MODE]]
```

```shell
# 示例
# 读取总线0 设备0x70 寄存器0x00的值
i2cget -f -y 0 0x70 0x00
```

### 1.4 i2ctransfer

命令读写一体化 读写都得先写寄存器地址然后在进行读写操作

```shell
# 示例
# 读总线0 设备0x50 寄存器0x1030的值，读2个字节
i2ctransfer -f -y 0 w2@0x50 0x10 0x30 r2
# 写总线0 设备0x50 寄存器0x1030的值为0x55aa
i2ctransfer -f -y 0 w4@0x50 0x10 0x30 0x55 0xaa
```

