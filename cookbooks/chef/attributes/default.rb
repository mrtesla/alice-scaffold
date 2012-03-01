alice_root = "/var/alice"

default["alice"]["chef"]["enabled"] = false
default["alice"]["chef"]["prefix"]  = File.join(alice_root, "env/chef")
