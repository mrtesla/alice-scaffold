alice_root = "/var/alice"

default["alice"]["graylog2"]["enabled"]   = false
default["alice"]["graylog2"]["prefix"]    = File.join(alice_root, "env/graylog2")
default["alice"]["graylog2"]["version"]   = "0.9.6"

default["alice"]["graylog2"]["email"]["from"]          = 'graylog@example.com'
default["alice"]["graylog2"]["email"]["smtp_host"]     = 'localhost'
default["alice"]["graylog2"]["email"]["smtp_port"]     = 25
default["alice"]["graylog2"]["email"]["smtp_auth"]     = 'login'
default["alice"]["graylog2"]["email"]["smtp_username"] = nil
default["alice"]["graylog2"]["email"]["smtp_password"] = nil
default["alice"]["graylog2"]["email"]["smtp_domain"]   = 'example.com'

default["alice"]["graylog2"]["host"]      = 'localhost'
default["alice"]["graylog2"]["http_port"] = 5050

default["alice"]["graylog2"]["mongodb"]["database"] = "graylog2"
default["alice"]["graylog2"]["mongodb"]["username"] = "graylog2"
default["alice"]["graylog2"]["mongodb"]["password"] = nil

default["alice"]["graylog2"]["elasticsearch"]["index"] = "graylog2"
