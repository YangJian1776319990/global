#!/bin/bash
read -p '虚拟机名字:' name
read -p 'eth0  ip/gateway:' aa
read -p 'eth1  ip/gateway:' bb
if [ -n $aa ]
then
ip1=${aa%\/*}
gateway1=${aa#*\/}
else
ip1=0.0.0.0
gateway1=0
fi
if [ -n $bb ]
then
ip2=${bb%\/*}
gateway1=${bb#*\/}
else
ip2=0.0.0.0
gateway2=0
fi

virsh dumpxml $name &> /dev/null
[ $? -eq 0 ] && echo "虚拟机已存在"&& exit
cp /virtqemu/beifeng.xml /virtqemu/$name.xml
sed -irn "/daniu/s/daniu/$name/" /virtqemu/$name.xml
qemu-img create -f qcow2 -b /virtqemu/daniu.qcow2 /var/lib/libvirt/images/$name.qcow2
guestmount -a /var/lib/libvirt/images/$name.qcow2 -i /virtqemu/qcowmount > /dev/null
sed -irn "/IPADDR/s/.*/IPADDR=$ip1/" /virtqemu/qcowmount/etc/sysconfig/network-scripts/ifcfg-eth0
sed -irn "/PREFIX/s/.*/PREFIX=$gateway1/" /virtqemu/qcowmount/etc/sysconfig/network-scripts/ifcfg-eth0
sed -irn "/IPADDR/s/.*/IPADDR=$ip2/" /virtqemu/qcowmount/etc/sysconfig/network-scripts/ifcfg-eth1
sed -irn "/PREFIX/s/.*/PREFIX=$gateway2/" /virtqemu/qcowmount/etc/sysconfig/network-scripts/ifcfg-eth1
echo "$name" > /virtqemu/qcowmount/etc/hostname
rm -f /virtqemu/qcowmount/etc/yum.repos.d/*
if [ $ip1 != "0.0.0.0" ]
then 
url=${ip1%.*}
echo -e "[dvd]\nname=dvd\nbaseurl=ftp://$url.254/centos-1804\nenable=1\ngpgcheck=0" > /virtqemu/qcowmount/etc/yum.repos.d/dvd.repo
fi
if [ $ip2 != "0.0.0.0" ]
then
url=${ip2%.*}
echo -e "[dvds]\nname=dvds\nbaseurl=ftp://$url.254/centos-1804\nenable=1\ngpgcheck=0" > /virtqemu/qcowmount/etc/yum.repos.d/dvds.repo
fi
sed -ir '/^SELINUX=/s/.*/SELINUX=disabled/' /virtqemu/qcowmount/etc/selinux/config
sed -ir '/^DefaultZone/s/.*/DefaultZone=trusted/' /virtqemu/qcowmount/etc/firewalld/firewalld.conf
umount /virtqemu/qcowmount
virsh define /virtqemu/$name.xml
rm -f /virtqemu/$name.xml
echo -e "\033[32mok\033[0m"
sleep 2
virsh start $name 2> /dev/null;


