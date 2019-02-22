P,$2是主机名
RELEASEVER=$(rpm -q --whatprovides redhat-release|awk -F "-" '{print $3}')
#set network
el6or7=$(ip a|awk -F: '/BROADCAST/{print $2}'|tr -d " ")
if [ $RELEASEVER == 6 ];then
cat  > /etc/sysconfig/network-scripts/ifcfg-${el6or7}<<EOF
TYPE="Ethernet"
BOOTPROTO="none"
DEVICE="${el6or7}"
ONBOOT="yes"
IPADDR=192.168.127.100
DNS1=114.114.114.114
GATEWAY=192.168.127.2
EOF
/etc/init.d/network restart && echo "成功重启网卡"
fi
if [ $RELEASEVER == 7 ];then
cat > /etc/sysconfig/network-scripts/ifcfg-${el6or7} <<EOF
TYPE="Ethernet"
BOOTPROTO="none"
DEVICE="${el6or7}"
ONBOOT="yes"
IPADDR=192.168.127.$1
DNS1=114.114.114.114
GATEWAY=192.168.127.2
EOF
ifdown ${el6or7};ifup ${el6or7} && echo "成功重启 ${el6or7} 网卡"
fi

#config yum source
cd /etc/yum.repos.d
[ -d /etc/yum.repos.d/bak ] || mkdir /etc/yum.repos.d/bak
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak
if [ $RELEASEVER == 6 ];then
        curl http://mirrors.aliyun.com/repo/Centos-6.repo   > qh.repo
     curl http://mirrors.aliyun.com/repo/epel-6.repo  > epel.repo
fi
if [ $RELEASEVER == 7 ];then
        curl http://mirrors.aliyun.com/repo/Centos-7.repo    >qh.repo
    curl http://mirrors.aliyun.com/repo/epel-7.repo   > epel.repo

fi
yum clean all
yum makecache

#set hostname
#ip   hostnameip=$(ifconfig |awk -F ":"  '/Bcast/{print $2}'|cut -d" " -f1)

if [ $RELEASEVER == 6 ];then
hostname $2.qh.com
sed -i "s/HOSTNAME=.*/HOSTNAME=$2.qh.com/" /etc/sysconfig/network
fi
if [ $RELEASEVER == 7 ];then
hostname $2.qh.com
echo "$2.qh.com" > /etc/hostname
fi

#disable SELINUX
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disable/' /etc/selinux/config

#clean iptables default rules
if [ $RELEASEVER == 6 ];then
        /sbin/iptables -F
        service iptables save
        chkconfig iptables off
fi

if [ $RELEASEVER == 7 ];then
        systemctl stop firewalld
        systemctl disable firewalld
fi
