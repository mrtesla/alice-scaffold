#
# Cookbook Name:: pluto
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

NODE_VERSION = "0.6.11"

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

execute "start pluto" do
  #not_if
  command "sleep 1"
end
