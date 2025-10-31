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

# Set default policies to ACCEPT (but don'\''t flush existing rules)
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Add NAT rules for ports 3000 to 3100 (without flushing existing rules)
for counter in {3000..3100}; do
    # Check if rule already exists before adding (to avoid duplicates)
    if ! iptables -t nat -C PREROUTING -p tcp --dport $counter -j DNAT --to-destination 80.209.109.231:$counter 2>/dev/null; then
        iptables -t nat -A PREROUTING -p tcp --dport $counter -j DNAT --to-destination 80.209.109.231:$counter
    fi
    
    if ! iptables -t nat -C PREROUTING -p udp --dport $counter -j DNAT --to-destination 80.209.109.231:$counter 2>/dev/null; then
        iptables -t nat -A PREROUTING -p udp --dport $counter -j DNAT --to-destination 80.209.109.231:$counter
    fi
done

# Add masquerading (check if it already exists)
if ! iptables -t nat -C POSTROUTING -j MASQUERADE 2>/dev/null; then
    iptables -t nat -A POSTROUTING -j MASQUERADE
fi

' > /root/make-nat-forwards-3000-3100.sh

# Set executable permissions on the NAT forwarding script
chmod 777 /root/make-nat-forwards-3000-3100.sh

# Install additional packages
apt install -y iptables joe tcpdump nload iftop

# Configure system parameters
echo "net.core.rmem_max=2500000" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fastopen=3" >> /etc/sysctl.conf
sysctl -w net.core.rmem_max=2500000
sysctl -w net.ipv4.tcp_fastopen=3

# Create /etc/rc.local to run the NAT forwarding script on startup
echo '#!/bin/sh -e
/root/make-nat-forwards-3000-3100.sh
exit 0
' > /etc/rc.local

# Set ownership and permissions on /etc/rc.local
chown root /etc/rc.local
chmod 755 /etc/rc.local

# Update nameservers
sed -i '/nameserver/c\nameserver 8.8.8.8\nnameserver 8.8.4.4' /etc/resolv.conf
