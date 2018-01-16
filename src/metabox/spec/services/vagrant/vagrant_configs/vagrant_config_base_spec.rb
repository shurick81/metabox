require_relative "../../../spec_helper"

RSpec.describe Metabox::VagrantConfigs::VagrantConfigBase do
  
  def _get_service 
    Metabox::VagrantConfigs::VagrantConfigBase.new
  end

  context '.initialize' do 
    it 'can create service' do
      service = _get_service
  
      expect(service).not_to be nil
    end
  end

  context '.initialize' do 
    it 'can configure raw template' do
      service = _get_service
  
      config = {}
      vm_config = {}

      service.configure(config: config, vm_config: vm_config)

      expect(vm_config).to eq(config)
    end
  end

 
end