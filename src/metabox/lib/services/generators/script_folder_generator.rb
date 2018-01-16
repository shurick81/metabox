module Metabox

    module Document

        class ScriptFolderGenerator < DocumentGeneratorBase

            def name
                "metabox::document::generators::script_folder"
            end

            def process(context:, resources:) 
                _internal_process(context, resources)
            end

            private 

            def _internal_process(context, resources)

                to_paths = [
                    env_service.get_metabox_packer_dir,
                    env_service.get_metabox_vagrant_dir
                ]

                to_paths.each do | to_path |
                    _copy_document_scripts(context[:all_document_dirs], to_path)
                end
            end

            def _copy_document_scripts(from_paths, to_path)
                
                from_paths.each do | path |
    
                    src = File.join path, "scripts"
                    dst = File.join to_path, "scripts"
    
                    if File.exists? src
                        FileUtils.mkdir_p to_path
                        log.debug "Copying script folder: #{src} -> #{dst}"
    
                        FileUtils.copy_entry src, dst
                    else
                        log.debug "Skipping script folder, it does not exist: #{src} -> #{dst}"
                    end
                end
            end

        end

    end
end