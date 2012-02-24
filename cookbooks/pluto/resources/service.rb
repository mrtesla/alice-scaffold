
actions :start, :stop, :enable, :disable, :restart

attribute :service_name, :name_attribute => true
attribute :enabled, :default => false
attribute :running, :default => false

attribute :environment, :kind_of => Hash,   :required => true
attribute :ports,       :kind_of => Array,  :required => true
attribute :cwd,         :kind_of => String, :required => true
attribute :user,        :kind_of => String, :default => 'pluto'
attribute :command,     :kind_of => String, :required => true

attribute :supports, :default => { :restart => true, :status => true }

def initialize(*args)
  super
  @environment = {}
  @ports       = []
end

def environment
  @environment
end

def ports
  @ports
end
