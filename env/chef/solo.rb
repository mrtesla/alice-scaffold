ROOT = File.expand_path('../../../', __FILE__)
ENV['ROOT'] = ROOT

file_cache_path  File.join(ROOT, "var/chef/file-cache")
file_backup_path File.join(ROOT, "var/chef/file-backup")
cookbook_path    File.join(ROOT, "env/chef/cookbooks")
data_bag_path    File.join(ROOT, "env/chef/data_bags")
role_path        File.join(ROOT, "env/chef/roles")
json_attribs     File.join(ROOT, "env/chef/solo.json")
cache_options({ :path => File.join(ROOT, "var/chef/file-checksums"), :skip_expires => true })

node_name "machine-001"
node_path ROOT
