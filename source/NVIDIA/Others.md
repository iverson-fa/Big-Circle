# 其他

## 1 工具及文档链接

- [Nsight Systems](https://developer.download.nvidia.com/devtools/nsight-systems/)

- [NVIDIA Forums](https://forums.developer.nvidia.com/c/agx-autonomous-machines/jetson-embedded-systems/70)



## 2 SD 卡修复及 dtb 反向编译

1. 进入 Jetson 盒子系统 `/boot` 目录，找到 `tegra210-p3448-0002-p3449-0000-b00.dtb` 文件，并将其拷贝到一个新建文件夹内。

2. 跳转到新建文件夹，将 `tegra210-p3448-0002-p3449-0000-b00.dtb` 反向编译成 dts 文件，注意先写 dts 文件名。

   ```bash
   dtc -I dtb -O dts -o tegra210-p3448-0002-p3449-0000-b00.dts tegra210-p3448-0002-p3449-0000-b00.dtb
   ```

3. 修改 `tegra210-p3448-0002-p3449-0000-b00.dts` 文件，即在sdhci@700b0400里添加一行：

   ```bash
   max-frequency = <40000000>;
   ```

4. 将 `tegra210-p3448-0002-p3449-0000-b00.dts` 文件编译成 `tegra210-p3448-0002-p3449-0000-b00.dtb`文件

```bash
dtc -I dts -O dtb -o tegra210-p3448-0002-p3449-0000-b00.dtb tegra210-p3448-0002-p3449-0000-b00.dts
```

5. 使用新生成的 `tegra210-p3448-0002-p3449-0000-b00.dtb` 文件替换 `/boot` 目录下的原有同名文件，重启系统，查看SD卡问题是否修复。
