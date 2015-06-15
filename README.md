> Working on a Packer Pull request to deprecate Packer Common (much cleaner)
> https://github.com/maoo/packer/tree/chef-solo-precommands

Packer Common
---

When using [Packer](www.packer.io) extensively, templates can difficult to maintain; [Racker](https://github.com/aspring/racker) allows to generate Packer templates from a list of template "fragments" (or Racker templates).

Packer Common is a collection of Racker templates; for our use case we identified the following ones:
- Amazon (Instance store) Builder  [packer-builder-amazon-instance.rb](packer-builder-amazon-instance.rb)
- Amazon (EBS) Builder [packer-builder-amazon.rb](packer-builder-amazon.rb)
- Virtualbox OVF Builder, based on ISO [packer-builder-vbox-iso.rb](packer-builder-vbox-iso.rb)
- Virtualbox OVF Builder, based on OVF [packer-builder-vbox-ovf.rb](packer-builder-vbox-ovf.rb)
- Chef Provisioner [packer-provisioner-chef.rb](packer-provisioner-chef.rb)

Using Chef/Berkshelf
---

If Chef is involved, you will probably need to run some tasks before invoking `racker` and `packer`:

1. Run Berkshelf to resolve all cookbooks needed
2. Download and unpack databags
3. Resolve Racker templates (from a Github repo)

[run-packer.sh](run-packer.sh) delivers these features, reading configurations from environment variables; check [packer.env.sample](packer.env.sample) for more info
