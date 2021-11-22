# CAN
## 常用指令
```shell
sudo modprobe vcan # 加载虚拟can模块
sudo ip link add dev vcan0 type vcan # 添加vcan0网卡
ifconfig -a # 可以查到当前can网络 can0 can1，包括收发包数量、是否有错误等等
ip link set can0 type can --help
ip link set can0 up type can bitrate 800000 # 设置can0的波特率为800kbps,CAN网络波特率最大值为1Mbps
ip link set can0 up type can bitrate 800000 loopback on # 设置回环模式，自发自收，用于测试是硬件是否正常,loopback不一定支持
ip link set can0 down # 关闭can0 网络
cansend can0 0x11 0x22 0x33 0x44 0x55 0x66 0x77 0x88 # 发送默认ID为0x1的can标准帧，数据为0x11 22 33 44 55 66 77 88,每次最大8个byte
cansend can0 -i 0x800 0x11 0x22 0x33 0x44 0x55 0x66 0x77 0x88 -e # -e 表示扩展帧，CAN_ID最大29bit，标准帧CAN_ID最大11bit -i表示CAN_ID
cansend can0 -i 0x02 0x11 0x12 --loop=20 # --loop 表示发送20个包
candump can0 # 接收CAN0数据
```