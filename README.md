# Linux namespaces
Working with linux namespaces. Create 2 namaspaces with dhcp servers.

# Commands:

ip netnas add smirnov-red --- add namespace

ip netns add smirnov-green

ip netns add dhcp-r

ip netns add dhcp-g

ovs-vsctl add-br OVS1 --- add open vSwitch

ip link add eth0-r type veth peer name veth-r  --- add interfaces and link between them

ip link add eth0-g type veth peer name veth-g

ip link set eth0-r netns smirnov-red  --- add interface to namespace 

ip link set eth0-g netns smirnov-green

ovs-vsctl add-port OVS1 veth-r  --- add port to open vSwitch

ovs-vsctl add-port OVS1 veth-g

ip netns exec smirnov-red ip link set dev lo up  --- up interfaces

ip netns exec smirnov-red ip link set dev eth0-r up

ip netns exec smirnov-green ip link set dev lo up 

ip netns exec smirnov-green ip link set dev eth0-g up

ip netns exec smirnov-red ip address add 10.0.0.1/24 dev eth0-r --- set ip addresses

ip netns exec smirnov-green ip address add 10.0.0.2/24 dev eth0-g

ovs-vsctl set port veth-r tag=100 --- set tags to interfaces

ovs-vsctl set port veth-g tag=200

ip netns exec smirnov-red ip address del 10.0.0.1/24 dev eth0-r --- dlete ip addresses

ip netns exec smirnov-green ip address del 10.0.0.2/24 dev eth0-g

ovs-vsctl add-port OVS1 tap-r --- add interfaces for dhcp (error is normal, next command will fix it)

ovs-vsctl set interface tap-r type=internal

ovs-vsctl set port tap-r tag=100

ovs-vsctl add-port OVS1 tap-g

ovs-vsctl set interface tap-g type=internal

ovs-vsctl set port tap-g tag=200

ip link set tap-r netns dhcp-r 

ip link set tap-g netns dhcp-g 

ip netns exec dhcp-r bash --- go to bash in new namespace

ip link set dev lo up 

ip link set dev tap-r up 

ip address add 10.50.50.2/24 dev tap-r

ip netns exec dhcp-g bash --- go to bash in new namespace

ip link set dev lo up 

ip link set dev tap-g up 

ip address add 10.50.50.2/24 dev tap-g

ip netns exec dhcp-r dnsmasq --interface=tap-r --dhcp-range=10.50.50.10,10.50.50.100,255.255.255.0  --- setup dhcp servers
  
ip netns exec dhcp-g dnsmasq --interface=tap-g --dhcp-range=10.50.50.10,10.50.50.100,255.255.255.0  

# Check system

ip netns exec smirnov-green dhclient -v eth0-g  --- Get ip from dhcp

dhclient -r eth0  --- Drop ip

ping -I eth0 10.50.50.2

# Help commands:
ip netns  --- show all namespaces

ip link del eth --- delete interface

ip netns exec smirnov-red ip link --- show interfaces in namespaces

ovs-vsctl show --- show intefacese on open vSwitch

ovs-vsctl add-port OVS1 veth-r --- delete port from open vSwitch

ovs-vsctl remove port veth-r tag 100 --- delete tag from open vSwitch

