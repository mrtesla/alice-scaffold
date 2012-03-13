#
# Cookbook Name:: rabbitmq
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not rabbitmqtribute
#

include_recipe "openssl"

version    = node.alice.rabbitmq.version
prefix     = File.join(node.alice.prefix, "env/rabbitmq/#{version}")
datdir     = File.join(node.alice.prefix, "var/rabbitmq")

directory File.dirname(prefix) do
  mode  "0755"
  action :create
  recursive true
end

directory File.dirname(datdir) do
  mode  "0755"
  action :create
  recursive true

  owner "root"
  group "root"
end

directory datdir do
  mode  "0755"
  action :create

  owner "pluto"
  group "pluto"
end

directory File.join(datdir, 'mnesia') do
  mode  "0755"
  action :create

  owner "pluto"
  group "pluto"
end

directory File.join(datdir, 'log') do
  mode  "0755"
  action :create

  owner "pluto"
  group "pluto"
end

installer_src = <<-BASH
  RABBITMQ_PREFIX=#{prefix.inspect}

  rm -rf   "$RABBITMQ_PREFIX"
  rm -rf   /tmp/rabbitmq-build
  mkdir -p /tmp/rabbitmq-build
  cd       /tmp/rabbitmq-build

  echo "Downloading rabbitmq-#{version}"
  wget http://www.rabbitmq.com/releases/rabbitmq-server/v#{version}/rabbitmq-server-generic-unix-#{version}.tar.gz 1>&2 || exit 1

  echo "Extracting rabbitmq-#{version}"
  tar xzf rabbitmq-server-generic-unix-#{version}.tar.gz || exit 2
  mv rabbitmq_server-#{version} $RABBITMQ_PREFIX
  mkdir -p $RABBITMQ_PREFIX/etc
  chown -R pluto:pluto $RABBITMQ_PREFIX/etc

  touch $RABBITMQ_PREFIX/.ok
BASH

cleanup_src = <<-BASH
  RABBITMQ_PREFIX=#{prefix.inspect}

  rm -rf /tmp/rabbitmq-build
  [[ -e "$RABBITMQ_PREFIX/.ok" ]] || rm -rf "$RABBITMQ_PREFIX"

  exit 0
BASH

script "rabbitmq-#{version}" do
  not_if      { File.file?(File.join(prefix, ".ok")) }
  interpreter "bash"
  code        installer_src

  notifies :run, "script[rabbitmq-#{version}-cleanup]"
end

script "rabbitmq-#{version}-cleanup" do
  action :nothing
  interpreter "bash"
  code        cleanup_src
end

unless node.alice.rabbitmq.root_password
  extend Opscode::OpenSSL::Password
  node['alice']['rabbitmq']['root_password'] = secure_password
end

template "rabbitmq-rabbitmq.config" do
  path   File.join(prefix, 'etc/rabbitmq.config')
  source "rabbitmq.config.erb"

  owner "pluto"
  group "pluto"
  notifies :restart, 'pluto_service[srv:rabbitmq]'
end

template "rabbitmq-enabled_plugins" do
  path   File.join(prefix, 'etc/enabled_plugins')
  source "enabled_plugins.erb"

  owner "pluto"
  group "pluto"
  notifies :restart, 'pluto_service[srv:rabbitmq]'
end

pluto_service "srv:rabbitmq" do
  command 'sbin/rabbitmq-server'

  cwd     prefix
  user    'pluto'

  environment['RABBITMQ_CONFIG_FILE'] = File.join(prefix, 'etc/rabbitmq')
  environment['RABBITMQ_PLUGINS_DIR'] = File.join(prefix, 'plugins')
  environment['RABBITMQ_ENABLED_PLUGINS_FILE'] = File.join(prefix, 'etc/enabled_plugins')
  environment['HOSTNAME']             = node.name
  environment['RABBITMQ_BASE']        = datdir
  environment['RABBITMQ_MNESIA_BASE'] = File.join(datdir, 'mnesia')
  environment['RABBITMQ_LOG_BASE']    = File.join(datdir, 'log')


  ports.push({ 'name' => 'AMQP_PORT', 'type' => 'amqp', 'port' => node.alice.rabbitmq.amqp_port })
  ports.push({ 'name' => 'PORT',      'type' => 'http', 'port' => node.alice.rabbitmq.http_port })

  action  [:enable, :start]
end
