
module Metabox
    
    class DocumentService < ServiceBase
        
        @document_dirs;
        @document_files;
        
        def initialize
            @document_dirs = {}
            @document_files = {}
        end
        
        def name 
            "metabox::document"
        end

        def generate(params = nil)

            # don't clean up every time
            # all documents share the same scripts folder
            # hence, parallel builds would fail deleting each other's script folder
            # we'll fix this in later releases providing a dedicated snapshot of the script folder
            # for evety build

            #log.debug "Cleaning up previous builds..."
            #_process_cleanup

            log.debug "Running generators..."

            generators = get_services(Metabox::Document::DocumentGeneratorBase)
            resources  = get_resources

            context = {
                :all_document_dirs => _get_all_document_dirs
            }

            generators.each do | generator |
                log.debug "Running document generator: #{generator.name}"
                generator.process(context: context, resources: resources) 
            end

            # processing metabox resources
            _process_packer_resources 
            _process_vagrant_resources
        end

        def list(params = nil)
            log_message = ["\n"]

            documents = get_documents

            log_message << "Found #{documents.count} metabox documents"
            log_message << ""

            documents.each do | document |
                log_message << " #{document} \n"
            end

            log.info log_message.join("\n")
        end

        def get_documents
            result = []
            
            paths = env_service.get_metabox_document_dirs
            
            paths.each do | path |
                log.debug "Loading metabox documents from: #{path}"
                files = _load_document_files(path: path, ext: get_document_extention)

                files.each do | file |
                    
                    config_path = File.absolute_path(file)
                    log.info "including: #{config_path}"

                    require config_path
                end              
            end

            MetaboxResource.configs
        end

        def get_resources 
            result = {} 
            
            docs = get_documents

            docs.each do | doc |
                resources = doc.resources
                resources.each { | resource | 
                    result[resource.name] = resource
                }
            end

            result
        end

        def get_document_extention 
            "metabox.rb"
        end

        def get_packer_build_resources
            get_resources.select { | name, value | value.is_a?(PackerBuildResource) }
        end

        def get_vagrant_vm_resources
            result = {} 
            docs = get_documents

            docs.each do | doc |
                resources = doc.vagrant_vm_resources
                resources.each { | name, value | 
                    result[name] = value
                }
            end

            result
        end
        
        def get_revision_resources
            result = {} 
            docs = get_documents

            docs.each do | doc |
                resources = doc.revision_resources
                resources.each { | name, value | 
                    result[name] = value
                }
            end

            result
        end

        def get_download_fileset_resources
            result = {} 
            docs = get_documents

            docs.each do | doc |
                resources = doc.download_file_set_resources
                resources.each { | name, value | 
                    result[name] = value
                }
            end

            result
        end

        def get_download_files_resources
            result = {} 
            docs = get_documents

            docs.each do | doc |
                resources = doc.download_files_resources
                resources.each { | name, value | 
                    result[name] = value
                }
            end

            result
        end

        def download_files_resources
            result = {} 
            docs = get_documents

            docs.each do | doc |
                resources = doc.download_files_resources
                resources.each { | name, value | 
                    result[name] = value
                }
            end

            result
        end

        def get_vagrant_environment_resources
            result = {} 
            docs = get_documents

            docs.each do | doc |
                resources = doc.vagrant_environment_resources
                resources.each { | name, value | 
                    result[name] = value
                }
            end

            result
        end

        def get_vagrant_vm_resources_for_environment(environment_name)

            result = {}
            resources = get_vagrant_vm_resources
            
            resources.each { | resource_name, resource_value | 
                if resource_name.include? (environment_name + '::') 
                    result[resource_name] = resource_value
                end
            }

            resource_names = resources.keys.sort.join("\n - ")

            if result.empty?
                error_message =  "Cannot find Vagrant VM resource by name: #{name}"

                log.error error_message
                log.info "Resourxes were: #{resource_names}"

                raise error_message
            end

            result
        end

        def get_download_files_resource_by_name(name)

            resources = get_download_files_resources
            
            resource = resources.fetch(name, nil)
            resource_names = "\n - " + resources.keys.sort.join("\n - ")

            if resource.nil?
                error_message =  "Cannot find download file resource by name: #{name}"

                log.error error_message
                log.info "Resources were: #{resource_names}"

                raise error_message
            end

            { name => resource }
        end

        def get_vagrant_vm_resource_by_name(name)

            resources = get_vagrant_vm_resources
            
            resource = resources.fetch(name, nil)
            resource_names = resources.keys.sort.join("\n - ")

            if resource.nil?
                error_message =  "Cannot find Vagrant VM resource by name: #{name}"

                log.error error_message
                log.info "Resourxes were: #{resource_names}"

                raise error_message
            end

            { name => resource }
        end

        def get_packer_build_resource_by_name(name)
            resources = get_packer_build_resources

            result = resources.fetch(name, nil)

            if result.nil?
                error_message = "Cannot find packer build resource with name: #{name}"
                resource_names = "\n - " + resources.keys.sort.join("\n - ")

                log.error error_message
                log.info "Resources were: #{resource_names}"
                
                raise error_message
            end

            result
        end
        
        private

        def _process_cleanup
            _cleanup_script_folders
        end
    
        def _cleanup_script_folders
            log.debug "Cleaning up previous script folders..."

            folder_paths = [
                env_service.get_metabox_vagrant_dir,
                env_service.get_metabox_packer_dir
            ]

            log.debug "Cleaning up dirs: #{folder_paths}"

            folder_paths.each do | folder_path |
                folder_path = File.join folder_path, "scripts"

                if File.exist? folder_path
                    log.debug "Deleting folder: #{folder_path}"
                    FileUtils.rm_rf(folder_path)
                else
                    log.debug "Skipping deletion. Folder does not exist: #{folder_path}"
                end
            end
        end

        def _process_packer_resources

            log.debug "Processing packer handlers..."

            to_dirs = [
                File.join(env_service.get_metabox_vagrant_dir, "scripts/packer"),
                File.join(env_service.get_metabox_packer_dir, "scripts/packer")
            ]

            services = get_services(Metabox::PackerConfigBase)

            services.each do | service |
                log.debug "  - #{service.name}"

                to_dirs.each do | to_dir |
                    _copy_scripts(
                        service.script_paths,
                        to_dir
                    )
                end
            end
        end

        def _get_all_document_dirs
            @document_dirs.keys.to_a.uniq
        end

        def _get_all_document_files
            @document_files.keys.to_a.uniq
        end

        def _process_vagrant_resources

            log.debug "Processing vagrant handlers..."

            to_dirs = [
                File.join(env_service.get_metabox_vagrant_dir, "scripts/vagrant"),
                File.join(env_service.get_metabox_packer_dir, "scripts/vagrant")
            ]

            services = get_services(Metabox::VagrantConfigs::VagrantConfigBase)

            services.each do | service |
                log.debug "  - #{service.name}"

                to_dirs.each do | to_dir |
                    _copy_scripts(
                        service.script_paths,
                        to_dir
                    )
                end
            end
        end

        def _copy_scripts(from_paths, to_path)
                
            from_paths.each do | path |

                src = path
                dst = File.join(to_path, File.basename(path))

                if File.exists? src
                    FileUtils.mkdir_p dst
                    log.debug "Copying script folder"
                    log.debug    "   - #{src}"
                    log.debug    "   - #{dst}"

                    FileUtils.copy_entry src, dst
                else
                    log.debug "Skipping script folder, it does not exist: #{src} -> #{dst}"
                end
            end
        end

        def _ensure_directory(dir_path)
             FileUtils.mkdir_p dir_path
        end

        def _load_document_files(path:, ext:)
            # this replace is to make it work under windows OS
            path = path.gsub('\\','/')
            Dir.glob("#{path}/**/*.#{ext}")
        end
        
    end

end