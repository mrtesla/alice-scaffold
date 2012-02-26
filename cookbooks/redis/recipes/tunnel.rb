
pluto_service "srv:redis-tunnel" do
  command "ssh root@#{node.alice.redis.remote_host} -L $PORT:localhost:#{node.alice.redis.remote_port} -N"
  cwd     "/tmp"
  ports.push({ 'name' => 'PORT', 'type' => 'redis', 'port' => node.alice.redis.port.to_i })
  action  [:enable, :start]
end
