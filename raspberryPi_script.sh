#!/bin/bash  
export DEBIAN_FRONTEND=noninteractive  
  
# Create the NAT forwarding script  
echo '#!/bin/bash  
  
# Enable IP forwarding  
sysctl net.ipv4.ip_forward=1  
  
# Set default policies to ACCEPT  
iptables -P INPUT ACCEPT  
iptables -P FORWARD ACCEPT  
iptables -P OUTPUT ACCEPT  
  
# Add NAT rules for ports 3000 to 3010  
for counter in {3000..3010}; do  
  iptables -t nat -A PREROUTING -p tcp --dport $counter -j DNAT --to-destination 80.209.109.228:$counter  
  iptables -t nat -A PREROUTING -p udp --dport $counter -j DNAT --to-destination 80.209.109.228:$counter  
done  
  
# Add masquerading  
iptables -t nat -A POSTROUTING -j MASQUERADE  
' > /root/make-nat-forwards-to-hgplays.sh  
  
# Set executable permissions on the NAT forwarding script  
chmod 777 /root/make-nat-forwards-to-hgplays.sh  
  
# Create /etc/rc.local to run the NAT forwarding script on startup  
echo '#!/bin/sh -e  
/root/make-nat-forwards-to-hgplays.sh  
exit 0  
' > /etc/rc.local  
  
# Set ownership and permissions on /etc/rc.local  
chown root /etc/rc.local  
chmod 755 /etc/rc.local  
