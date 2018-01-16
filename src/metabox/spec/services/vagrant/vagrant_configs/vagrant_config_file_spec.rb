require_relative "../../../spec_helper"

RSpec.describe Metabox::VagrantConfigs::VagrantConfigFile do
  
  def _get_service 
    Metabox::VagrantConfigs::VagrantConfigFile.new
  end

  context '.initialize' do 
    it 'can create service' do
      service = _get_service
  
      expect(service).not_to be nil
    end
  end

  context '.configure' do 
    it 'can configure' do
    #   service = _get_service
  
    #   config = {}
    #   vm_config = _get_vm_config
    
    #   service.configure(config: config, vm_config: vm_config)

    #   expect(vm_config).to eq(config)
    end
  end

  context '.config_schema' do 
    # it 'can get config_schema' do
    #   service = _get_service
  
    #   schema = service.schema
      
    #   puts schema.to_yaml

    #   expect(schema).to_not be(nil)
    # end

    

    it 'can get config_schema yaml' do
        service = _get_service
    
        yaml_schema = service.yaml_schema
        yaml_example = service.yaml_example
        
        puts yaml_example

        expect(schema).to_not be(nil)
        expect(yaml_example).to_not be(nil)
      end
  end

 
end