
require_relative "task_service_base"
require 'json'

module Metabox

    class FileSetService < TaskServiceBase

        def name 
            "metabox::tasks:fileset"
        end

        def rake_alias 
            "fileset"
        end

        def download(params)
            batch_size = _get_batch_threads

            log.info "Executing 'download' task with parameters: #{params}"
            log.debug "batch_threads: #{batch_size}"

            name = params.first
            force = params[1] == "--force" ||  params[1] == "-f"

            _validate_name_param(name)

            file_resource_names = _get_resource_names(name)
            
            _execute_pre_handlers(name, file_resource_names)
            _download_resources(file_resource_names, batch_size, force)
            _execute_post_handlers(name, file_resource_names)
        end

        def import_from_file(params)
            log.info "Executing 'import' task with parameters: #{params}"
           
            name = params.first
            path = params[1]
            force = params[2] == "--force"

            _validate_name_param(name)
            
            _execute_pre_handlers(name, [name])
            _import_resource(name, path, force)
            _execute_post_handlers(name, [name])
        end

        def pack(params)
            batch_size = _get_batch_threads

            log.info "Executing 'pack' task with parameters: #{params}"

            name = params.first
            force = params[1] == "--force"

            _validate_name_param(name)

            file_resource_names = _get_resource_names(name)

            _pack_resources(file_resource_names, batch_size, force)
        end

        private

        def _pack_resources(file_resource_names, batch_size, force = false)
            file_resource_names.each_slice(batch_size) do | resource_batch |

                threads = []   

                resource_batch.each do | file_resource_name |
                    threads << Thread.new { 
                        _pack_resource(file_resource_name, force)
                    }
                end

                threads.each { |t| t.join }
            end
        end

        def _download_resources(file_resource_names, batch_size, force = false)
            
            file_resource_names.each_slice(batch_size) do | resource_batch |

                threads = []   

                resource_batch.each do | file_resource_name |
                    threads << Thread.new { 
                        _execute_resource(file_resource_name, force)
                    }
                end

                threads.each { |t| t.join }
            end
        end

        def _execute_handlers(name, file_resource_names, section)

            if name.include?("::_all") && file_resource_names.count > 0
                first_resource_name = file_resource_names.first
                parent_resource_name = first_resource_name.split('::').first
                
                file_resource = document_service.get_download_files_resources[first_resource_name]
                
                filesets = document_service.get_download_fileset_resources
                fileset_resource = filesets[parent_resource_name]

                scripts = get_section_value(fileset_resource, section, [])
                home_folder = _get_destination_folder_path(file_resource)
        
                log.debug "Executing in folder: #{home_folder}"
                log.debug "Scripts: \n " + scripts.join(" \n - ")

                execute_inline_scripts(home_folder, scripts)
            else
                log.debug "Parent resource weren't ::_all - returning..."
            end
        end
       
        def _get_destination_path(resource)
            result = get_section_value(resource, "Properties.DestinationPath")
            result
        end

        def execute_inline_scripts(home_folder, scripts)

            # hack to clean up /zip folder
            FileUtils.rm_rf "#{home_folder}/zip"

            scripts.each do | script |
                run_cmd(cmd: "cd #{home_folder} && #{script}")
            end
        end

        def _get_destination_folder_path(resource)
            result =  File.dirname _get_destination_path(resource)
            FileUtils.mkdir_p result

            result
        end

        def _execute_pre_handlers(name, file_resource_names)

            log.debug "Executing pre-handlers on resources: #{file_resource_names}"
            _execute_handlers(name, file_resource_names, "Properties.Hooks.Pre.Inline")
        end

        def _execute_post_handlers(name, file_resource_names)
            log.debug "Executing post-handlers on resources: #{file_resource_names}"
            _execute_handlers(name, file_resource_names, "Properties.Hooks.Post.Inline")
        end

        def _get_batch_threads 
            env_service.get_metabox_fileset_threads
        end

        def _validate_name_param(resource_name)
            if resource_name.nil? || resource_name.empty?
                error_message = "File resource name, first parameters, is empty or nil"

                log.error error_message
                raise error_message
            end

            if !resource_name.include? "::"
                error_message = "File resource name should be in format: fileset_name::file_name"

                log.error error_message
                raise error_message
            end
        end

        def _get_resource_names(resource_name)
            result = []

            if resource_name.include? "::_all"

                env_name = resource_name.split('::').first
                resources  = document_service.get_download_files_resources

                resources.each { | name, value |
                    if name.include? "#{env_name}::"
                        result << name
                    end
                }
            else 
                result << resource_name
            end

            result
        end 
        
        def _import_resource(resource_name, path, force = false)
            log.info "Executing import resource: #{resource_name}"
           
            service = get_service_by_name("metabox::http::file")
            service.import_resource(resource_name, path, force) 
        end

        def _execute_resource(resource_name, force = false)
            log.info "Executing download resource: #{resource_name}"
            resource_parts = resource_name.split('::')
        
            service = get_service_by_name("metabox::http::file")
            service.execute_resource(resource_name, force) 
        end

        def _pack_resource(resource_name, force)
            log.info "Executing pack resource: #{resource_name}"
            resource_parts = resource_name.split('::')
        
            service = get_service_by_name("metabox::http::file")
            service.pack_resource(resource_name, force) 
        end
    end
end