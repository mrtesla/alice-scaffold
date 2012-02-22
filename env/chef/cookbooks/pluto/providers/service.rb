require 'chef/mixin/command'
require 'chef/mixin/language'
include Chef::Mixin::Command



action :enable do
  srv = @srv
  env = new_resource.environment.dup

  definition = {
    'alice_root'      => node.alice.prefix,
    'user_separation' => node.alice.pluto.user.separation,
    'logger'          => (node.alice.pluto.logger || {}),

    'task'    => new_resource.service_name,
    'user'    => (new_resource.user || node.alice.pluto.user.default || 'pluto'),
    'root'    => new_resource.cwd,
    'command' => new_resource.command,

    'env' => env.map do |(key, value)|
      { 'name' => key.to_s, 'value' => value.to_s }
    end,

    'ports' => []
  }

  srv_dir = ::File.join(node.alice.prefix, 'var/runit/available-services', new_resource.service_name.to_s.gsub(':', '.'))

  Chef::Resource::Directory.new("#{new_resource.service_name}-/", @run_context).tap do |r|
    r.path srv_dir
    r.mode "0755"
    r.run_action(:create)
  end

  Chef::Resource::Directory.new("#{new_resource.service_name}-/supervise", @run_context).tap do |r|
    r.path ::File.join(srv_dir, 'supervise')
    r.mode "0755"
    r.run_action(:create)
  end

  Chef::Resource::Directory.new("#{new_resource.service_name}-/log", @run_context).tap do |r|
    r.path ::File.join(srv_dir, 'log')
    r.mode "0755"
    r.run_action(:create)
  end

  Chef::Resource::Directory.new("#{new_resource.service_name}-/log/main", @run_context).tap do |r|
    r.path ::File.join(srv_dir, 'log', 'main')
    r.mode "0755"
    r.run_action(:create)
  end

  Chef::Resource::File.new("#{new_resource.service_name}-/supervise/lock", @run_context).tap do |r|
    r.path ::File.join(srv_dir, 'supervise', 'lock')
    r.mode "0644"
    r.run_action(:create_if_missing)
  end

  Chef::Resource::Template.new("#{new_resource.service_name}-/run", @run_context).tap do |r|
    r.path ::File.join(srv_dir, 'run')
    r.mode "0755"
    r.cookbook 'pluto'
    r.source "process_run.sh.erb"
    r.variables(definition)

    r.run_action(:create)
    if r.updated_by_last_action? and @srv.running
      new_resource.notifies :restart, new_resource
      new_resource.updated_by_last_action(true)
    end
  end

  Chef::Resource::Template.new("#{new_resource.service_name}-/finish", @run_context).tap do |r|
    r.path ::File.join(srv_dir, 'finish')
    r.mode "0755"
    r.cookbook 'pluto'
    r.source "process_finish.sh.erb"
    r.variables(definition)

    r.run_action(:create)
    if r.updated_by_last_action? and @srv.running
      new_resource.notifies :restart, new_resource
      new_resource.updated_by_last_action(true)
    end
  end

  Chef::Resource::Template.new("#{new_resource.service_name}-/log/run", @run_context).tap do |r|
    r.path ::File.join(srv_dir, 'log', 'run')
    r.mode "0755"
    r.cookbook 'pluto'
    r.source "logger_run.sh.erb"
    r.variables(definition)

    r.run_action(:create)
    if r.updated_by_last_action? and @srv.running
      new_resource.notifies :restart, new_resource
      new_resource.updated_by_last_action(true)
    end
  end

  Chef::Resource::Template.new("#{new_resource.service_name}-/log/main/config", @run_context).tap do |r|
    r.path ::File.join(srv_dir, 'log', 'main', 'config')
    r.mode "0644"
    r.cookbook 'pluto'
    r.source "logger_config.erb"
    r.variables(definition)

    r.run_action(:create)
    if r.updated_by_last_action? and @srv.running
      new_resource.notifies :restart, new_resource
      new_resource.updated_by_last_action(true)
    end
  end
end

action :disable do
  if @srv.enabled
    run_pluto(['destroy', 'service', new_resource.service_name])
  end
end

action :start do
  unless @srv.running
    run_pluto(['start', new_resource.service_name])
  end
end

action :stop do
  if @srv.running
    run_pluto(['stop', new_resource.service_name])
  end
end

action :restart do
  if @srv.running
    run_pluto(['restart', new_resource.service_name])
  end
end



def load_current_resource
  @srv = Chef::Resource::PlutoService.new(new_resource.name)
  @srv.service_name(new_resource.service_name)

  Chef::Log.debug("Checking status of service #{new_resource.service_name}")

  begin
    if run_pluto(['status', new_resource.service_name]) == 0
      @srv.running(true)
    end
  rescue Chef::Exceptions::Exec
    @srv.running(false)
    nil
  end

  if ::File.directory?("#{node.alice.prefix}/services/#{new_resource.service_name.gsub(':', '.')}")
    @srv.enabled(true)
  else
    @srv.enabled(false)
  end
end

def run_pluto(args)
  command = "#{node.alice.prefix}/bin/pluto"

  if Array === args
    command = [command] + args
  else
    command = "#{command} #{args}"
  end

  run_command_with_systems_locale(
    :command     => command,
    :cwd => node.alice.prefix
  )
end
