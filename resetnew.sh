#!/bin/bash
while :
do
read -p '虚拟机名字:' vname
virsh dumpxml ${vname} &> /dev/null
[ $? -ne 0 ] && break
echo "虚拟机已存在!!!" 
done

read -p '主机名(默认与虚拟机名字相同):' host_name
[ -z $host_name ] && host_name=${vname}

cp /virtqemu/beifeng.xml /virtqemu/${vname}.xml
sed -irn "/daniu/s/daniu/${vname}/" /virtqemu/${vname}.xml
qemu-img create -f qcow2 -b /virtqemu/daniu.qcow2 /var/lib/libvirt/images/${vname}.qcow2 > /dev/null
guestmount -a /var/lib/libvirt/images/${vname}.qcow2 -i /virtqemu/qcowmount > /dev/null
rm -f /virtqemu/qcowmount/etc/yum.repos.d/*

i=0
while [ $i -le 3 ] 
do
read -p "请设置eth${i}ip/gateway:" ip_gateway
if [ -n "$ip_gateway" ]
then
ip=${ip_gateway%\/*}
gateway=${ip_gateway#*\/}
if [ $ip == $gateway ]
then
default_gateway=${ip_gateway%%\.*}
[ $default_gateway -ge 1 ] && [ $default_gateway -le 126 ] && gateway=8
[ $default_gateway -ge 127 ] && [ $default_gateway -le 191 ] && gateway=16
[ $default_gateway -ge 192 ] && [ $default_gateway -le 223 ] && gateway=24
[ $default_gateway -ge 224 ] && [ $default_gateway -le 239 ] && gateway=32
[ $default_gateway -ge 240 ] && [ $default_gateway -le 254 ] && gateway=32
fi
sed -irn "/IPADDR/s/.*/IPADDR=$ip/" /virtqemu/qcowmount/etc/sysconfig/network-scripts/ifcfg-eth${i}
sed -irn "/PREFIX/s/.*/PREFIX=$gateway/" /virtqemu/qcowmount/etc/sysconfig/network-scripts/ifcfg-eth${i}
url=${ip%.*}
echo -e "[dvd]\nname=dvd\nbaseurl=ftp://$url.254/centos-1804\nenable=1\ngpgcheck=0" > /virtqemu/qcowmount/etc/yum.repos.d/dvd.repo
case $url in
192.168.4)
sed -irn "/eth${i}/s/default/private1/" /virtqemu/${vname}.xml;;
192.168.2)
sed -irn "/eth${i}/s/default/private2/" /virtqemu/${vname}.xml;;
201.1.1)
sed -irn "/eth${i}/s/default/public1/" /virtqemu/${vname}.xml;;
201.1.2)
sed -irn "/eth${i}/s/default/public2/" /virtqemu/${vname}.xml;;
*)
;;
esac
fi
let i++
done

cp -r /virtqemu/.ssh/ /virtqemu/qcowmount/root/
echo "$host_name" > /virtqemu/qcowmount/etc/hostname
sed -ir '/^SELINUX=/s/.*/SELINUX=disabled/' /virtqemu/qcowmount/etc/selinux/config
sed -ir '/^DefaultZone/s/.*/DefaultZone=trusted/' /virtqemu/qcowmount/etc/firewalld/firewalld.conf
umount /virtqemu/qcowmount
virsh define /virtqemu/${vname}.xml
rm -f /virtqemu/${vname}.xml
rm -f /virtqemu/${vname}.xmlrn
echo -e "\033[32mok\033[0m"
sleep 2
virsh start ${vname} 2> /dev/null
