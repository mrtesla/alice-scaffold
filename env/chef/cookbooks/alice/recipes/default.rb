#
# Cookbook Name:: alice
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

include_recipe "alice::system"

include_recipe "runit"
include_recipe "redis"
include_recipe "ruby"
include_recipe "node"

include_recipe "alice::prober"
include_recipe "alice::passers"
include_recipe "alice::routers"
