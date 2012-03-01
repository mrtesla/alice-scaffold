#
# Cookbook Name:: logstash
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

version    = node.alice.logstash.version
prefix     = File.join(node.alice.prefix, "env/logstash/#{version}")

directory prefix do
  mode  "0755"
  action :create
  recursive true
end

installer_src = <<-BASH
  LOG_STASH_PREFIX=#{prefix.inspect}

  rm -rf   "$LOG_STASH_PREFIX"
  rm -rf   /tmp/logstash-build
  mkdir -p /tmp/logstash-build
  mkdir -p "$LOG_STASH_PREFIX"
  cd       /tmp/logstash-build

  echo "Downloading logstash-#{version}"
  wget http://semicomplete.com/files/logstash/logstash-#{version}-monolithic.jar 1>&2 || exit 1
  mv ./logstash-#{version}-monolithic.jar "$LOG_STASH_PREFIX/logstash-#{version}-monolithic.jar" || exit 2

  touch $LOG_STASH_PREFIX/.ok
BASH

cleanup_src = <<-BASH
  LOG_STASH_PREFIX=#{prefix.inspect}

  rm -rf /tmp/logstash-build
  [[ -e "$LOG_STASH_PREFIX/.ok" ]] || rm -rf "$LOG_STASH_PREFIX"

  exit 0
BASH

script "logstash-#{version}" do
  not_if      { File.file?(File.join(prefix, ".ok")) }
  interpreter "bash"
  code        installer_src

  notifies :run, "script[logstash-#{version}-cleanup]"
end

script "logstash-#{version}-cleanup" do
  action :nothing
  interpreter "bash"
  code        cleanup_src
end

template "logstash-config" do
  path   File.join(prefix, 'logstash.conf')
  source "logstash.conf.erb"

  mode  "0640"
  group "pluto"

  notifies :restart, 'pluto_service[srv:logstash]'
end

pluto_service "srv:logstash" do
  command "java -jar logstash-#{version}-monolithic.jar agent -f logstash.conf"
  cwd     prefix
  user    "pluto"

  environment['LOG_STASH_MIN_MEM']  = '256m'
  environment['LOG_STASH_MAX_MEM']  = '1024m'

  action [:enable, :start]
end
