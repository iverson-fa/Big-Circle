# 天准J6域控

## 1 ROS2 环境配置

```shell
├── deps.tar.gz
├── humble-arm-20240410.221244.tar.gz
└── python-3.10.12.tar.gz
```
分别解压，得到

```shell
├── deps
├── humble
└── Python-3.10.12
```

执行以下脚本配置ROS2环境

```shell
#!/bin/bash
ros_distro=$(printenv ROS_DISTRO)

# 检查Python版本
python_version=$(python3 --version | awk '{print $2}')
if [ "$python_version" != "3.10.12" ]; then
    echo "Python版本不是3.10.12，正在修改..."
    rm -rf /usr/bin/python3
    rm -rf /usr/bin/python
    rm -rf /usr/lib/libpython3.10.so.1.0
    ln -s /userdata/nvme/zjf/ros2/Python-3.10.12/install/bin/python3 /usr/bin/python
    ln -s /userdata/nvme/zjf/ros2/Python-3.10.12/install/bin/python3 /usr/bin/python3
    ln -s /userdata/nvme/zjf/ros2/Python-3.10.12/install/lib/libpython3.10.so.1.0 /usr/lib/libpython3.10.so.1.0
else
    # 打印Python版本
    echo "Python  版本: $(python --version)"
    echo "Python3 版本: $(python3 --version)"
fi

# 检查ROS版本
if [ ! -d "/opt/ros/humble" ]; then
    echo "/opt/ros下没有humble，正在创建..."
    mkdir -p /opt/ros
    ln -s /userdata/nvme/zjf/ros2/humble /opt/ros/humble
    source /opt/ros/humble/setup.bash
    if [ "$ros_distri" = "humble" ]; then
        echo "ROS版本已设置为 : $ros_distro."
    else
        echo "ROS版本设置失败."
    fi
else
    source /opt/ros/humble/setup.bash
    echo "检查ROS版本..."
    if [ "$ros_distro" = "humble" ]; then
	echo "ROS 版本: $ros_distro"
    else
	echo "ROS 版本: $ros_distro"
    fi
fi

# 检查并添加环境变量和source命令到~/.bashrc
if ! grep -q 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/userdata/nvme/zjf/ros2/deps' ~/.bashrc; then
    echo 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/userdata/nvme/zjf/ros2/deps' >> ~/.bashrc
    source ~/.bashrc
fi
if ! grep -q 'source /opt/ros/humble/setup.bash' ~/.bashrc; then
    echo 'source /opt/ros/humble/setup.bash' >> ~/.bashrc
    source ~/.bashrc
fi
    source ~/.bashrc
echo "环境变量和source命令已检查并添加到~/.bashrc."
```

**查找和添加python依赖的package**

如果报错缺少依赖package，在安装了相同python版本的arm平台上，使用命令pip show [package名]查找其安装路径（Location），例如查找numpy：pip show numpy，提示其Location为/usr/lib/python3/dist-packages。
然后将package拷贝到J6的python安装路径的lib/python3.10/site-packages/路径下。

## 2 J6 平台 6V ISX031 相机适配与调试

更新时间：2026-10-29

完整板端调试日志：{download}`6V_ISX031_cam_debug.log <./log/6V_ISX031_cam_debug.log>`

### 2.1 目标与验证结论

将原先已测通的 7 路方案调整为 6 路，摄像头规格不变：

| 项目 | 原 7V | 目标 6V |
|---|---|---|
| CONN2 / RX0 | 1、3、4 号口 | 1、2、3、4 号口 |
| CONN4 / RX4 | 1、2、3、4 号口 | 1、2 号口 |
| 图像规格 | ISX031，1920×1536，30fps | ISX031，1920×1536，30fps |

**最终验证：用户已确认六路取帧正常、帧率稳定。** 留存日志显示初始化成功、掩码为 3312，RX4 后续出现高速接收及 SENSOR6/7 的帧开始、帧结束事件。六路持续取帧及稳定帧率的最终结论来自用户板端反馈；留存日志未包含完整的最终应用层长时间统计。

硬件型号以用户核对的原理图为准：RX0 使用 MAX96712，其他相机 RX 使用 MAX96724。旧 case 中的型号配置不能代替原理图。

### 2.2 使用哪些文件

本次工作目录为 `/home/ieit/tmp/cam`，板端运行目录为 `/map/cam_yunchuang`。

当前可复现的部署组合如下。**FIXED 目录中的 vpm_config.json 仍保留 RX4 的旧 VC3/2；部署时必须使用 VC01_TEST 中的文件覆盖它。**

