Racker::Processor.register_template do |t|
  t.provisioners = {
    10 => {
      "chef" => {
        "cookbook_paths"=> ["{{user `cookbook_path`}}"],
        "data_bags_path" => "{{user `data_bags_path`}}",
        "execute_command"=> "sudo chef-solo --no-color -c {{.ConfigPath}} -j {{.JsonPath}} -l debug",
        "install_command"=> "sudo bash -c 'curl -L https://www.opscode.com/chef/install.sh| bash -s -- -v 12.0.3'",
        "prevent_sudo"=> false,
        "skip_install"=> false,
        "type"=> "chef-solo"
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
