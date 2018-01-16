require_relative 'vagrant_config_base.rb'

module Metabox

    module VagrantConfigs

        class VagrantSQL12Config < VagrantConfigBase

            def initialize

            end

            def name 
                "metabox::vagrant::sql12"
            end

            def configure_host(config:, vm_config:)

                if !should_run?(config: config) 
                    return 
                end

                _configire_sql(config: config, vm_config: vm_config)
            end
          
            def _configire_sql(config:, vm_config:)
                
                default_properties = {
                    "sql_instance_name" => "MSSQLSERVER",
                    "sql_instance_features" => "SQLENGINE,SSMS,ADV_SSMS"
                }

                _safe_merge_hash(default_properties, 
                                 ObjectUtils.deep_clone(config.fetch('Properties', {})))
                
                sql_sys_admin_accounts = [
                    default_properties.fetch('sql_sys_admin_accounts')
                ].join(',')

                default_properties["sql_sys_admin_accounts"] = sql_sys_admin_accounts
            
                env = _get_metabox_env(default_properties)

                vm_config.vm.provision "shell", path: get_handler_script_path("sql.dsc.ps1"), env: env
            
                execute_tests config: config, 
                              vm_config: vm_config, 
                              paths: "#{get_handler_tests_scripts_path}/sql.dsc.*"
                 
            end

        end

    end

end