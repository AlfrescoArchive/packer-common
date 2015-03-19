Racker::Processor.register_template do |t|

  t.variables = {
    "ssh_username" => "{{env `SSH_USERNAME`}}",
    # Virtualbox source image coordinates
    "iso_url" => "{{env `ISO_URL`}}",
    "iso_sha256" => "{{env `ISO_SHA256`}}",
    # Virtualbox target image coordinates
    "output_directory" => "{{env `OUTPUT_DIRECTORY`}}",
    "ks_directory" => "{{env `KS_DIRECTORY`}}",
    "vm_name" => "{{env `VM_NAME`}}",
    # Chef Provisioning parameters
    "data_bags_path" => "{{env `DATA_BAGS_PATH`}}",
    "cookbook_path" => "{{env `COOKBOOK_PATH`}}"
  }

  t.builders['vbox-iso'] = {
    "type"=> "virtualbox-iso",
    "iso_url"=> "{{user `iso_url`}}",
    "iso_checksum"=> "{{user `iso_sha256`}}",
    "output_directory" => "{{user `output_directory`}}",
    "vm_name" => "{{user `vm_name`}}",
    "iso_checksum_type"=> "sha256",
    "ssh_username"=> "vagrant",
    "ssh_password"=> "vagrant",
    "boot_command"=> [
      "<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"
    ],
    "disk_size"=> "20000",
    "hard_drive_interface"=> "sata",
    "guest_additions_path"=> "VBoxGuestAdditions_{{.Version}}.iso",
    "guest_additions_sha256"=> "2a87971ae3c7e57e87713967a6f242acbdafcc09b635cba98e6dd3a7f5292d3b",
    "guest_os_type" => "RedHat_64",
    "headless"=> "true",
    "http_directory"=> "{{user `ks_directory`}}",
    "shutdown_command"=> "echo 'vagrant' | sudo -S /sbin/halt -p",
    "vboxmanage"=> {
      'memory'  => [ 'modifyvm', '{{.Name}}', '--memory',    '1024' ],
      'cpus'    => [ 'modifyvm', '{{.Name}}', '--cpus',      '1' ],
      'ioapic'  => [ 'modifyvm', '{{.Name}}', '--ioapic',    'on' ]
    }
  }
end
