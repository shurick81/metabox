require_relative 'vagrant_config_base.rb'

module Metabox

    module VagrantConfigs

        class VagrantDC12Config < VagrantConfigBase

            def initialize

            end

            def name 
                "metabox::vagrant::dc12"
            end

            def configure_host(config:, vm_config:)

                if !should_run?(config: config) 
                    return 
                end
                
                host_ip = get_ip_address(environment_name: _get_environment_name, vm_name: _get_vm_name)
                vm_config.vm.provision "shell", path: "#{default_vagrant_scripts_path}/metabox.vagrant.core/metabox.fix-second-network.ps1", privileged: false, args: host_ip

                default_properties = {}

                _safe_merge_hash(default_properties, config.fetch('Properties', {}))               
                
                dc_domain_name = default_properties.fetch('dc_domain_name')

                # provision DCm, reload
                default_properties["dsc_check_skip"] = "1"
                domain_env = _get_metabox_env(default_properties)

                vm_config.vm.provision "shell", path: get_handler_script_path("dc.dsc.ps1"), env: domain_env
                vm_config.vm.provision "reload"

                default_properties["vagrant_user_name"] = dc_domain_name.split('.')[0] + "\\vagrant"
                default_properties["vagrant_user_password"] = "vagrant"
            
                # provision DC users
                default_properties.delete("dsc_check_skip")
                users_env = _get_metabox_env(default_properties)   

                vm_config.vm.provision "shell", path: get_handler_script_path("dc.users.dsc.ps1"), env: users_env
                #vm_config.vm.provision "reload"

            
                # execute tests
                execute_tests config: config, 
                              vm_config: vm_config, 
                              paths: "#{get_handler_tests_scripts_path}/dc.dsc.*"
    
            end


        end

    end

end