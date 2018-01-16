require_relative "../../spec_helper"

RSpec.describe Metabox::YamlServiceBase do
  
  def _get_service 
    Metabox::YamlServiceBase.new
  end

  def _get_yaml_config_files
    Dir.glob("#{SPEC_DOCUMENTS_DATA_DIR}/**/*.yaml")
  end

  context '.initialize' do 
    it 'can create service' do
      service = _get_service
  
      expect(service).not_to be nil
    end
    
  end

  context '.load' do 
    it 'can load files' do
      service = _get_service

      file_paths = _get_yaml_config_files

      file_paths.each do | file_path |
        config = service.load(file_path)

        expect(config).not_to be nil
        expect(config.class).to eq(Hash)
      end
  
    end
  end

end