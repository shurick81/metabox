require_relative 'vagrant_config_base.rb'

module Metabox

    module VagrantConfigs

        class VagrantJoinDCConfig < VagrantConfigBase

            def initialize

            end

            def name 
                "metabox::vagrant::dcjoin"
            end

            def configure_host(config:, vm_config:)
             
                if !should_run?(config: config) 
                    return 
                end

                props = config.fetch('Properties')

                vm_name = _get_full_vm_name
                host_name = get_persisted_random_string(key: vm_name)
                host_ip = get_ip_address(environment_name: _get_environment_name, vm_name: _get_vm_name)
                
                dns_ip = get_environment_ip_range(name: _get_environment_name) + ".5"
                domain_host_ip = get_environment_ip_range(name: _get_environment_name) + ".5"
            
                vm_config.vm.provision "shell", path: "#{default_vagrant_scripts_path}/metabox.vagrant.core/metabox.fix-second-network.ps1", privileged: false, args: "-ip #{host_ip} -dns #{dns_ip}"
  
                props["dc_domain_host_ip"] = domain_host_ip
                props["host_name"] = host_name

                env = _get_metabox_env(props)

                log.debug "configuring dc join"
                log.debug " domain name: #{props.fetch('dc_domain_name')}"
                log.debug " domain ip: #{domain_host_ip}"
                log.debug " user name: #{props.fetch('dc_join_user_name')}"
                
                vm_config.vm.provision "shell", path: get_handler_script_path("dc.join.dsc.ps1"), env: env
                vm_config.vm.provision "reload"
            
                vm_config.vm.provision "shell", path: get_handler_script_path("dc.join.hostname.ps1"), env: env

                execute_tests config: config, 
                              vm_config: vm_config, 
                              paths: "#{get_handler_tests_scripts_path}/dc.join.dsc.*",
                              env: env
          
            end
           
        end

    end

end