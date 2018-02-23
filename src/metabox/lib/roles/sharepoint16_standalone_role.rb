
require_relative 'sharepoint_role'

include Metabox::Roles

module Metabox
    module Roles

        class SharePoint16_Standalone_Role < SharePointRole

            def self.default(&block)
              result = SharePoint16_Standalone_Role.new(&block)
              result
            end
          
            def name 
              "metabox-sharepoint16-standalone"
            end
          
            def _init_properties
              super
              
              @sp_version = "sp2016"
              @sp_role    = [ "wfe" ]
            end
          
          end
          

    end

end