require_relative 'resource_base' 
include Metabox::Resources

module Metabox
    module Resources  
       
        class FileResourceChecksum < ResourceBase
            def initialize(&block)
                super("default", &block)
            end


            attr_accessor :enabled
            attr_accessor :type
            attr_accessor :value
        end

        class FileResource < ResourceBase

            attr_accessor :source_url
            attr_accessor :destination_path
            attr_accessor :hooks
            attr_accessor :checksum
            attr_accessor :options
            attr_accessor :is_file_resource
        
            def define_checksum(&block)

                if !block_given?
                    return  @checksum
                end

                @checksum = FileResourceChecksum.new(&block)
                @checksum
            end

            def _init_dsl_properties
                @hooks = {}
                @options = []
                @is_file_resource = true
            end

            def dsl_properties
                [
                    "source_url",
                    "destination_path",
                    "hooks",
                    "checksum"
                ]
            end

        end
    end
end


