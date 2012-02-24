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

  pluto_service "sys:alice:prober" do
    command     "node prober.js $PORT"
    cwd         node.alice.prober.prefix
    environment['NODE_VERSION'] = '0.6.10'
    action [:enable, :start]
  end
end
