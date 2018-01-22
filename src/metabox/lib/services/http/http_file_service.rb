
require 'open3'
require 'digest'

module Metabox

    class HttpFileService < ServiceBase

        def initialize
           
        end

        def name
            "metabox::http::file"
        end

        def execute_resource(resource_name)

            resource = document_service.get_download_files_resource_by_name(resource_name)

            _execute_pre_handlers(resource_name, resource)
            _execute_download(resource_name, resource)
            _execute_post_handlers(resource_name, resource)
        end

        private

        def _get_download_tool_cmd
            env_service.get_metabox_download_tool_cmd
        end

        def _execute_pre_handlers(resource_name, resource)
            log.debug "Executing pre-handlers on resource: #{resource_name}"

            scripts = get_section_value(resource.values.first, "Properties.Hooks.Pre.Inline", [])
            home_folder = _get_destination_folder_path(resource.values.first)

            execute_inline_scripts(home_folder, scripts)
        end

        def _execute_post_handlers(resource_name, resource)
            log.debug "Executing post-handlers on resource: #{resource_name}"

            scripts = get_section_value(resource.values.first, "Properties.Hooks.Post.Inline", [])
            home_folder = _get_destination_folder_path(resource.values.first)

            execute_inline_scripts(home_folder, scripts)
        end

        def _execute_download(resource_name, resource)
            log.debug "Executing download on resource: #{resource_name}"

            home_folder = _get_destination_folder_path(resource.values.first)
            
            src = get_section_value(resource.values.first, "Properties.SourceUrl")
            dst = get_section_value(resource.values.first, "Properties.DestinationPath")
            options = get_section_value(resource.values.first, "Properties.Options", [])

            should_download = _process_checksum(resource_name, resource, dst)

            if should_download 
                
                # clean up
                _delete_file dst

                # download
                _download_file(
                    src: src,
                    dst: dst,
                    options: options
                )

                file_sha1_value = _get_file_sha1_value(dst)
                log.warn "SHA1: #{file_sha1_value} for file: #{dst}"
            end
            
        end

        def _process_checksum(resource_name, resource, file_path)
            result = true

            if !File.exists? file_path
                log.debug "File does not exist: #{file_path}"
                return true
            end
            
            checksum_section = get_section_value(resource.values.first, "Properties.Checksum")

            checksum_enabled = checksum_section.fetch('Enabled', true)
            checksum_type = checksum_section.fetch('Type', "sha1")
            checksum_value = checksum_section.fetch('Value')

            if checksum_enabled.to_s.downcase != "true" 
                return true
            end

            if checksum_type.downcase != "sha1"
                log.error "sha1 is the only supported checksum. Giving type was: #{checksum_type}"
            end

            file_sha1_value = _get_file_sha1_value(file_path)
            log.warn "SHA1: #{file_sha1_value} for file: #{file_path}"

            if(checksum_value == file_sha1_value)
                log.info "Checksum match: expected:[#{checksum_value}] file:[#{file_sha1_value}]"
                log.info "No download is needed"
                
                result = false
            else
                log.info "Checksum didn't match: expected:[#{checksum_value}] file:[#{file_sha1_value}]"
                log.info "FIle will be deleted and re-downloading it: #{file_path}"
                
                result = true
            end

            result
        end

        def _get_file_sha1_value(path)
            sha1 = Digest::SHA1.file path
            sha1.hexdigest
        end

        def _delete_file(path)
            begin
                if File.exist? path
                    log.debug "Deleting file: #{path}"
                    FileUtils.rm_rf path
                    log.debug "Deleted file: #{path}"
                end
            rescue => exception
                log.error "Error while releting file: #{path} - error: #{exception}"
            end
        end

        def _download_file(src:, dst:, options: [])

            dst_folder = File.basename dst
            log.debug "Ensuring folder: #{dst_folder}"
            FileUtils.mkdir_p dst_folder

            options_string = options.join(' ')

            cmd = _get_download_tool_cmd % {src: src, dst: dst, options: options_string }                            
            data = {:out => [], :err => []}

            log.info "Running download: #{cmd}"
            log.info "Updates will be posted every 60 sec"

            Open3.popen3(cmd) do |stdin, stdout, stderr, thread|
                { :out => stdout, :err => stderr }.each do |key, stream|
                    Thread.new do

                        last_time = Time.now 

                        until (raw_line = stream.gets).nil? do
                            
                            now_time = Time.now
                            should_report = (now_time - last_time) * 1000 > 60000
                            
                            if should_report == true
                                log.info "#{now_time} - batch download: pid: #{thread.pid}"
                                
                                log.info "  src: [#{src}]"
                                log.info "  dst: [#{dst}]"
                                log.info "  #{raw_line}"

                                last_time = Time.now 
                            end
                            
                        end
                        
                    end
                end
                
                thread.join 
            end

            log.info "Download completed!"

        end

        def _get_destination_path(resource)
            result = get_section_value(resource, "Properties.DestinationPath")
            result
        end

        def _get_destination_folder_path(resource)
            result =  File.dirname _get_destination_path(resource)
            FileUtils.mkdir_p result

            result
        end

        def execute_inline_scripts(home_folder, scripts)

            # hack to clean up /zip folder
            FileUtils.rm_rf "#{home_folder}/zip"

            scripts.each do | script |
                run_cmd(cmd: "cd #{home_folder} && #{script}")
            end
        end
    end

end