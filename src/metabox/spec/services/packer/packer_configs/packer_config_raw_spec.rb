require_relative "../../../spec_helper"

RSpec.describe Metabox::PackerConfigRaw do
  
  def _get_service 
    Metabox::PackerConfigRaw.new
  end

  context '.initialize' do 
    it 'can create service' do
      service = _get_service
  
      expect(service).not_to be nil
    end
  end

  def _test_configs(config:, packer_config:)

    puts "------------------------------------------------------------------------------------------"
    puts "GENERATED:"
    puts config.to_yaml

    puts "------------------------------------------------------------------------------------------"
    puts "EXPECTED:"
    puts packer_config.to_yaml
    puts "------------------------------------------------------------------------------------------"

    expect(packer_config).to eq(config)
  end

  context '.configure' do 
    it 'can configure null template' do
      service = _get_service
  
      config = {}
      packer_config = {}

      service.configure(config: config, packer_config: packer_config)
      
      expect(packer_config).to eq({})
    end

    it 'can configure raw template' do
      service = _get_service
  
      config = {
        'variables' => {
          'a' => 1,
          'b' => 2
        },
        'builders' => [
          {
            "type" => "vagrant",
            "box_name" => "geerlingguy/centos7"
          }
        ],
        "provisioners" => [
          {
            "type" => "shell"
          }
        ],
        "post-processors" => [
          {
            "type" => "vagrant",
            "keep_input_artifact" => false,
            "output" => "centos7-mb-canary-{{ user `metabox_git_branch` }}-{{.Provider}}.box"
          }
        ]
      }
      packer_config = {}
      expected = config

      service.configure(config: config, packer_config: packer_config)
      _test_configs(config: packer_config, packer_config: config)
    end

  end

end