Racker::Processor.register_template do |t|
  t.provisioners = {
    5 => {
      "create-packer-folders" => {
        "type" => "shell",
        "inline" => [
          "echo PRINTING OUT chef clientrb",
          "cat /tmp/packer-chef-client/first-boot.json",
          "sudo mkdir -p /etc/chef",
          "sudo chmod 777 /etc/chef",
          "sudo chown -R root:root /etc/chef",
          "sudo mkdir -p /tmp/packer-chef-client",
          "sudo chown -R root:root /tmp/packer-chef-client",
          "sudo chmod 777 /tmp/packer-chef-client"
        ]
      }
    },
    6 => {
      "create-cookbooks" => {
        "type" => "file",
        "source"=> "{{pwd}}/berks-cookbooks",
        "destination"=> "/etc/chef/cookbooks"
      }
    },
    7 => {
      "create-databags" => {
        "type"=> "file",
        "source"=> "{{pwd}}/databags_checkout",
        "destination"=> "/etc/chef/databags"
      }
    },
    10 => {
      "chef" => {
        "execute_command"=> "sudo chef-client --no-color --local-mode -c /tmp/packer-chef-client/client.rb -j /tmp/packer-chef-client/first-boot.json -l {{user `chef_log_level`}}",
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
