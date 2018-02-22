require_relative "../../spec_helper"

include Metabox

RSpec.describe OSService do

    def _get_service 
        Metabox::OSService.new
      end
    
      context '.initialize' do 
        it 'can create service' do
          service = _get_service
      
          expect(service).not_to be nil
        end
      end

end