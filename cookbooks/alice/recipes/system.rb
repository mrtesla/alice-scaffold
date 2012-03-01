#
# Cookbook Name:: alice-sys-deps
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

PACKAGES = []

if platform?('mac_os_x')
  include_recipe 'homebrew'

  PACKAGES.concat %w(
    git
    subversion
    curl
    wget
    pcre
    pkg-config

    imagemagick
    ghostscript
  )

  script "update-brew-index" do
    interpreter "bash"
    code        "brew update 1>&2"

    retries        3
    ignore_failure true
  end
end

if platform?("ubuntu", "debian")
  PACKAGES.concat %w(
    build-essential
    autoconf
    automake
    cmake
    libtool
    scons
    bison
    libreadline6
    libreadline6-dev
    libc6-dev
    vim

    openssl
    curl
    wget
    zlib1g
    zlib1g-dev
    libssl-dev
    libcurl4-gnutls-dev
    libyaml-dev
    openjdk-6-jre-headless

    erlang
    libicu-dev
    libmozjs-dev

    pkg-config
    libpcre3
    libpcre3-dev

    libxml2-dev
    libxslt-dev
    ncurses-dev
    libboost-dev
    libboost-program-options-dev
    libboost-thread-dev
    libboost-filesystem-dev

    git
    subversion

    mysql-client
    libmysqlclient-dev

    sqlite3
    libsqlite-dev
    libsqlite3-0
    libsqlite3-dev

    imagemagick
    ghostscript
    ffmpeg
  )

  script "update-apt-index" do
    interpreter "bash"
    code        "apt-get update"
  end
end

PACKAGES.each do |name|
  package name do
    action [:install]
  end
end
