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

    node.alice.routers.ports.size.times do |i|
      i += 1
      notifies :restart, "pluto_service[sys:alice:router:#{i}]"
    end
  end

  controller_endpoint = URI.parse(node.alice.controller.endpoint)

  node.alice.routers.ports.each_with_index do |port, i|
    i += 1
    pluto_service "sys:alice:router:#{i}" do
      command     "node router.js $PORT"
      cwd         node.alice.routers.prefix

      environment['NODE_VERSION'] = '0.6.10'
      environment['ROUTER_HOST']  = node.name
      environment['ALICE_HOST']   = controller_endpoint.host
      environment['ALICE_PORT']   = (controller_endpoint.port || 4080).to_s

      if node.alice.airbrake.key
        environment['AIRBRAKE_KEY'] = node.alice.airbrake.key
      end

      ports.push({ 'name' => 'PORT', 'type' => 'http', 'port' => port })
      action [:enable, :start]
    end
  end
end
