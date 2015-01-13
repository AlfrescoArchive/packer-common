Racker::Processor.register_template do |t|
  t.provisioners = {
    # knock out chef provisioning
    10 => {
      "chef" => "~~"
    }
  }
end
