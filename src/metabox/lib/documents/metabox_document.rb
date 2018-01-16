
require 'yaml'

module Metabox
    
    class MetaboxDocument < ServiceBase
        
        @hash;
        @path;

        def name 
            "metabox::documents::metabox_document"
        end

        def load(file_path)
            log.debug "Loading document from path: #{file_path}"
            
            @path = file_path
            begin
                parse(File.read(file_path))
            rescue => yaml_file_exception
                log.error "Error while parsing YAML file: #{file_path}"
                raise yaml_file_exception
            end
        end

        def parse(yaml_string)
            @hash = nil

            begin
                @hash = YAML.load(yaml_string)
            rescue => yaml_load_exception
                log.error "Error while parsing YAML!"
                raise yaml_load_exception
            end
            
            yaml_service.process_hash(@hash)
            _validate_document(@hash)

            @hash
        end

        def path
            @path
        end

        def document_hash
            @hash
        end
        
        def description
            _get_section_value(@hash, "Metabox.Description", "")
        end

        def packer_build_resources
            _get_resource_by_type("metabox::packer::build")
        end

        def revision_resources
            _get_resource_by_type("vagrant::revision")
        end

        def vagrant_environment_resources
            _get_resource_by_type("vagrant::stack")
        end

        def download_file_set_resources
            _get_resource_by_type("metabox::http::file_set")
        end

        def download_files_resources
            result = {}
            filesets = download_file_set_resources

            filesets.each  { | fileset_name, fileset_value |
                    
                resources = fileset_value.fetch('Resources', {})

                resources.each { | resource_name, resource_value|
                    result[fileset_name + "::" + resource_name] = resource_value
                }
            }

            result
        end

        def vagrant_vm_resources
            result = {}
            vagrant_envs = vagrant_environment_resources

            vagrant_envs.each  { | env_name, env_value |
                    
                resources = env_value.fetch('Resources', {})

                resources.each { | resource_name, resource_value|
                    result[env_name + "::" + resource_name] = resource_value
                }
            }

            result
        end

        def resources
            _get_section_value(@hash, "Metabox.Resources", {})
        end

        def all_resources
            _get_section_value(@hash, "Metabox.Resources", {})
        end
        
        def to_s
            result = []

            if !@path.nil?
                result << "Document path: #{@path}"
            end

            result << "     Description: #{description}"

            typed_resources = all_resources.group_by { |k,v| v.fetch('Type') }
            typed_resources.keys.each do | resource_type |
                result = result + _get_resource_to_s_value(resource_type, typed_resources[resource_type])
            end

            return result.join("\n")
        end

        def self.from_file(file_path)
            result = MetaboxDocument.new
            result.load(file_path)

            result
        end

        def self.from_yaml(yaml_string)
            result = MetaboxDocument.new
            result.parse(yaml_string)

            result
        end

        private 

        def _get_resource_to_s_value(resource_type_name, resource_hash)
            result = []

            result << "     #{resource_type_name}: #{resource_hash.count} resources"
            resource_hash.each { | key, value|
                result << "         #{key}"
                result = result + _get_nested_resource_to_s_value(key, value)
            }

            return result
        end

        def _get_nested_resource_to_s_value(parent_resource_name, parent_resource_hash)
            result = []
            
            nested_resources = parent_resource_hash.fetch('Resources', nil)

            if !nested_resources.nil? && nested_resources.count > 0

                # hit for _all
                result << "         - #{parent_resource_name}::_all (alias to invoke operation on all VMs in stack)"

                # all nested resources
                nested_resources.each { | nested_resource_key, nested_resource_name |
                    full_name = "#{parent_resource_name}::#{nested_resource_key}"
                    result << "         - #{full_name}"
                }

            end

            result
        end

        def _get_resource_by_type(type_name)
            resources = all_resources

            resources.select { |key, value| value.fetch('Type', nil) == type_name  }
        end

        def _validate_document(hash)
            _get_section_value(hash, "Metabox")
        end

        def _get_section_value(hash, path, default_value = nil)
            HashUtils.get_value_by_path(hash, path, default_value)
        end

    end

end