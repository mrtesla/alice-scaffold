#
# Cookbook Name:: alice-passers
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

NODE_VERSION = "0.6.11"

directory File.dirname(node.alice.passers.prefix) do
  mode  "0755"
  action :create
end

git node.alice.passers.prefix do
  repository "git://github.com/mrtesla/alice-passer.git"
  reference  "master"
  action     :sync

  notifies :run, "script[update-sys:alice:passer]"
end

script "update-sys:alice:passer" do
  action :nothing
  interpreter "bash"
  code <<-SH
    export PATH="#{node.alice.prefix}/env/node/#{NODE_VERSION}/bin:$PATH"
    cd "#{node.alice.passers.prefix}"
    npm install 1>&2
  SH
end

pluto_service "sys:alice:passer:1" do
  command     "node index.js"
  cwd         node.alice.passers.prefix
  environment['NODE_VERSION'] = NODE_VERSION
  environment['PORT']         = 5001
end

pluto_service "sys:alice:passer:2" do
  command     "node index.js"
  cwd         node.alice.passers.prefix
  environment['NODE_VERSION'] = NODE_VERSION
  environment['PORT']         = 5002
end