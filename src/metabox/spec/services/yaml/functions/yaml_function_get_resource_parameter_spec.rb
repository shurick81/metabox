require_relative "../../../spec_helper"

RSpec.describe Metabox::YamlFunctionGetResourceParameter do
  
  def _get_service 
    Metabox::YamlFunctionGetResourceParameter.new
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
  
      expect(service.name).to eq("yaml::function::get_resource_parameter")
    end

    it '.order' do
        service = _get_service
    
        expect(service.order).to eq(40)
    end

  end

  context '.process' do 
    it 'can replace parameters' do
        service = _get_service

        data_set = [
            {
                in: { 
                    "Resources" => {
                        "Parameters" => {
                            "MyParam1" => "VeryTop1",
                            "MyNestedParam1" => "VeryNested1",
                        },
                        "Resource1" => {
                            "Parameters" => {
                                "MyParam1" => "Top1",
                                "MyParam2" => "Top2",
                                "MyNestedParam1" => "Nested1",
                                "MyNestedParam2" => "Nested2"
                            },
                            "TopParams" =>  {
                                "TopProp1" => "Fn::GetResourceParameter MyParam1",
                                "TopProp2" => "Fn::GetResourceParameter MyParam2"
                            },
                            "Nested" => {
                                "MyProps" => {
                                    "NestedProp1" => "Fn::GetResourceParameter MyNestedParam1",
                                    "TopProp2" => "Fn::GetResourceParameter MyNestedParam2"
                                }
                            }
                        }
                    }
                    
                },
                out: { 
                    "Resources" => {
                        "Parameters" => {
                            "MyParam1" => "VeryTop1",
                            "MyNestedParam1" => "VeryNested1",
                        },
                        "Resource1" => {
                            "Parameters" => {
                                "MyParam1" => "Top1",
                                "MyParam2" => "Top2",
                                "MyNestedParam1" => "Nested1",
                                "MyNestedParam2" => "Nested2"
                            },
                            "TopParams" =>  {
                                "TopProp1" => "Top1",
                                "TopProp2" => "Top2"
                            },
                            "Nested" => {
                                "MyProps" => {
                                    "NestedProp1" => "Nested1",
                                    "TopProp2" => "Nested2"
                                }
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
            puts result.to_yaml
            puts "---"
            puts data[:out].to_yaml

            expect(result).to eq(data[:out])

        end
      
  
    end
  end

end