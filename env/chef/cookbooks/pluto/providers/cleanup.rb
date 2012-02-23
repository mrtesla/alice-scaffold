require 'chef/mixin/command'
require 'chef/mixin/language'
include Chef::Mixin::Command

action :run do
  defined_services = []
  @run_context.resource_collection.each do |resource|
    next unless resource.resource_name.to_s == 'pluto_service'
    defined_services << resource.service_name.to_s
  end

  @services.each do |service|
    next if defined_services.include? service
    run_pluto(['stop', service])
    run_pluto(['destroy', 'service', service])
  end
end

def load_current_resource
  services = %x[ #{node.alice.prefix}/bin/pluto list '#{new_resource.pattern}' ]
  services = services.split("\n").select {|i| String === i and i.size > 0 }
  @services = services
end

def run_pluto(args)
  command = "#{node.alice.prefix}/bin/pluto"

  if Array === args
    command = [command] + args
  else
    command = "#{command} #{args}"
  end

  run_command_with_systems_locale(
    :command => command,
    :cwd     => node.alice.prefix
  )
end
