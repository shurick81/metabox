
require_relative 'role_base'

include Metabox::Roles

module Metabox
    module Roles

        class WinDCJoinRole < RoleBase

            attr_accessor :dc_domain_name 
            attr_accessor :dc_join_user_name 
            attr_accessor :dc_join_user_password 

            def self.default(&block)
              result = WinDCJoinRole.new(&block)
              result
            end
          
            def name 
              "metabox-win-dc-join"
            end
          
            def _init_properties
              super

              @dc_join_user_name     = @default_dc_join_user_name
              @dc_join_user_password = @default_dc_join_user_password
            end
          
            def validate(vagrant_host:)
              if  @dc_domain_name.nil?
                @dc_domain_name = vagrant_host.stack.dc_domain_full_name
              end

              raise "dc_domain_name" if @dc_domain_name.nil?
              raise "dc_join_user_name" if @dc_join_user_name.nil?
              raise "dc_join_user_password" if @dc_join_user_password.nil?
            end
          
            def configure(vagrant_host:)
            
              vagrant_host.add_configs([
                {
                  "Type" => "metabox::vagrant::dcjoin",
                  "Name" => "DC Join",
                  "Tags" => [ "dc-join" ],
                  "Properties" => {
                    "execute_tests" => @execute_tests,

                    "dc_domain_name" => @dc_domain_name,
                    "dc_join_user_name" => @dc_join_user_name,
                    "dc_join_user_password" => @dc_join_user_password
                  }
                } 
              ])
            end
          
          end
          

    end

end