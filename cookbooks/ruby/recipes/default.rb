#
# Cookbook Name:: ruby
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

directory File.join(node.alice.prefix, 'env/ruby') do
  mode  "0755"
  action :create
  recursive true
end

node.alice.ruby.versions.each do |version|
  prefix     = File.join(node.alice.prefix, "env/ruby/#{version}")
  source     = File.join(node.alice.prefix, "env/ruby/#{version}.sh")

  template source do
    source "#{version}.sh.erb"
    mode   0644
    variables(:prefix => prefix)
  end

  script "ruby-#{version}" do
    not_if      { File.directory?(prefix) }
    interpreter "bash"
    code        "bash #{source}"
  end
end
