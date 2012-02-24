#
# Cookbook Name:: alice-routers
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

NODE_VERSION = "0.6.11"

directory node.alice.routers.prefix do
  mode  "0755"
  recursive true
  action (node.alice.routers.enabled ? :create : :delete)
end

if node.alice.routers.enabled
  git "alice-routers" do
    destination node.alice.routers.prefix
    repository  "git://github.com/mrtesla/alice-router.git"
    reference   "master"
    action      :sync
  end

  script "update-sys:alice:router" do
    only_if { !File.file?(File.join(node.alice.routers.prefix, '.ok')) or [resources(
      'git[alice-routers]'
    )].flatten.any?(&:updated_by_last_action?) }

    interpreter "bash"
    code <<-SH
      export PATH="#{node.alice.prefix}/env/node/#{NODE_VERSION}/bin:$PATH"
      cd "#{node.alice.routers.prefix}"
      npm install 1>&2 || exit 1
      touch .ok
    SH

    4.times do |i|
      i += 1
      notifies :restart, "pluto_service[sys:alice:router:#{i}]"
    end
  end

  4.times do |i|
    i += 1
    pluto_service "sys:alice:router:#{i}" do
      command     "node router.js $PORT"
      cwd         node.alice.routers.prefix
      environment['NODE_VERSION'] = '0.6.10'
      ports.push({ 'name' => 'PORT', 'type' => 'http', 'port' => (4000 + i) })
      action [:enable, :start]
    end
  end
end
