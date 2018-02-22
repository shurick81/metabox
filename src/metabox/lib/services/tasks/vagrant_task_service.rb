
require_relative "task_service_base"
require 'socket'

module Metabox

    class VagrantTaskService < TaskServiceBase

        @http_server_pid;

        def name 
            "metabox::tasks:vagrant"
        end

        def rake_alias 
            "vagrant"
        end

        def add(params)
            #log.info "Running task [#{__method__}] with arguments: #{params}"

            first_param =  params.first

            if first_param.nil?
                raise "Firt parameter, Packer resource name, is required!"
            end

            packer_resource = document_service.get_packer_build_resource_by_name(first_param)
            
            packer_resource_file = packer_resource.packer_file_name
            vagrant_box_name = packer_resource.vagrant_box_name
            
            log.info "  - file name: #{packer_resource_file}"
            log.info "  - box  name: #{vagrant_box_name}"
            
            file_name_base = File.basename packer_resource_file, ".json"
            
            working_dir = env_service.get_metabox_working_dir
            metabox_branch = get_metabox_branch

            vagrant_box_path = "#{working_dir}/packer_boxes/#{file_name_base}-#{metabox_branch}-virtualbox.box"
            
            log.info "  - box path: #{vagrant_box_path}"
            log.info "  - box name: #{vagrant_box_name}"
            
            if !File.exist? vagrant_box_path
                raise "Cannot find box file for resource: #{vagrant_box_name} - file: #{vagrant_box_path} "
            end
            
            cmd = [
                "vagrant box add --force #{vagrant_box_path} --name #{vagrant_box_name}"
            ].join(' && ')
            
            result = nil
            track_execution("Executing cmd") { result = os_service.run_cmd(cmd: cmd, is_dry_run: is_dry_run? ) }

            if result == true
                # copying vagrant box to 'shadow' folders
                _copy_box_to_shadow_folders(vagrant_box_path)

                # cleaning up old file
                _delete_vagrant_box(vagrant_box_path)               
            end
        end        

        def add_from_file(params) 
            #log.info "Running task [#{__method__}] with arguments: #{params}"

            if params.count < 2
                error_message = "This task requires at least 2 params: box_file_path, box_name and optional --force"

                log.erro error_message
                raise error_message
            end

            vagrant_box_path = params[0]
            vagrant_box_name = params[1]

            additional_params = ''

            if params.count > 2
                additional_params = params[2]
            end

            log.info "  - box path: #{vagrant_box_path}"
            log.info "  - box name: #{vagrant_box_name}"
            
            if !File.exist? vagrant_box_path
                raise "Cannot find box file #{vagrant_box_path}"
            end

            cmd = [
                "vagrant box add --force #{vagrant_box_path} --name #{vagrant_box_name}"
            ].join(' && ')
            
            result = nil
            track_execution("Executing cmd") { result = os_service.run_cmd(cmd: cmd, is_dry_run: is_dry_run? ) }
        end

        def up(params)
            cmd_params = _get_vagrant_cmd_details params
            log.verbose cmd_params.to_yaml

            full_vm_name = cmd_params[:full_vm_name]
            env = cmd_params[:environment_name]
            vm = cmd_params[:vm_name]
            additional_params = cmd_params[:additional_params]
            all_additional_params = cmd_params[:all_additional_params]

            vm_names = _get_environment_vm_names(env, vm)
        
            begin 
                _pre_vagrant_vm_provision

                vm_names.each do | vm_name |
                    _internal_vagrant_up(environment_name: env, vm_name: vm_name, additional_params: all_additional_params)
                    _print_vagrant_vm_info(environment_name: env, vm_name: vm_name)
                end
            ensure
                _post_vagrant_vm_provision
            end
        end 

        def reload(params)

            cmd_params = _get_vagrant_cmd_details params
            log.verbose cmd_params.to_yaml

            full_vm_name = cmd_params[:full_vm_name]
            env = cmd_params[:environment_name]
            vm = cmd_params[:vm_name]
            additional_params = cmd_params[:additional_params]

            vm_names = _get_environment_vm_names(env, vm)
            
            log.debug "Running: -stack: #{env} -vm: #{vm} -fullname: #{full_vm_name}"

            working_dir = env_service.get_metabox_vagrant_dir

            begin 
                _pre_vagrant_vm_provision

                vm_names.each do | vm_name |
                    full_vm_name = env + "-" + vm_name

                    cmd = [
                        "vagrant reload #{full_vm_name} #{additional_params}"
                    ].join(' && ')
        
                    track_execution("Executing cmd") { os_service.run_cmd(cmd: cmd, pwd: working_dir, is_dry_run: is_dry_run? ) }
                    _print_vagrant_vm_info(environment_name: env, vm_name: vm)
                end
            ensure
                _post_vagrant_vm_provision
            end
        end 

        def box_list(params)
            log.info "Executing 'vagrant box list' task with arguments: #{params}"
           
            working_dir = env_service.get_metabox_vagrant_dir

            cmd = [
                "vagrant box list"
            ].join(' && ')

            #track_execution("Executing cmd") { os_service.run_cmd(cmd: cmd, pwd: working_dir, is_dry_run: is_dry_run? ) }
            track_execution("Executing cmd") { os_service.run_cmd(cmd: cmd, is_dry_run: is_dry_run? ) }
        end 

        def box_remove(params)
            log.info "Executing 'vagrant box remove' task with arguments: #{params}"
           
            first_argument = params.first

            if first_argument.nil?
                raise "First argiment, box name, should be provided"
            end

            additional_params = ''
            if params.count > 1
                additional_params = params[1]
            end

            working_dir = env_service.get_metabox_vagrant_dir

            cmd = [
                "vagrant box remove #{first_argument} #{additional_params}"
            ].join(' && ')

            #track_execution("Executing cmd") { os_service.run_cmd(cmd: cmd, pwd: working_dir, is_dry_run: is_dry_run? ) }
            track_execution("Executing cmd") { os_service.run_cmd(cmd: cmd, is_dry_run: is_dry_run? ) }
        end 

        def list(params)
            log.info "Executing 'vagrant list' task with arguments: #{params}"
           
            working_dir = env_service.get_metabox_vagrant_dir

            cmd = [
                "vagrant list"
            ].join(' && ')

            #track_execution("Executing cmd") { os_service.run_cmd(cmd: cmd, pwd: working_dir,  is_dry_run: is_dry_run? ) }
            track_execution("Executing cmd") { os_service.run_cmd(cmd: cmd,  is_dry_run: is_dry_run? ) }
        end 

        def status(params)
            log.info "Executing 'vagrant list' task with arguments: #{params}"
           
            working_dir = env_service.get_metabox_vagrant_dir

            cmd = [
                "vagrant status"
            ].join(' && ')

            track_execution("Executing cmd") { os_service.run_cmd(cmd: cmd, pwd: working_dir,  is_dry_run: is_dry_run? ) }
        end 

        def validate(params)
            log.info "Executing 'vagrant list' task with arguments: #{params}"
           
            working_dir = env_service.get_metabox_vagrant_dir

            cmd = [
                "vagrant validate"
            ].join(' && ')

            track_execution("Executing cmd") { os_service.run_cmd(cmd: cmd, pwd: working_dir,  is_dry_run: is_dry_run? ) }
        end 

        def global_status(params)
            log.info "Executing 'vagrant globalstatus' task with arguments: #{params}"
           
            working_dir = env_service.get_metabox_vagrant_dir

            cmd = [
                "vagrant global-status"
            ].join(' && ')

            track_execution("Executing cmd") { os_service.run_cmd(cmd: cmd, pwd: working_dir,  is_dry_run: is_dry_run? ) }
        end 

        def destroy(params)
            log.info "Executing 'vagrant destroy' task with arguments: #{params}"

            first_param = params.first

            if !first_param.nil? && first_param.start_with?("_")
                native_vm_name = first_param.gsub('_', '')
                log.debug "Running: native VM name: #{native_vm_name}"

                additional_params = ''
                if params.count > 1
                    additional_params = params[1]
                end

                cmd = [
                        "vagrant destroy #{native_vm_name} #{additional_params}"
                    ].join(' && ')

                    
                begin
                    #_execute_pre_vagrant_destroy_handlers(environment_name: environment_name, vm_name: vm_name)

                    working_dir = env_service.get_metabox_vagrant_dir
                    track_execution("Executing cmd") { os_service.run_cmd(cmd: cmd, pwd: working_dir, is_dry_run: is_dry_run? ) }
                ensure
                    #_execute_post_vagrant_destroy_handlers(environment_name: environment_name, vm_name: vm_name)
                end
            
                return
            end

            cmd_params = _get_vagrant_cmd_details params
            log.verbose cmd_params.to_yaml

            full_vm_name = cmd_params[:full_vm_name]
            env = cmd_params[:environment_name]
            vm = cmd_params[:vm_name]
            additional_params = cmd_params[:additional_params]

            vm_names = _get_environment_vm_names(env, vm)
            
            log.debug "Running: -stack: #{env} -vm: #{vm} -fullname: #{full_vm_name}"

            working_dir = env_service.get_metabox_vagrant_dir

            vm_names.each do | vm_name |
                full_vm_name = env + "-" + vm_name

                cmd = [
                    "vagrant destroy #{full_vm_name} #{additional_params}"
                ].join(' && ')

                begin
                    _execute_pre_vagrant_destroy_handlers(environment_name: env, vm_name: vm_name)

                    working_dir = env_service.get_metabox_vagrant_dir

                    # vagrant destroy exits 1 when no running vm found #9137
                    # https://github.com/hashicorp/vagrant/issues/9137
                    # -> valid_exit_codes: [0, 1] 
                    track_execution("Executing cmd") { 
                        os_service.run_cmd(
                            cmd: cmd, 
                            pwd: working_dir, 
                            is_dry_run: is_dry_run?, 
                            valid_exit_codes: [0, 1] ) 
                    }
                ensure
                    _execute_post_vagrant_destroy_handlers(environment_name: env, vm_name: vm_name)
                end
            
            end 
        end 

        def halt(params)
            log.info "Executing 'vagrant destroy' task with arguments: #{params}"

            cmd_params = _get_vagrant_cmd_details params
            log.verbose cmd_params.to_yaml

            full_vm_name = cmd_params[:full_vm_name]
            env = cmd_params[:environment_name]
            vm = cmd_params[:vm_name]
            additional_params = cmd_params[:additional_params]

            vm_names = _get_environment_vm_names(env, vm)
            
            log.debug "Running: -stack: #{env} -vm: #{vm} -fullname: #{full_vm_name}"

            working_dir = env_service.get_metabox_vagrant_dir

            vm_names.each do | vm_name |
                full_vm_name = env + "-" + vm_name

                cmd = [
                    "vagrant halt #{full_vm_name} #{additional_params}"
                ].join(' && ')

                track_execution("Executing cmd") { os_service.run_cmd(cmd: cmd, pwd: working_dir, is_dry_run: is_dry_run? ) }
            end 
        end 

        private
        
        def _print_vagrant_vm_info(environment_name:, vm_name:)
            full_name = environment_name + "-" + vm_name
            
            log.warn "Finished configuring host: #{full_name}"
            log.warn "!!! use information below to ssh/rdp to this host !!!"

            vagrant_config_service = get_service_by_name("metabox::vagrant::config::base")
            vagrant_config_service.print_host_connection_info(
                environment_name: environment_name,
                vm_name: vm_name
            )

            log.warn "!!! --------------------------------------------- !!!"
        end

        def _delete_vagrant_box(vagrant_box_path)

            if env_service.get_metabox_vagrant_delete_boxfile?
                log.info "Deleting vagtant box file: #{vagrant_box_path}"
                FileUtils.rm_rf vagrant_box_path    
            else 
                log.info "Skipping box file deletion: #{vagrant_box_path}"
            end
        end

        def _copy_box_to_shadow_folders(vagrant_box_path) 
            shadow_folders = env_service.get_metabox_vagrant_box_shadow_folders

            if shadow_folders.empty? 
                log.info "Skipping shadow vagrant folders copy"
            else
                shadow_folders_string = "\n - " + shadow_folders.join("\n - ")
                log.info "Copying vagrant box to shadow folders: #{shadow_folders_string}"

                shadow_folders.each do | shadow_folder |
                    target_file_name = File.basename vagrant_box_path
                    target_file_path = File.join shadow_folder, target_file_name

                    log.info "  #{vagrant_box_path} -> #{target_file_path}"

                    FileUtils.copy_file(vagrant_box_path, target_file_path)
                end
            end
        end

        def _get_environment_vm_names(env, current_vm_name)
            vm_names = []

            if current_vm_name == "_all"
                vagrant_resources = document_service.get_vagrant_vm_resources_for_environment(env)
                vagrant_resources.each { | resource_name, resource_value | 
                    vm_names << resource_name.split('::')[1]
                }
               
                vm_names_string = "\n - " + vm_names.join("\n - ")
                log.warn "Processing [#{vm_names.count}] virtual machines in stack: #{env} #{vm_names_string}"
            else 
                vm_names << current_vm_name
            end

            vm_names
        end

        def _get_free_port
            (0..50).each do |n|
                socket = Socket.new(:INET, :STREAM, 0)
                socket.bind(Addrinfo.tcp("127.0.0.1", 0))
                port = socket.local_address.ip_port
                socket.close
                return port
            end
        end

        def _pre_vagrant_vm_provision
            
            begin
                port_number = _get_free_port

                if port_number.nil?
                    port_error_message = "Cannot allocate random port for HTTP server to serve files"
                    log.error port_error_message

                    throw port_error_message
                end

                folder_path = env_service.get_metabox_downloads_path 
                cmd = "ruby -rsinatra -e 'set :public_folder, \"#{folder_path}\"; set :port, #{port_number}'"

                log.debug "spawn-ing: #{cmd}"
                @http_server_pid = spawn(cmd)

                env_service.set_metabox_http_server_addr("10.0.2.2:#{port_number}")

            rescue => exception
                error_message = "Cannot start local HTTP server to serve files for Vagrant VMs. Error: #{exception}"
                log.error error_message

                throw error_message
            ensure
                env_service.set_metabox_http_server_addr("10.0.2.2:#{port_number}")
            end
        end

        def _get_kill_signal

            result = "SIGTERM"

            if os_service.is_windows?
                result = "KILL"
            end

            result

        end

        def _post_vagrant_vm_provision
            if !@http_server_pid.nil?
                begin
                    signal = _get_kill_signal

                    log.info "Signalling: #{signal} for process: #{@http_server_pid}"
                    Process.kill(signal, @http_server_pid)

                    log.info "  - waiting for process to exit: #{@http_server_pid}"
                    Process.wait

                    log.info "  - exited process: #{@http_server_pid}"
                rescue => exception
                    error_message = "Cannot kill local HTTP server process with PID: #{@http_server_pid}. Error: #{exception}"
                    log.error error_message
                end
            end
        end
        
        def _internal_vagrant_up(environment_name:, vm_name:, additional_params:)
            begin
                _execute_pre_vagrant_handlers(environment_name: environment_name, vm_name: vm_name)
                _execute_vagrant_up(environment_name: environment_name, vm_name: vm_name, additional_params: additional_params)
            ensure
                _execute_post_vagrant_handlers(environment_name: environment_name, vm_name: vm_name)
            end
        end

        def _execute_pre_vagrant_handlers(environment_name:, vm_name:)
            log.info "Executing pre-vagrant handlers..."

            vagrant_config_service = get_service_by_name("metabox::vagrant::config::base")
            vagrant_config_service.execute_pre_vagrant_config(environment_name: environment_name, vm_name: vm_name)
        end

        def _execute_pre_vagrant_destroy_handlers(environment_name:, vm_name:)
            log.info "Executing pre-vagrant-destroy handlers..."

            vagrant_config_service = get_service_by_name("metabox::vagrant::config::base")
            vagrant_config_service.execute_pre_vagrant_destroy_config(environment_name: environment_name, vm_name: vm_name)
        end

        def _execute_post_vagrant_handlers(environment_name:, vm_name:)
            log.info "Executing post-vagrant handlers..."

            vagrant_config_service = get_service_by_name("metabox::vagrant::config::base")
            vagrant_config_service.execute_post_vagrant_config(environment_name: environment_name, vm_name: vm_name)
        end

        def _execute_post_vagrant_destroy_handlers(environment_name:, vm_name:)
            log.info "Executing post-vagrant-destroy handlers..."

            vagrant_config_service = get_service_by_name("metabox::vagrant::config::base")
            vagrant_config_service.execute_post_vagrant_destroy_config(environment_name: environment_name, vm_name: vm_name)
        end

        def _get_metabox_params_hash(value)
            
            result = {}
            
            if value.is_a?(Array) && value.count > 1 
                tmp_value = value[1]

                if !tmp_value.nil? && tmp_value.include?("=")
                    split_values = tmp_value.split(';')

                    split_values.each do | split_value |
                        value_parts = split_value.split('=')

                        name = value_parts.first.strip.upcase
                        value = nil 

                        if value_parts.count > 1
                            value = value_parts[1].strip.upcase
                        end

                        result["METABOX_VAGRANT_" + name] = value
                    end

                end
            end

            return result
        end

        def _get_additional_param_value(additional_params)
            result = ""

            if additional_params.is_a?(String)
                result = additional_params
            elsif additional_params.is_a?(Array)
                result = additional_params.first
            end

            result
        end

        def _execute_vagrant_up(environment_name:, vm_name:, additional_params:)

            additional_param_value = _get_additional_param_value(additional_params)
            metabox_param_hash = _get_metabox_params_hash(additional_params)
           
            env_service.set_metabox_variables(metabox_param_hash)
            full_vm_name = environment_name + "-" + vm_name

            log.info "Executing 'vagrant up' task with arguments: #{additional_param_value}, all arguments were: #{additional_params}, metabox params: #{metabox_param_hash}"
            log.debug "Running: -stack: #{environment_name} -vm: #{vm_name} -fullname: #{full_vm_name}"

            working_dir = env_service.get_metabox_vagrant_dir

            # syntax sugar to avoid constant switch between --provision and --force
            # vagrant up/vagrant destroy have different syntax which is annoying something
            if additional_param_value == "--force"
                additional_param_value = "--provision"
            end

            cmd = [
                "vagrant up #{full_vm_name} #{additional_param_value}"
            ].join(' ')

            track_execution("Executing cmd") { os_service.run_cmd(cmd: cmd, pwd: working_dir, is_dry_run: is_dry_run? ) }
        end

        def _get_vagrant_cmd_details(params)
            full_vm_name =  params.first.downcase

            if !full_vm_name.include? ":" 
                error_message = "Full Vagrant VM should be: environment_name:vm_name, but was: #{full_vm_name}"
                log.error error_message
                
                raise error_message
            end

            vm_paths = full_vm_name.split('::')
            vm_resource_name = full_vm_name

            environment_name = vm_paths[0]
            vm_name = vm_paths.drop(1).join('-')

            additional_params = ''
            if params.count > 1
                additional_params = params[1]
            end

            all_additional_params = params.drop(1)

            # checking with actual environments
            vagrant_vms = document_service.get_vagrant_vm_resources
            vagrant_vm_names = vagrant_vms.keys.sort

            if vm_name != "_all" && !vagrant_vm_names.include?(vm_resource_name)
                error_message = "Cannot find vagrant vm resource with name: #{vm_resource_name}"
                resource_names = "\n - " + vagrant_vm_names.join("\n - ")

                log.error error_message
                log.info "Resources were: #{resource_names}"
                
                raise error_message
            end

            {
                :full_vm_name => full_vm_name.gsub('::','-'),
                :environment_name => environment_name,
                :vm_name => vm_name,
                :additional_params => additional_params,
                :all_additional_params => all_additional_params
            }
        end
    end

end