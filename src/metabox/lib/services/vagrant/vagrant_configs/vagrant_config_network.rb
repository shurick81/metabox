module Metabox

    module VagrantConfigs

        class VagrantConfigNetwork < VagrantConfigBase

            def initialize()

            end

            def name 
                "vagrant::config::vm::network"
            end
           
            def configure_host(config:, vm_config:)
                default_properties = {
                    
                }

                _safe_merge_hash(default_properties, config.fetch('Properties', {}))

                provision_type = default_properties.fetch('type')
                provision_props = ObjectUtils.deep_clone(default_properties)
                provision_props.delete('type')

                guest_port = provision_props.fetch('guest')
                host_port = provision_props.fetch('host')

                log.debug "Configuring network: #{provision_type} guest: #{guest_port} -> host: #{host_port}"
                vm_config.vm.network provision_type, guest: guest_port, host: host_port
            end

        end

    end

end