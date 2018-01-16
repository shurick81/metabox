
module Metabox

    class PackerService < ServiceBase

        def name
            "packer"
        end

        def clean(params)

            log.info "Cleaning Packer build with arguments: #{params}"
            validate_params(params: params)
            
            template_file_path = params[0]
        
            if(template_file_path == "box" || template_file_path == "output") 
            
                delete_pattern = "*.box"
        
                if(template_file_path == "output") 
                    delete_pattern = "output-*"
                end
        
                log.info "Cleaning Packer folder using pattern: #{delete_pattern}" 
                cmd = "cd packer && pwd && ls -la && rm -rf #{delete_pattern} && ls -la"
            
                run_cmd(cmd:cmd)
            else 
                
                template_name = template_file_path.gsub(".json", '')
                
                packer_file_name = create_packer_vars_file(template_name: template_name)
                
                log.info "Cleaning Packer build for template: #{template_name}"
        
                packer_vars_file = "./../#{packer_file_name}"
        
                box_file_name = "#{template_name}-virtualbox.box"
                output_folder_name = "output-#{template_name}"
        
                cmd = "cd packer && pwd && ls -la && rm -rf #{box_file_name} && rm -rf #{output_folder_name}"
                run_cmd(cmd:cmd)
            end

        end

        def build(params)
            log.info "Building Packer image with arguments: #{params}"
            validate_params(params: params)
            
            template_file_path = params[0]
            template_name = template_file_path.gsub(".json", '')
            
            log.info "Loading default config..."
            yaml_config = get_config_data(
                template_name: template_name
            )

            log.info "Generating JSON file for packer..."
            json_file_path = create_tmp_json_file(
                template_name: template_name,
                data: yaml_config
            )

            log.info "Running Packer build for template: #{template_name}"
            cmd = "cd packer && pwd && ls -la && packer build -force -var-file=#{json_file_path} #{template_file_path}"
        
            run_cmd(cmd:cmd)
        end
        
        #private 

        def validate_params(params:)
            if(params.count == 0)
        
                log.info "Please provide a packer template name:"
                log.info "> rake packer:build[centos7-mb-canary.json]"
                log.info "> ruby packer:clean[centos7-mb-java8.json]"
            
                exit 1
            end
        end

        def _file_exists?(path)
            File.exist? path
        end

        def _default_config_file_name
            '.metabox.yaml'
        end

        def _get_metabox_env_config_path
            env_config_path = _env.fetch('METABOX_CONFIG_PATH', nil)
        end

        def _default_config_paths
            
            result = []
            file_name = _default_config_file_name

           
            # env override
            if !_get_metabox_env_config_path.nil?
                result << _get_metabox_env_config_path
            end

            # current folder
            result << file_name

            # user folder
            result << "~/#{file_name}"

            # fall back to default, within ruby gem and 3 levels up
            result << "#{File.dirname(__FILE__)}/#{file_name}"
            result << "#{File.dirname(__FILE__)}/../#{file_name}"
            result << "#{File.dirname(__FILE__)}/../../#{file_name}"
            
            result
        end

        def load_default_config

            result = nil
            paths = _default_config_paths

            paths.each do | path |
                abs_path = File.absolute_path (File.expand_path(path ))
                exist = _file_exists? abs_path

                if(exist)
                    log.info " [+] loading config: #{abs_path}"
                    result = YAML.load_file(abs_path)
                else
                    log.debug "[-] tried path: #{path}"
                end
            end
            
            if( result == nil)
                raise "Can't find default Metabox config. Paths were: #{paths}"
            end

            result
        end

        def create_tmp_json_file(template_name:, data:)
            tmp_dir = "./.tmp"
            file_path = File.join(tmp_dir, template_name + "-" + current_metabox_branch +  ".json")

            file_path = File.absolute_path file_path

            generate_packer_var_file(
                template_name: template_name,
                file_path: file_path,
                data: data
            )

            file_path
        end

        def get_vagrant_environments()
            data = load_default_config
            
            # prepare variable 
            environments = env_service.get_mb_config_value(
                mb_env_config: data,
                path: [
                    "metabox",
                    "Environments"
                ]
            )

            environments

        end

        def get_config_data(template_name:)
            
            data = load_default_config

             # prepare variable 
             shared_variables = env_service.get_mb_config_value(
                mb_env_config: data,
                path: [
                    "metabox",
                    "variables",
                    "shared"
                ]
            )

            shared_variables_hash = _flatten_hash(hash: shared_variables)

            build_varaibles = env_service.get_mb_config_value(
                mb_env_config: data,
                path: [
                    "metabox",
                    "variables",
                    "builds",
                    template_name 
                ]
            )

            if( build_varaibles != nil && !build_varaibles.empty?)
                log.debug "Found build specific variables!"

                build_flat_hash =  _flatten_hash(hash: build_varaibles)
                shared_variables_hash = shared_variables_hash.merge(build_flat_hash)
            else
                log.debug "Cannot find build specific variables"
            end

            branch_varaibles = env_service.get_mb_config_value(
                mb_env_config: data,
                path: [
                    "metabox",
                    "variables",
                    "builds",
                    template_name + "-" + current_metabox_branch
                ]
            )

            if( branch_varaibles != nil && !branch_varaibles.empty?)
                log.debug "Found branch specific variables!"

                branch_flat_hash =  _flatten_hash(hash: branch_varaibles)
                shared_variables_hash = shared_variables_hash.merge(branch_flat_hash)
            else
                log.debug "Cannot find branch specific variables"
            end

            # post processing env variables
            _process_env_variables(hash: shared_variables_hash)

            shared_variables_hash
        end

        def generate_packer_var_file(template_name:, file_path:, data:)
            shared_variables_hash = data

            log.debug "New packer file: #{file_path}"
            
            result = JSON.pretty_generate(shared_variables_hash) 
            log.debug result

            File.open(file_path,"w") do |f|
                f.write(result)
            end
        end

        def _flatten_hash(hash:)

            result = {}

            hash.keys.each do | install_key | 
            
                install = hash[install_key]

                if(install.is_a?(Array))
                    result[install_key] = install.clone.join(',')
                elsif (install.is_a?(Hash))
                    unnested_install = install.unnest
        
                    unnested_install.keys.sort.each do | flat_key |
                    
                        flat_value = unnested_install[flat_key]
                        final_key = install_key + "." + flat_key
                        
                        if flat_value.is_a?(Array) 
            
                            first = flat_value[0].clone
                            flat_value = flat_value.join(',')
            
                            # adding first zip file to beunzipped
                            # "sp2013sp1.source_http.zip_files": "sp2013sp1.zip.001,sp2013sp1.zip.002,sp2013sp1.zip.003,sp2013sp1.zip.004,sp2013sp1.zip.005",
                            # "sp2013sp1.source_http.unzip_file": "sp2013sp1.zip.001",
                            
                            if(flat_key.end_with?("string")) 
                                result[final_key.gsub(".zip_files", ".unzip_file")] = first
                            end
            
                        end
            
                        result[final_key] = flat_value
                    end
                else
                    result[install_key] = install
                end
            end

            result
        end

    end
end