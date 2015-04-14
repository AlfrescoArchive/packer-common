Racker::Processor.register_template do |t|

  t.variables = {
    "ssh_username" => "{{env `SSH_USERNAME`}}",
    # Virtualbox source image coordinates
    "source_path" => "{{env `SOURCE_PATH`}}",
    # Virtualbox target image coordinates
    "output_directory" => "{{env `OUTPUT_DIRECTORY`}}",
    "vm_name" => "{{env `VM_NAME`}}",
    # Chef Provisioning parameters
    "data_bags_path" => "{{env `DATA_BAGS_PATH`}}",
    "cookbook_path" => "{{env `COOKBOOK_PATH`}}",
    "chef_log_level" => "{{env `CHEF_LOG_LEVEL`}}"
  }

  t.builders['vbox-ovf'] = {
    "type"=> "virtualbox-ovf",
    "source_path" => "{{user `source_path`}}",
    "output_directory" => "{{user `output_directory`}}",
    "vm_name" => "{{user `vm_name`}}",
    "ssh_username"=> "vagrant",
    "ssh_password"=> "vagrant",
    "boot_command"=> [
      "<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks-ovf.cfg<enter><wait>"
    ],
    "guest_additions_path"=> "VBoxGuestAdditions_{{.Version}}.iso",
    "guest_additions_sha256"=> "2a87971ae3c7e57e87713967a6f242acbdafcc09b635cba98e6dd3a7f5292d3b",
    "headless"=> "true",
    "shutdown_command"=> "echo 'vagrant' | sudo -S /sbin/halt -p",
    "vboxmanage"=> {
      'memory'  => [ 'modifyvm', '{{.Name}}', '--memory',    '1024' ],
      'cpus'    => [ 'modifyvm', '{{.Name}}', '--cpus',      '1' ],
      'ioapic'  => [ 'modifyvm', '{{.Name}}', '--ioapic',    'on' ]
    }
  }

  # t.postprocessors['vagrant'] = {
  #   'type' => 'vagrant',
  #   'output' => '{{user `vagrant_output_file`}}',
  #   'compression_level' => 7,
  #   'keep_input_artifact' => true,
  #   'only' => ['vbox-ovf','vbox-iso']
  # }
end
