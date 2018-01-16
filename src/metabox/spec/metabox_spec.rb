require_relative "spec_helper"

RSpec.describe Metabox do
  it "has a version number" do
    expect(Metabox::VERSION).not_to be nil
  end
end

RSpec.describe Metabox::ApiClient do
  
    def _get_instance
      Metabox::ApiClient.new
    end
    
    context '.initialise' do
      it 'Can create instance' do
        client = _get_instance
    
        expect(client).not_to be nil
      end
    end

    context '.api' do
      it '.welcome_message' do
        client = _get_instance
    
        client.welcome_message
      end
    end

  end
  