action :create do
  unless @user.present

    if new_resource.connection[:username] and new_resource.connection[:password]
      @conn['admin'].authenticate(new_resource.connection[:username], new_resource.connection[:password])
    end

    @db.remove_user(new_resource.username)
    @db.add_user(new_resource.username, new_resource.password)

    new_resource.updated_by_last_action(true)

  end
end

action :delete do
  if @user.present

    if new_resource.connection[:username] and new_resource.connection[:password]
      @conn['admin'].authenticate(new_resource.connection[:username], new_resource.connection[:password])
    end

    @db.remove_user(new_resource.username)

    new_resource.updated_by_last_action(true)

  end
end

def load_current_resource
  @user = Chef::Resource::MongodbUser.new(new_resource.name)
  @user.connection(new_resource.connection)
  @user.username(new_resource.username)
  @user.password(new_resource.password)
  @user.database(new_resource.database)

  Chef::Log.debug("Checking status of mongodb user #{new_resource.username}")

  require 'mongo'

  @conn = Mongo::Connection.from_uri([
    'mongodb://',
    new_resource.connection[:host] || 'localhost',
    ':',
    new_resource.connection[:port] || 27017
  ].join(''))

  attempts = 0
  begin
    attempts += 1
    @conn.connect
  rescue Mongo::ConnectionFailure
    raise if attempts >= 3
    sleep 3
    retry
  end

  @db = @conn[new_resource.database]

  begin
    @db.authenticate(new_resource.username, new_resource.password)
    @db.logout
    @user.present(true)
  rescue Mongo::AuthenticationError
    @user.present(false)
  end
end
