require_relative "../spec_helper"

RSpec.describe Metabox::TaskServiceBase do
  
    def _get_instance
      Metabox::TaskServiceBase.new
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
    
        expect(client.name).to eq("metabox::tasks:base")
      end

      it '.rake_alias' do
        client = _get_instance
    
        expect(client.rake_alias).to eq("base")
      end
    end

  end
  