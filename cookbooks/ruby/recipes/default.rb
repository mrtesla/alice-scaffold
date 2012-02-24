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
end

node.alice.ruby.versions.each do |version|
  prefix     = File.join(node.alice.prefix, "env/ruby/#{version}")
  locate_gcc = File.join(node.alice.prefix, "env/chef/cookbooks/ruby/versions/_locate_gcc.sh")
  source     = File.join(node.alice.prefix, "env/chef/cookbooks/ruby/versions/#{version}.sh")

  script "ruby-#{version}" do
    not_if      { File.directory?(prefix) }
    interpreter "bash"
    code        File.read(source).gsub('%PREFIX%', prefix.inspect).gsub('%LOCATE_GCC%', File.read(locate_gcc))
  end
end