| 目标文件 | 本机来源（相对于 cam 根目录） | 用途 |
|---|---|---|
| `cfg/hb_j6dev.json` | `case/6V_4xISX031_RX0_2xISX031_RX4_SENSING_FIXED/hb_j6dev.json` | 板级参数、解串器及六路相机 |
| `cfg/vpm_config.json` | `case/6V_RX4_VC01_TEST/vpm_config.json` | 六路流水线，RX4 使用 VC0/1 |
| `cfg/lpwm_rx0.json` | `case/6V_4xISX031_RX0_2xISX031_RX4_SENSING_FIXED/lpwm_rx0.json` | RX0 触发配置 |
| `cfg/lpwm_rx4.json` | `case/6V_4xISX031_RX0_2xISX031_RX4_SENSING_FIXED/lpwm_rx4.json` | RX4 触发配置 |

`tools/det_cam_conn.sh` 使用仓库官方原版。本次曾尝试修改该工具，之后已完整恢复，不需要使用修改版。

`cam_debug/hb_j6dev.json`、`cam_debug/vpm_config.json` 是中间参考配置。其有效 JSON 与原始 6V RAR 一致，但该版 VPM 尚未包含最终 RX4 VC0/1 调整。不要仅按文件名判断是否为最终版本。

### 2.3 六路配置对应关系

下表为当前配置的对应关系。现场可通过遮挡镜头进一步核实图像对应接口；本次未单独留存逐口遮挡记录。

| 物理接口 | pipeline / port | deserial_index | deserial_port（link） | RX | VC | PYM hw / slot |
|---|---:|---:|---:|---:|---:|---|
| CONN2_1 | 10 | 0 | 2 | 0 | 2 | 0 / 6 |
| CONN2_2 | 11 | 0 | 3 | 0 | 3 | 0 / 7 |
| CONN2_3 | 4 | 0 | 0 | 0 | 0 | 0 / 4 |
| CONN2_4 | 5 | 0 | 1 | 0 | 1 | 0 / 5 |
| CONN4_1 | 6 | 2 | 2 | 4 | 0 | 4 / 4 |
| CONN4_2 | 7 | 2 | 3 | 4 | 1 | 4 / 5 |

物理接口编号与解串器 link 的关系为：link0→接口3，link1→接口4，link2→接口1，link3→接口2。

#### 2.3.1 解串器配置

| 配置对象 | 用途 | 型号 | 地址 | errb / lock GPIO |
|---|---|---|---|---|
| `deserial_0` | CONN2 / RX0 | max96712 | 0x2d | 451 / 478 |
| `deserial_1` | 当前六路无 port 引用 | max96724 | 0x2e | 450 / 476 |
| `deserial_2` | CONN4 / RX4 | max96724 | 0x4e | 454 / 502 |

保留参考配置中未使用的 `deserial_1`，本次没有为了精简而删除或重排编号。

RX0 的 `camerr_pin=[9,14,6,8]`、`trig_pin=[2,4,5,7]`；RX4 的 `camerr_pin=[7,8]`、`trig_pin=[0]`。这些参数随本次配置通过了用户取帧验证，不应套用其他解串器的引脚配置。

#### 2.3.2 相机地址与公共参数

| port | serial_addr | sensor_addr | eeprom_addr |
|---|---|---|---|
| 4 | 0x41 | 0x11 | 0x51 |
| 5 | 0x42 | 0x12 | 0x52 |
| 10 | 0x43 | 0x13 | 0x53 |
| 11 | 0x44 | 0x14 | 0x54 |
| 6 | 0x43 | 0x13 | 0x53 |
| 7 | 0x44 | 0x14 | 0x54 |

地址检查需按解串器所属链路分组，不能将不同组的相同地址直接视为冲突。

公共参数：`sensor_name=isx031std`、`sensor_mode=5`、`extra_mode=2`、`config_index=512`、`fps=30`、分辨率 1920×1536。

当前六路 `fov` 均沿用 cam_debug 的 196。旧 7V 的 CONN2 三路曾分别填写 118/30/60；成功取帧不代表光学视场角或标定参数得到验证。后续用于标定、拼接时，应再次核对实际镜头规格。

### 2.4 适配过程与问题定位

#### 2.4.1 初始参考：从 7V 增一路、删两路

原始参考包为 `7v_3xISX031_rx0_4xISX_rx4_SENSING`。拓扑上，需要新增 CONN2_2，删除 CONN4_3、CONN4_4。

