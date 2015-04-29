#static values added by packer-common to enable chef-zero
local_mode = true
chef_repo_path = "/etc/chef"

cookbook_path = "/etc/chef/cookbooks"
data_bag_path = "/etc/chef/databags"

# Default Packer template
log_level        :info
log_location     STDOUT
node_name "{{.NodeName}}"
