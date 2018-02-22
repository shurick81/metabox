
module Metabox

    class ResourceEnvironmentService < EnvironmentService
        
        def name 
            "metabpx::core::resource_environment"
        end

        def method_missing(method_name, *args, &block)  
            
            if !method_name.nil? && !method_name.to_s.empty?
                return ENV[method_name.to_s]
            end

            return nil
        end 
    end

end