require_relative 'vagrant_config_base.rb'

module Metabox

    module VagrantConfigs

        class VagrantSharePointConfig < VagrantConfigBase

            def initialize

            end

            def name 
                "metabox::vagrant::sharepoint"
            end

            def configure_host(config:, vm_config:)
                
                if !should_run?(config: config) 
                    return 
                end

                _configire_sharepoint(config: config, vm_config: vm_config)
            end

            private
           
            def _configire_sharepoint(config:, vm_config:)

                props = {} 
                _safe_merge_hash(props, config.fetch('Properties', {}))

                sp_version = props.fetch('sp_version')
                sp_roles = props.fetch('sp_role')

                env = _get_metabox_env(props)

                case sp_version
                when "sp2013", "sp2016"
                    _configure_sharepoint_provision(
                        config: config, vm_config: vm_config, env: env, 
                        sp_version: sp_version, 
                        roles: sp_roles
                    )
                else
                    error_message = "Unsupported SharePoint version: #{sp_version}, should be 'sp2013/sp2016'"
                    raise error_message
                end

            end

            def _configure_sharepoint_provision(config:, vm_config:, env:, sp_version:, roles:)
               
                # shared scritps
                vm_config.vm.provision "file", 
                                        source: "#{get_handler_shared_path}/sp.helpers.ps1", 
                                        destination: "#{get_handler_host_shared_path}/sp.helpers.ps1"

                if sp_version == "sp2016" 
                    # provision, pre-setup 1
                    vm_config.vm.provision "shell", 
                                            path: get_handler_script_path("sp2016.pre_setup1.dsc.ps1"), 
                                            env: env

                    # reload
                    vm_config.vm.provision "reload"

                    # provision, pre-setup 2
                    vm_config.vm.provision "shell", 
                                            path: get_handler_script_path("sp2016.pre_setup2.dsc.ps1"), 
                                            env: env
                end

                # provision
                vm_config.vm.provision "shell", 
                                        path: get_handler_script_path("#{sp_version}.dsc.ps1"), 
                                        env: env

                # post-provision to bring up services
                vm_config.vm.provision "shell", 
                                        path: get_handler_script_path("#{sp_version}.post_setup.dsc.ps1"), 
                                        env: env
            
                # tests
                execute_tests config: config, 
                              vm_config: vm_config, 
                              paths: "#{get_handler_tests_scripts_path}/#{sp_version}.dsc.wfe.*"
            end
    
        end

    end

end