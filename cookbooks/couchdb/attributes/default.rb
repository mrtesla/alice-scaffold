alice_root = "/var/alice"

default["alice"]["couchdb"]["enabled"] = false
default["alice"]["couchdb"]["prefix"]  = File.join(alice_root, "env/couchdb")
default["alice"]["couchdb"]["version"] = "1.1.1"

default["alice"]["couchdb"]["http_port"]     = 5984
default["alice"]["couchdb"]["ssl_port"]      = 6984
default["alice"]["couchdb"]["bind_address"]  = '0.0.0.0'

default["alice"]["couchdb"]["auth"]               = false
default["alice"]["couchdb"]["root_user"]          = 'root'
default["alice"]["couchdb"]["root_password"]      = nil
default["alice"]["couchdb"]["root_password_salt"] = nil
