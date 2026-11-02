#!/bin/bash
echo 'host' > /sys/devices/platform/bus@0/3520000.padctl/usb2-0/usb_role/usb2-0-role-switch/role
iptables -I INPUT -p tcp --dport 111 -j DROP
iptables -I INPUT -p udp --dport 111 -j DROP
/opt/tools/EIS860_Get_CPU_temp/pythoninstall.sh
/opt/tools/EIS860_Get_CPU_temp/EIS860_Set_Cpu_temp.sh 2>&1 &
/opt/tools/EIS860_Get_CPU_temp/NetLight.sh
