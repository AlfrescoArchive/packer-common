Racker::Processor.register_template do |t|

  t.variables = {
    # AWS Account variables
    "account_id" => "{{env `AWS_ACCOUNT_ID`}}",
    "access_key" => "{{env `AWS_KEY_ID`}}",
    "secret_key" => "{{env `AWS_KEY_SECRET`}}",
    "x509_cert_path"=> "{{env `AWS_CERT_PATH`}}",
    "x509_key_path"=> "{{env `AWS_KEY_PATH`}}",
    "source_ami"=> "{{env `SOURCE_AMI`}}",
    "region" => "{{env `REGION`}}",
    "ami_virtualization_type"=> "{{env `AMI_VIRTUALIZATION_TYPE`}}",
    "security_group_id1" => "{{env `SECURITY_GROUP_ID1`}}",
    "security_group_id2" => "{{env `SECURITY_GROUP_ID2`}}",
    "instance_type"=> "{{env `INSTANCE_TYPE`}}",
    # Coordinates for generated AMI
    "s3_bucket" => "{{env `S3_BUCKET`}}",
    "ami_name"=> "{{env `AMI_NAME`}}",
    "ami_description"=> "{{env `AMI_DESCRIPTION`}}",
    "bundle_destination" => "{{env `BUNDLE_DESTINATION`}}",
    "ssh_username" => "{{env `SSH_USERNAME`}}",
    # AWS Volumes configurations
    "ebs_device_name"=> "{{env `EBS_DEVICE_NAME`}}",
    "ebs_virtual_name"=> '{{env `EBS_VIRTUAL_NAME`}}',
    "ebs_root_size"=> '{{env `EBS_ROOT_SIZE`}}',
    # Chef Provisioning parameters
    "data_bags_path" => "{{env `DATA_BAGS_PATH`}}",
    "cookbook_path" => "{{env `COOKBOOK_PATH`}}"
  }

  t.builders['amazon'] = {
    "type"=> "amazon-instance",
    "access_key"=> "{{user `access_key`}}",
    "secret_key"=> "{{user `secret_key`}}",
    "region"=> "{{user `region`}}",
    "source_ami"=> "{{user `source_ami`}}",
    "instance_type"=> "{{user `instance_type`}}",
    "ssh_username"=> "{{user `ssh_username`}}",
    "security_group_ids" => ['{{user `security_group_id1`}}','{{user `security_group_id2`}}'],
    "ami_name"=> "{{user `ami_name`}}",
    "ami_description"=> "{{user `ami_description`}}",
    "ami_virtualization_type" => "{{user `ami_virtualization_type`}}",
    # Volumes configuration
    # ----
    "ami_block_device_mappings" => [ {
      "device_name"=> "{{user `ebs_device_name`}}",
      "virtual_name" => "{{user `ebs_virtual_name`}}",
      "volume_size"=> "{{user `ebs_root_size`}}"
    } ],
    "launch_block_device_mappings" => [ {
      "device_name"=> "{{user `ebs_device_name`}}",
      "virtual_name" => "{{user `ebs_virtual_name`}}",
      "volume_size"=> "{{user `ebs_root_size`}}"
    } ],
    #
    # Instance-store specific configurations
    # ----
    "account_id"=> "{{user `account_id`}}",
    "s3_bucket"=> "{{user `s3_bucket`}}",
    "bundle_destination" => "{{user `bundle_destination`}}",
    "x509_cert_path"=> "{{user `x509_cert_path`}}",
    "x509_key_path"=> "{{user `x509_key_path`}}",
    "bundle_vol_command"=> "PATH=/sbin:$PATH \
    sudo -n ec2-bundle-vol \
    -k {{.KeyPath}}  \
    -u {{.AccountId}} \
    -c {{.CertPath}} \
    -r {{.Architecture}} \
    -e {{.PrivatePath}}/* \
    -d {{.Destination}} \
    -p {{.Prefix}} \
    --batch \
    --no-filter",
    "bundle_upload_command"=> "PATH=/sbin:$PATH \
    sudo -n ec2-upload-bundle \
    -b {{.BucketName}} \
    -m {{.ManifestPath}} \
    -a {{.AccessKey}} \
    -s {{.SecretKey}} \
    -d {{.BundleDirectory}} \
    --batch \
    --region {{.Region}} \
    --retry"
  }

  t.provisioners = {
    0 => {
      "install-ami-tools" => {
        "type"=> "shell",
        "inline" => [
          "sudo yum install -y wget parted device-mapper kpartx",
          "sudo wget http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools-1.5.6.noarch.rpm",
          "sudo yum install -y ec2-ami-tools-1.5.6.noarch.rpm",
          "sudo export EC2_AMITOOL_HOME=/opt/aws/amitools/ec2-1.5.6",
          "sudo export PATH=$PATH:$EC2_AMITOOL_HOME/bin",
          "echo 'Printing DF\n' ; sudo df -h"
        ]
      }
    }
  }
end
