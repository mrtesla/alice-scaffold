#
# Cookbook Name:: alice
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

include_recipe "alice::system"

include_recipe "ruby"
include_recipe "node"

include_recipe "runit"
include_recipe "pluto"
include_recipe "mysql::client"

pluto_cleanup 'sys:**'
pluto_cleanup 'srv:**'

include_recipe "redis"             if node.alice.controller.enabled
include_recipe "varnish"           if node.alice.controller.enabled

include_recipe "alice::controller" if node.alice.controller.enabled
include_recipe "alice::prober"
include_recipe "alice::passers"
include_recipe "alice::routers"
