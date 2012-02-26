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
  prefix = File.join(node.alice.prefix, "env/node/#{version}")
  source = File.join(node.alice.prefix, "env/node/#{version}.sh")

  template source do
    source "#{version}.sh.erb"
    mode   0644
    variables(:prefix => prefix)
  end

  script "node-#{version}" do
    not_if      { File.directory?(prefix) }
    interpreter "bash"
    code        "bash #{source}"
  end
end
