#1/bin/bash
ovs-vsctl del-port OVS1 veth0-r
ovs-vsctl del-port OVS1 veth1-r
ovs-vsctl del-port OVS1 veth0-g
ovs-vsctl del-port OVS1 veth1-g
ovs-vsctl del-port OVS1 tap-r
ovs-vsctl del-port OVS1 tap-g

ip netns exec smirnov-red0 ip link del eth0-r
ip netns exec smirnov-red1 ip link del eth1-r
ip netns exec smirnov-green0 ip link del eth0-g
ip netns exec smirnov-green1 ip link del eth1-g
ovs-vsctl del-br OVS1

ip netns del smirnov-red0
ip netns del smirnov-green0
ip netns del smirnov-red1
ip netns del smirnov-green1
ip netns del dhcp-r
ip netns del dhcp-g
