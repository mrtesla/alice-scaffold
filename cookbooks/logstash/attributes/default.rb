alice_root = "/var/alice"

default["alice"]["logstash"]["enabled"] = false
default["alice"]["logstash"]["prefix"]  = File.join(alice_root, "env/logstash")
default["alice"]["logstash"]["version"] = "1.1.0"

default["alice"]["logstash"]["gelf"]["host"] = "localhost"
default["alice"]["logstash"]["gelf"]["port"] = 12201