第一版直接保留旧 7V 的板级参数，使用端口 3/4/5/6/7/10，同时将 RX4 保留为 `max96712 / 0x2d`。这与后来确认的原理图及 cam_debug 配置不同，因此该版不再采用。

官方检测工具按解串器地址映射总线及接口。旧版两组都填写 0x2d，检测日志就重复列出 CONN2_1、CONN2_2，没有 CONN4。正确处理是核实配置及硬件，不是通过修改工具掩盖差异。

#### 2.4.2 采用检测正确的 cam_debug 板级配置

用户提供检测正确的 cam_debug 配置，核对其有效 JSON 与原始 6V RAR 一致：

- RX0 为 `deserial_0 / max96712 / 0x2d`。
- RX4 为 `deserial_2 / max96724 / 0x4e`。
- 使用 port/pipeline 4、5、6、7、10、11。

用户随后通过原理图确认解串器型号，排除了继续按旧 case 修改 RX4 型号的方向。

#### 2.4.3 排除新旧配置混用

日志曾出现：

```text
hb_j6dev.json：port_3、4、5、6、7、10
vpm_config.json：pipeline4、5、6、7、10、11
hb_cam_init fail, ret: -3601
```

这组文件存在明确不一致：缺少 `port_11`，且部分同编号端口的物理意义已变化。`camera.sh` 和 demo 实际使用运行目录下的 `cfg/`，仅修改或复制 `case/` 中的文件不会生效。

同时更新两份配置后，日志显示：

```text
hb_cam_init success
port_mask: 3312
port : 4 / 5 / 6 / 7 / 10 / 11 is used
```

此处没有取得 `-3601` 的 SDK 精确定义，不将它泛化为“必然表示配置编号错误”；本次确定的是配置混用问题，修正后初始化成功。

#### 2.4.4 初始化成功，但 RX4 两路不能取帧

更新后 CONN2 四路已有 1920×1536 图像，后段帧间隔约 33ms；pipeline6/7 返回：

```text
hb_vio_get_data failed, pipeid: 7, ret: -6028
hb_vio_get_data failed, pipeid: 6, ret: -6028
```

这表明失败阶段已从相机初始化转到取帧。连接检测正常和 `hb_cam_init success` 都不能单独证明六路视频数据正常。

#### 2.4.5 按实际 RX4 接收配置修正 VC

板端运行状态显示：

```text
channel_num    : 2
channel_sel[0] : 0
channel_sel[1] : 1
```

但原 VPM 沿用旧 RX4 四路方案的 VC：pipeline6=3、pipeline7=2。为与当前两路接收配置对齐，仅修改以下字段：

| JSON 字段 | 修改前 | 修改后 |
|---|---:|---:|
| `pipeline6.vin_node0.cim.input.mipi.vc_index` | 3 | 0 |
| `pipeline7.vin_node0.cim.input.mipi.vc_index` | 2 | 1 |

测试文件为 `case/6V_RX4_VC01_TEST/vpm_config.json`，与修正前配置相比仅这两个字段不同。保持 RX0、PYM、LPWM 和板级配置不变，以便确认变量。

后续内核日志出现：

```text
[RX4]: entry hs reception
[SENSOR7]: sensor_frame_event_record 1 --------- fs
[SENSOR7]: sensor_frame_event_record 1 ... fe
[SENSOR6]: sensor_frame_event_record 1 --------- fs
[SENSOR6]: sensor_frame_event_record 1 ... fe
```

用户最终确认取帧正常、帧率稳定。本次结果说明不能将旧四路方案的 VC 分配直接用于当前两路配置；也不能推广为“所有 MAX96724 双路方案都固定使用 VC0/1”，应以具体运行配置和验证结果为准。

### 2.5 部署步骤

先将第 2 节的两个 case 目录复制到板端 `case/`。停止正在运行的 demo 或 ROS2 取流进程，在板端 cam 根目录执行：

```bash
cd /map/cam_yunchuang
backup_dir="cfg_backup_$(date +%Y%m%d_%H%M%S)"
cp -a cfg "$backup_dir"

cp case/6V_4xISX031_RX0_2xISX031_RX4_SENSING_FIXED/hb_j6dev.json cfg/
cp case/6V_4xISX031_RX0_2xISX031_RX4_SENSING_FIXED/lpwm_rx0.json cfg/
cp case/6V_4xISX031_RX0_2xISX031_RX4_SENSING_FIXED/lpwm_rx4.json cfg/
cp case/6V_RX4_VC01_TEST/vpm_config.json cfg/
```

