module Metabox

    module VagrantConfigs

        class VagrantConfigProvison < VagrantConfigBase

            def initialize()

            end

            def name 
                "vagrant::vm:provision"
            end
           
            def configure_host(config:, vm_config:)

                if !should_run?(config: config) 
                    return 
                end

                default_properties = {
                    
                }

                _safe_merge_hash(default_properties, config.fetch('Properties', {}))

                provision_type = default_properties.fetch('type')
                provision_props = ObjectUtils.deep_clone(default_properties)
                provision_props.delete('type')

                vm_config.vm.provision provision_type do | provision |
                    _transfer_props(provision, provision_props)
                end

            end

        end

    end

end