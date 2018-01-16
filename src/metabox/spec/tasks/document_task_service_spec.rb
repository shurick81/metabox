require_relative "../spec_helper"

RSpec.describe Metabox::DocumentTaskService do
  
    def _get_instance
      Metabox::DocumentTaskService.new
    end
    
    context '.initialise' do
      it 'Can create instance' do
        client = _get_instance
    
        expect(client).not_to be nil
      end
    end

    context '.api' do
      it '.name' do
        client = _get_instance
    
        expect(client.name).to eq("metabox::tasks:document")
      end

      it '.rake_alias' do
        client = _get_instance
    
        expect(client.rake_alias).to eq("document")
      end
    end

  end
  