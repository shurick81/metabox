


module Metabox
    module Roles

        class RoleBase 

            attr_accessor :execute_tests 
            attr_accessor :dsc_check

            def initialize(&block)
                
                _init_properties
            
                if block_given?
                    (block.arity < 1 ? (instance_eval &block) : block.call(self)) 
                end 
            end
        
            def _init_properties
                @dsc_check = 1
                @execute_tests = true
            end
        
            def validate 
        
            end

            def services 
                Metabox::ServiceContainer.instance
            end

            def get_service_by_name(service_name)
                services.get_service_by_name(service_name)
            end

            def log
                services.get_service(Metabox::LogService) 
            end
        
        end

    end
end