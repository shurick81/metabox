require_relative "../../spec_helper"

RSpec.describe Metabox::SchemaValidationService do
  
  def _get_service 
    Metabox::SchemaValidationService.new
  end

  def show_error(result) 
    puts "validation result:"
    puts result[:error].inspect
  end

  describe '.initialize' do
    it 'can create service' do
        service = _get_service
    
        expect(service).not_to be nil
      end
  end

  describe '.validate_hash' do

    it 'can validate empty hash' do
        service = _get_service

        hash = {}
        schema = {}

        validation_result = service.validate_hash(hash, schema)

        show_error(validation_result)

        expect(validation_result[:valid]).to eq(true)
        expect(validation_result[:error]).to eq(nil)
    end

    it 'can validate hash' do
        service = _get_service

        hash = {
            "Type" => "something",
            "Tags" => [ "1" , "2", "3"],
            "Properties" => {

            }
        }

        schema = {}

        validation_result = service.validate_hash(hash, schema)

        show_error(validation_result)

        expect(validation_result[:valid]).to eq(true)
        expect(validation_result[:error]).to eq(nil)
    end

  end

end