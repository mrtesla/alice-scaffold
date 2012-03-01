#
# Cookbook Name:: pluto
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

NODE_VERSION  = "0.6.11"
RUNIT_VERSION = "2.1.1"

directory File.join(node.alice.prefix, 'bin') do
  mode  "0755"
  action :create
end

directory File.dirname(node.alice.pluto.prefix) do
  mode  "0755"
  action :create
end

git 'pluto' do
  destination node.alice.pluto.prefix
  repository  "git://github.com/mrtesla/pluto.git"
  reference   "develop"
  action      :sync
end

script "update-pluto" do
  only_if { !File.file?(File.join(node.alice.pluto.prefix, '.ok')) or [resources(
    'git[pluto]'
  )].flatten.any?(&:updated_by_last_action?) }

  interpreter "bash"
  code <<-SH
    export PATH="#{node.alice.prefix}/env/node/#{NODE_VERSION}/bin:$PATH"
    cd "#{node.alice.pluto.prefix}"
    npm install 1>&2
    touch .ok
  SH
end

file "bin/pluto" do
  path File.join(node.alice.prefix, 'bin/pluto')
  mode '0755'
  content <<-BASH
#!/usr/bin/env bash
export NODE_VERSION=#{NODE_VERSION}
export PATH="#{node.alice.prefix}/env/node/$NODE_VERSION/bin:$PATH"
export PATH="#{node.alice.prefix}/env/runit/#{RUNIT_VERSION}/bin:$PATH"
export PLUTO_ROOT="#{node.alice.prefix}"
export PLUTO_SRV_ENABLED="$PLUTO_ROOT/var/runit/enabled-services"
export PLUTO_SRV_AVAILABLE="$PLUTO_ROOT/var/runit/available-services"

exec "#{node.alice.pluto.prefix}/bin/pluto" "$@"
BASH
end

file "bin/pluto-init" do
  path File.join(node.alice.prefix, 'bin/pluto-init')
  mode '0755'
  content <<-BASH
#!/usr/bin/env bash
export PATH="#{node.alice.prefix}/env/runit/#{RUNIT_VERSION}/bin:$PATH"
export PLUTO_ROOT="#{node.alice.prefix}"
export PLUTO_SRV_ENABLED="$PLUTO_ROOT/var/runit/enabled-services"

exec runsvdir -P "$PLUTO_SRV_ENABLED" 'log: ...........................................................................................................................................................................................................................................................................................................................................................................................................'
BASH
end

if platform?('mac_os_x')
  launchd_plist = File.expand_path('~/Library/LaunchAgents/cc.mrtesla.pluto-init.plist')

  script "pluto-unload-launchd" do
    only_if { resources(
      "script[runit-#{node.alice.runit.version}]",
      'git[pluto]', 'file[bin/pluto-init]', 'file[bin/pluto]'
    ).any?(&:updated_by_last_action?) }

    ignore_failure true

    interpreter 'bash'
    code <<-BASH
      launchctl unload -w #{launchd_plist}
    BASH
  end

  template "launchd-pluto-init" do
    only_if { resources(
      "script[runit-#{node.alice.runit.version}]",
      'git[pluto]', 'file[bin/pluto-init]', 'file[bin/pluto]'
    ).any?(&:updated_by_last_action?) }

    path   launchd_plist
    source "pluto_init.plist.erb"
    variables(:alice_root => node.alice.prefix)
  end

  script "pluto-load-launchd" do
    only_if { resources(
      "script[runit-#{node.alice.runit.version}]",
      'git[pluto]', 'file[bin/pluto-init]', 'file[bin/pluto]'
    ).any?(&:updated_by_last_action?) }

    interpreter 'bash'
    code <<-BASH
      launchctl load -w #{launchd_plist}
    BASH
  end
else
  if File.directory?('/etc/init')
    template "/etc/init/pluto-init.conf" do
      mode "0644"
      source "upstart.conf.erb"
      variables :command => File.join(node.alice.prefix, 'bin/pluto-init')
    end

    execute "initctl status pluto-init" do
      retries 30
    end

    # If we are stop/waiting, start
    #
    # Why, upstart, aren't you idempotent? :(
    execute "service pluto-init start" do
      only_if "initctl status pluto-init | grep stop"
    end

  else
    svdir_line = 'PL:123456:respawn:'+File.join(node.alice.prefix, 'bin/pluto-init')

    execute "echo '#{svdir_line}' >> /etc/inittab" do
      not_if "grep '#{svdir_line}' /etc/inittab"
      notifies :run, "execute[init q]", :immediately
    end

    execute "init q" do
      action :nothing
    end
  end
end

template File.join(node.alice.prefix, 'bin', 'staticd') do
  mode   "0755"
  source "staticd.sh.erb"
  variables :node_bin => File.join(node.alice.prefix, 'env/node', NODE_VERSION, 'bin/node'),
            :pluto    => node.alice.pluto.prefix
end
