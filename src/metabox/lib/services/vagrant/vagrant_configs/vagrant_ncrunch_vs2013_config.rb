require_relative 'vagrant_config_base.rb'

module Metabox

    module VagrantConfigs

        class VagrantNCrunchConfig < VagrantConfigBase

            def initialize

            end

            def name 
                "vagrant::ncrunch-vs2013"
            end

            def configure_host(vm_config:)

                if !should_run?(config: config) 
                    return 
                end

                _configire_ncrunch(vm_config: vm_config)
                _configire_ncrunch_tests(vm_config: vm_config)
            end

            def _configire_ncrunch(vm_config:)
                
                vm_config.vm.provision "shell", path: "./../scripts/_dc_ncrunch_vs2013.ps1"
                
            end

            def _configire_ncrunch_tests(vm_config:)
                
                tests_folder_path = _section_tests_folder_path

                configure_tests(
                    vm_config: vm_config,
                    src_test_paths: [
                        "#{tests_folder_path}/Roles.NCrunch.*"
                    ]
                )
            end


        end

    end

end