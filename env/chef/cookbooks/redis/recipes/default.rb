#
# Cookbook Name:: redis
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

version    = node.alice.redis.version
prefix     = File.join(node.alice.prefix, "env/redis/#{version}")
datdir     = File.join(node.alice.prefix, "var/redis")

directory prefix do
  mode  "0755"
  action :create
  recursive true
end

directory File.join(prefix, 'etc') do
  mode  "0755"
  action :create
  recursive true
end

directory datdir do
  mode  "0755"
  action :create
  recursive true
end

installer_src = <<-BASH
  REDIS_PREFIX=#{prefix.inspect}

  rm -rf   "$REDIS_PREFIX"
  rm -rf   /tmp/redis-build
  mkdir -p /tmp/redis-build
  cd       /tmp/redis-build

  echo "Downloading redis-#{version}"
  wget http://redis.googlecode.com/files/redis-#{version}.tar.gz 1>&2 || exit 1

  echo "Extracting redis-#{version}"
  tar xzf redis-#{version}.tar.gz || exit 2
  cd redis-#{version}

  echo "Building redis-#{version}"
  make 1>&2 || exit 3
  make PREFIX=$REDIS_PREFIX install 1>&2 || exit 4
  touch $REDIS_PREFIX/.ok
BASH

cleanup_src = <<-BASH
  REDIS_PREFIX=#{prefix.inspect}

  rm -rf /tmp/redis-build
  [[ -e "$REDIS_PREFIX/.ok" ]] || rm -rf "$REDIS_PREFIX"

  exit 0
BASH

script "redis-#{version}" do
  not_if      { File.file?(File.join(prefix, ".ok")) }
  interpreter "bash"
  code        installer_src

  notifies :run, "script[redis-#{version}-cleanup]"
end

script "redis-#{version}-cleanup" do
  action :nothing
  interpreter "bash"
  code        cleanup_src
end

template "redis-config" do
  path   File.join(prefix, 'etc/redis.conf')
  source "redis.conf.erb"
  variables(:port => node.alice.redis.port, :dir => datdir)

  notifies :restart, 'pluto_service[srv:redis]'
end

pluto_service "srv:redis" do
  command "bin/redis-server etc/redis.conf"
  cwd     prefix
  action  [:enable, :start]
end
