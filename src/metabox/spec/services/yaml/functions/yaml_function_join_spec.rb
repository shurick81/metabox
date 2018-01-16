require_relative "../../../spec_helper"

RSpec.describe Metabox::YamlFunctionJoin do
  
  def _get_service 
    Metabox::YamlFunctionJoin.new
  end

  context '.initialize' do 
    it 'can create service' do
      service = _get_service
  
      expect(service).not_to be nil
    end
  end

  context '.methods' do 
    it '.name' do
      service = _get_service
  
      expect(service.name).to eq("yaml::function::join")
    end

    it '.order' do
        service = _get_service
    
        expect(service.order).to eq(20)
    end
  end

  context '.process' do 
    it 'can join property value' do
        service = _get_service

        data_set = [
            {
                in: { 
                    "MyProp" => {
                        "Fn::Join" => ['-', [1,2,3] ]
                    },
                    "Nested" =>  {
                        "MyNestedProp" => {
                            "Fn::Join" => ['-', [1,2,3,4,5] ]
                        }
                    }
                    
                },
                out: { 
                    "MyProp"  => "1-2-3",
                    "Nested" => {
                        "MyNestedProp" => "1-2-3-4-5"
                    }
                }
            }
        ]

        data_set.each do | data | 

            allow(service).to receive(:_env).and_return(data[:env])

            result = ObjectUtils.deep_clone(data[:in])

            service.process(result)
            expect(result).to eq(data[:out])

        end
      
  
    end
  end

end