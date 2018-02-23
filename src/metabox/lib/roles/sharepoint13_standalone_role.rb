
require_relative 'sharepoint_role'

include Metabox::Roles

module Metabox
    module Roles

        class SharePoint13_Standalone_Role < SharePointRole

            def self.default(&block)
              result = SharePoint13_Standalone_Role.new(&block)
              result
            end
          
            def name 
              "metabox-sharepoint13-standalone"
            end
          
            def _init_properties
              super
              
              @sp_version = "sp2013"
              @sp_role    = [ "wfe" ]
            end
          
          end
          

    end

end