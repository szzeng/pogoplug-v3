 #!/bin/bash
for ((i = 3; i < 253; i++))  
# 这里给一个变量，是对于网内一个IP地址段做限速
do
  iptables -A FORWARD -s 192.168.2.$i -m limit --limit 10/s -j ACCEPT
  iptables -A FORWARD -s 192.168.2.$i -j DROP
done