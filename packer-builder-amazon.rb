Racker::Processor.register_template do |t|

  t.variables = {
    # AWS Account variables
    "access_key" => "{{env `AWS_KEY_ID`}}",
    "secret_key" => "{{env `AWS_KEY_SECRET`}}",
    "ssh_private_key_file"=> "{{env `AWS_KEY_PATH`}}",
    "temporary_key_pair_name"=> "{{env `KEYPAIR_NAME`}}",
    "source_ami"=> "{{env `SOURCE_AMI`}}",
    "region" => "{{env `REGION`}}",
    "ami_virtualization_type"=> "{{env `AMI_VIRTUALIZATION_TYPE`}}",
    "enhanced_networking" => "{{env `ENHANCED_NETWORKING`}}",
    "security_group_id1" => "{{env `SECURITY_GROUP_ID1`}}",
    "security_group_id2" => "{{env `SECURITY_GROUP_ID2`}}",
    "instance_type"=> "{{env `INSTANCE_TYPE`}}",
    # Coordinates for generated AMI
    "ami_name"=> "{{env `AMI_NAME`}}",
    "ami_description"=> "{{env `AMI_DESCRIPTION`}}",
    "ssh_username" => "{{env `SSH_USERNAME`}}",
    # Chef Provisioning parameters
    "data_bags_path" => "{{env `DATA_BAGS_PATH`}}",
    "cookbook_path" => "{{env `COOKBOOK_PATH`}}",
    "chef_log_level" => "{{env `CHEF_LOG_LEVEL`}}"
  }

  t.builders['amazon'] = {
    "type"=> "amazon-ebs",
    "access_key"=> "{{user `access_key`}}",
    "secret_key"=> "{{user `secret_key`}}",
    "ssh_private_key_file"=> "{{user `ssh_private_key_file`}}",
    "temporary_key_pair_name"=> "{{user `temporary_key_pair_name`}}",
    "region"=> "{{user `region`}}",
    "source_ami"=> "{{user `source_ami`}}",
    "instance_type"=> "{{user `instance_type`}}",
    "ssh_username"=> "{{user `ssh_username`}}",
    "security_group_ids" => ['{{user `security_group_id1`}}','{{user `security_group_id2`}}'],
    "ami_name"=> "{{user `ami_name`}}",
    "ami_description"=> "{{user `ami_description`}}",
    "ami_virtualization_type" => "{{user `ami_virtualization_type`}}",
    "enhanced_networking" => "{{user `enhanced_networking`}}",
  }
end
