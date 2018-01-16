require_relative "../../../spec_helper"

RSpec.describe Metabox::YamlFunctionServiceBase do
  
  def _get_service 
    Metabox::YamlFunctionServiceBase.new
  end

  context '.initialize' do 
    it 'can create service' do
      service = _get_service
  
      expect(service).not_to be nil
    end
  end

  context '.api' do 
    it '.name' do
      service = _get_service
  
      expect(service.name).to eq("yaml::function::base")
    end

    it '.order' do
        service = _get_service
    
        expect(service.order).to eq(100)
    end

    it '.process' do
        service = _get_service
    
        expect { service.process(nil) }.not_to raise_error
        expect { service.process({}) }.not_to raise_error
    end
  end

  context '.process' do
    it '.process test data' do

        service = _get_service
        
        test_data = [
            {
                :test => {},
                :expect => {}
            },
            {
                :test => { :a => 1, :b => 2},
                :expect => { :a => 1, :b => 2}
            },
            {
                :test => { :a => 1, :b => 2, :c => [1,2,3]},
                :expect => { :a => 1, :b => 2, :c => [1,2,3]}
            },
            {
                :test => { :a => 1, :b => 2, :c => { :a => 1  }},
                :expect => { :a => 1, :b => 2, :c => { :a => 1  }}
            }
        ]

        test_data.each do | data |
            test = data[:test]
            expect = data[:expect]

            service.process(test)

            expect(test).to eq(expect)
        end
    end
    end

end