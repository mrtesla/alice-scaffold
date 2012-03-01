alice_root = "/var/alice"

default["alice"]["mongodb"]["enabled"] = false
default["alice"]["mongodb"]["prefix"]  = File.join(alice_root, "env/mongodb")
default["alice"]["mongodb"]["version"] = "2.0.2"
default["alice"]["mongodb"]["port"]    = 27017
default["alice"]["mongodb"]["auth"]    = true
default["alice"]["mongodb"]["root_user"]     = 'root'
default["alice"]["mongodb"]["root_password"] = nil
