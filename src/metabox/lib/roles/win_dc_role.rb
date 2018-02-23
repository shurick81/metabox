
require_relative 'role_base'

include Metabox::Roles

module Metabox
    module Roles

        class WinDCRole < RoleBase

            attr_accessor :dc_domain_name 
            attr_accessor :dc_domain_admin_name 
            attr_accessor :dc_domain_admin_password 

            def self.default(&block)
              result = WinDCRole.new(&block)
              result
            end
          
            def name 
              "metabox-win-dc"
            end
          
            def _init_properties
              super

              @dc_domain_admin_name     = @default_dc_domain_admin_name
              @dc_domain_admin_password = @default_dc_domain_admin_password
            end
          
            def validate(vagrant_host:)
              if  @dc_domain_name.nil?
                @dc_domain_name = vagrant_host.stack.dc_domain_full_name
              end

              raise "dc_domain_name" if @dc_domain_name.nil?
              raise "dc_domain_admin_name" if @dc_domain_admin_name.nil?
              raise "dc_domain_admin_password" if @dc_domain_admin_password.nil?
            end
            
            def configure(vagrant_host:)
            
              vagrant_host.add_configs([
                {
                  "Type" => "metabox::vagrant::dc12",
                  "Name" => "DC configuration",
                  "Tags" => [ "dc" ],
                  "Properties" => {
                    "execute_tests" => @execute_tests,

                    "dc_domain_name" => @dc_domain_name,
                    "dc_domain_admin_name" => @dc_domain_admin_name,
                    "dc_domain_admin_password" => @dc_domain_admin_password
                  }
                } 
              ])
            end
          
          end
          

    end

end