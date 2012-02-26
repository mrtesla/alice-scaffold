alice_root = "/var/alice"

default["alice"]["pluto"]["prefix"] = File.join(alice_root, "env/alice/pluto")

default["alice"]["pluto"]["logger"]             = {}
default["alice"]["pluto"]["user"]["separation"] = true
default["alice"]["pluto"]["user"]["default"]    = "pluto"
