
require_relative 'role_base'

include Metabox::Roles

module Metabox
    module Roles

        class SharePointRole < RoleBase

            attr_accessor :sp_version 
            attr_accessor :sp_role

            attr_accessor :sp_farm_sql_server_host_name 
            attr_accessor :sp_farm_sql_db_prefix 
            
            attr_accessor :sp_farm_passphrase 

            attr_accessor :sp_setup_user_name 
            attr_accessor :sp_setup_user_password 
          
            def self.default(&block)
              result = SharePointRole.new(&block)
              result
            end
          
            def name 
              "metabox-sharepoint"
            end
          
            def _init_properties
              super

              @sp_farm_passphrase = @default_dc_domain_admin_password
            end
          
            def validate(vagrant_host:)

              if @sp_setup_user_name.nil?
                @sp_setup_user_name = "#{vagrant_host.stack.dc_short_name}\\vagrant"
              end

              if @sp_setup_user_password.nil?
                @sp_setup_user_password = "vagrant"
              end

              if @sp_farm_sql_db_prefix.nil?
                @sp_farm_sql_db_prefix = vagrant_host.name 
              end

              raise "sp_version" if @sp_version.nil?
              raise "sp_role" if @sp_role.nil?

              raise "sp_farm_sql_server_host_name" if @sp_farm_sql_server_host_name.nil?
              raise "sp_farm_sql_db_prefix" if @sp_farm_sql_db_prefix.nil?
            
              raise "sp_farm_passphrase" if @sp_farm_passphrase.nil?
              
              raise "sp_setup_user_name" if @sp_setup_user_name.nil?
              raise "sp_setup_user_password" if @sp_setup_user_password.nil?
            end
          
            def configure(vagrant_host:)
            
              vagrant_host.add_configs([
                {
                  "Type" => "metabox::vagrant::sharepoint",
                  "Name" => "sharepoint install",
                  "Tags" => [ "sp_install" ],
                  "Properties" => {
                    "execute_tests" => @execute_tests,
              
                    "sp_version" => @sp_version,
                    "sp_role" => @sp_role,
              
                    "sp_farm_sql_server_host_name" => @sp_farm_sql_server_host_name,
                    "sp_farm_sql_db_prefix" => @sp_farm_sql_db_prefix,
              
                    "sp_farm_passphrase" => @sp_farm_passphrase,
              
                    "sp_setup_user_name" => @sp_setup_user_name,
                    "sp_setup_user_password" => @sp_setup_user_password      
                  }
                }

              ])
            end
          
          end
          

    end

end