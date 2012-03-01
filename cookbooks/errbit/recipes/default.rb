#
# Cookbook Name:: alice
# Recipe:: errbit
#
# Copyright 2012, Mr. Henry
#
# All rights reserved - Do Not Redistribute
#

RUBY_VERSION = '1.9.3-p125'

unless node.alice.errbit.mongodb.password
  extend Opscode::OpenSSL::Password
  node['alice']['errbit']['mongodb']['password'] = secure_password
end

mongodb_user node.alice.errbit.mongodb.username do
  connection({ :port     => node.alice.mongodb.port,
               :username => node.alice.mongodb.root_user,
               :password => node.alice.mongodb.root_password })

  password node.alice.errbit.mongodb.password
  database node.alice.errbit.mongodb.database

  action :create
end

prefix = node.alice.errbit.prefix

directory File.dirname(node.alice.errbit.prefix) do
  mode  "0755"
  action :create
end

git 'alice-errbit' do
  destination node.alice.errbit.prefix
  repository  "git://github.com/errbit/errbit.git"
  reference   "master"
  action      :sync
end

template "errbit-/config/config.yml" do
  path   File.join(prefix, 'config/config.yml')
  source "config.yml.erb"
  mode   "0640"
  group  "pluto"

  notifies :restart, 'pluto_service[srv:errbit:web]'
end

template "errbit-/config/mongoid.yml" do
  path   File.join(prefix, 'config/mongoid.yml')
  source "mongoid.yml.erb"
  mode   "0640"
  group  "pluto"

  notifies :restart, 'pluto_service[srv:errbit:web]'
end

script "update-sys:alice:errbit" do
  only_if { !File.file?(File.join(node.alice.errbit.prefix, '.ok')) or [resources(
    'git[alice-errbit]'
  )].flatten.any?(&:updated_by_last_action?) }

  interpreter "bash"
  code <<-SH
    export PATH="#{node.alice.errbit.prefix}/bin:#{node.alice.prefix}/env/ruby/#{RUBY_VERSION}/bin:$PATH"
    export RAILS_ENV=production
    cd "#{node.alice.errbit.prefix}"

    echo 'gem "thin"' >> Gemfile
    echo 'Errbit::Application.configure do'   >> config/environments/production.rb
    echo 'config.serve_static_assets = true'  >> config/environments/production.rb
    echo 'end'                                >> config/environments/production.rb
    bundle install --path vendor/bundle --binstubs --without development test 1>&2 || exit 1

    if [[ ! -e .bootstrapped ]]
    then
      rake db:seed 1>&2 || exit 2
      rake db:mongoid:create_indexes 1>&2 || exit 2
      touch .bootstrapped
    else
      rake db:migrate 1>&2
    fi

    mkdir -p tmp
    mkdir -p log
    chown -R pluto:pluto tmp
    chown -R pluto:pluto log
    chmod 0644 log/*.log

    touch .ok
  SH

  notifies :restart, 'pluto_service[srv:errbit:web]'
end

pluto_service "srv:errbit:web" do
  command     "bin/rails server thin -p $PORT"
  cwd         node.alice.errbit.prefix

  environment['RUBY_VERSION']   = RUBY_VERSION
  environment['RAILS_ENV']      = 'production'

  ports.push('name' => 'PORT', 'type' => 'http', 'port' => node.alice.errbit.http_port)

  action [:enable, :start]
end

