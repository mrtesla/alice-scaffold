#
# Cookbook Name:: alice
# Recipe:: controller
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

RUBY_VERSION = '1.9.3-p125'

directory File.dirname(node.alice.controller.prefix) do
  mode  "0755"
  action :create
end

git 'alice-controller' do
  destination node.alice.controller.prefix
  repository  "git://github.com/mrtesla/alice-controller.git"
  reference   "master"
  action      :sync
end


mysql_database 'alice_p' do
  connection({:host => "localhost", :username => 'root', :password => ''})
  action :create

  notifies :restart, 'pluto_service[sys:alice:controller]'
end

mysql_database_user 'alice_u' do
  connection({:host => "localhost", :username => 'root', :password => ''})
  password 'foorbar'
  action :create

  notifies :restart, 'pluto_service[sys:alice:controller]'
end

mysql_database_user 'alice_u-alice_p-priv' do
  connection({:host => "localhost", :username => 'root', :password => ''})
  username      'alice_u'
  database_name 'alice_p'
  password      'foorbar'
  privileges [
    'ALTER',
    'ALTER ROUTINE',
    'CREATE',
    'CREATE ROUTINE',
    'CREATE TEMPORARY TABLES',
    'CREATE VIEW',
    'DELETE',
    'DROP',
    'EXECUTE',
    'INDEX',
    'INSERT',
    'LOCK TABLES',
    'REFERENCES',
    'SELECT',
    'SHOW VIEW',
    'UPDATE'
  ]
  host          '%'

  action        :grant
end

script "update-sys:alice:controller" do
  only_if { !File.file?(File.join(node.alice.controller.prefix, '.ok')) or [resources(
    'git[alice-controller]'
  )].flatten.any?(&:updated_by_last_action?) }

  interpreter "bash"
  code <<-SH
    export PATH="#{node.alice.controller.prefix}/bin:#{node.alice.prefix}/env/ruby/#{RUBY_VERSION}/bin:$PATH"
    export RAILS_ENV=production
    export MYSQL_HOST=localhost
    export MYSQL_DATABASE=alice_p
    export MYSQL_USERNAME=alice_u
    export MYSQL_PASSWORD=foorbar
    cd "#{node.alice.controller.prefix}"
    bundle install --path vendor/bundle --binstubs --deployment --without development test deploy 1>&2 || exit 1
    rake db:migrate 1>&2 || exit 2
    rake assets:precompile 1>&2 || exit 3
    touch .ok
  SH

  notifies :restart, 'pluto_service[sys:alice:controller]'
end


pluto_service "sys:alice:controller" do
  command     "bin/rails server thin -p $PORT"
  cwd         node.alice.controller.prefix

  environment['RUBY_VERSION']   = RUBY_VERSION
  environment['RAILS_ENV']      = 'production'

  environment['MYSQL_HOST']     = 'localhost'
  environment['MYSQL_DATABASE'] = 'alice_p'
  environment['MYSQL_USERNAME'] = 'alice_u'
  environment['MYSQL_PASSWORD'] = 'foorbar'

  ports.push('name' => 'PORT', 'type' => 'http', 'port' => 4080)

  action [:enable, :start]
end
