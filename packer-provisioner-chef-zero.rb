Racker::Processor.register_template do |t|
  t.provisioners = {
    9 => {
      "type" => "shell",
      "inline" => [
        "sudo mkdir -p /etc/chef && sudo chown -R root:root /etc/chef",
        "sudo mkdir -p /tmp/packer-chef-client && sudo chown -R root:root /tmp/packer-chef-client"
      ]
    },
    10 => {
      "chef" => {
        "execute_command"=> "sudo chef-client --no-color --local-mode -c {{.ConfigPath}} -j {{.JsonPath}} -l {{user `chef_log_level`}}",
        "server_url" => "http://localhost:8889",
        "install_command"=> "sudo bash -c 'curl -L https://www.opscode.com/chef/install.sh| bash -s -- -v 12.2.1'",
        "prevent_sudo"=> false,
        "skip_install"=> false,
        "type"=> "chef-client"
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
