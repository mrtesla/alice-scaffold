
actions :start, :stop

attribute :name,        :kind_of => String, :required => true, :name_attribute => true
attribute :environment, :kind_of => Hash,   :required => true
attribute :cwd,         :kind_of => String, :required => true
attribute :user,        :kind_of => String, :required => true, :default => 'pluto'
attribute :command,     :kind_of => String, :required => true

def initialize(*args)
  super
  @environment = {}
  @action = :start
end

def environment
  @environment
end
