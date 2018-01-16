require_relative "../../../spec_helper"

RSpec.describe Metabox::PackerVaiablesConfig do
  
  def _get_service 
    Metabox::PackerVaiablesConfig.new
  end

  context '.initialize' do 
    it 'can create service' do
      service = _get_service
  
      expect(service).not_to be nil
    end
  end

  context '.configure' do 
    it 'can configure' do
      service = _get_service
  
      config = {
        "variables" => {
          "var1" => "1",
          "var2" => "2"
        }
      }

      packer_config = {}

      service.configure(config: config, packer_config: packer_config)

      expect(packer_config["variables"]).to eq(config["variables"])
    end
  end

end