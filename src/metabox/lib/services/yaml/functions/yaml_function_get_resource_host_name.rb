require 'yaml'

require_relative 'yaml_function_service_base'

module Metabox
    class YamlFunctionGetResourceHostName < YamlFunctionServiceBase

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
                "Fn::GetResourceHostName",
                "!GetResourceHostName"
            ]
        end

        def _lookup_parameter(tree:, name:)
            env_name = get_first_tree_environment_section_name(tree: tree)
            vm_name = name

            service = get_service_by_name("metabox::vagrant::config::base")
            result = service.get_host_name(environment_name: env_name, vm_name: vm_name)
            
            return result
        end
        
    end
end
