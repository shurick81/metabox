require_relative "../../../spec_helper"

RSpec.describe Metabox::YamlFunctionGetResourceProperty do
  
  def _get_service 
    Metabox::YamlFunctionGetResourceProperty.new
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
  
      expect(service.name).to eq("yaml::function::get_resource_property")
    end

    it '.order' do
        service = _get_service
    
        expect(service.order).to eq(70)
    end

  end

  context '.process' do 
    it 'can replace parameters' do
        service = _get_service

        data_set = [
            {
                in: { 
                    "Resources" => {
                        "MasterResource" => {
                            "TopProperty" => "MasterResource-TopValue",
                            "Nested" => {
                                "NestedProp" =>  "MasterResource-NestedValue"
                            }
                        },
                        "ChildResource" => {
                            "ChildTopProperty" => "Fn::GetResourceProperty MasterResource.TopProperty",
                            "Nested" => {
                                "ChildNestedProp" => "Fn::GetResourceProperty MasterResource.Nested.NestedProp"
                            }
                        }
                    }
                    
                },
                out: { 
                    "Resources" => {
                        "MasterResource" => {
                            "TopProperty" => "MasterResource-TopValue",
                            "Nested" => {
                                "NestedProp" =>  "MasterResource-NestedValue"
                            }
                        },
                        "ChildResource" => {
                            "ChildTopProperty" => "MasterResource-TopValue",
                            "Nested" => {
                                "ChildNestedProp" =>  "MasterResource-NestedValue"
                            }
                        }
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