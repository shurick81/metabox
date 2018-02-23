
require_relative 'role_base'

include Metabox::Roles

module Metabox
    module Roles

        class Win12SOERole < RoleBase

            def self.default(&block)
              result = Win12SOERole.new(&block)
            end
          
            def name 
              "metabox-win12-soe"
            end
          
            def _init_properties
              super
            end
          
            def validate
              
            end
          
            def configure(vagrant_host:)
            
              vagrant_host.add_configs([
                {
                  "Type" => "metabox::vagrant::win12soe",
                  "Name" => "SOE config",
                  "Tags" => [ "soe" ],
                  "Properties" => {
                    "execute_tests" => @execute_tests
                  }
                } 
              ])
            end
          
          end
          

    end

end