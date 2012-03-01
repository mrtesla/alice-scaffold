node.mysql.allow_remote_root = true
node.mysql.bind_address      = '0.0.0.0'

include_recipe "mysql::server"

search('mysql-databases', "node:#{node.name.inspect}") do |db|
  mysql_database db['name'] do
    connection({:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']})

    encoding 'utf-8'

    action (db['removed'] ? :drop : :create)
  end
end

search('mysql-users', "node:#{node.name.inspect}") do |user|

  mysql_database_user user['username'] do
    connection({:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']})

    password user['password']
    host '%'

    action (user['removed'] ? :drop : :create)
  end

  unless user['removed']
    user['databases'].each do |database|
      mysql_database_user "#{user['username']}-#{database}" do
        connection({:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']})
        username      user['username']
        database_name database
        password      user['password']
        privileges [
          'ALTER',
          'ALTER ROUTINE',
          'CREATE',
          'CREATE ROUTINE',
          'CREATE TEMPORARY TABLES',
          'CREATE VIEW',
          'DELETE',
          'DROP',
          'EXECUTE',
          'INDEX',
          'INSERT',
          'LOCK TABLES',
          'REFERENCES',
          'SELECT',
          'SHOW VIEW',
          'UPDATE'
        ]
        host          '%'

        action :grant
      end
    end
  end

end
