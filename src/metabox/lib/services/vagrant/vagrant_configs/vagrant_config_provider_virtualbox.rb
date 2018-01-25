module Metabox

    module VagrantConfigs

        class VagrantConfigProviderVirtualBox < VagrantConfigBase

            def initialize()

            end

            def name 
                "vagrant::config::vm::provider::virtualbox"
            end

            def pre_vagrant(config:)
                _set_custom_vm_default_folder(config: config)
         
            end

            def post_vagrant(config:)
                _set_vm_default_folder(config: config)
            end

            def _set_custom_vm_default_folder(config:)
                props = config.fetch('Properties')
                
                # always switching to a custom machine folder
                # trying to avoid clutterning default system drive
                machinefolder = props.fetch('machinefolder', env_service.get_metabox_vagrant_vm_folder)
                virtualbox_service.set_machinefolder(machinefolder)
            end

            def _set_vm_default_folder(config:)
                virtualbox_service.set_default_machinefolder
            end

            def configure_host(config:, vm_config:)

                default_properties = {
                    'gui' => false, 
                    'memory' => 512, 
                    'cpus' => 2 
                }

                _safe_merge_hash(default_properties, config.fetch('Properties', {}))

                default_properties.delete('machinefolder')

                vm_config.vm.provider "virtualbox" do | provider |
                    _transfer_props(provider, default_properties)
                end
                
            end

        end

    end

end