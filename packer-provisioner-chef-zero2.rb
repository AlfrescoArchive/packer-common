Racker::Processor.register_template do |t|
  t.provisioners = {
    10 => {
      "chef" => {
        "cookbook_paths"=> ["{{user `cookbook_path`}}"],
        "data_bags_path" => "{{user `data_bags_path`}}",
        # "execute_command"=> "sudo chef-solo --no-color -c {{.ConfigPath}} -j {{.JsonPath}} -l {{user `chef_log_level`}}",
          "execute_command"=> "sudo chef-client --no-color --local-mode \
          -c {{.ConfigPath}} \
          -j /tmp/packer-chef-client/first-boot.json \
          -l :info",
        "install_command"=> "sudo bash -c 'curl -L https://www.opscode.com/chef/install.sh| bash -s -- -v 12.2.1'",
        "prevent_sudo"=> false,
        "skip_install"=> false,
        "type"=> "chef-solo",
        "config_template" => "{{pwd}}/packer_common_checkout/chef-zero-client.rb"
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
