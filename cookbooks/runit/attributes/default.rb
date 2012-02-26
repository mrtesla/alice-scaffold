alice_root = "/var/alice"

default["alice"]["runit"]["prefix"]  = File.join(alice_root, "env/runit")
default["alice"]["runit"]["version"] = "2.1.1"
