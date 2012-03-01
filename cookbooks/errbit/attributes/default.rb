alice_root = "/var/alice"

default["alice"]["errbit"]["enabled"]   = false
default["alice"]["errbit"]["prefix"]    = File.join(alice_root, "env/errbit")

default["alice"]["errbit"]["email"]["from"]          = 'errbit@example.com'
default["alice"]["errbit"]["email"]["smtp_host"]     = 'localhost'
default["alice"]["errbit"]["email"]["smtp_port"]     = 25
default["alice"]["errbit"]["email"]["smtp_auth"]     = 'login'
default["alice"]["errbit"]["email"]["smtp_username"] = nil
default["alice"]["errbit"]["email"]["smtp_password"] = nil
default["alice"]["errbit"]["email"]["smtp_domain"]   = 'example.com'

default["alice"]["errbit"]["host"]      = 'localhost'
default["alice"]["errbit"]["http_port"] = 5051

default["alice"]["errbit"]["mongodb"]["database"] = "errbit"
default["alice"]["errbit"]["mongodb"]["username"] = "errbit"
default["alice"]["errbit"]["mongodb"]["password"] = nil
