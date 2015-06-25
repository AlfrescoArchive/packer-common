Racker::Processor.register_template do |t|
  t.provisioners = {
    5 => {
      "create-packer-folders" => {
        "type" => "shell",
        "inline" => [
          "sudo mkdir -p /etc/chef",
          "sudo chmod 777 /etc/chef",
        ]
      }
    },
    6 => {
      "create-cookbooks" => {
        "type" => "file",
        "source"=> "{{user `cookbook_path`}}",
        "destination"=> "/etc/chef/cookbooks"
      }
    },
    7 => {
      "create-databags" => {
        "type"=> "file",
        "source"=> "{{user `data_bags_path`}}",
        "destination"=> "/etc/chef/data_bags"
      }
    },
    10 => {
      "chef" => {
        "cookbook_paths"=> ["{{user `cookbook_path`}}"],
        "data_bags_path" => "{{user `data_bags_path`}}",
          "execute_command"=> "cd /etc/chef && sudo chef-client --no-color --local-mode \
          -c {{.ConfigPath}} \
          -j {{.JsonPath}} \
          -l {{user `chef_log_level`}}",
        "install_command"=> "sudo bash -c 'curl -L https://www.opscode.com/chef/install.sh| bash -s -- -v 12.3.0'",
        "prevent_sudo"=> false,
        "skip_install"=> false,
        "type"=> "chef-solo",
        # TODO - this should be handled in a better way
        "config_template" => "{{pwd}}/../packer_common_checkout/chef-zero-client.rb"
      }
    },
    100 => {
      "cleanup-network" => {
        "type"=> "shell",
        "inline" => [
          "sudo sed -i 's/^HWADDR.*$//' /etc/sysconfig/network-scripts/ifcfg-eth0",
          "sudo sed -i 's/^UUID.*$//' /etc/sysconfig/network-scripts/ifcfg-eth0",
          "sudo rm -Rf /etc/udev/rules.d/70-persistent-net.rules"
        ]
      }
    }
  }
end
