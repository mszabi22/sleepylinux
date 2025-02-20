firewall-cmd --set-default-zone=drop
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -j ACCEPT
firewall-cmd --permanent --zone=public --add-icmp-block-inversion
firewall-cmd --permanent --zone=public --add-icmp-block=echo-reply
firewall-cmd --permanent --zone=public --add-icmp-block=echo-request
firewall-cmd --permanent --zone=drop --add-service=ssh
firewall-cmd --permanent --zone=drop --add-port=5678/udp --add-port=8291/tcp
firewall-cmd --permanent --zone=drop --add-port=68/udp --add-port=67/udp 
firewall-cmd --reload
