module Metabox

    module Document

        class PackerGenerator < DocumentGeneratorBase

            def name
                "metabox::document::generators::packer_build"
            end

            def process(context:, resources:) 
                _internal_process(resources)
            end

            private 

            def _internal_process(resources)

                packer_build_resources = _get_resources_by_type(resources, "metabox::packer::build")
                dir = env_service.get_metabox_packer_dir
               
                packer_build_resources.each do | name, value |
                    _create_packer_build_file(dir, value)
                end
            end

            def _create_packer_build_file(dir, resource)

                FileUtils.mkdir_p dir

                log.debug "Creating Packer build file for resource"
                log.verbose resource.to_yaml

                props = resource.fetch('Properties')

                file_name = props.fetch('PackerFileName')
                template = props.fetch('PackerTemplate')

                packer_service = get_service_by_name("metabox::packer::config::base")
                packer_config = {}

                # TODO - this current_resource is a hack
                # we need to re-engineer it, pass the whole template
                packer_service.current_resource = resource
                packer_service.configure(config: template, packer_config: packer_config)

                packer_file = File.join dir, file_name
                log.info "Saving Packer template: #{file_name} -> #{packer_file}"
                
                log.verbose "YAML:"
                log.verbose packer_config.to_yaml

                json = JSON.pretty_generate(packer_config)
                log.verbose "JSON:"
                log.verbose json
                
                open( packer_file, 'w') do |f|
                    f.puts json
                end
                
            end

        end
    end
end