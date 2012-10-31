#
# Cookbook Name:: multi-home
# Recipe:: default
#
# Copyright 2011, Cramer Development, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Set up a 'cloud' attribute for the node using eth0 as the private IP and 
# eth1 as the public.

unless node.has_key?(:cloud)
  require 'ipaddr'

  node_network_interfaces = node[:network][:interfaces]
  ifaces = {
    :private  => ((node_network_interfaces[:eth0] || {})[:addresses] || {}),
    :public   => ((node_network_interfaces[:eth1] || {})[:addresses] || {})
  }
  ips = {
    :private => [],
    :public  => []
  }

  ifaces.each do |p, iface|
    # The interface is ipv4 if it doesn't have an :s
    iface.keys.each {|addr| ips[p] << addr if !addr.include?(':') }
  end

  unless ips.values.any?(&:empty?)
    node[:cloud] = {
      :local_hostname  => node[:hostname],
      :local_ipv4      => ips[:private].first,
      :private_ips     => ips[:private],
      :provider        => 'internal',
      :public_hostname => node[:hostname],
      :public_ips      => ips[:public],
      :public_ipv4     => ips[:public].first
    }
  end
end
