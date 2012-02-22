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

4.times do |i|
  i += 1
  pluto_service "sys:alice:passer:#{i}" do
    command     "node passer.js $PORT"
    cwd         node.alice.passers.prefix
    environment['NODE_VERSION'] = NODE_VERSION
    environment['PORT']         = 5000 + i
    action [:enable, :start]
  end
end
