require 'yaml'

require_relative 'yaml_function_service_base'

module Metabox

    class YamlFunctionGetParameter < YamlFunctionServiceBase

        def name
            "yaml::function::get_parameter"
        end

        def order
            50
        end

        private

        def function_aliases
            [
                "Fn::GetParameter",
                "!GetParameter"
            ]
        end

        def _process_simple_property(root:, tree:, name:, value:) 
            {
                name: name,
                value: _get_function_value(tree: tree, value: value)
            }
        end

        def _get_function_value(tree:, value:)
            # checking token, them return default lookup via "Fn::GetParameter"
            new_value = _lookup_token(tree: tree, value: value)
            log.verbose "new_value: #{new_value}, value: #{value}"

            if (value != new_value)
                log.verbose "returning token based match"
                return new_value
            end

            log.verbose "falling back to Fn:: based match"
            super
        end

        def _lookup_token(tree:, value:)

            if !value.is_a? String
                return value
            end

            match_result = value.scan(/(GetParameter:[a-zA-Z_0-9]+)/)

            if match_result.nil? || match_result.empty? 
                return value
            end

            match_result.each do | match_result_data_array |

                match_result_data = match_result_data_array.first
                value_name = match_result_data.gsub('${','').gsub('}','').split(':')[1]

                value_value = _lookup_parameter(tree: tree, name: value_name)

                log.verbose "Replacing token: #{value} -> #{value_value}"
                value = value.gsub("${GetParameter:#{value_name}}", value_value)
                log.verbose " #{value}"
            end

            return value
        end

        def _lookup_parameter(tree:, name: )
            sections = _get_tree_parameter_sections(tree: tree)

            result = nil
            log.verbose sections.to_yaml

            sections.each do | node_value |
                section = node_value[:value]
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
