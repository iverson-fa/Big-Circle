# 常用命令
## 1 系统信息
```bash
# temperature
cat /sys/class/thermal/thermal_zone0/temp 
```

## 2 屏幕常亮
适用于 `raspbian` 系统，该系统桌面管理器为 `lightdm`，修改 `/etc/lightdm/lightdm.conf`
```bash
# 在 [Seat:*] 中
# xserver-command=X
xserver-command=X -s 0 -dpms
```
其中，-s 参数：设置屏幕保护不启动，0 数字零，-dpms 参数：关闭电源节能管理。重启生效。
## 3 安装中文字体
适用于 `raspbian` 系统，树莓派默认是采用英文字库的，而且系统里没有预装中文字库，即使在locale中改成中文，也不会显示中文，只会显示一堆方块。
```bash
# 安装中文字库，选项都选 y
sudo  apt-get install ttf-wqy-zenhei
# 安装中文输入法
sudo apt-get install fcitx fcitx-googlepinyin fcitx-module-cloudpinyin fcitx-sunpinyin
```
安装完成后在树莓派设置首选项里有一个Fcitx配置，里面可以修改输入法的配置信息，个性化这是必须的。
`sudo raspi-config` 打开设置界面，依次选择 `4 Localisation -> I1 Chage Locale`，一直按方向下键，按空格键选择`zh_CN GB2312`、`zh_CN.GB18030 GB18030`、`zh_CN.GBK GBK`、`zh_CN.UTF-8 UTF-8`，按回车确认。
一直按到最下面，选择`zh_CN.UTF-8`，按回车确认。
重启。
打开树莓派设置：`Preferences -> Raspberry Pi Configuration -> Localisation -> Set Locale`，修改 `Character Set` 为 `GB18030`，重启后会显示中文。
打开树莓派设置：`首选项 -> Fcitx 配置`，点击左下角 `+`，添加`Google 拼音`或`Sunpinyin`。
切换中文输入法：`ctrl+space`。在中文输入法下，可以按`Ctrl+Shift`来切换中文输入法（在输入法设置里可以自行修改）。
## 4 