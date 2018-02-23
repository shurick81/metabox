
require_relative 'sql_role'

include Metabox::Roles

module Metabox
    module Roles

        class Sql16Role < SqlRole

            def self.default(&block)
              result = Sql16Role.new(&block)
            end
          
            def name 
              "metabox-sql16"
            end
          
            def _init_properties
              super
              
              @sql_resource_name = "sql2016"
            end
          
          end

    end

end