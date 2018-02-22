require_relative 'resource_base' 
include Metabox::Resources

module Metabox
    module Resources  

        class VagrantHostResource < ResourceBase
         
            attr_accessor :os 

            attr_accessor :host_name
            attr_accessor :handlers
            attr_accessor :require_tools
          
            def _init_dsl_properties
               @os = "windows"

               @handlers = []
               @require_tools = []
            end

            def configs 
                @handlers
            end

            def add_config(config) 
                @handlers << config
            end
        end

        class VagrantStackResource < ResourceBase
        
            def define_vagrant_host(host_name, &block)

                vagrant_host = VagrantHostResource.new(host_name, &block)

                @resources << vagrant_host
                @resources.last
            end
    
        end

    end
end