#
# Cookbook Name:: node
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

directory File.join(node.alice.prefix, 'env/node') do
  mode  "0755"
  action :create
end

node.alice.node.versions.each do |version|
  prefix     = File.join(node.alice.prefix, "env/node/#{version}")
  #locate_gcc = File.join(node.alice.prefix, "env/chef/cookbooks/node/versions/_locate_gcc.sh")
  source     = File.join(node.alice.prefix, "env/chef/cookbooks/node/versions/#{version}.sh")

  script "node-#{version}" do
    not_if      { File.directory?(prefix) }
    interpreter "bash"
    code        File.read(source).gsub('%PREFIX%', prefix.inspect)#.gsub('%LOCATE_GCC%', locate_gcc)
  end
end
