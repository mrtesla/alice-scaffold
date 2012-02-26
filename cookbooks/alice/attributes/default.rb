
alice_root = "/var/alice"

default["alice"]["prefix"] = alice_root

default["alice"]["prober"]["enabled"]  = false
default["alice"]["prober"]["prefix"]   = File.join(alice_root, "env/alice/prober")

default["alice"]["routers"]["enabled"] = false
default["alice"]["routers"]["prefix"]  = File.join(alice_root, "env/alice/routers")

default["alice"]["passers"]["enabled"] = false
default["alice"]["passers"]["prefix"]  = File.join(alice_root, "env/alice/passers")

default["alice"]["controller"]["enabled"] = false
default["alice"]["controller"]["prefix"]  = File.join(alice_root, "env/alice/controller")
