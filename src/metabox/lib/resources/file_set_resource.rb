require_relative 'resource_base' 
include Metabox::Resources

module Metabox
    module Resources  

        class FilesetSetResource < ResourceBase

            def define_file(name, &block)
                @resources << FileResource.new(name, &block)
                @resources.last
            end
        end

    end
end