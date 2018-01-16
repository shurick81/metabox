require 'yaml'

require_relative 'yaml_function_service_base'

module Metabox
    class YamlFunctionEnvVar < YamlFunctionServiceBase

        def name
            "yaml::function::env_var"
        end

        def order
            10
        end

        def function_aliases
            [
                "Fn::Env",
                "!Env"
            ]
        end

        private

        def _process_array_property(root:, tree:, name:, value:) 
            {
                name: _get_replaced_env_varaible(name),
                value: value
            }
        end

        def _process_hash_property(root:, tree:, name:, value:) 
            {
                name: _get_replaced_env_varaible(name),
                value: value
            }
        end

        def _process_simple_property(root:, tree:, name:, value:) 
            {
                name: _get_replaced_env_varaible(name),
                value: _get_replaced_env_varaible(value)
            }
        end

        def _fetch_env_variable(value_name:) 
            
            if value_name.upcase == "METABOX_GIT_BRANCH"
                return _get_metabox_env_variables["METABOX_GIT_BRANCH"]
            end

            env_value = nil

            if _env.keys.include? value_name
                env_value = _env[value_name]

                if env_value.nil?
                    error_message = "Environment variable is nil or empty: #{value_name}"
                    log.error error_message
    
                    raise error_message
                end

                
            else
                error_message = "Environment variable is nil or empty: #{value_name}"
                log.error error_message

                raise error_message
            end

            if env_value.include? "~/"
                env_value = File.expand_path env_value
            end

            env_value
        end

        def _lookup_function(value)

            function_aliases.each do | function_aliase |
            
                if( !value.include? function_aliase)
                    next
                end

                value_name = value.split(function_aliase)[1].strip
                value_value = _fetch_env_variable(value_name: value_name)

                return value_value
            end

            return value
        end

        def _lookup_token(value)
            match_result = value.scan(/(ENV:[a-zA-Z_]+)/)

            if match_result.nil? || match_result.empty? 
                return value
            end

            match_result.each do | match_result_data_array |

                match_result_data = match_result_data_array.first

                value_name = match_result_data.gsub('${','').gsub('}','').split(':')[1]
                value_value = _fetch_env_variable(value_name: value_name)

                log.verbose "Replacing ENV value: #{value_name} -> #{value_value}"
                
                value = value.gsub("${ENV:#{value_name}}", value_value)
            end

            return value
        end

        def _get_replaced_env_varaible(value)
            
            result = value
           
            if(value != nil && value.is_a?(String))
                new_value = _lookup_token(value)
                new_value = _lookup_function(new_value)

                if new_value != value
                    result = new_value
                end
            end

            result
        end

    end
end
