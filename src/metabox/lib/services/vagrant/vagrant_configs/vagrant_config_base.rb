module Metabox

    module VagrantConfigs

        class VagrantConfigBase < ServiceBase

            @config

            attr_accessor :environment_config

            def initialize()

            end

            def name 
                "metabox::vagrant::config::base"
            end

            def script_paths
                [
                    File.join(
                        File.expand_path(File.dirname(__FILE__)),
                        "scripts/" + name.gsub('::','.')
                    )
                ]
            end

            def get_handler_config_path(file_name)
                File.join get_handler_configs_path, file_name
            end

            def get_handler_script_path(file_name)
                File.join get_handler_scripts_path, file_name
            end

            def get_handler_scripts_path
                File.join default_vagrant_scripts_path, safe_name
            end

            def safe_name 
                name.gsub('::',".")
            end

            def get_handler_tests_scripts_path
                File.join get_handler_scripts_path,  "tests"
            end

            def get_handler_configs_path
                File.join get_handler_scripts_path,  "config"
            end

            def get_handler_shared_path
                File.join get_handler_scripts_path,  "shared"
            end

            def get_handler_host_shared_path
                "c:/windows/temp/#{safe_name}/shared"
            end

            def default_vagrant_scripts_path 
                "./scripts/vagrant"
            end

            def default_tests_scripts_path 
                "./scripts/tests"
            end

            def default_packer_scripts_path 
                "./scripts/packer"
            end

            def yaml_schema 
                {
                    "Type" => { :type => "String", :required => true,  :comments => "Handler type", :value => name},
                    "Name" => { :type => "String", :required => false, :comments => "Other comment", :url => "" },
                    "Tags" => { :type => "Array", :required => false, :comments => "", :url => "" } 
                }
            end

            def yaml_example
                valiation_service.get_schema_example_yaml yaml_schema
            end

            def valiation_service 
                get_service_by_name("metabox::core::schema_validation")
            end

            def configure_host(vm_config:)
                
            end

            def _get_active_tags
                env_service.get_metabox_vagrant_provision_tags
            end

            def get_tags(config:)
                config.fetch('Tags', [])
            end

            def should_run?(config:, active_tags: nil) 
              
                provision_name = config.fetch('Name', 'provision')

                # default to incoming tags via METABOX_VAGRNAT_PROVISION_TAGS
                if active_tags.nil?
                    active_tags = _get_active_tags
                end

                tags = get_tags(config: config)

                if tags.any? { |s| s.casecmp("_always") == 0 }
                    log.info "[+] running  [#{provision_name}], '_always' tag found in tags: #{tags}"
                    return true
                end  

                # no incoming tags were provided
                if active_tags.nil?
                    return true
                end

                # empty incoming tags were provided
                if active_tags.empty?
                    log.warn "[-] skipping [#{provision_name}], no tag match detected"
                    return false
                end

                # only if active tags include any of specified in handler
                tags.each do | tag |
                    if active_tags.any? { |s| s.casecmp(tag)==0 }  
                        log.info "[+] running  [#{provision_name}], tag found: #{tags} among #{tags}"
                        return true
                    end
                end
                
                log.warn "[-] skipping [#{provision_name}], no tag match detected"
                return false
            end

            def pre_vagrant(config:)
                
            end

            def post_vagrant(config:)
            end

            def configure(config:, vm_config:)
                _internal_global_setting(config: config, vm_config: vm_config)
                _internal_configure(config: config, vm_config: vm_config)            
            end

            def execute_post_vagrant_config(environment_name:, vm_name:)
                targeted_config = _get_vm_config(environment_name: environment_name, vm_name: vm_name)
                
                log.verbose "execute_post_vagrant_config"

                service = get_service_by_name("vagrant::stack")
                service.post_vagrant(config: targeted_config)
            end
            
            def execute_pre_vagrant_config(environment_name:, vm_name:)
                targeted_config = _get_vm_config(environment_name: environment_name, vm_name: vm_name)
                
                log.verbose "execute_pre_vagrant_config"

                service = get_service_by_name("vagrant::stack")
                service.pre_vagrant(config: targeted_config)
            end

            def configure_vagrant_config(config:)
                
                log.info "Metabox configures vagrant virtual machines..."
                current_config = document_service.get_vagrant_environment_resources
                log.verbose current_config.to_yaml
        
                configure(config: current_config, vm_config: config)

                log.info "Metabox completed vagrant VMs configuration. Vagrant takes it from here."
            end

            def get_host_name(environment_name:, vm_name:)
                key = environment_name + "-" + vm_name
                get_persisted_random_string(key: key) 
            end

            private

            def _get_metabox_env(hash) 
                result = {}
                
                hash.each { | name, value | 
                    string_value = value

                    if value.is_a? Hash 
                        string_value = value.to_json
                    elsif value.is_a? Array
                        string_value = value.join(',')
                    else
                        string_value = value
                    end

                    result["METABOX_" + name.to_s.upcase] = string_value
                }

                result
            end

            def get_document_script(path)
                return "./#{path}}"
            end

            def execute_tests?(config:)
                result = config.fetch('Properties',{}).fetch('execute_tests', "true") 
                result == true || result == "true"
            end

            def execute_tests(config:, vm_config:, paths:, env: {})

                if !execute_tests?(config: config)
                    log.debug "Skipping test execition due to false flag in properties"
                    return
                end

                if !paths.is_a?(Array)
                    paths = [paths]
                end

                test_paths_stirng = "\n " +  paths.join(" \n")
                log.info "Configuring test execution: #{test_paths_stirng}"

                paths.each do |src_test_path|
            
                    test_files = Dir[src_test_path]
                    test_files_string = "\n - " + test_files.join("\n - ")
                    log.info "  - scanned: #{src_test_path}, found: #{test_files_string}"
                    
                    if test_files.empty?
                        log.warn "Cannot find any test files under path: #{src_test_path} - mostlikely, wrong location/pattern"
                    end

                    test_files.each do |fname|

                        log.debug "adding test file: #{fname}"
                       
                        src_path = fname
                        dst_path = "c:/windows/temp/tests/" + File.basename(fname)
            
                        vm_config.vm.provision :file do |file|
                            file.source = fname
                            file.destination = dst_path
                        end
            
                        vm_config.vm.provision "shell", inline: "Invoke-Pester -EnableExit -Script #{dst_path}", env: env
                    end
                end
            
            end
           
            def get_persisted_random_string(key:, file: nil ) 

                if file.nil?
                    file = File.join(env_service.get_metabox_config_folder, '.metabox-hostname-map.yaml')
                end

                # load
                if(!File.exist? file)
                  File.open(file,"w") do |f|
                    f.write({}.to_yaml)
                  end
                end
              
                # existing
                map = YAML.load_file(file)
          
                name = map.fetch(key.downcase, nil)
              
                if(name == nil)
                  name = "mb-" + get_random_string
                  map[key.downcase] = name
                end
          
                File.open(file,"w") do |f|
                  f.write(map.to_yaml)
                end
          
                return name
            end

            def get_ip_address(environment_name:, vm_name:)
                start_index = 5
                ip_range = get_environment_ip_range(name: environment_name)
                
                map = load_ip_map
                
                ip_map = map.fetch(environment_name.downcase) 
                vm_ip = ip_map["hosts"].fetch(vm_name.downcase, nil)

                if vm_ip.nil?
                    vm_ip = ip_map["ip"] + "." + (start_index + ip_map["hosts"].count).to_s
                end

                ip_map["hosts"][vm_name.downcase] = vm_ip
                
                save_ip_map(ip_map: map)

                vm_ip
            end

            def get_environment_ip_range(name:)
                map = load_ip_map
                
                log.debug "map:"
                log.debug map.to_yaml

                start_index = 5
                ip = map.fetch(name.downcase, nil)
              
                if(ip == nil)
                  ip = "192.168." + (map.count + start_index).to_s
                  map[name.downcase] = {
                    "ip" => ip,
                    "hosts" => {}
                  } 
                end
              
                save_ip_map(ip_map: map)
              
                return ip["ip"]
              
            end 

            def save_ip_map(ip_map:, file: nil)

                if file.nil?
                    file = File.join(env_service.get_metabox_config_folder, '.metabox-ip-map.yaml')
                end

                File.open(file,"w") do |f|
                    f.write(ip_map.to_yaml)
                end
            end
            
            def load_ip_map(file: nil)

                if file.nil?
                    file = File.join(env_service.get_metabox_config_folder, '.metabox-ip-map.yaml')
                end

                if(!File.exist? file)
                    File.open(file,"w") do |f|
                    f.write({}.to_yaml)
                    end
                end
                
                log.debug "loading env ip map from file: #{file}"

                result = YAML.load_file(file)

                if result.nil?
                    result = {}
                end

                result
            end

            def _get_environment_name 
                @environment_config.keys.first
            end

            def _get_vm_name 
                @environment_config[_get_environment_name]["Resources"].keys.first
            end

            def _get_full_vm_name
                [
                    _get_environment_name,
                    _get_vm_name
                ].join("-").downcase
            end

            def _get_vm_config(environment_name:, vm_name:)

                vm_full_name = environment_name + "::" + vm_name

                vm_config = document_service.get_vagrant_vm_resource_by_name(vm_full_name)
                current_config = ObjectUtils.deep_clone(vm_config)

                # trim to this env and vm
                targeted_config = {
                    environment_name => {
                        'Resources' => {
                            vm_name => current_config.values.first
                        }
                    }
                }
               
                targeted_config
            end

            def _internal_global_setting(config:, vm_config:)

                vagrant_cmd_args = _get_vagrant_argv
                
                vagrant_cmd = vagrant_cmd_args[:cmd]
                vagrant_vm_name  = vagrant_cmd_args[:vm_name]

                if !vagrant_vm_name.nil?
                    # if VM name is provided, configure additional settings for both linux/windows VMs
                    # we are looking into WinRM settings to enable 2012/2016 consistent provision

                    all_vms = document_service.get_vagrant_vm_resources
                    all_vms_aliases = {}

                    all_vms.each { |key, value| 
                        all_vms_aliases[key.gsub('::','-')] = value
                    }
                    
                    target_vm = all_vms_aliases.fetch(vagrant_vm_name)
                    target_vm_os = target_vm.fetch('OS', 'windows')

                    case target_vm_os
                    when "windows"
                        log.info "Configuring global Vagrant settings for windows os. VM: #{vagrant_vm_name}"
                    
                        vm_config.vm.communicator = "winrm"
                        vm_config.winrm.transport = :plaintext
                        vm_config.winrm.basic_auth_only = true
                    when "linux"
                        log.info "Configuring global Vagrant settings for linux os. VM: #{vagrant_vm_name}"
                    else
                        raise "Unsupported OS: #{os}"
                    end
                end

                # https://github.com/devopsgroup-io/vagrant-hostmanager
                vm_config.hostmanager.enabled = true
                vm_config.hostmanager.manage_host = true
                vm_config.hostmanager.manage_guest = false
            end
            
            def _get_vagrant_argv
                args = ARGV

                return {
                    :cmd => args[0],
                    :vm_name => args[1],
                    :additional_params => args[2]
                }

            end

            def _transfer_props(vm_config, props)
                props.each { | key, value |
                    #log.debug "Transferring prop: #{key} -> #{value}"
                    vm_config.send("#{key}=", value)
                }
            end
          
            def _internal_configure(config: , vm_config: )                        
                
                service = get_service_by_name("vagrant::stack")
                service.configure_host(config: config, vm_config: vm_config)
                
            end
           
            def _configire_synced_folder(vm_config:)
                _section_shared_folders.each  do | folder |
                    vm_config.vm.synced_folder folder["src_path"], folder["dst_path"]    
                end
            end

        end

    end

end