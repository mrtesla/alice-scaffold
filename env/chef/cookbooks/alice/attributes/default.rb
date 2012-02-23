default["alice"]["prefix"]             = ENV['ROOT']

default["alice"]["prober"]["enabled"]  = true
default["alice"]["prober"]["prefix"]   = File.join(ENV['ROOT'], "env/alice/prober")

default["alice"]["routers"]["enabled"] = true
default["alice"]["routers"]["prefix"]  = File.join(ENV['ROOT'], "env/alice/routers")

default["alice"]["passers"]["enabled"] = true
default["alice"]["passers"]["prefix"]  = File.join(ENV['ROOT'], "env/alice/passers")

default["alice"]["controller"]["enabled"] = true
default["alice"]["controller"]["prefix"]  = File.join(ENV['ROOT'], "env/alice/controller")
