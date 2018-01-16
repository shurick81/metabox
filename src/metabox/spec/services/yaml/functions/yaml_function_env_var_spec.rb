require_relative "../../../spec_helper"

RSpec.describe Metabox::YamlFunctionEnvVar do
  
  def _get_service 
    Metabox::YamlFunctionEnvVar.new
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
  
      expect(service.name).to eq("yaml::function::env_var")
    end

    it '.order' do
        service = _get_service
    
        expect(service.order).to eq(10)
    end

  end

  def _test_dataset(data_set)

    service = _get_service

    data_set.each do | data | 

        allow(service).to receive(:_env).and_return(data[:env])

        result = ObjectUtils.deep_clone(data[:in])

        service.process(result)
        expect(result).to eq(data[:out])

    end
  end

  context '.process' do 
    it 'can replace two values' do
        
        data_set = [
            #properry value
            {
                env: {
                    'TopValue' => "TopValue-Value",
                    'NestedValue' => "NestedValue-Value",
                },
                in: { 
                    "MyProp" => "${ENV:TopValue}",
                    "Nested" => {
                        "MyNestedProp" => "${ENV:TopValue}-${ENV:NestedValue}"
                    }
                },
                out: { 
                    "MyProp"  => "TopValue-Value",
                    "Nested" => {
                        "MyNestedProp" =>  "TopValue-Value-NestedValue-Value"
                    }
                }
            }
        ]

        _test_dataset(data_set)
        
    end

    it 'can replace property value' do
        
        data_set = [
            #properry value
            {
                env: {
                    'TopValue' => "TopValue-Value",
                    'NestedValue' => "NestedValue-Value",
                },
                in: { 
                    "MyProp" => "${ENV:TopValue}",
                    "Nested" => {
                        "MyNestedProp" => "${ENV:NestedValue}"
                    }
                },
                out: { 
                    "MyProp"  => "TopValue-Value",
                    "Nested" => {
                        "MyNestedProp" =>  "NestedValue-Value"
                    }
                }
            },

            # property name - value
            {
                env: {
                    'TopValue' => "TopValue-Value",
                    'NestedValue' => "NestedValue-Value",

                    'TopSectionName' => "TopSectionName-Value",
                    'NestedSectionName' => "NestedSectionName-Value",
                },
                in: { 
                    "${ENV:TopSectionName}" => "${ENV:TopValue}",
                    "Nested" => {
                        "${ENV:NestedSectionName}" => "${ENV:NestedValue}"
                    }
                },
                out: { 
                    "TopSectionName-Value" => "TopValue-Value",
                    "Nested" => {
                        "NestedSectionName-Value" => "NestedValue-Value"
                    }
                }
            },

            # function shortcut
            {
                env: {
                    'TopValue' => "TopValue-Value",
                    'NestedValue' => "NestedValue-Value",

                    'TopSectionName' => "TopSectionName-Value",
                    'NestedSectionName' => "NestedSectionName-Value",
                },
                in: { 
                    "Fn::Env TopSectionName" => "Fn::Env TopValue",
                    "Nested" => {
                        "Fn::Env NestedSectionName" => "Fn::Env NestedValue"
                    }
                },
                out: { 
                    "TopSectionName-Value" => "TopValue-Value",
                    "Nested" => {
                        "NestedSectionName-Value" => "NestedValue-Value"
                    }
                }
            }
        ]

        _test_dataset(data_set)
      
  
    end
  end

end