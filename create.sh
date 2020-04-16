#!/bin/bash
# add namespace
ip netns add smirnov-red
ip netns add smirnov-green
ip netns add dhcp-r
ip netns add dhcp-g

#add open vSwitch
ovs-vsctl add-br OVS1

# add links between host and future ovs
ip link add eth0-r type veth peer name veth0-r
ip link add eth1-r type veth peer name veth1-r
ip link add eth2-r type veth peer name veth2-r

ip link add eth0-g type veth peer name veth0-g
ip link add eth1-g type veth peer name veth1-g
ip link add eth2-g type veth peer name veth2-g

# add interface to namespace
ip link set eth0-r netns smirnov-red
ip link set eth1-r netns smirnov-red
ip link set eth2-r netns smirnov-red
ip link set eth0-g netns smirnov-green
ip link set eth1-g netns smirnov-green
ip link set eth2-g netns smirnov-green

# add port to open vSwitch
ovs-vsctl add-port OVS1 veth0-r
ovs-vsctl add-port OVS1 veth1-r
ovs-vsctl add-port OVS1 veth2-r
ovs-vsctl add-port OVS1 veth0-g
ovs-vsctl add-port OVS1 veth1-g
ovs-vsctl add-port OVS1 veth2-g

#  up interfaces
ip link set veth0-r up
ip link set veth1-r up
ip link set veth2-r up
ip link set veth0-g up
ip link set veth1-g up
ip link set veth2-g up
ip netns exec smirnov-red ip link set dev lo up
ip netns exec smirnov-red ip link set dev eth0-r up
ip netns exec smirnov-red ip link set dev eth1-r up
ip netns exec smirnov-red ip link set dev eth2-r up
ip netns exec smirnov-green ip link set dev lo up
ip netns exec smirnov-green ip link set dev eth0-g up
ip netns exec smirnov-green ip link set dev eth1-g up
ip netns exec smirnov-green ip link set dev eth2-g up


# set tags to interfaces
ovs-vsctl set port veth0-r tag=100
ovs-vsctl set port veth1-r tag=100
ovs-vsctl set port veth2-r tag=100
ovs-vsctl set port veth0-g tag=200
ovs-vsctl set port veth1-g tag=200
ovs-vsctl set port veth2-g tag=200


# add interfaces for dhcp (error is normal, next command will fix it)
ovs-vsctl add-port OVS1 tap-r
ovs-vsctl set interface tap-r type=internal
ovs-vsctl set port tap-r tag=100
ovs-vsctl add-port OVS1 tap-g
ovs-vsctl set interface tap-g type=internal
ovs-vsctl set port tap-g tag=200
ip link set tap-r netns dhcp-r
ip link set tap-g netns dhcp-g

# set dhcp dev
ip netns exec dhcp-r ip link set dev lo up
ip netns exec dhcp-r ip link set dev tap-r up
ip netns exec dhcp-r ip address add 10.50.50.2/24 dev tap-r


# set dhcp dev
ip netns exec dhcp-g ip link set dev lo up
ip netns exec dhcp-g ip link set dev tap-g up
ip netns exec dhcp-g ip address add 10.50.50.2/24 dev tap-g

# set dhcp processes
ip netns exec dhcp-r dnsmasq --interface=tap-r --dhcp-range=10.50.50.10,10.50.50.100,255.255.255.0
ip netns exec dhcp-g dnsmasq --interface=tap-g --dhcp-range=10.50.50.10,10.50.50.100,255.255.255.0

# get ip address from dhcp
ip netns exec smirnov-red dhclient eth0-r
ip netns exec smirnov-red dhclient eth1-r
ip netns exec smirnov-red dhclient eth2-r
ip netns exec smirnov-green dhclient eth0-g
ip netns exec smirnov-green dhclient eth1-g
ip netns exec smirnov-green dhclient eth2-g