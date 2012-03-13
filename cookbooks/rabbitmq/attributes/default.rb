alice_root = "/var/alice"

default["alice"]["rabbitmq"]["enabled"] = false
default["alice"]["rabbitmq"]["prefix"]  = File.join(alice_root, "env/rabbitmq")
default["alice"]["rabbitmq"]["version"] = "2.7.1"

default["alice"]["rabbitmq"]["http_port"]     = 55672
default["alice"]["rabbitmq"]["amqp_port"]     = 5672

default["alice"]["rabbitmq"]["root_user"]          = 'root'
default["alice"]["rabbitmq"]["root_password"]      = nil
