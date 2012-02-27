#
# Cookbook Name:: elasticsearch
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

version    = node.alice.elasticsearch.version
prefix     = File.join(node.alice.prefix, "env/elasticsearch/#{version}")
datdir     = File.join(node.alice.prefix, "var/elasticsearch")

directory File.dirname(prefix) do
  mode  "0755"
  action :create
  recursive true
end

directory datdir do
  mode  "0755"
  action :create
  recursive true
end

package "openjdk-6-jre-headless" do
  action :install
end

installer_src = <<-BASH
  ES_PREFIX=#{prefix.inspect}

  rm -rf   "$ES_PREFIX"
  rm -rf   /tmp/elasticsearch-build
  mkdir -p /tmp/elasticsearch-build
  cd       /tmp/elasticsearch-build

  echo "Downloading elasticsearch-#{version}"
  wget https://github.com/downloads/elasticsearch/elasticsearch/elasticsearch-#{version}.tar.gz 1>&2 || exit 1

  echo "Extracting elasticsearch-#{version}"
  tar xzf elasticsearch-#{version}.tar.gz || exit 2
  mv ./elasticsearch-#{version} "$ES_PREFIX" || exit 2
  mkdir -p "$ES_PREFIX/etc"

  touch $ES_PREFIX/.ok
BASH

cleanup_src = <<-BASH
  ES_PREFIX=#{prefix.inspect}

  rm -rf /tmp/elasticsearch-build
  [[ -e "$ES_PREFIX/.ok" ]] || rm -rf "$ES_PREFIX"

  exit 0
BASH

script "elasticsearch-#{version}" do
  not_if      { File.file?(File.join(prefix, ".ok")) }
  interpreter "bash"
  code        installer_src

  notifies :run, "script[elasticsearch-#{version}-cleanup]"
end

script "elasticsearch-#{version}-cleanup" do
  action :nothing
  interpreter "bash"
  code        cleanup_src
end

template "elasticsearch-config" do
  path   File.join(prefix, 'etc/elasticsearch.yml')
  source "elasticsearch.yml.erb"

  notifies :restart, 'pluto_service[srv:elasticsearch]'
end

template "elasticsearch-logging" do
  path   File.join(prefix, 'etc/logging.yml')
  source "logging.yml.erb"

  notifies :restart, 'pluto_service[srv:elasticsearch]'
end

pluto_service "srv:elasticsearch" do
  command "bin/elasticsearch -f -Des.config=$CONFIG_FILE -Des.path.home=$ES_HOME -Des.path.logs=$LOG_DIR -Des.path.data=$DATA_DIR -Des.path.work=$WORK_DIR"
  cwd     prefix
  user    "root"

  environment['CONFIG_FILE'] = File.join(prefix, 'etc/elasticsearch.yml')
  environment['LOG_DIR']     = File.join(node.alice.prefix, 'var/elasticsearch/log')
  environment['DATA_DIR']    = File.join(node.alice.prefix, 'var/elasticsearch/data')
  environment['WORK_DIR']    = '/tmp/elasticsearch'
  environment['ES_HOME']     = prefix
  environment['ES_MIN_MEM']  = '256m'
  environment['ES_MAX_MEM']  = '1024m'

  action [:enable, :start]
end
