#!/bin/bash
ovs-vsctl del-port OVS1 veth-r
ovs-vsctl del-port OVS1 veth-g
ovs-vsctl del-port OVS1 tap-r
ovs-vsctl del-port OVS1 tap-g

ip netns exec smirnov-red ip link del eth0-r
ip netns exec smirnov-green ip link del eth0-g
