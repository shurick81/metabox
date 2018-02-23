
module Metabox

    class ResourceEnvironmentService < EnvironmentService
        
        def name 
            "metabpx::core::resource_environment"
        end

        def method_missing(method_name, *args, &block)  
            
            result = nil

            if !method_name.nil? && !method_name.to_s.empty?
                log.debug "fetching ENV variable: #{method_name.to_s} additional args were: #{args}"
                result = ENV[method_name.to_s]
            else
                log.debug "missing method does not correspons to ENV variable: #{method_name} additional args were: #{args}"
            end

            if result.nil? && (!args.nil? && args.count > 0 && !args[0].nil? && !args[0].to_s.empty?)
                default_result = args[0].to_s

                log.debug "cannot find ENV variable: #{method_name}, fall back on defailt value: #{default_result}"
                result = default_result
            else 
                if result.nil?
                    log.debug "cannot find ENV variable: #{method_name}, no default value were provided either"
                end
            end

            return result
        end 
    end

end