不要在最后一步之后再用 FIXED 目录的 `*.json` 整体覆盖 cfg，否则会恢复 RX4 的旧 VC3/2。

部署后核对文件内容是否一致：

```bash
cmp cfg/hb_j6dev.json case/6V_4xISX031_RX0_2xISX031_RX4_SENSING_FIXED/hb_j6dev.json
cmp cfg/vpm_config.json case/6V_RX4_VC01_TEST/vpm_config.json
```

`cmp` 无输出且退出码为 0 表示文件一致。随后运行：

```bash
(cd tools && bash ./det_cam_conn.sh)
./camera.sh demo 2>&1 | tee camera_6v_demo.log
```

检测脚本依赖相对路径，需从 `tools/` 目录运行。它会复位相机并切换链路、写寄存器，不能在正常取流时并行运行。demo 启动脚本也会执行复位及复制驱动库。

### 2.6 调试方法

#### 2.6.1 先检查实际加载的配置

始终查看 `cfg/`，不要只查看 `case/`。若文件名相同但版本不确定，以内容和校验值为准。

```bash
cd /map/cam_yunchuang
sha256sum cfg/hb_j6dev.json cfg/vpm_config.json
cat cfg/hb_j6dev.json
```

可用板端自带 jq 检查 JSON 与关键字段：

```bash
export LD_LIBRARY_PATH="$PWD/tools/.jq${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
./tools/.jq/jq empty cfg/hb_j6dev.json cfg/vpm_config.json
./tools/.jq/jq -r 'keys[] | select(startswith("port_"))' cfg/hb_j6dev.json
./tools/.jq/jq -r 'to_entries[] | [.key, .value.vin_node0.cim.input.mipi.rx_index, .value.vin_node0.cim.input.mipi.vc_index] | @tsv' cfg/vpm_config.json
```

本项目自带 jq 是 ARM 可执行程序，适合在板端使用，不能直接在 x86 主机运行。

检查原则：

1. 六个 `pipelineN` 均有对应 `port_N`，无多余旧版端口混入。
2. 每个 port 引用存在的解串器。
3. 同一 RX 内 VC 不重复；不同 RX 可以使用相同 VC。
4. 当前方案同一 PYM 硬件上的 slot 不重复。
5. LPWM 引用文件存在，分辨率、帧率与传感器方案一致。

#### 2.6.2 连接检测：确认控制链路与接口

运行官方 `det_cam_conn.sh`，应覆盖六个不同接口：CONN2_1/2/3/4、CONN4_1/2。

若出现重复 CONN2，先核对解串器地址、port 引用及是否部署了正确文件。该工具检查的连接状态不能替代解串器型号、触发引脚、VC 和实际图像的验证。

#### 2.6.3 初始化：区分 VIO 与相机阶段

本项目 `demo/source/main.cpp` 先执行 `hb_vio_init`，再执行 `hb_cam_init`：

| 日志 | 优先检查 |
|---|---|
| `hb_vio_init fail` | VPM、资源配置、引用文件及对应底层日志 |
| `hb_cam_init fail` | 板级配置、端口引用、解串器/传感器初始化及驱动日志 |
| `hb_cam_init success` 后取帧失败 | 出流、触发、VC、CIM/PYM 数据链路 |

不要仅凭负数错误码猜测唯一根因。保留完整日志，结合 SDK 错误码定义和失败前的底层输出定位。

#### 2.6.4 取帧：按 pipeline 分组观察

本方案掩码为：

```text
(1<<4)+(1<<5)+(1<<6)+(1<<7)+(1<<10)+(1<<11)
= 3312 = 0xCF0
```

`camera.sh` 从 VPM 自动计算掩码。本脚本没有启用用户第二参数覆盖掩码的逻辑，不要依赖 `./camera.sh demo 某掩码` 做单路测试。

应用日志应同时出现 4、5、6、7、10、11 六个 pipeid 的连续帧。1920×1536、约 33ms 的连续帧间隔符合本次 30fps 目标。首帧 interval 可能包含初始时间差，不应将它当作稳定帧率；应看连续多帧和较长时间的统计。

若只缺某一 RX 的全部流水线，优先检查该 RX 的公共路径；若仅缺一路，再检查该路 link、VC、地址和图像路由。

#### 2.6.5 MIPI：比较配置与运行状态

保持 demo 运行，在第二个终端执行：

