#
# Cookbook Name:: alice-passers
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

NODE_VERSION = "0.6.11"

directory node.alice.passers.prefix do
  mode  "0755"
  recursive true
  action (node.alice.passers.enabled ? :create : :delete)
end

if node.alice.passers.enabled
  git "alice-passers" do
    destination node.alice.passers.prefix
    repository  "git://github.com/mrtesla/alice-passer.git"
    reference   "master"
    action      :sync
  end

  script "update-sys:alice:passer" do
    only_if { !File.file?(File.join(node.alice.passers.prefix, '.ok')) or [resources(
      'git[alice-passers]'
    )].flatten.any?(&:updated_by_last_action?) }

    interpreter "bash"
    code <<-SH
      export PATH="#{node.alice.prefix}/env/node/#{NODE_VERSION}/bin:$PATH"
      cd "#{node.alice.passers.prefix}"
      npm install 1>&2 || exit 1
      touch .ok
    SH

    node.alice.passers.ports.size.times do |i|
      i += 1
      notifies :restart, "pluto_service[sys:alice:passer:#{i}]"
    end
  end

  controller_endpoint = URI.parse(node.alice.controller.endpoint)

  node.alice.passers.ports.each_with_index do |port, i|
    i += 1
    pluto_service "sys:alice:passer:#{i}" do
      command     "node passer.js $PORT"
      cwd         node.alice.passers.prefix

      environment['NODE_VERSION'] = '0.6.10'
      environment['PASSER_HOST']  = node.name
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
