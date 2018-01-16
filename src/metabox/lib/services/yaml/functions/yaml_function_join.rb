require 'yaml'

require_relative 'yaml_function_service_base'

module Metabox
    class YamlFunctionJoin < YamlFunctionServiceBase

        def name
            "yaml::function::join"
        end

        def order
            20
        end

        private

        def function_aliases
            [
                "Fn::Join",
                "!Join"
            ]
        end

        def _process_hash_property(root:, tree:, name:, value:) 
            
            function_aliases.each do | function_aliase |
                if(value.is_a?(Hash) && value.keys.first == function_aliase)

                    log.info "Detected !Join"
                    log.debug "#{name} -> #{value}"

                    join_value = _calculate_join(join_hash: value[function_aliase])

                    return {
                        :name => name,
                        :value => join_value
                    }
                end
            end

            return {
                :name => name,
                :value => value
            }
        end

        def _calculate_join(join_hash:) 
            delemiter = join_hash[0]
            values = join_hash[1]

            return values.join(delemiter)
        end
       
    end
end
