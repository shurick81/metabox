
module Metabox

    class PackerConfigBase < ServiceBase

        @default_type;

        attr_accessor :current_resource

        def name
            "metabox::packer::config::base"
        end

        def configure(config:, packer_config:)
            @default_type = 'metabox::packer::config::raw'
            services = get_services(Metabox::PackerConfigBase)
            
            _validate_required_tools(config: config)

            _inject_metabox_core_scripts(config: config)
            _internal_configure(services: services, config: config, packer_config: packer_config)            
        end

        def script_paths
            [
                File.join(
                    File.expand_path(File.dirname(__FILE__)),
                    "scripts/" + name.gsub('::','.')
                )
            ]
        end

        private

        def _validate_required_tools(config:)
            
            tools = @current_resource.require_tools

            if tools.count > 0 
                log.info "Validating required tools..."
                tool_validation_service.require_tools(tool_names: tools)
            end
        
        end

        def _validate_tool(tool_name:)
            log.info "  - validating tool: #{tool_name}"
   
        end

        def _inject_metabox_core_scripts(config:)
            log.debug "Injecting core metabox scripts..."
            os = @current_resource.os 
            
            if os.nil? 
                os = 'windows'
            end

            case os.downcase
            when "windows"
                config.provisioners.insert(0, {
                    "Type" => "metabox::packer::core"
                })
            when "linux"
               # TODO
            else
                raise "Unsupported OS: #{os}"
            end
        end

        def _internal_configure(services:, config:, packer_config:)
            
            packer_sections = {
                "builders" => config.builders,
                "provisioners" => config.provisioners,
                "post-processors" => config.post_processors
            }

            packer_sections.each { | section_name, value | 

                if value.is_a?(Array) && value.first.is_a?(Hash)

                    new_values = []
                    new_packer_config = {}

                    value.each  do | item |
                        section_type = _lookup_section_type(name: nil, value: item)
                        section_service = _lookup_section_service(services: services, section_type: section_type)

                        new_packer_config = {}
                        section_service.configure_section(name: nil, value: item, packer_config: new_packer_config) 

                        new_values << new_packer_config.values.first
                    end

                    packer_config.merge!({ section_name => new_values})

                else

                    section_type = _lookup_section_type(name: section_name, value: value)
                    section_service = _lookup_section_service(services: services, section_type: section_type)

                    new_packer_config = {}

                    #log.warn "Using service: #{section_service.name}"
                    section_service.configure_section(name: section_name, value: value, packer_config: new_packer_config) 

                    packer_config.merge!(new_packer_config)
                end
            }  

        end

        def _lookup_section_service(services:, section_type:)
            return get_service_by_name(section_type)
        end

        def _lookup_section_type(name:, value:)
            
            log.verbose "Processing section: #{name} -> #{value}"

            if value.is_a?(Hash)
                return value.fetch('Type', @default_type)
            end

            @default_type 

        end
        
    end

end