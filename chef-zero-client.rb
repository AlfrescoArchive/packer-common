#static values added by packer-common to enable chef-zero
local_mode = true
chef_repo_path = "/etc/chef"

cookbook_path = "/etc/chef/cookbooks"
data_bag_path = "/etc/chef/databags"

# Default Packer template
log_level        :info
log_location     STDOUT
chef_server_url  "{{.ServerUrl}}"
{{if ne .ValidationClientName ""}}
validation_client_name "{{.ValidationClientName}}"
{{else}}
validation_client_name "chef-validator"
{{end}}
{{if ne .ValidationKeyPath ""}}
validation_key "{{.ValidationKeyPath}}"
{{end}}
node_name "{{.NodeName}}"
{{if ne .ChefEnvironment ""}}
environment "{{.ChefEnvironment}}"
{{end}}
{{if ne .SslVerifyMode ""}}
ssl_verify_mode :{{.SslVerifyMode}}
{{end}}
