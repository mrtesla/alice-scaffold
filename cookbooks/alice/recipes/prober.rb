#
# Cookbook Name:: alice-prober
# Recipe:: default
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

NODE_VERSION = "0.6.11"

directory node.alice.prober.prefix do
  mode  "0755"
  recursive true
  action (node.alice.prober.enabled ? :create : :delete)
end

if node.alice.prober.enabled
  git "alice-prober" do
    destination node.alice.prober.prefix
    repository  "git://github.com/mrtesla/alice-prober.git"
    reference   "master"
    action      :sync
  end

  script "update-sys:alice:prober" do
    only_if { !File.file?(File.join(node.alice.prober.prefix, '.ok')) or [resources(
      'git[alice-prober]'
    )].flatten.any?(&:updated_by_last_action?) }

    interpreter "bash"
    code <<-SH
      export PATH="#{node.alice.prefix}/env/node/#{NODE_VERSION}/bin:$PATH"
      cd "#{node.alice.prober.prefix}"
      npm install 1>&2 || exit 1
      touch .ok
    SH

    notifies :restart, "pluto_service[sys:alice:prober]"
  end

  controller_endpoint = URI.parse(node.alice.controller.endpoint)
  airbrake_key        = data_bag_item('service-keys', 'airbreak')

  pluto_service "sys:alice:prober" do
    command     "node prober.js $PORT"
    cwd         node.alice.prober.prefix

    environment['NODE_VERSION'] = '0.6.10'
    environment['PROBER_HOST']  = node.name
    environment['ALICE_HOST']   = controller_endpoint.host
    environment['ALICE_PORT']   = (controller_endpoint.port || 4080).to_s

    if airbrake_key and airbrake_key['key']
      environment['AIRBRAKE_KEY'] = airbrake_key['key']
    end

    action [:enable, :start]
  end
end
