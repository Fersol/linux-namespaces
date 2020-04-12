# linux-namespaces
Working with linux namespaces

All namespaces are in root namespaces

To add new namespace use **ip netns add** command (under sudo):

ip netnas add smirnov-red

ip netns add smirnov-green

To show all namespaces:

ip netns

For executing programs inside other namespace use command **exec** (under sudo):

ip netns exec smirnov-red ip link    ---   Look at link in namespace


Add open vSwitch bridge (under sudo):

ovs-vsctl add-br OVS1   ---  del-br to delete

Add port devices (with sudo):

sudo ip link add eth0-r type bridge

???sudo ip link add veth-r type bridge

To add ports to OVS bridge (under sudo):

ovs-vsctl add-port OVS1 veth-r

To look, that all is ok:

ovs-vsctl show

Add port to namespace:

?ip link set eth0-r netns smirnov-red


To set bridge interface into namespace:

ip link OVS1 

