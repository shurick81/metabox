require 'yaml'

require_relative 'yaml_function_service_base'

module Metabox
    class YamlFunctionGetHostName < YamlFunctionServiceBase

        def name
            "yaml::function::get_resource_parameter"
        end

        def order
            200
        end

        def _process_simple_property(root:, tree:, name:, value:) 
            {
                name: name,
                value: _get_function_value(tree: tree, value: value)
            }
        end

        def function_aliases
            [
                "Fn::GetHostName",
                "!GetHostName"
            ]
        end

        def _get_function_value(tree:, value:)
            
            function_aliases.each do | function_aliase |
                if value.is_a?(String) && value.include?(function_aliase)

                    service = get_service_by_name("metabox::vagrant::config::base")
                    
                    env_name = get_first_tree_environment_section_name(tree: tree)
                    vm_name = get_first_tree_vagrant_section_name(tree: tree)
           
                    function_value = service.get_host_name(environment_name: env_name, vm_name: vm_name)
                    
                    return function_value
                end
            end

            return value
        end

        def _lookup_parameter(tree:, name:)
            sections = _get_tree_parameter_sections(tree: tree)

            result = nil

            sections.each do | node_value |
                
                section = node_value[:value]
                section_name = node_value[:name]
                
                if( section_name == "Resources")
                    break
                end

                tmp_result = section.fetch(name, nil)

                if !tmp_result.nil?
                    result =  tmp_result
                end
            end

            if result.nil?
                raise "Cannot find parameter by name: #{name}"
            end
            
            return result
        end
        
    end
end
