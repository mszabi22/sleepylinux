firewall-cmd --set-default-zone=drop
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -j ACCEPT
firewall-cmd --permanent --zone=drop --add-service=ssh --add-service=samba
firewall-cmd --permanent --zone=drop --add-port=5678/udp --add-port=8291/tcp	#Winbox
firewall-cmd --permanent --zone=drop --add-port=68/udp --add-port=67/udp #DHCP
firewall-cmd --permanent --zone=drop --add-port=9100/tcp --add-port=5353/udp # printer
firewall-cmd --permanent --zone=public --add-icmp-block-inversion
firewall-cmd --permanent --zone=public --add-icmp-block=echo-reply
firewall-cmd --permanent --zone=public --add-icmp-block=echo-request
firewall-cmd --reload
