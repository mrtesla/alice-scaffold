#
# Cookbook Name:: mongodb
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not mongodbtribute
#

include_recipe "openssl"

version    = node.alice.mongodb.version
prefix     = File.join(node.alice.prefix, "env/mongodb/#{version}")
datdir     = File.join(node.alice.prefix, "var/mongodb")

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

installer_src = <<-BASH
  MONGO_PREFIX=#{prefix.inspect}

  rm -rf   "$MONGO_PREFIX"
  rm -rf   /tmp/mongodb-build
  mkdir -p /tmp/mongodb-build
  cd       /tmp/mongodb-build

  echo "Downloading mongodb-#{version}"
  wget http://fastdl.mongodb.org/linux/mongodb-linux-i686-#{version}.tgz -O mongodb-linux-i686-#{version}.tar.gz 1>&2 || exit 1

  echo "Extracting mongodb-#{version}"
  tar xzf mongodb-linux-i686-#{version}.tar.gz || exit 2

  echo "Building mongodb-#{version}"
  mv mongodb-linux-i686-#{version} "$MONGO_PREFIX"

  touch $MONGO_PREFIX/.ok
BASH

cleanup_src = <<-BASH
  MONGO_PREFIX=#{prefix.inspect}

  rm -rf /tmp/mongodb-build
  [[ -e "$MONGO_PREFIX/.ok" ]] || rm -rf "$MONGO_PREFIX"

  exit 0
BASH

script "mongodb-#{version}" do
  not_if      { File.file?(File.join(prefix, ".ok")) }
  interpreter "bash"
  code        installer_src

  notifies :run, "script[mongodb-#{version}-cleanup]"
end

script "mongodb-#{version}-cleanup" do
  action :nothing
  interpreter "bash"
  code        cleanup_src
end

%w( bsondump  mongoexport  mongoimport  mongostat
    mongo     mongodump    mongofiles   mongorestore  mongosniff  mongotop ).each do |cmd|
  link File.join(node.alice.prefix, 'bin', cmd) do
    to File.join(prefix, 'bin', cmd)
  end
end

pluto_service "srv:mongodb" do
  command "bin/mongod --journal --nounixsocket --dbpath=$DB_PATH --port=$PORT $AUTH"
  cwd     prefix

  environment['DB_PATH'] = datdir
  environment['AUTH']    = (node.alice.mongodb.auth ? '--auth' : '')

  ports.push({ 'name' => 'PORT', 'type' => 'mongodb', 'port' => node.alice.mongodb.port.to_i })
  action  [:enable, :start]
end

if node.alice.mongodb.auth
  unless node.alice.mongodb.root_password
    extend Opscode::OpenSSL::Password
    password = secure_password
    node['alice']['mongodb']['root_password'] = password
  end

  mongodb_user node.alice.mongodb.root_user do
    connection({ :port => node.alice.mongodb.port })
    password node.alice.mongodb.root_password
    database 'admin'

    action :create
  end
end
