#
# Cookbook Name:: chef-client
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not chef-clienttribute
#

RUBY_VERSION = '1.9.2-p290'

prefix = File.join(node.alice.prefix, "env/chef")

directory prefix do
  mode  "0755"
  action :create
  recursive true
end

%w( chef mongo mysql couchrest ).each do |gem_name|
  gem_package gem_name do
    gem_binary "#{node.alice.prefix}/env/ruby/#{RUBY_VERSION}/bin/gem"
    action :install
  end
end

file "bin/chef-client" do
  path File.join(node.alice.prefix, 'bin/chef-client')
  mode '0755'
  content <<-BASH
#!/usr/bin/env bash
export RUBY_VERSION=#{RUBY_VERSION}
export PATH="#{node.alice.prefix}/env/ruby/$RUBY_VERSION/bin:$PATH"

exec "#{node.alice.prefix}/env/ruby/$RUBY_VERSION/bin/chef-client" "$@"
BASH
end

pluto_service "srv:chef-client" do
  command "chef-client -c /etc/chef/client.rb -i 1800 -s 20"
  cwd     prefix
  user    "root"

  environment['RUBY_VERSION'] = RUBY_VERSION

  action  [:enable, :start]
end

package 'chef' do
  action :remove
end
