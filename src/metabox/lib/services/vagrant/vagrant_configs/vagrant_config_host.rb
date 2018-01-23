module Metabox

    module VagrantConfigs

        class VagrantConfigMetaboxHost < VagrantConfigBase

            def initialize()

            end

            def name 
                "metabox::vagrant::host"
            end
           
            def configure_host(config:, vm_config:)

                vm_name = _get_full_vm_name
                host_name = get_host_name(environment_name: _get_environment_name, vm_name: _get_vm_name)

                log.warn "Configuring host #{vm_name}"
                log.info " hostname:    #{host_name}"
                vm_config.vm.hostname = host_name

                host_ip = get_ip_address(environment_name: _get_environment_name, vm_name: _get_vm_name)
                gateway_ip = get_environment_ip_range(name: _get_environment_name) + ".1"
                
                log.info " host_ip:     #{host_ip}"
                log.info " gateway_ip:  #{gateway_ip}"
                
                vm_config.vm.network :private_network, ip: host_ip, gateway: gateway_ip
        
                hostnames = [
                    vm_name,
                    host_name
                ]
               
                log.info " hostnames:"
                hostnames.each do | name | 
                    log.info "  - #{name}"
                end

                # https://github.com/devopsgroup-io/vagrant-hostmanager
                # this plugin make this VM availble on host via vm_name/host name shortcuts
                # check metabox output for these values - stack::vm, and vm name itself
                vm_config.hostmanager.aliases = [ vm_name, host_name ]

                _handler_synced_folder(config: config, vm_config: vm_config)

                log.warn "Finished configuring host #{vm_name}"
            end

            private

            def _handler_synced_folder(config:, vm_config:)
                synced_folders = config.fetch('Properties',{}).fetch('synced_folder',[])
                
                log.info " synced_folders:"         
                synced_folders.each do | folder | 
                    log.info "  - #{folder}"
                end

                synced_folders.each do | folder | 
                    src = folder["src"]
                    dst = folder["dst"]
                    type = folder["type"]

                    # TODO
                    # win-linux path / -> \ 
                    # but we don't use synced_folder at all in favour to custom-run sintra web server at 10.0.2.2

                    if type.nil?
                        log.info "  - default: #{src} -> #{dst}"
                        vm_config.vm.synced_folder src, dst
                    else
                        log.info "  - #{type}: #{src} -> #{dst}"
                        vm_config.vm.synced_folder src, dst, type: type
                    end
                end
            end
        end

    end

end