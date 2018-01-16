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
                machinefolder = props.fetch('machinefolder', nil)

                if !machinefolder.nil? && !machinefolder.empty?

                    machinefolder = File.expand_path machinefolder
                    FileUtils.mkdir_p machinefolder

                    if !File.exists? machinefolder
                        raise "Cannot VirtualBox default machinefolder - folder does not exist: #{machinefolder}"
                    end

                    log.info "      - updating VirtualBox default machinefolder to '#{machinefolder}'"
                    run_cmd(cmd: "VBoxManage setproperty machinefolder #{machinefolder}")
                end
            end

            def _set_vm_default_folder(config:)
                log.info "      - reverting VirtualBox default machinefolder to 'default'"
                run_cmd(cmd: "VBoxManage setproperty machinefolder default")
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