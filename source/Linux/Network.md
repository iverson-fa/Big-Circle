# Network

## 1 网络分享

B -> A -> www

```shell
# on A
export eth_share=eth1
export eth_net=eth0
ifconfig $eth_share 192.168.3.1/24
bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'  
iptables -F
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -o $eth_net -j MASQUERADE
```
```shell
# on B
eth_www=eth2
ifconfig $eth_www 192.168.3.2/24
route add -net 0.0.0.0/0 gw 192.168.3.1
chmod +666 /etc/resolv.conf 
echo "nameserver 114.114.114.114" > /etc/resolv.conf
```
