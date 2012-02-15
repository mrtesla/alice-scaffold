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

    imagemagick
    ghostscript
  )

  script "update-brew-index" do
    interpreter "bash"
    code        "brew update 1>&2"
  end
end

if platform?("ubuntu", "debian")
  PACKAGES.concat %w(
    build-essential
    autoconf
    automake
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
    libcurl-dev
    libcurl3-gnutls-dev
    libyaml-dev

    libxml2-dev
    libxslt-dev
    ncurses-dev

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
