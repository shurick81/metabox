require_relative "../../../spec_helper"

RSpec.describe Metabox::PackerConfigBase do
  
  def _get_service 
    Metabox::PackerConfigBase.new
  end

  context '.initialize' do 
    it 'can create service' do
      service = _get_service
  
      expect(service).not_to be nil
    end
  end

  def _test_configs(config:, packer_config:)

    puts "------------------------------------------------------------------------------------------"
    puts "GENERATED:"
    puts config.to_yaml

    puts "------------------------------------------------------------------------------------------"
    puts "EXPECTED:"
    puts packer_config.to_yaml
    puts "------------------------------------------------------------------------------------------"

    expect(packer_config).to eq(config)
  end

  def _get_document_files
    Dir.glob("#{SPEC_PACKER_DATA_DIR}/**/*.yaml")
  end

  def _get_yaml_files(contains) 

    result = []

    file_paths = _get_document_files

    file_paths.each do | file_path |

      if !file_path.include? contains
        next
      end

      result << file_path
      
    end

    result
    
  end

  context '.configure' do 
    it 'can configure null template' do
      service = _get_service
  
      config = {}
      packer_config = {}

      service.configure(config: config, packer_config: packer_config)
      
      expect(packer_config).to eq({})
    end

    it 'can configure raw template' do
      service = _get_service
  
      config = {
        'variables' => {
          'a' => 1,
          'b' => 2
        },
        'builders' => [
          {
            "type" => "vagrant",
            "box_name" => "geerlingguy/centos7"
          }
        ],
        "provisioners" => [
          {
            "type" => "shell"
          }
        ],
        "post-processors" => [
          {
            "type" => "vagrant",
            "keep_input_artifact" => false,
            "output" => "centos7-mb-canary-{{ user `metabox_git_branch` }}-{{.Provider}}.box"
          }
        ]
      }
      packer_config = {}
      expected = config

      service.configure(config: config, packer_config: packer_config)
      _test_configs(config: packer_config, packer_config: config)
    end

  end

  def _test_configs(config:, packer_config:)

    puts "------------------------------------------------------------------------------------------"
    puts "GENERATED:"
    puts packer_config.to_yaml

    puts "------------------------------------------------------------------------------------------"
    puts "EXPECTED:"
    puts config.to_yaml
    puts "------------------------------------------------------------------------------------------"

    expect(packer_config).to eq(config)
  end

  def _run_yaml_test(contains) 
    yaml_files = _get_yaml_files contains
      yaml_files.each do | file_path | 

        yaml_data = YAML.load_file(file_path)
        expected_packer_config =JSON.parse(File.read(file_path.gsub('.yaml', '.json')))

        yaml_data["Documents"].each { | name, value | 
          yaml_raw = value
          puts "Testing YAML: #{name}"

          packer_config = {}
          service = _get_service

          service.configure(config: yaml_raw, packer_config: packer_config)
          _test_configs(config: expected_packer_config, packer_config: packer_config)
        }
      end
  end

  context '.configre integration' do
    
    it 'centos7-mb-canary.yaml' do
      _run_yaml_test 'centos7-mb-canary.yaml'
    end

    it 'centos7-mb-canary.yaml' do
      _run_yaml_test 'centos7-mb-java8.yaml'
    end

    it 'centos7-mb-canary.yaml' do
      _run_yaml_test 'centos7-mb-jenkins2.yaml'
    end

    it 'win2012-r2-mb-soe.yaml' do
      _run_yaml_test 'win2012-r2-mb-soe.yaml'
    end

    it 'win2012-r2-mb-app.yaml' do
      _run_yaml_test 'win2012-r2-mb-app.yaml'
    end

    it 'win2012-r2-mb-bin-sp13.yaml' do
      _run_yaml_test 'win2012-r2-mb-bin-sp13.yaml'
    end

  end

end