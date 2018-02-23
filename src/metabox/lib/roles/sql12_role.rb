
require_relative 'sql_role'

include Metabox::Roles

module Metabox
    module Roles

        class Sql12Role < SqlRole

            def self.default(&block)
              result = Sql12Role.new(&block)
            end
          
            def name 
              "metabox-sql12"
            end
          
            def _init_properties
              super
              
              @sql_resource_name = "sql2012sp2"
            end
          
          end

    end

end