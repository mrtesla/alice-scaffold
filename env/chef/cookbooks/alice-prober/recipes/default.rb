#
# Cookbook Name:: alice-prober
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

NODE_VERSION = "0.6.11"

directory File.dirname(node.alice.prober.prefix) do
  mode  "0755"
  action :create
end

git node.alice.prober.prefix do
  repository "git://github.com/mrtesla/alice-prober.git"
  reference  "master"
  action     :sync

  notifies :run, "script[update-sys:alice:prober]"
end

script "update-sys:alice:prober" do
  action :nothing
  interpreter "bash"
  code <<-SH
    export PATH="#{node.alice.prefix}/env/node/#{NODE_VERSION}/bin:$PATH"
    cd "#{node.alice.prober.prefix}"
    npm install 1>&2
  SH
end

pluto_service "sys:alice:prober" do
  command     "node index.js"
  cwd         node.alice.prober.prefix
  environment['NODE_VERSION'] = '0.6.10'
end
