module Metabox

    module VagrantConfigs

        class VagrantConfigShell < VagrantConfigBase

            def initialize()

            end

            def name 
                "metabox::vagrant::shell"
            end
           
            def configure_host(config:, vm_config:)

                if !should_run?(config: config) 
                    return 
                end

                default_properties = {
                    
                }

                _safe_merge_hash(default_properties, config.fetch('Properties', {}))
                _handle_properties(default_properties)
               
                vm_config.vm.provision "shell" do |shell|
                    _transfer_props(shell, default_properties)
                end
            end

            private 

            def _handle_properties(default_properties)
                 
                # adding metabox http server var
                 http_server_addr = env_service.get_metabox_http_server_addr

                 env_hash = default_properties["env"]   
                 
                 # handling array/hash compatibility
                 # this is very cool! 
                 # allows us to define vars in Vagrant same way as in Packer :)
                 if env_hash.is_a?(Array)
                     tmp_hash = {}
                     
                     env_hash.each  do | array_item |
                         array_item_split = array_item.split('=')
                         tmp_hash[array_item_split[0]] = array_item_split[1]
                     end
                     
                     env_hash = tmp_hash
                 end
 
                 # overriding METABOX_HTTP_ADDR to point to the http server
                 # metabox spins up sinatra server to server files within Vagrant VMs
                 # also very cool, give an ability to have same experience for Azure/AWS provision ;)
                 if !http_server_addr.nil?
                     if env_hash.nil?
                         env_hash = {}
                     end
 
                     env_hash["METABOX_HTTP_ADDR"] = http_server_addr
                 else 
                     log.debug "METABOX_HTTP_ADDR is NULL or empty"
                 end

                 if env_hash.nil? || env_hash.empty?
                    env_hash = {}
                 end

                 _safe_merge_hash(env_hash, _get_metabox_env(env_hash))
                 default_properties["env"] = env_hash
            end
        end
    end
end