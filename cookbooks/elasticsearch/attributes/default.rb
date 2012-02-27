alice_root = "/var/alice"

default["alice"]["elasticsearch"]["enabled"] = false
default["alice"]["elasticsearch"]["prefix"]  = File.join(alice_root, "env/elasticsearch")
default["alice"]["elasticsearch"]["version"] = "0.18.7"
