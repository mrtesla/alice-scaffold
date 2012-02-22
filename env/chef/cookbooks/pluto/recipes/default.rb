#
# Cookbook Name:: pluto
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

NODE_VERSION = "0.6.11"

directory File.join(node.alice.prefix, 'bin') do
  mode  "0755"
  action :create
end

directory File.dirname(node.alice.pluto.prefix) do
  mode  "0755"
  action :create
end

git node.alice.pluto.prefix do
  repository "git://github.com/mrtesla/pluto.git"
  reference  "develop"
  action     :sync

  notifies :run, "script[update-pluto]"
end

script "update-pluto" do
  action :nothing
  interpreter "bash"
  code <<-SH
    export PATH="#{node.alice.prefix}/env/node/#{NODE_VERSION}/bin:$PATH"
    cd "#{node.alice.pluto.prefix}"
    npm install 1>&2
  SH
end

file "bin/pluto" do
  path File.join(node.alice.prefix, 'bin/pluto')
  mode '0755'
  content <<-BASH
#!/usr/bin/env bash
export PATH="#{node.alice.prefix}/env/node/0.6.11/bin:$PATH"
export NODE_VERSION=0.6.11
export PLUTO_ROOT="#{node.alice.prefix}"
export PLUTO_SRV_ENABLED="#{node.alice.prefix}/var/runit/enabled-services"
export PLUTO_SRV_AVAILABLE="#{node.alice.prefix}/var/runit/available-services"
exec "#{node.alice.pluto.prefix}/bin/pluto" "$@"
BASH
end

file "bin/pluto-init" do
  path File.join(node.alice.prefix, 'bin/pluto-init')
  mode '0755'
  content <<-BASH
#!/usr/bin/env bash
export PATH="#{node.alice.prefix}/env/runit/2.1.1/bin:$PATH"
export PLUTO_SRV_ENABLED="#{node.alice.prefix}/var/runit/enabled-services"
exec runsvdir -P "$PLUTO_SRV_ENABLED" 'log: ...........................................................................................................................................................................................................................................................................................................................................................................................................'
BASH
end

if platform?('mac_os_x')
  template "launchd-pluto-init" do
    path   File.expand_path('~/Library/LaunchAgents/cc.mrtesla.pluto-init.plist')
    source "pluto_init.plist.erb"
    variables(:alice_root => node.alice.prefix)
  end
end
