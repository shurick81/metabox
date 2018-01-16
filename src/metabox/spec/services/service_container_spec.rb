require_relative "../spec_helper"

RSpec.describe Metabox::ServiceContainer do
  
  def _get_client
    Metabox::ServiceContainer.new
  end

  context '.initialize' do
    it 'can create instance' do
      instance = _get_client
      expect(instance).not_to be nil
    end
  end

  context 'default instance' do
    it 'default instance is not null' do
      instance = Metabox::ServiceContainer.instance

      expect(instance).not_to be nil
    end
  end

  context 'can find services by type' do
    it 'one service' do
      instance = Metabox::ServiceContainer.instance

      services = instance.get_services(Metabox::LogService)

      expect(services).not_to be nil
      expect(services.count).to be 1
    end

    it 'many services' do
      instance = Metabox::ServiceContainer.instance

      services = instance.get_services(Metabox::YamlFunctionServiceBase)

      expect(services).not_to be nil
      expect(services.count).to be 8
    end
  end


  context 'default services' do
    it 'returns default services by type' do
      instance = Metabox::ServiceContainer.instance

      expect(instance).not_to be nil
      
      expect(instance.get_service(Metabox::OSService)).not_to eq(nil)
      expect(instance.get_service(Metabox::LogService)).not_to eq(nil)

      expect(instance.get_service(Metabox::PackerService)).not_to eq(nil)
      expect(instance.get_service(Metabox::VagrantService)).not_to eq(nil)
      #expect(instance.get_service(Metabox::YamlService)).not_to eq(nil)
    end

    it 'returns default services by name' do
      instance = Metabox::ServiceContainer.instance

      expect(instance).not_to be nil
      
      expect(instance.get_service_by_name("os")).not_to eq(nil)
      expect(instance.get_service_by_name("log")).not_to eq(nil)

      expect(instance.get_service_by_name("packer")).not_to eq(nil)
      expect(instance.get_service_by_name("vagrant")).not_to eq(nil)
      #expect(instance.get_service_by_name("yaml")).not_to eq(nil)
    end
  end

 

  
end