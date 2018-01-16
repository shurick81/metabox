require_relative 'vagrant_config_base.rb'

module Metabox

    module VagrantConfigs

        class VagrantVS13Config < VagrantConfigBase

            @config

            def initialize()

            end

            def name 
                "metabox::vagrant::visual_studio13"
            end

            def configure_host(config:, vm_config:)
             
                if !should_run?(config: config) 
                    return 
                end

                target_file_name = "vs2013.admin-deployment.xml"
                target_deployment_file = File.join "c:\\_metabox_config\\#{safe_name}", target_file_name

                props = {
                    'vs_executable_path' => "c:\\_metabox_resources\\vs2013.5_ent_enu\\vs_ultimate.exe",
                    'vs_product_name' => "Microsoft Visual Studio Ultimate 2013 with Update 5",
                    'vs_admin_deployment_file_path' => target_deployment_file
                }

                _safe_merge_hash(props, config.fetch('Properties', {}))

                env = _get_metabox_env(props)
                
                # bring admin file
                vm_config.vm.provision "file", 
                                        source: get_handler_config_path(target_file_name),
                                        destination: target_deployment_file

                # deploy
                vm_config.vm.provision "shell", 
                                        path: get_handler_script_path("vs13.dsc.ps1"), 
                                        env: env

                # reload
                vm_config.vm.provision "reload"

                # post-deploy, VS 2015 needs some goodies
                vm_config.vm.provision "shell", 
                                        path: get_handler_script_path("vs13.dsc.post_deploy.ps1"), 
                                        env: env

                # test
                execute_tests config: config, 
                              vm_config: vm_config, 
                              paths: "#{get_handler_tests_scripts_path}/vs13.dsc.*",
                              env: env

            end
           
        end

    end

end