#!/bin/bash

# Update and install necessary packages
export DEBIAN_FRONTEND=noninteractive
apt update -y
apt-get upgrade -y -o Dpkg::Options::="--force-confnew"
apt install iptables iptables-persistent tcpdump joe iftop nload net-tools -y

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Flush existing rules to avoid duplicates
iptables -F
iptables -t nat -F
iptables -X

# Set default policies to accept
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Set up NAT and forwarding for the specific Storj port
iptables -t nat -A PREROUTING -p tcp --dport 31000 -j DNAT --to-destination 10.200.200.2:28967
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Save the iptables rules to ensure they persist after reboot
netfilter-persistent save

# Network optimizations (optional)
echo "net.core.rmem_max=2500000" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fastopen=3" >> /etc/sysctl.conf
sysctl -w net.core.rmem_max=2500000
sysctl -w net.ipv4.tcp_fastopen=3

# Set DNS servers (optional)
sed -i '/nameserver/c\nameserver 8.8.8.8 8.8.4.4' /etc/resolv.conf
