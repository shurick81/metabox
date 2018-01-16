require_relative "../../../spec_helper"

RSpec.describe Metabox::PackerConfigProvisionerShellCentOS7 do
  
  def _get_service 
    Metabox::PackerConfigProvisionerShellCentOS7.new
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
    it 'can configure packer::provisioners::shell' do
        service = _get_service
    
        config = {
          'provisioners' => [
            {
              "Type" => "packer::provisioners::shell_centos7",
              "Properties" => {
                'scripts' => [
                  "./scripts/shared/mb_printenv.sh"
                ],
                "environment_vars": [
                  "a" => "1"
                ]
                
              }
            }
          ]
        }
        packer_config = {}
  
        expected = {
          'provisioners' => [ 
            {
              "type" => "shell",
              'scripts' => [
                  "./scripts/shared/mb_printenv.sh"
                ],
              "environment_vars": [
                "a" => "1"
              ],
              "execute_command" => "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"        
            }
          ]
        }
  
        service.configure(config: config, packer_config: packer_config)
        _test_configs(config: packer_config, packer_config: expected)
      end
  end

end