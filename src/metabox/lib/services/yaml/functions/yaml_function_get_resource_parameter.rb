require 'yaml'

require_relative 'yaml_function_service_base'

module Metabox
    class YamlFunctionGetResourceParameter < YamlFunctionServiceBase

        def name
            "yaml::function::get_resource_parameter"
        end

        def order
            40
        end

        def _process_simple_property(root:, tree:, name:, value:) 
            {
                name: name,
                value: _get_function_value(tree: tree, value: value)
            }
        end

        def function_aliases
            [
                "Fn::GetResourceParameter",
                "!GetResourceParameter"
            ]
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
