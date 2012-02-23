
actions :run

attribute :pattern, :name_attribute => true

def initialize(*args)
  super
  @action = :run
end
