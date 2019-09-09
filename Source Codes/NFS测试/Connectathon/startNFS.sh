systemctl restart rpcbind
systemctl restart nfs

firewall-cmd --add-service=nfs --permanent
firewall-cmd --reload

