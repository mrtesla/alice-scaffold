alice_root = "/var/alice"

default["alice"]["redis"]["prefix"]  = File.join(alice_root, "env/redis")
default["alice"]["redis"]["version"] = "2.4.7"
default["alice"]["redis"]["port"]    = 6379

default["alice"]["redis"]["remote_host"] = 'localhost'
default["alice"]["redis"]["remote_port"] = 6379
