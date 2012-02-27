#
# Cookbook Name:: varnish
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

HIREDIS_VERSION = 'v0.10.1'
LIBVMOD_REDIS_VERSION = 'master'

version    = node.alice.varnish.version
prefix     = File.join(node.alice.prefix, "env/varnish/#{version}")
datdir     = File.join(node.alice.prefix, "var/varnish")

directory prefix do
  mode  "0755"
  action :create
  recursive true
end

directory File.join(datdir, node.hostname) do
  mode  "0755"
  action :create
  recursive true
end

installer_src = <<-BASH
  VARNISH_PREFIX=#{prefix.inspect}

  rm -rf   "$VARNISH_PREFIX"
  rm -rf   /tmp/varnish-build
  mkdir -p /tmp/varnish-build
  mkdir -p /tmp/varnish-build/hiredis-#{HIREDIS_VERSION}
  mkdir -p /tmp/varnish-build/libvmod-redis-#{LIBVMOD_REDIS_VERSION}
  cd       /tmp/varnish-build

  if [ "$(uname -s)" = "Darwin" ]
  then
    export CC="/usr/bin/gcc-4.2"
  fi

  echo "Downloading varnish-#{version}"
  wget http://repo.varnish-cache.org/source/varnish-#{version}.tar.gz 1>&2 || exit 1
  wget https://github.com/antirez/hiredis/tarball/#{HIREDIS_VERSION} -O hiredis-#{HIREDIS_VERSION}.tar.gz 1>&2 || exit 1
  wget https://github.com/zephirworks/libvmod-redis/tarball/#{LIBVMOD_REDIS_VERSION} -O libvmod-redis-#{LIBVMOD_REDIS_VERSION}.tar.gz 1>&2 || exit 1

  echo "Extracting varnish-#{version}"
  tar -xzf varnish-#{version}.tar.gz || exit 2
  tar --strip-components 1 -C hiredis-#{HIREDIS_VERSION} -xzf hiredis-#{HIREDIS_VERSION}.tar.gz || exit 2
  tar --strip-components 1 -C libvmod-redis-#{LIBVMOD_REDIS_VERSION} -xzf libvmod-redis-#{LIBVMOD_REDIS_VERSION}.tar.gz || exit 2

  echo "Building varnish-#{version}"
  cd varnish-#{version}
  ./configure --prefix=$VARNISH_PREFIX --localstatedir=#{node.alice.prefix}/var 1>&2 || exit 3
  make         1>&2 || exit 3
  make install 1>&2 || exit 3
  mkdir -p #{node.alice.prefix}/var
  cd /tmp/varnish-build

  cd hiredis-#{HIREDIS_VERSION}
  make static 1>&2 || exit 3
  cd /tmp/varnish-build

  cd libvmod-redis-#{LIBVMOD_REDIS_VERSION}
  sed -i.bak "s|-version-info 1:0:0|-avoid-version|" src/Makefile.am
  # sed -i.bak "s|-version-info 1:0:0|-avoid-version -R${VARNISH_PREFIX}/lib|" src/Makefile.am
  ./autogen.sh 1>&2 || exit 3
  ./configure \
    VARNISHSRC=/tmp/varnish-build/varnish-#{version} \
    VMODDIR=#{prefix}/lib/varnish/vmods \
    LDFLAGS="-L'/tmp/varnish-build/hiredis-#{HIREDIS_VERSION}' -L'${VARNISH_PREFIX}/lib' ${LDFLAGS}" \
    CPPFLAGS="-I'/tmp/varnish-build/hiredis-#{HIREDIS_VERSION}' -I'${VARNISH_PREFIX}/include' ${CPPFLAGS}" \
    1>&2 || exit 3
  make 1>&2 || exit 3
  make install 1>&2 || exit 3
  cd /tmp/varnish-build

  rm "#{node.alice.prefix}/bin/varnish*"

  touch $VARNISH_PREFIX/.ok
BASH

cleanup_src = <<-BASH
  VARNISH_PREFIX=#{prefix.inspect}

  rm -rf /tmp/varnish-build
  [[ -e "$VARNISH_PREFIX/.ok" ]] || rm -rf "$VARNISH_PREFIX"

  exit 0
BASH

script "varnish-#{version}" do
  not_if      { File.file?(File.join(prefix, ".ok")) }
  interpreter "bash"
  code        installer_src

  notifies :run, "script[varnish-#{version}-cleanup]"
end

script "varnish-#{version}-cleanup" do
  action :nothing
  interpreter "bash"
  code        cleanup_src
end

%w( varnishadm   varnishlog   varnishreplay  varnishstat  varnishtop
    varnishhist  varnishncsa  varnishsizes   varnishtest ).each do |cmd|
  link File.join(node.alice.prefix, 'bin', cmd) do
    to File.join(prefix, 'bin', cmd)
  end
end

template "varnish-config" do
  path   File.join(prefix, 'etc/varnish/default.vcl')
  source "default.vcl.erb"
  variables(:routers => node.alice.routers.ports.map(&:to_s))

  notifies :restart, 'pluto_service[srv:varnish]'
end

file "varnish-secret" do
  path   File.join(prefix, 'etc/varnish/secret')
  action :create_if_missing

  content Digest::SHA1.hexdigest(rand(1<<100).to_s)
end

pluto_service "srv:varnish" do
  command <<-SH.gsub(/\s+/m, ' ')
    sbin/varnishd
      -F
      -i #{node.hostname}
      -n #{datdir}/#{node.hostname}
      -a :$PORT
      -T localhost:$CMD_PORT
      -f #{prefix}/etc/varnish/default.vcl
      -S #{prefix}/etc/varnish/secret
      -s file,#{datdir}/#{node.hostname}/varnish_storage.bin,1500M
  SH
  cwd     prefix
  user    'root'
  ports.push({ 'name' => 'PORT', 'type' => 'http', 'port' => node.alice.varnish.port })
  ports.push({ 'name' => 'CMD_PORT', 'type' => 'varnish.cmd', 'port' => 6082 })

  close_stdin false

  action  [:enable, :start]
end

# Open files (usually 1024, which is way too small for varnish)
#ulimit -n ${NFILES:-131072}

# Maxiumum locked memory size for shared memory log
#ulimit -l ${MEMLOCK:-82000}
