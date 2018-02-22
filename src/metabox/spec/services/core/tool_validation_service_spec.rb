require_relative "../../spec_helper"

include Metabox

RSpec.describe ToolValidationService do

    def _get_service 
        Metabox::ToolValidationService.new
      end
    
      context '.initialize' do 
        it 'can create service' do
          service = _get_service
      
          expect(service).not_to be nil
        end
      end

end