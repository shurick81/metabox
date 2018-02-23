
require_relative 'role_base'

include Metabox::Roles

module Metabox
    module Roles

        class SqlRole < RoleBase

            attr_accessor :sql_resource_name 

            attr_accessor :sql_instance_name
            attr_accessor :sql_instance_features 
            attr_accessor :sql_sys_admin_accounts 
          
            def self.default(&block)
              result = SqlRole.new(&block)
            end
          
            def name 
              "metabox-sql"
            end
          
            def _init_properties
              super 
              
              @sql_resource_name = "sql2012sp2"
              
              @sql_instance_name       = @default_sql_instance_name
              @sql_instance_features   = @default_sql_instance_features
             
              @sql_sys_admin_accounts = [
                "vagrant"
              ]
            end
          
            def validate(vagrant_host:)
              raise "sql_resource_name" if @sql_resource_name.nil?

              raise "sql_instance_name" if @sql_instance_name.nil?
              raise "sql_instance_features" if @sql_instance_features.nil?
              raise "sql_sys_admin_accounts" if @sql_sys_admin_accounts.nil?
            end
          
            def configure(vagrant_host:)
            
              vagrant_host.add_configs([
              {
                "Type" => "metabox::vagrant::shell",
                "Name" => "sql installation media",
                "Tags" => [ "sql_bin" ],
                "Properties" => {
                  "path" => "./scripts/packer/metabox.packer.core/_metabox_dist_helper.ps1",
                  "env" => [
                    "METABOX_RESOURCE_NAME=#{@sql_resource_name}"
                  ]
                }
              },
                
              {
                "Type" => "metabox::vagrant::sql12",
                "Name" => "sql isntall",
                "Tags" => [ "sql_install" ],
                "Properties" => {
                  "execute_tests" => true,

                  "sql_bin_path" =>  "c:\\_metabox_resources\\#{@sql_resource_name}",
                  "sql_instance_name" => @sql_instance_name,
                  "sql_instance_features" => @sql_instance_features,
                  "sql_sys_admin_accounts" => @sql_sys_admin_accounts,
                  "dsc_check" => @dsc_check
                }
              }
                
              ])
            end
          
          end
          

    end

end