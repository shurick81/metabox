require 'yaml'

require_relative 'yaml_service_base'

module Metabox
    class YamlConfigService < YamlServiceBase

        def name
            "yaml_service"
        end

        def load(file_path)
            hash = super

            _process_yaml(hash: hash)

            hash
        end

        def process_hash(hash)
            _process_yaml(hash: hash)
            hash
        end
        
        private 

        def _get_services
            services = get_services(Metabox::YamlFunctionServiceBase)

            # sorting services
            # this applies YAML processing services in order
            services = services.sort { | a, b | a.order <=> b.order }

            services
        end

        def _process_yaml(hash:)

            log.debug "Preprocessing YAML"
            services = _get_services
          
            services.each do | service |
                log.debug " - service: #{service.name}, order: #{service.order}"
                service.process(hash)
            end

            log.verbose hash.to_yaml
        end

    end
end
