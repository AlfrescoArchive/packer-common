Packer Common
---

When using [Packer](www.packer.io) extensively, templates can be difficult to maintain; Packer common aims to fix it, by allowing to define separate Packer templates for builders, provisioners and project-specific items, merging them at execution time.


### How to Run 

Invoking Packer Common is simple:
```
curl -L https://raw.githubusercontent.com/Alfresco/packer-common/master/run-packer.sh --no-sessionid | bash -s -- ./ami.env
```

To run Packer Common you need:

- A .env file (in this example `ami.env`) that defines all environment variables used by Packer logic; the .env file will include - amongst many other variables used by Packer Templates - a builder, a provisioner and a project-specific template "snippet":
```
export PACKER_BUILDER_TPL_NAME=amazon
export PACKER_PROVISIONER_TPL_NAME=chef-zero
export PACKER_INSTANCE_TPL=$ROOT_FOLDER/packer-ami.rb
```
- The project-specific Packer logic, in this example `packer-ami.rb`

### Template Composition

Based on the variables, the following "snippets" are fetched and merged:
- The [common builder](https://github.com/Alfresco/packer-common/blob/master/packer-builder-amazon.rb)
- The [common provisioner](https://github.com/Alfresco/packer-common/blob/master/packer-provisioner-chef-zero.rb)
- The project-specific template "snippet", which can patch bits and pieces of builders and provisioners; an example is reported below

A project-specific Packer Common snippet
```
Racker::Processor.register_template do |t|
  t.provisioners = {
    10 => {
      "chef" => {
        "json"=> {
          "name"=> "img-basic"
        },
        "run_list" => [ "img-basic::default" ]
      }
    },
    20 => {
      "yum-clean-all" => {
        "type"=> "shell",
        "inline" => [
          "sudo yum -y clean all",
          "sudo rm -f /var/log/*",
          "sudo rm -rf /tmp/*"
        ]
      }
    }
  }
  t.builders['amazon'] = {
    "ami_block_device_mappings" => [
      {
        "device_name" => "/dev/sda1",
        "volume_size" => 12,
        "delete_on_termination" => true
      },
      {
        "device_name" => "/dev/sdb",
        "virtual_name" => "ephemeral0"
      },
      {
        "device_name" => "/dev/sdc",
        "virtual_name" => "ephemeral1"
      }
    ]
  }
end
```

[Racker](https://github.com/aspring/racker) allows to generate Packer templates from a list of template "fragments" (or Racker templates).


### Reusable Packer Template "snippets"

This is the list of currently available Packer Template "snippets" that can be reused with Packer Common:
- Amazon (Instance store) Builder  [packer-builder-amazon-instance.rb](packer-builder-amazon-instance.rb)
- Amazon (EBS) Builder [packer-builder-amazon.rb](packer-builder-amazon.rb)
- Virtualbox OVF Builder, based on ISO [packer-builder-vbox-iso.rb](packer-builder-vbox-iso.rb)
- Virtualbox OVF Builder, based on OVF [packer-builder-vbox-ovf.rb](packer-builder-vbox-ovf.rb)
- Chef Provisioner [packer-provisioner-chef.rb](packer-provisioner-chef.rb)

### Using Chef/Berkshelf

When Chef is involved, Packer Common will run some tasks before invoking `racker` and `packer`:

1. Run Berkshelf to resolve all cookbooks needed
2. Download and unpack databags
3. Resolve Racker templates (from a Github repo)

[run-packer.sh](run-packer.sh) delivers these features, reading configurations from environment variables; check [packer.env.sample](packer.env.sample) for more info
