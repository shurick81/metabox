require_relative "../../spec_helper"

RSpec.describe Metabox::YamlConfigService do
  
  def _get_service 
    Metabox::YamlConfigService.new
  end

  def _get_yaml_config_files
    Dir.glob("#{SPEC_DOCUMENTS_DATA_DIR}/**/*.yaml")
  end

  context '.initialize' do 
    it 'can create service' do
      service = _get_service
  
      expect(service).not_to be nil
    end
  end

  def _get_yaml_files(contains) 

    result = []

    file_paths = _get_yaml_config_files

    file_paths.each do | file_path |

      if file_path.include?(".expected.") || !file_path.include?("intrinsic-functions")
        next
      end

      if !file_path.include? contains
        next
      end

      result << file_path
      
    end

    result
    
  end

  def _load_expected_config(file_path) 
    # compare with expected YAML document
    expected_file_path = file_path.gsub('.yaml', '.expected.yaml')

    if !File.exist? expected_file_path
      raise "Cannot find 'expected' YAML file for: #{file_path}"
    end

    expected_hash = YAML.load_file(expected_file_path)
  end

  def _test_config(config:, expected_config:)

    puts "Processed config:"
    puts config.to_yaml
    puts '-----------------'
    puts "Expected config:"
    puts expected_config.to_yaml

    expect(config).to eq(expected_config)
  end

  context 'intrinsic-functions' do 

    it 'Fn::GetParameter - from parent sections' do
      service = _get_service
      file_paths = _get_yaml_files("parameter-from-parent-sections")
      
      file_paths.each do | file_path |

        config = service.load(file_path)
        expected_config = _load_expected_config(file_path)

        # base checks
        expect(config).not_to be nil
        expect(config.class).to eq(Hash)
        
        _test_config(config: config, expected_config: expected_config)
      end
    end

    it 'Fn::GetResourceProperty - from other resource' do
      service = _get_service
      file_paths = _get_yaml_files("property-from-other-resource")
      
      file_paths.each do | file_path |

        config = service.load(file_path)
        expected_config = _load_expected_config(file_path)

        # base checks
        expect(config).not_to be nil
        expect(config.class).to eq(Hash)
        
        _test_config(config: config, expected_config: expected_config)
      end
    end

    it 'Fn::GetResourceParameter - from current resource' do
      service = _get_service
      file_paths = _get_yaml_files("parameter-from-resource-current")
      
      file_paths.each do | file_path |

        config = service.load(file_path)
        expected_config = _load_expected_config(file_path)

        # base checks
        expect(config).not_to be nil
        expect(config.class).to eq(Hash)
        
        _test_config(config: config, expected_config: expected_config)
      end
    end

    it 'Fn::Join' do
      service = _get_service
      file_paths = _get_yaml_files("array")
      
      file_paths.each do | file_path |

        config = service.load(file_path)
        expected_config = _load_expected_config(file_path)

        # base checks
        expect(config).not_to be nil
        expect(config.class).to eq(Hash)
        
        _test_config(config: config, expected_config: expected_config)
      end
    end

    it 'Fn::Env' do
      service = _get_service
      file_paths = _get_yaml_files("environment")
      
      file_paths.each do | file_path |

        _env = {
          "TopValue" => "TopValue1",
          "TopParameterValue" => "TopParameterValue1",
          "ResourceParameterName" => "ResourceParameterName1",
          "PropertyValueFunction" => "PropertyValueFunction1",
          "PropertyValueToken" => "PropertyValueToken1",
          "PropertyNameToken" => "PropertyNameToken1"
        }

        env_service = Metabox::ServiceContainer.instance.get_service(Metabox::EnvironmentService)

        allow(env_service).to receive(:get_env_variables).and_return(_env)
        
        config = service.load(file_path)
        expected_config = _load_expected_config(file_path)

        # base checks
        expect(config).not_to be nil
        expect(config.class).to eq(Hash)

        # compare with expected YAML document
        expected_file_path = file_path.gsub('.yaml', '.expected.yaml')

        if !File.exist? expected_file_path
          raise "Cannot find 'expected' YAML file for: #{file_path}"
        end

        _test_config(config: config, expected_config: expected_config)
      end
    end
 
  end

end