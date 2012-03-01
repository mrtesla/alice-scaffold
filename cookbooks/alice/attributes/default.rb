
alice_root = "/var/alice"

default["alice"]["prefix"] = alice_root
default["alice"]["airbrake"]["key"] = false
default["alice"]["controller"]["endpoint"] = "http://localhost:4080"

default["alice"]["prober"]["enabled"]  = false
default["alice"]["prober"]["prefix"]   = File.join(alice_root, "env/alice/prober")

default["alice"]["routers"]["enabled"] = false
default["alice"]["routers"]["ports"]   = [4001, 4002, 4003, 4004]
default["alice"]["routers"]["prefix"]  = File.join(alice_root, "env/alice/routers")

default["alice"]["passers"]["enabled"] = false
default["alice"]["passers"]["ports"]   = [5001, 5002, 5003, 5004]
default["alice"]["passers"]["prefix"]  = File.join(alice_root, "env/alice/passers")

default["alice"]["controller"]["enabled"] = false
default["alice"]["controller"]["prefix"]  = File.join(alice_root, "env/alice/controller")

default["alice"]["mysql"]["enabled"] = false
