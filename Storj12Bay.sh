#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Update and upgrade the system
apt update -y
apt-get upgrade -y -o Dpkg::Options::="--force-confnew"

# Install necessary packages
apt install iptables tcpdump joe iftop nload net-tools -y

# Create the NAT forwarding script
echo '#!/bin/bash

# Enable IP forwarding
sysctl net.ipv4.ip_forward=1

# Set default policies to ACCEPT
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Flush all existing rules
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X

# Add NAT rules for ports 31000 to 31100
for counter in {31000..31100}; do
  iptables -t nat -A PREROUTING -p tcp --dport $counter -j DNAT --to-destination 80.209.109.231:$counter
  iptables -t nat -A PREROUTING -p udp --dport $counter -j DNAT --to-destination 80.209.109.231:$counter
done

# Add masquerading
iptables -t nat -A POSTROUTING -j MASQUERADE
' > /root/make-nat-forwards-to-80-209-109-231.sh

# Set executable permissions on the NAT forwarding script
chmod 777 /root/make-nat-forwards-to-80-209-109-231.sh

# Install additional packages
apt install -y iptables joe tcpdump nload iftop

# Configure system parameters
echo "net.core.rmem_max=2500000" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fastopen=3" >> /etc/sysctl.conf
sysctl -w net.core.rmem_max=2500000
sysctl -w net.ipv4.tcp_fastopen=3

# Create /etc/rc.local to run the NAT forwarding script on startup
echo '#!/bin/sh -e
/root/make-nat-forwards-to-80-209-109-231.sh
exit 0
' > /etc/rc.local

# Set ownership and permissions on /etc/rc.local
chown root /etc/rc.local
chmod 755 /etc/rc.local

# Update nameservers
sed -i '/nameserver/c\nameserver 8.8.8.8 8.8.4.4' /etc/resolv.conf
