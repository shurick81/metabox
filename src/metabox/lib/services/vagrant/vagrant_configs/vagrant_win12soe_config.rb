require_relative 'vagrant_config_base.rb'

module Metabox

    module VagrantConfigs

        class VagrantWin12SOEConfig < VagrantConfigBase

            @config

            def initialize

            end

            def name 
                "metabox::vagrant::win12soe"
            end

            def configure_host(config:, vm_config:)
                
                if !should_run?(config: config) 
                    return 
                end

                vm_config.vm.provision "shell", 
                    path: get_handler_script_path("soe.dsc.ps1")
                
                execute_tests config: config, 
                              vm_config: vm_config, 
                              paths: "#{get_handler_scripts_path}/soe.*"

            end

        end

    end

end