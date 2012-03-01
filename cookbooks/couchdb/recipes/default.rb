#
# Cookbook Name:: couchdb
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not couchdbtribute
#

include_recipe "openssl"

version    = node.alice.couchdb.version
prefix     = File.join(node.alice.prefix, "env/couchdb/#{version}")
datdir     = File.join(node.alice.prefix, "var/couchdb")

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

directory File.join(datdir, 'run') do
  mode  "0755"
  action :create

  owner "pluto"
  group "pluto"
end

directory File.join(datdir, 'lib') do
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
  COUCHDB_PREFIX=#{prefix.inspect}

  rm -rf   "$COUCHDB_PREFIX"
  rm -rf   /tmp/couchdb-build
  mkdir -p /tmp/couchdb-build
  cd       /tmp/couchdb-build

  echo "Downloading couchdb-#{version}"
  wget http://apache.cs.uu.nl/dist//couchdb/#{version}/apache-couchdb-#{version}.tar.gz -O apache-couchdb-#{version}.tar.gz 1>&2 || exit 1

  echo "Extracting couchdb-#{version}"
  tar xzf apache-couchdb-#{version}.tar.gz || exit 2
  cd apache-couchdb-#{version}

  echo "Building couchdb-#{version}"
  ./configure --prefix=#{prefix} --disable-init --disable-launchd 1>&2 || exit 3
  make 1>&2 || exit 3
  make install 1>&2 || exit 3
  chown -R pluto:pluto $COUCHDB_PREFIX/etc

  touch $COUCHDB_PREFIX/.ok
BASH

cleanup_src = <<-BASH
  COUCHDB_PREFIX=#{prefix.inspect}

  rm -rf /tmp/couchdb-build
  [[ -e "$COUCHDB_PREFIX/.ok" ]] || rm -rf "$COUCHDB_PREFIX"

  exit 0
BASH

script "couchdb-#{version}" do
  not_if      { File.file?(File.join(prefix, ".ok")) }
  interpreter "bash"
  code        installer_src

  notifies :run, "script[couchdb-#{version}-cleanup]"
end

script "couchdb-#{version}-cleanup" do
  action :nothing
  interpreter "bash"
  code        cleanup_src
end

if node.alice.couchdb.auth
  unless node.alice.couchdb.root_password
    extend Opscode::OpenSSL::Password
    node['alice']['couchdb']['root_password']      = secure_password
    node['alice']['couchdb']['root_password_salt'] = Digest::SHA1.hexdigest(secure_password)
  end
end

template "couchdb-default.ini" do
  path   File.join(prefix, 'etc/couchdb/default.ini')
  source "default.ini.erb"
  variables(
    :prefix       => datdir,
    :http_port    => node.alice.couchdb.http_port,
    :ssl_port     => node.alice.couchdb.ssl_port,
    :bind_address => node.alice.couchdb.bind_address,
    :auth         => node.alice.couchdb.auth
  )

  owner "pluto"
  group "pluto"
  notifies :restart, 'pluto_service[srv:couchdb]'
end

template "couchdb-local.ini" do
  path   File.join(prefix, 'etc/couchdb/local.ini')
  source "local.ini.erb"
  variables(
    :prefix       => datdir,
    :http_port    => node.alice.couchdb.http_port,
    :ssl_port     => node.alice.couchdb.ssl_port,
    :bind_address => node.alice.couchdb.bind_address,
    :auth         => node.alice.couchdb.auth,
    :root_user          => node.alice.couchdb.root_user,
    :root_password      => node.alice.couchdb.root_password,
    :root_password_salt => node.alice.couchdb.root_password_salt
  )

  owner "pluto"
  group "pluto"
  notifies :restart, 'pluto_service[srv:couchdb]'
end

pluto_service "srv:couchdb" do
  command 'bin/couchdb'

  cwd     prefix
  user    'pluto'

  ports.push({ 'name' => 'PORT', 'type' => 'http', 'port' => node.alice.couchdb.http_port })
  ports.push({ 'name' => 'SSL_PORT', 'type' => 'https', 'port' => node.alice.couchdb.ssl_port })

  action  [:enable, :start]
end
