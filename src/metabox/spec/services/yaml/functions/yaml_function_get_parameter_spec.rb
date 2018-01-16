require_relative "../../../spec_helper"

RSpec.describe Metabox::YamlFunctionGetParameter do
  
  def _get_service 
    Metabox::YamlFunctionGetParameter.new
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
  
      expect(service.name).to eq("yaml::function::get_parameter")
    end

    it '.order' do
        service = _get_service
    
        expect(service.order).to eq(50)
    end

  end

  context '.process' do 
    it 'can replace parameters' do
        service = _get_service

        data_set = [
            {
                in: { 
                    "Parameters" => {
                        "MyParam1" => "VeryTop1",
                        "MyNestedParam1" => "VeryNested1",
                    },
                    "Resources" => {
                        "Parameters" => {
                            "MyParam1" => "Top1",
                            "MyParam2" => "Top2",
                            "MyNestedParam1" => "Nested1",
                            "MyNestedParam2" => "Nested2"
                        },
                        "TopParams" =>  {
                            "TopProp1" => "Fn::GetParameter MyParam1",
                            "TopProp2" => "Fn::GetParameter MyParam2"
                        },
                        "Nested" => {
                            "MyProps" => {
                                "NestedProp1" => "Fn::GetParameter MyNestedParam1",
                                "TopProp2" => "Fn::GetParameter MyNestedParam2"
                            }
                        }
                    }
                    
                },
                out: {
                    "Parameters" => {
                        "MyParam1" => "VeryTop1",
                        "MyNestedParam1" => "VeryNested1",
                    },
                    "Resources" => {
                        "Parameters" => {
                            "MyParam1" => "Top1",
                            "MyParam2" => "Top2",
                            "MyNestedParam1" => "Nested1",
                            "MyNestedParam2" => "Nested2"
                        },
                        "TopParams" =>  {
                            "TopProp1" => "VeryTop1",
                            "TopProp2" => "Top2"
                        },
                        "Nested" => {
                            "MyProps" => {
                                "NestedProp1" => "VeryNested1",
                                "TopProp2" => "Nested2"
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

    it 'can replace tokens' do
        service = _get_service

        data_set = [
            {
                in: { 
                    "Parameters" => {
                        "MyParam1" => "VeryTop1",
                        "MyNestedParam1" => "VeryNested1",
                    },
                    "Resources" => {
                        "Parameters" => {
                            "MyParam1" => "Top1",
                            "MyParam2" => "Top2",
                            "MyNestedParam1" => "Nested1",
                            "MyNestedParam2" => "Nested2"
                        },
                        "TopParams" =>  {
                            "TopProp1" => "${GetParameter:MyParam1}",
                            "TopProp2" => "${GetParameter:MyParam2}"
                        },
                        "Nested" => {
                            "MyProps" => {
                                "NestedProp1" => "${GetParameter:MyNestedParam1}",
                                "TopProp2" => "${GetParameter:MyNestedParam2}"
                            }
                        },
                        "ArrayProperty" => [
                            "${GetParameter:MyNestedParam1}",
                            "${GetParameter:MyNestedParam2}",
                            "1-${GetParameter:MyNestedParam1}",
                            "2-${GetParameter:MyNestedParam2}"
                        ]
                    }
                    
                },
                out: {
                    "Parameters" => {
                        "MyParam1" => "VeryTop1",
                        "MyNestedParam1" => "VeryNested1",
                    },
                    "Resources" => {
                        "Parameters" => {
                            "MyParam1" => "Top1",
                            "MyParam2" => "Top2",
                            "MyNestedParam1" => "Nested1",
                            "MyNestedParam2" => "Nested2"
                        },
                        "TopParams" =>  {
                            "TopProp1" => "VeryTop1",
                            "TopProp2" => "Top2"
                        },
                        "Nested" => {
                            "MyProps" => {
                                "NestedProp1" => "VeryNested1",
                                "TopProp2" => "Nested2"
                            }
                        },
                        "ArrayProperty" => [
                            "VeryNested1",
                            "Nested2",
                            "1-VeryNested1",
                            "2-Nested2"
                        ]
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