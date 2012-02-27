
# load ports
ports_file        = File.join(node.alice.prefix, 'var/pluto/legacy_ports.yml')
available_ports   = (5100..6000).to_a
process_ports     = File.file?(ports_file) ? YAML.load_file(ports_file) : {}
process_ports     = {} unless Hash === process_ports
new_process_ports = {}

directory File.dirname(ports_file) do
  mode "0744"
  recursive true
  action :create
end

processes = []
search('alice-processes', "node:#{node.name.inspect} AND legacy:\"true\"") do |process|
  processes << process
end

processes = processes.sort_by do |process|
  process['task']
end

processes.each do |process|
  process['ports'].each do |port|
    unless port['port']
      port_name = [process['task'], port['name']].join('#')
      port['port'] = process_ports[port_name]
      port['port'] = port['port'].to_i if port['port']
    end
  end
end

processes.each do |process|
  process['ports'].each do |port|
    if port['port']
      port_name = [process['task'], port['name']].join('#')
      available_ports.delete(port['port'].to_i)
      new_process_ports[port_name] = port['port'].to_i
    end
  end
end

processes.each do |process|
  process['ports'].each do |port|
    unless port['port']
      port_name = [process['task'], port['name']].join('#')
      port['port'] = available_ports.shift
      new_process_ports[port_name] = port['port'].to_i
    end
  end
end

processes.each do |process|

  pluto_service "app:#{process['task']}" do
    command process['command']
    cwd File.join('/var/u/apps', process['env']['ALICE_APPLICATION'])

    rails_env = process['env']['RAILS_ENV'] || process['env']['RACK_ENV']
    if rails_env.nil? and /[-](staging|production)$/ === process['env']['ALICE_APPLICATION']
      rails_env = $1
    end

    process['env'].each do |name, value|
      if name == 'RAILS_ENV'
        value = rails_env
      end

      if name == 'RACK_ENV'
        value = rails_env
      end

      if name == 'RUBY_VERSION'
        value = node.alice.ruby.default_versions[value] || value
      end

      environment[name] = value.to_s
    end

    process['ports'].each do |port|
      ports.push port
    end

    action [:enable, :start]
  end

end

ruby_block "pluto-save-legacy_ports" do
  block do
    File.open(ports_file, 'w+', 0644) do |f|
      f.write YAML.dump(new_process_ports)
    end
  end
  action :create
end

ruby_block "pluto-register-legacy_processes" do
  block do
    endpoint = URI.parse(node.alice.controller.endpoint)

    body = processes.map do |process|
      port_number = nil

      process['ports'].each do |port|
        next unless port['type'] == 'http'
        port_number = port['port']
      end

      next unless port_number

      {
        :type =>        'backend',
        :machine =>     node.name,
        :application => process['env']['ALICE_APPLICATION'],
        :process =>     process['env']['ALICE_PROCESS'],
        :instance =>    process['env']['ALICE_INSTANCE'].to_i,
        :port =>        port_number.to_i
      }
    end

    Net::HTTP.start(endpoint.host, endpoint.port) do |http|
      request = Net::HTTP::Post.new("/api_v1/register.json")
      request.body = JSON.dump(body.compact)
      request.content_type = "application/json"
      request['Accepts'] = "application/json"
      http.request(request)
    end
  end
  action :create
end
