require_relative 'resource_base' 
include Metabox::Resources

module Metabox
    module Resources  

        class MetaboxResource < ResourceBase
        
            @@configs 
            
            def self.configs
                @@configs ||= []
                @@configs
            end
        
            def self.define_config(name, &block)
                @@configs ||= []
                @@configs << MetaboxResource.new(name, &block)

                @@configs.last
            end

            def define_file_set(name, &block)
                @resources << FilesetSetResource.new(name, &block)
                @resources.last
            end

            def define_packer_build(name, &block)
                @resources << PackerBuildResource.new(name, &block)
                @resources.last
            end

            def define_vagrant_stack(name, &block)
                @resources << VagrantStackResource.new(name, &block)
                @resources.last
            end
    
        end

    end
end