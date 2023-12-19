#!/bin/bash

apt update -y

apt upgrade -y

apt install iptables tcpdump joe iftop nload net-tools -y

echo '#!/bin/bash

#
#  iptables -t nat -L -v -n
#
#  Madeby Th3Van.dk - 19-07-2023

sysctl net.ipv4.ip_forward=1
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X 

for counter in {28967..29900}; do
 iptables -t nat -A PREROUTING -p tcp --dport $counter -j DNAT --to-destination 212.27.25.143:$counter
 iptables -t nat -A PREROUTING -p udp --dport $counter -j DNAT --to-destination 212.27.25.143:$counter
done

iptables -t nat -A POSTROUTING -j MASQUERADE

' > /root/make-nat-forwards-to-hgplays.sh

apt install -y iptables joe tcpdump nload iftop

chmod 777 /root/make-nat-forwards-to-hgplays.sh

echo "net.core.rmem_max=2500000" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fastopen=3" >> /etc/sysctl.conf

sysctl -w net.core.rmem_max=2500000
sysctl -w net.ipv4.tcp_fastopen=3

echo '#!/bin/sh -e

/root/make-nat-forwards-to-hgplays.sh

exit 0
' > /etc/rc.local

chown root /etc/rc.local
chmod 755 /etc/rc.local

sed -i '/nameserver/c\nameserver 8.8.8.8 8.8.4.4' /etc/resolv.conf 

