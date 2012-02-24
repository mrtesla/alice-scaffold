#
# Cookbook Name:: redis
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

version    = node.alice.runit.version
prefix     = File.join(node.alice.prefix, "env/runit/#{version}")
srvdir     = File.join(node.alice.prefix, "var/runit/enabled-services")
avadir     = File.join(node.alice.prefix, "var/runit/available-services")

directory prefix do
  mode  "0755"
  action :create
  recursive true
end

directory srvdir do
  mode  "0755"
  action :create
  recursive true
end

directory avadir do
  mode  "0755"
  action :create
  recursive true
end

patches = []

if platform?('mac_os_x')
  patches.push <<-BASH
    echo 'cc -Xlinker -x' >src/conf-ld
    cp src/Makefile src/Makefile.old
    sed -e 's/ -static//' <src/Makefile.old >src/Makefile
  BASH
end

installer_src = <<-BASH
  RUNIT_PREFIX=#{prefix.inspect}

  rm -rf   "$RUNIT_PREFIX"
  rm -rf   /tmp/runit-build
  mkdir -p /tmp/runit-build
  mkdir -p "$RUNIT_PREFIX/bin"
  cd       /tmp/runit-build

  echo "Downloading runit-#{version}"
  wget http://smarden.org/runit/runit-#{version}.tar.gz 1>&2 || exit 1

  echo "Extracting runit-#{version}"
  tar xzf runit-#{version}.tar.gz || exit 2
  cd admin/runit-#{version}

  echo "Patching runit-#{version}"
  #{patches.join("\n\n")}

  echo "Building runit-#{version}"
  package/compile 1>&2 || exit 3

  for i in `cat package/commands`; do
    cp command/$i "$RUNIT_PREFIX/bin/$i"
  done

  touch $RUNIT_PREFIX/.ok
BASH

cleanup_src = <<-BASH
  RUNIT_PREFIX=#{prefix.inspect}

  rm -rf /tmp/runit-build
  [[ -e "$RUNIT_PREFIX/.ok" ]] || rm -rf "$RUNIT_PREFIX"

  exit 0
BASH

script "runit-#{version}" do
  not_if      { File.file?(File.join(prefix, ".ok")) }
  interpreter "bash"
  code        installer_src

  notifies :run, "script[runit-#{version}-cleanup]"
end

script "runit-#{version}-cleanup" do
  action :nothing
  interpreter "bash"
  code        cleanup_src
end


