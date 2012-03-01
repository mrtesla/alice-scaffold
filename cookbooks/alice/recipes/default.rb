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

if node.alice.elasticsearch.enabled
  include_recipe "elasticsearch"
end

if node.alice.mongodb.enabled
  include_recipe "mongodb"
end

if node.alice.couchdb.enabled
  include_recipe "couchdb"
end

if node.alice.chef.enabled
  include_recipe 'chef::client'
end

if node.alice.graylog2.enabled
  include_recipe 'graylog2'
end

if node.alice.errbit.enabled
  include_recipe 'errbit'
end

if node.alice.logstash.enabled
  include_recipe 'logstash'
end

if node.alice.mysql.enabled
  include_recipe "alice::mysql"
end

pluto_cleanup 'sys:**'
pluto_cleanup 'srv:**'
pluto_cleanup 'app:**'

if node.alice.controller.enabled
  include_recipe "redis::server"
elsif node.alice.routers.enabled
  include_recipe "redis::tunnel"
end

if node.alice.routers.enabled
  include_recipe "varnish"
end

include_recipe "alice::controller" if node.alice.controller.enabled
include_recipe "alice::prober"
include_recipe "alice::passers"
include_recipe "alice::routers"

if node.alice.passers.enabled
  include_recipe "alice::legacy_applications"
end
