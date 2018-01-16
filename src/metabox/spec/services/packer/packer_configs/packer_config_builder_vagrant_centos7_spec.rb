require_relative "../../../spec_helper"

RSpec.describe Metabox::PackerConfigBuilderVagrantCentos7 do
  
  def _get_service 
    Metabox::PackerConfigBuilderVagrantCentos7.new
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
   
    it 'can configure packer::builders::vagrant' do
      service = _get_service
  
      config = {
        'builders' => [
          {
            "Type" => "packer::builders::vagrant_centos7",
            "Properties" => {
              'box_name' => "geerlingguy/centos7",
              'builder' => {
                "output_directory" => 'output-centos7-mb-canary'
              }
            }
          }
        ]
      }
      packer_config = {}

      expected = {
        'builders' => [ 
          {
            "type" => "vagrant",
            
            "box_name" => "geerlingguy/centos7",
            "box_provider" => "virtualbox",
            "box_file" => ".ovf",
            'box_name' => "geerlingguy/centos7",
            
            'builder' => {
                "output_directory" => 'output-centos7-mb-canary',
                "type" =>"virtualbox-ovf",
                "headless" => 'true',
                "boot_wait" => "30s",
                "ssh_username" => "vagrant",
                "ssh_password" => "vagrant",
                "ssh_wait_timeout" => "8h",
                "shutdown_command" => "sudo -S sh -c '/usr/sbin/shutdown -h'",
                "shutdown_timeout" => "15m"
            }
          }
        ]
      }

      service.configure(config: config, packer_config: packer_config)
      _test_configs(config: packer_config, packer_config: expected)
    end

  end
end