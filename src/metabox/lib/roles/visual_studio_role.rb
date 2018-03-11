
require_relative 'role_base'

include Metabox::Roles

module Metabox
    module Roles

       

        class VisualStudioRole < RoleBase

            attr_accessor :dc_short_name 

            attr_accessor :vs_product_name
            attr_accessor :vs_resource_name 

            attr_accessor :vs_test_product_name 
            attr_accessor :vs_test_officetools_package_name 

            def self.default(&block)
              result = VisualStudioRole.new(&block)
              result
            end
          
            def name 
              "metabox-visual-studio"
            end
          
            def _init_properties
              super
            end
          
            def validate(vagrant_host:)

              if @dc_short_name.nil?
                @dc_short_name = vagrant_host.stack.dc_short_name
              end

              raise "dc_short_name" if @dc_short_name.nil?

              raise "vs_product_name" if @vs_product_name.nil?
              raise "vs_resource_name" if @vs_resource_name.nil?

              raise "vs_test_product_name" if @vs_test_product_name.nil?
              raise "vs_test_officetools_package_name" if @vs_test_officetools_package_name.nil?
            end
          
            def configure(vagrant_host:)
            
              vagrant_host.add_configs([
                {
                  "Type" => "metabox::vagrant::shell",
                  "Name" => "vs installation media",
                  "Tags" => [ "vs_bin" ],
                  "Properties" => {
                    "path" => "./scripts/packer/metabox.packer.core/_metabox_dist_helper.ps1",
                    "env" => [
                      "METABOX_RESOURCE_NAME=#{@vs_resource_name}"
                    ]
                  }
                },
                
                {
                  "Type" => "metabox::vagrant::visual_studio13",
                  "Name" => "vs isntall",
                  "Tags" => [ "vs_install" ],
                  "Properties" => {
                    "vs_domain_user_name" =>  "#{@dc_short_name}\\vagrant",
                    "vs_domain_user_password" => "vagrant",

                    "dsc_check" => "1",
                    "execute_tests" => @execute_tests,

                    "vs_executable_path" => "c:\\_metabox_resources\\#{@vs_resource_name}",
                    "vs_product_name" => @vs_product_name,

                    "vs_test_product_name" => @vs_test_product_name,
                    "vs_test_officetools_package_name" => @vs_test_officetools_package_name
                  }
                }
                
              ])
            end
          
          end
          

    end

end