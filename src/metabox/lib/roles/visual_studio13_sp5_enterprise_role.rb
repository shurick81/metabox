
require_relative 'visual_studio_role'

include Metabox::Roles

module Metabox
    module Roles

        class VisualStudio13_SP5_Enterprise_Role < VisualStudioRole

          def self.default(&block)
            result = VisualStudio13_SP5_Enterprise_Role.new(&block)
            result
          end

          def _init_properties
            super
            
            @vs_resource_name                 = "vs2013.5_ent_enu"
            @vs_product_name                  = "Microsoft Visual Studio Ultimate 2013 with Update 5"

            @vs_test_product_name             = "Microsoft Visual Studio Ultimate 2013 with Update 5"
            @vs_test_officetools_package_name = "Microsoft Office Developer Tools for Visual Studio"
          end
        end
        
    end

end