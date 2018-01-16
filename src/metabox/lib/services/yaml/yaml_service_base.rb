require 'yaml'

module Metabox
    class YamlServiceBase < ServiceBase

        def name
            "yaml_base"
        end

        def load(file_path)
            hash = nil 
            
            begin
                log.debug("Loading YAML from file: #{file_path}")
                hash = YAML.load_file(file_path)
            rescue => exception  
                log.error "Error while loading YAML file: #{file_path}"
                log.error exception

                raise exception
            end

            hash
        end

        private 

        def _process_yaml(hash:)

        end

    end
end
