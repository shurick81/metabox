require_relative "../../spec_helper"

RSpec.describe Metabox::DocumentService do
  
  def _get_service 
    Metabox::DocumentService.new
  end

  context '.initialize' do 
    it 'can create service' do
      service = _get_service
  
      expect(service).not_to be nil
    end
  end

  context '.generate' do 
    it 'can generate document resources' do
        service = _get_service
    
        env = {
            'METABOX_DOCUMENT_FOLDERS' => 'documents'
        }

        allow(ENV).to receive(:to_hash) .and_return(env)

        service.generate
    end
  end

  context '.list' do 
    it 'can list document resources' do
        service = _get_service
    
        env = {
            'METABOX_DOCUMENT_FOLDERS' => 'documents'
        }

        allow(ENV).to receive(:to_hash) .and_return(env)

        service.list
    end
  end

end