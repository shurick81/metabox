


module Metabox
    module Roles

        class RoleBase 

            attr_accessor :execute_tests 
            attr_accessor :dsc_check

            attr_accessor :default_dc_domain_admin_name
            attr_accessor :default_dc_domain_admin_password

            attr_accessor :default_sql_instance_name
            attr_accessor :default_sql_instance_features
            attr_accessor :default_sql16_instance_features

            def initialize(&block)
                
                _init_properties
            
                if block_given?
                    (block.arity < 1 ? (instance_eval &block) : block.call(self)) 
                end 
            end
        
            def _init_properties
                @dsc_check = 1
                @execute_tests = true

                @default_dc_domain_admin_name       = "admin" 
                @default_dc_domain_admin_password   = "u8wxvKQ2zn"

                @default_dc_join_user_name          = @default_dc_domain_admin_name
                @default_dc_join_user_password      = @default_dc_domain_admin_password

                @default_sql_instance_name          = "MSSQLSERVER"
                @default_sql_instance_features      = "SQLENGINE,SSMS,ADV_SSMS"
                @default_sql16_instance_features    = "SQLENGINE,CONN,REPLICATION,FULLTEXT"
            end
        
            def validate(vagrant_host:)
        
            end

            def configure(vagrant_host:)

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