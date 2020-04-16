#1/bin/bash
ovs-vsctl del-port OVS1 veth0-r
ovs-vsctl del-port OVS1 veth1-r
ovs-vsctl del-port OVS1 veth2-r
ovs-vsctl del-port OVS1 veth0-g
ovs-vsctl del-port OVS1 veth1-g
ovs-vsctl del-port OVS1 veth2-g
ovs-vsctl del-port OVS1 tap-r
ovs-vsctl del-port OVS1 tap-g

ip netns exec smirnov-red ip link del eth0-r
ip netns exec smirnov-red ip link del eth1-r
ip netns exec smirnov-red ip link del eth2-r
ip netns exec smirnov-green ip link del eth0-g
ip netns exec smirnov-green ip link del eth1-g
ip netns exec smirnov-green ip link del eth2-g
ovs-vsctl del-br OVS1

ip netns del smirnov-red
ip netns del smirnov-green
ip netns del dhcp-r
ip netns del dhcp-g
