
require_relative 'sql_role'

include Metabox::Roles

module Metabox
    module Roles

        class Sql14Role < SqlRole

            def self.default(&block)
              result = Sql12Role.new(&block)
              result
            end
          
            def name 
              "metabox-sql14"
            end
          
            def _init_properties
              super 

              @sql_resource_name = "sql2014sp1"
            end
          
          end

    end

end