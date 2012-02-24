if platform?('mac_os_x')
  default["alice"]["prefix"] = File.expand_path('~/.alice')
else
  default["alice"]["prefix"] = "/var/alice"
end

default["alice"]["prober"]["enabled"]  = true
default["alice"]["prober"]["prefix"]   = File.join(default["alice"]["prefix"], "env/alice/prober")

default["alice"]["routers"]["enabled"] = false
default["alice"]["routers"]["prefix"]  = File.join(default["alice"]["prefix"], "env/alice/routers")

default["alice"]["passers"]["enabled"] = true
default["alice"]["passers"]["prefix"]  = File.join(default["alice"]["prefix"], "env/alice/passers")

default["alice"]["controller"]["enabled"] = false
default["alice"]["controller"]["prefix"]  = File.join(default["alice"]["prefix"], "env/alice/controller")
