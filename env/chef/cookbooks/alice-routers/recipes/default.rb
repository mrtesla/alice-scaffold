#
# Cookbook Name:: alice-routers
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

NODE_VERSION = "0.6.11"

directory File.dirname(node.alice.routers.prefix) do
  mode  "0755"
  action :create
end

git node.alice.routers.prefix do
  repository "git://github.com/mrtesla/alice-router.git"
  reference  "master"
  action     :sync

  notifies :run, "script[update-sys:alice:router]"
end

script "update-sys:alice:router" do
  action :nothing
  interpreter "bash"
  code <<-SH
    export PATH="#{node.alice.prefix}/env/node/#{NODE_VERSION}/bin:$PATH"
    cd "#{node.alice.routers.prefix}"
    npm install 1>&2
  SH
end

pluto_service "sys:alice:router:1" do
  command     "node index.js"
  cwd         node.alice.routers.prefix
  environment['NODE_VERSION'] = '0.6.10'
  environment['PORT']         = 4001
end

pluto_service "sys:alice:router:2" do
  command     "node index.js"
  cwd         node.alice.routers.prefix
  environment['NODE_VERSION'] = '0.6.10'
  environment['PORT']         = 4002
end
