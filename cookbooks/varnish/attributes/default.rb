alice_root = "/var/alice"

default["alice"]["varnish"]["prefix"]  = File.join(alice_root, "env/varnish")
default["alice"]["varnish"]["version"] = "3.0.2"
