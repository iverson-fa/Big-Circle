# 软件安装

## 1. 火狐浏览器

[官网下载](http://firefox.com.cn/download/)

```shell
sudo apt remove firefox*
tar -jxvf Firefox-latest-x86_64.tar.bz2
sudo mv firefox  /opt
sudo vim /usr/share/applications/firefox.desktop
```

将快捷方式放到桌面上，右键赋予启动权限。文件内容为：
```
[Desktop Entry]
Name=firefox
Name[zh_CN]=火狐浏览器
Comment=火狐浏览器
Exec=/opt/firefox/firefox
##Icon=/opt/firefox/browser/icons/mozicon128.png #可能在其他位置
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Application
Encoding=UTF-8
StartupNotify=true
```

## 2. 主题美化

```shell
sudo apt install gnome-tweak-tool
sudo apt install chrome-gnome-shell
```

[美化包下载](https://pan.baidu.com/s/1fhU0dDWqcS2pESK-bzxinw)

也可以在[GTK主题网站](https://www.opendesktop.org/)自己下载，注意安装目录就可以。

```shell
z -d Cupertino.tar.xz
tar xvf Cupertino.tar
sudo cp -r Cupertino /usr/share/icons/Cupertino
```
在[Gnome扩展网站](https://extensions.gnome.org/)安装相应的扩展，一般选两个：
- dash to dock
- user themes

## 3. 安装中文输入法
```shell
sudo apt install ibus-libpinyin
sudo apt install ibus-clutter
```
设置->区域与语言->中文（智能拼音）
## 4. Office2021
1. 下载部署工具 [office tool plus](https://otp.landian.vip/zh-cn/)，解压缩后运行 `Office Tool Plus.exe`；
2. 卸载已安装版本；
3. 主页选择“部署”进入部署界面；
4. 选择：基础设置>产品>“添加产品”>“**Office 专业增强版2021-批量版**”；
5. 在“应用程序”中选择自己需要安装的组件，比如Word、Excel、PowerPoint、Viso等；
6. 然后在“语言”中添加自己的语言，比如“简体中文”；
7. 接下来在“激活设置”中输入激活密钥，并且勾选“自动激活”选项;

   **T3N47-WVHW9-VCT2V-QKP29-P393W** (Office2021)

   **M9N3Y-CCB6D-J66FD-KKGF4-8B799** (Viso2021)

   **2NYG6-3BBBX-M97JW-B7DFV-G6RMB** (Project2021)

8. 通道选择“**Office2021企业长期版**”；
9. 部署模式选择“安装”;
10. 最后点击上方的“**开始部署**”。