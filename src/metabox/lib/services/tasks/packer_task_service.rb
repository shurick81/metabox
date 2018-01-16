
require_relative "task_service_base"

module Metabox

    class PackerTaskService < TaskServiceBase

        def name 
            "metabox::tasks:packer"
        end

        def rake_alias 
            "packer"
        end

        def clean(params)
            log.info "Running task [#{__method__}] with arguments: #{params}"

        end

        def build(params)
            log.info "Running task [#{__method__}] with arguments: #{params}"

            first_param =  params.first

            if first_param.nil?
                raise "Firt parameter, Packer resource name, is required!"
            end

            packer_resource = document_service.get_packer_build_resource_by_name(first_param)
            packer_resource_file = packer_resource.fetch('Properties').fetch('PackerFileName')
            
            log.info "  - file name: #{packer_resource_file}"
            
            additional_params = ''
            if params.count > 1
                additional_params = params[1]
            end

            working_dir = env_service.get_metabox_packer_dir

            cmd = [
                "packer build #{additional_params} #{packer_resource_file}"
            ].join(' && ')

            track_execution("Executing cmd") { os_service.run_cmd(cmd: cmd, pwd: working_dir, is_dry_run: is_dry_run? ) }
            
        end

    end

end