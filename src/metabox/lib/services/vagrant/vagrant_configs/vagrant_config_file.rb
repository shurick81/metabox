require_relative 'vagrant_config_base'

module Metabox

    module VagrantConfigs

        class VagrantConfigFile < VagrantConfigBase

            def initialize

            end

            def yaml_schema 
                {
                    "Type" => { :type => "String", :required => true,  :comments => "Handler type", :value => name},
                    "Name" => { :type => "String", :required => false, :comments => "Other comment", :url => "" },

                    "Tags" => { :type => "Array", :required => false, :comments => "", :url => "" },

                    "Properties" => {
                        "source" =>      { :type => "string", :required => true, :comments => "", :url => "" },
                        "destination" => { :type => "string", :required => true, :comments => "", :url => "" }
                    }
                }
            end

            def name 
                "metabox::vagrant::file"
            end

            def tags 
                []
            end

            def configure_host(config:, vm_config:)

                if !should_run?(config: config) 
                    return 
                end

                default_properties = {
                    
                }

                _safe_merge_hash(default_properties, config.fetch('Properties', {}))
                _configure_files(config: config, vm_config: vm_config, properties: default_properties)
            end

            private 
            
            def _configure_files(config:, vm_config:, properties:)

                src = properties.fetch("source")
                dst = properties.fetch("destination")

                vm_config.vm.provision "file", source: src, destination: dst
            end
        end
    end
end