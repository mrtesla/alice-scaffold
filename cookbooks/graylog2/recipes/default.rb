#
# Cookbook Name:: graylog2
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

RUBY_VERSION = '1.9.3-p125'

unless node.alice.graylog2.mongodb.password
  extend Opscode::OpenSSL::Password
  node['alice']['graylog2']['mongodb']['password'] = secure_password
end

mongodb_user node.alice.graylog2.mongodb.username do
  connection({ :port     => node.alice.mongodb.port,
               :username => node.alice.mongodb.root_user,
               :password => node.alice.mongodb.root_password })

  password node.alice.graylog2.mongodb.password
  database node.alice.graylog2.mongodb.database

  action :create
end

version    = node.alice.graylog2.version
prefix     = File.join(node.alice.prefix, "env/graylog2/#{version}")

directory File.dirname(prefix) do
  mode  "0755"
  action :create
  recursive true
end

package "openjdk-6-jre-headless" do
  action :install
end

installer_src = <<-BASH
  GL_PREFIX=#{prefix.inspect}

  unset BUNDLE_PATH
  unset BUNDLE_FROZEN
  unset BUNDLE_WITHOUT
  unset BUNDLE_BIN
  unset BUNDLE_GEMFILE

  export PATH="$GL_PREFIX/web/bin:#{node.alice.prefix}/env/ruby/#{RUBY_VERSION}/bin:$PATH"

  rm -rf   "$GL_PREFIX"
  rm -rf   /tmp/graylog2-build
  mkdir -p /tmp/graylog2-build
  mkdir -p "$GL_PREFIX"
  mkdir -p "$GL_PREFIX/etc"
  cd       /tmp/graylog2-build

  echo "Downloading graylog2-#{version}"
  wget https://github.com/downloads/Graylog2/graylog2-server/graylog2-server-#{version}.tar.gz 1>&2 || exit 1
  wget https://github.com/downloads/Graylog2/graylog2-web-interface/graylog2-web-interface-#{version}.tar.gz 1>&2 || exit 1

  echo "Extracting graylog2-#{version}"
  tar xzf graylog2-server-#{version}.tar.gz || exit 2
  tar xzf graylog2-web-interface-#{version}.tar.gz || exit 2
  mv ./graylog2-server-#{version} "$GL_PREFIX/server" || exit 2
  mv ./graylog2-web-interface-#{version} "$GL_PREFIX/web" || exit 2

  cd "$GL_PREFIX/web"
  echo 'gem "thin"' >> Gemfile
  echo 'Graylog2WebInterface::Application.configure do'   >> config/environments/production.rb
  echo 'config.serve_static_assets = true'  >> config/environments/production.rb
  echo 'end'                                >> config/environments/production.rb
  bundle install --path vendor/bundle --binstubs --without development test 1>&2 || exit 1
  mkdir -p log
  mkdir -p tmp
  chown -R pluto:pluto log
  chown -R pluto:pluto tmp

  touch $GL_PREFIX/.ok
BASH

cleanup_src = <<-BASH
  GL_PREFIX=#{prefix.inspect}

  rm -rf /tmp/graylog2-build
  [[ -e "$GL_PREFIX/.ok" ]] || rm -rf "$GL_PREFIX"

  exit 0
BASH

script "graylog2-#{version}" do
  not_if      { File.file?(File.join(prefix, ".ok")) }
  interpreter "bash"
  code        installer_src

  notifies :run, "script[graylog2-#{version}-cleanup]"
end

script "graylog2-#{version}-cleanup" do
  action :nothing
  interpreter "bash"
  code        cleanup_src
end

template "graylog2-server-/graylog2.conf" do
  path   File.join(prefix, 'etc/graylog2.conf')
  source "graylog2.conf.erb"

  notifies :restart, 'pluto_service[srv:graylog2:server]'
end

directory File.join(prefix, 'web/log') do
  mode  "0755"
  action :create
  recursive true

  owner "pluto"
  group "pluto"
end

template "graylog2-web-/config/email.yml" do
  path   File.join(prefix, 'web/config/email.yml')
  source "email.yml.erb"
  mode   "0640"
  group  "pluto"

  notifies :restart, 'pluto_service[srv:graylog2:web]'
end

template "graylog2-web-/config/general.yml" do
  path   File.join(prefix, 'web/config/general.yml')
  source "general.yml.erb"
  mode   "0640"
  group  "pluto"

  notifies :restart, 'pluto_service[srv:graylog2:web]'
end

template "graylog2-web-/config/indexer.yml" do
  path   File.join(prefix, 'web/config/indexer.yml')
  source "indexer.yml.erb"
  mode   "0640"
  group  "pluto"

  notifies :restart, 'pluto_service[srv:graylog2:web]'
end

template "graylog2-web-/config/mongoid.yml" do
  path   File.join(prefix, 'web/config/mongoid.yml')
  source "mongoid.yml.erb"
  mode   "0640"
  group  "pluto"

  notifies :restart, 'pluto_service[srv:graylog2:web]'
end

pluto_service "srv:graylog2:server" do
  command "java -jar server/graylog2-server.jar -f $CONFIG_FILE"
  cwd     prefix
  user    "root"

  environment['CONFIG_FILE'] = File.join(prefix, 'etc/graylog2.conf')
  environment['GL_MIN_MEM']  = '256m'
  environment['GL_MAX_MEM']  = '512m'

  action [:enable, :start]
end

pluto_service "srv:graylog2:web" do
  command "script/rails server thin -p $PORT"
  cwd     File.join(prefix, 'web')
  user    "pluto"

  environment['RUBY_VERSION'] = RUBY_VERSION
  environment['RAILS_ENV']    = 'production'
  ports.push('name' => 'PORT', 'type' => 'http', 'port' => node.alice.graylog2.http_port)

  action [:enable, :start]
end
