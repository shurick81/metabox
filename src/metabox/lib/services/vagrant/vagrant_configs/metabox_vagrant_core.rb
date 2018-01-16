require_relative 'vagrant_config_file'

module Metabox

    module VagrantConfigs

        class VagrantMetaboxCore < VagrantConfigFile

            def initialize

            end

            def name 
                "metabox::vagrant::core"
            end
           
            def configure_host(config:, vm_config:)
                default_properties = {
                    "Name" => "metabox core script",
                    "Tags" => [ "_always" ],
                    "Properties" => {
                        "source" => "#{default_vagrant_scripts_path}/metabox.vagrant.core/_metabox_core.ps1",
                        "destination" => "c:/Windows/Temp/_metabox_core.ps1"
                    }   
                }

                _safe_merge_hash(default_properties, config.fetch('Properties', {}))
                _configure_files(config: config, vm_config: vm_config, properties: default_properties.fetch('Properties'))
            end

        end

    end

end