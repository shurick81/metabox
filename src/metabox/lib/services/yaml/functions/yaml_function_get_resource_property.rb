require 'yaml'

require_relative 'yaml_function_service_base'

module Metabox
    class YamlFunctionGetResourceProperty < YamlFunctionServiceBase

        def name
            "yaml::function::get_resource_property"
        end

        def order
            70
        end

        def _process_simple_property(root:, tree:, name:, value:) 
            {
                name: name,
                value: _get_function_value(tree: tree, value: value)
            }
        end

        def _get_function_value(tree:, value:)

            if value.is_a?(String) && value.include?("Fn::GetResourceProperty")
                function_param = value.split('Fn::GetResourceProperty')[1].strip
                function_value = _lookup_parameter(tree: tree, name: function_param)

                return function_value
            end

            return value
        end
        
        def _lookup_parameter(tree:, name:)
            
            params_paths = name.split('.')
            log.info "Looking for param: #{name} as Resourses: #{params_paths}"

            resource_section = _get_first_tree_resource_sections(tree: tree)
            result = resource_section

            params_paths.each do | params_path |
                result = result[params_path]
            end
            
            if result.nil?
                raise "Cannot find value for parameter: #{name}"
            end

            log.debug "returning: #{result}"
            return result
        end
        
    end
end
