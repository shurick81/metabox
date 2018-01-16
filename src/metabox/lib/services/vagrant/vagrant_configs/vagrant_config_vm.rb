module Metabox

    module VagrantConfigs

        class VagrantConfigVM < VagrantConfigBase

            def initialize

            end

            def name 
                "vagrant::config::vm"
            end
           
            def configure_host(config:, vm_config:)
                default_properties = {
                    
                }

                _safe_merge_hash(default_properties, config.fetch('Properties', {}))
                _transfer_props(vm_config.vm, default_properties)
            end

        end

    end

end