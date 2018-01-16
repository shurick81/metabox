require_relative "../spec_helper"

RSpec.describe Metabox::ServiceBase do
  
  def _get_client
    Metabox::ServiceBase.new
  end

  context '.initialize' do
    it 'can create instance' do
      instance = _get_client
      expect(instance).not_to be nil
    end
  end

  context '.properties' do
    it 'returns name' do
      instance = _get_client

      expect(instance.name).to eq("service_base")
    end
    
    it 'returns log service' do
      instance = _get_client

      expect(instance.log).not_to be(nil)
    end
  end

end