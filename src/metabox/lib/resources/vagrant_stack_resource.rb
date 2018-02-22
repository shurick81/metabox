require_relative 'resource_base' 
include Metabox::Resources

module Metabox
    module Resources  

        class VagrantTemplateResource < ResourceBase
            
            attr_accessor :host_name
            attr_accessor :handlers
          
            def _init_dsl_properties
               @handlers = []
            end

            def add_config(config) 
                @handlers << config
            end
        end

        class VagrantStackResource < ResourceBase
        
            def define_vagrant_template(host_name, &block)

                vagrant_template = VagrantTemplateResource.new(&block)

                if vagrant_template.nil? 
                    vagrant_template.host_name = host_name
                end

                @resources << vagrant_template
                @resources.last
            end
    
        end

    end
end