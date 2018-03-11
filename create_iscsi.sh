#!/bin/bash
name=$1
size=$2
user=$3
password=$4
pool=$5
rbd create "$name" --size "$size" --pool "$pool"
echo "rbd create"
rbdname=$( rbd map "$name" --pool "$pool" --name client.admin)
echo "rbd map"
#echo "Create name $name, size object storage $size";
rbd --image $name info --pool "$pool"
echo "rbd info";
echo "scsi/"$name"" >> /etc/ceph/rbdmap
targetcli /backstores/block create $name $rbdname
#echo "targetcli /backstores/block create $name $rbdname"
targetcli /iscsi create iqn.2003-01.org.linux-iscsi.mon00.x8664:sn.$name
#echo "targetcli /iscsi create iqn.2003-01.org.linux-iscsi.mon00.x8664:sn.$name"
name1=iqn.2003-01.org.linux-iscsi.mon00.x8664:sn.$name
#echo "$name1"
#echo "targetcli /iscsi/$name1/tpg1/portals create"
targetcli /iscsi/$name1/tpg1/portals create
#sleep 2;
#echo "targetcli /iscsi/$name1/tpg1/luns create /backstores/block/$name"
targetcli /iscsi/$name1/tpg1/luns create /backstores/block/$name
#sleep 2;
#echo "targetcli /iscsi/$name1/tpg1/acls create iqn.1994-05.com.redhat:$name"
targetcli /iscsi/$name1/tpg1/acls create iqn.1994-05.com.redhat:$name
targetcli /iscsi/$name1/tpg1 set auth userid=$user
targetcli /iscsi/$name1/tpg1 set auth password=$password
targetcli /iscsi/$name1/tpg1 set attribute demo_mode_write_protect=0
targetcli /iscsi/$name1/tpg1 set attribute generate_node_acls=1
targetcli saveconfig
echo -en "\033[37;1;41m use client wwn InitiatorName=iqn.1994-05.com.redhat:$name \033[0m"
systemctl restart targetd; systemctl restart target
