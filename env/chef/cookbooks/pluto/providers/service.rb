
action :start do
  #execute "start service: #{new_resource.name}" do
    #not_if  "mysql -e 'show databases;' | grep #{new_resource.name}"
    #command "mysqladmin create #{new_resource.name}"
  #end
end

action :stop do
  #execute "stop service: #{new_resource.name}" do

  #end
end