```bash
cat /sys/class/vps/mipi_host4/status/cfg
cat /sys/class/vps/mipi_host4/status/icnt
cat /sys/class/vps/mipi_host0/status/cfg
cat /sys/class/vps/mipi_host0/status/icnt
```

重点比较：RX、通道数、`channel_sel`、datatype、分辨率、lane 和速率。本次 RX4 显示 4 lane、1920×1536、datatype 0x1e、30fps、两个通道 0/1。

错误计数全零仅说明该次读取未记录这些错误，不能证明有视频流。应同时查看帧事件、应用取帧及计数随时间的变化。

#### 2.6.6 内核日志：确认数据走到哪一层

```bash
dmesg > camera_6v_dmesg.log
dmesg | grep -Ei 'RX4|VCON4|SENSOR6|SENSOR7|cim4|pym4|fail|error|timeout' | tail -200
```

先保存完整 dmesg，再过滤阅读，避免初始化原因被后续大量重试信息挤出视野。不使用 `dmesg -c` 清空日志。

本次可参考的进展标志：

- `deserial_start links 0xc start done`：RX4 所启用 link2/3 的启动记录。
- `[RX4]: entry hs reception`：进入高速接收阶段。
- SENSOR6/7 出现 `fs`、`fe`：有帧开始/结束事件。
- 应用 `hb_vio_get_data` 成功：进一步确认 PYM 缓冲能够取到。

内核启动成功、单次 fs/fe、`vpf_video_check_hw_status: ret = 0` 均不能单独替代持续取帧验证。

#### 2.6.7 必要时进一步检查 CIM

仓库 `tools/mipi_cim.sh` 提供了 CIM 调试路径。RX4 对应的示例路径为：

```bash
cat /sys/devices/platform/soc/37c30000.cim/regdump
dmesg | grep -E 'DUMP|IMG|IPI|cim4' | tail -120
```

该接口会请求寄存器转储，仅在常规配置/日志检查不足时使用；不同固件需核对实际节点。可辅助判断 IPI 分辨率及接收状态，不要将一次瞬时寄存器值当作长期测量结果。

#### 2.6.8 环境报错的处理边界

日志中曾有 `/opt/ros/humble/setup.bash` 不存在的报错，但 demo 随后完成相机初始化并取帧，因此该报错不是本次 RX4 无图的直接证据。运行 ROS2 功能时仍需补齐 ROS2 环境。

现有 `camera.sh` 会操作 ROS/Python 软链接及系统库，排查相机问题时不要反复把这些环境提示与视频链路故障混为一谈。本次没有为适配修改启动脚本。

### 2.7 验收与回退

验收应包括：

- 六个物理接口检测正常且不重复。
- 初始化成功，掩码 3312，启用端口为 4/5/6/7/10/11。
- 六路持续取得 1920×1536 图像，帧率稳定，观察是否存在重复丢帧或重试。
- 逐个遮挡镜头，确认接口与 pipeline 的对应，不仅检查“六路有图”。
- 建议补做重启、冷启动及较长时间运行，记录测试时长和结果；这些项目不因本次取帧成功自动视为完成。

若某次修改导致回归，停止取流，恢复部署前备份中的整套 JSON 后重新启动。将下列示例目录替换为实际备份目录：

```bash
cp cfg_backup_YYYYMMDD_HHMMSS/*.json cfg/
./camera.sh demo 2>&1 | tee camera_rollback.log
```

每次只改变有依据的一组参数，并记录修改前后值、配置校验值、运行日志及物理接线。日志中不要只追加历史输出而不标记新一轮测试，避免将旧错误误判为新结果。

### 2.8 本次适配的要点

1. 硬件型号以原理图为准，旧包仅作配置参考。
2. `hb_j6dev.json` 和 `vpm_config.json` 必须配套，并部署到实际运行的 `cfg/`。
3. 控制链路检测、初始化、帧接收和应用取帧是不同验证阶段。
4. 当前 RX4 两路方案需要 VC0/1，不能直接沿用旧方案的 VC3/2。
5. 本次修复使用原版官方检测工具；最终板级配置加 VC01 VPM 已由用户确认取帧正常、帧率稳定。

参考材料：`/home/ieit/tmp/cam_todo`、`/home/ieit/tmp/cam_debug/log`、cam_debug 配置、仓库 case 配置与 demo/tools 源码、用户原理图核对及最终板端反馈。任务最初提到的测试 PDF 未取得，未作为本次结论依据。
