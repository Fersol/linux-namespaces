#!/bin/bash
# add namespace
ip netnas add smirnov-red
ip netns add smirnov-green
ip netns add dhcp-r
ip netns add dhcp-g

add open vSwitch
ovs-vsctl add-br OVS1

# add interfaces and link between them
ip link add eth0-r type veth peer name veth-r
ip link add eth0-g type veth peer name veth-g

# add interface to namespace
ip link set eth0-r netns smirnov-red
ip link set eth0-g netns smirnov-green

# add port to open vSwitch
ovs-vsctl add-port OVS1 veth-r
ovs-vsctl add-port OVS1 veth-g
#  up interfaces
ip netns exec smirnov-red ip link set dev lo up
ip netns exec smirnov-red ip link set dev eth0-r up
ip netns exec smirnov-green ip link set dev lo up
ip netns exec smirnov-green ip link set dev eth0-g up

# set ip addresses
ip netns exec smirnov-red ip address add 10.0.0.1/24 dev eth0-r 
ip netns exec smirnov-green ip address add 10.0.0.2/24 dev eth0-g

# set tags to interfaces
ovs-vsctl set port veth-r tag=100
ovs-vsctl set port veth-g tag=200

# delete ip addresses
ip netns exec smirnov-red ip address del 10.0.0.1/24 dev eth0-r
ip netns exec smirnov-green ip address del 10.0.0.2/24 dev eth0-g

# add interfaces for dhcp (error is normal, next command will fix it)
ovs-vsctl add-port OVS1 tap-r
ovs-vsctl set interface tap-r type=internal
ovs-vsctl set port tap-r tag=100
ovs-vsctl add-port OVS1 tap-g
ovs-vsctl set interface tap-g type=internal
ovs-vsctl set port tap-g tag=200
ip link set tap-r netns dhcp-r
ip link set tap-g netns dhcp-g

# go to bash in new namespace
ip netns exec dhcp-r bash
ip link set dev lo up
ip link set dev tap-r up
ip address add 10.50.50.2/24 dev tap-r

# go to bash in new namespace
ip netns exec dhcp-g bash
ip link set dev lo up
ip link set dev tap-g up
ip address add 10.50.50.2/24 dev tap-g
ip netns exec dhcp-r dnsmasq --interface=tap-r --dhcp-range=10.50.50.10,10.50.50.100,255.255.255.0
ip netns exec dhcp-g dnsmasq --interface=tap-g --dhcp-range=10.50.50.10,10.50.50.100,255.255.255.0
