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

                log.debug "Configuring network: #{provision_type}"

                case provision_type
                when 'forwarded_port'
                    guest_port = provision_props.fetch('guest')
                    host_port = provision_props.fetch('host')

                    log.debug " guest: #{guest_port} -> host: #{host_port}"
                    vm_config.vm.network provision_type, guest: guest_port, host: host_port
                when 'public_network'
                    ip = provision_props.fetch('ip', nil)

                    if ip.nil?
                        log.debug " public_network, parametless"
                        vm_config.vm.network "public_network"
                    else
                        log.debug " public_network, ip: #{ip}"
                        vm_config.vm.network "public_network", ip: ip
                    end
                else
                    error_message = "Unknown, unsupported network type: #{provision_type}"

                    log.error error_message
                    raise error_message
                end
            end

        end

    end

end