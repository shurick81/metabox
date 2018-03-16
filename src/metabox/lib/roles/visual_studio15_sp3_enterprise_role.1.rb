
require_relative 'visual_studio_role'

include Metabox::Roles

module Metabox
    module Roles

      class VisualStudio17_Role < VisualStudioRole

        def self.default(&block)
          result = VisualStudio17_Role.new(&block)
          result
        end
        
        def _init_properties
          super
          
          @vs_resource_name                 = "vs2015.3_ent_enu"
          @vs_product_name                  = "Microsoft Visual Studio Enterprise 2017"
        
          @vs_test_product_name             = "Microsoft Visual Studio Enterprise 2017"
          @vs_test_officetools_package_name = "Microsoft Office Developer Tools for Visual Studio 2017"
        end
      end
        
    end

end