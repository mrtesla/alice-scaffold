actions :create, :delete

attribute :connection, :required => true
attribute :username,   :name_attribute => true
attribute :password,   :required => true
attribute :database,   :required => true

attribute :present, :default => false
