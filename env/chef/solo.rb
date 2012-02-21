ROOT = File.expand_path('../../../', __FILE__)

file_cache_path  File.join(ROOT, "var/chef/file-cache")
file_backup_path File.join(ROOT, "var/chef/file-backup")
cookbook_path    File.join(ROOT, "env/chef/cookbooks")
#data_bag_path    File.join(ROOT, "env/chef/data_bags")
role_path        File.join(ROOT, "env/chef/roles")
json_attribs     File.join(ROOT, "env/chef/solo.json")

node_name "machine-001"
node_path ROOT
