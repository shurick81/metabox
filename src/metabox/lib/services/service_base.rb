require 'logger'
require 'objspace'
require 'yaml'
require 'json'

require_relative "service_container.rb"
require_relative "core/log_service.rb"
require_relative "core/log_service.rb"

include Metabox::Utils

module Metabox
    
    class ServiceBase
        
        @@timers = {}

        def initialize
            
        end

        def name
            "service_base"
        end
        
        def track_execution(name, &block)

            tracker_id = get_random_string

            begin
                @@timers[tracker_id] = Time.now

                log.info "#{name} - started"
                block.call
            rescue => exception
                log.error "Error while executing block"
                log.error exception

                raise exception
            ensure
                elapsed_time = 0
                begin
                    elapsed_time = Time.now - @@timers[tracker_id]
                ensure
                    begin
                        @@timers.delete(tracker_id)
                    end
                end
                format = (Time.mktime(0)+ elapsed_time).strftime("%H:%M:%S")
                log.info "#{name} - finished in #{format}"
            end

        end

        def is_dry_run? 
            value = env_service.get_env_variables.fetch('METABOX_DRY_RUN', nil)
            return value.nil? == false
        end

        def get_random_string
            RndUtils.get_random_string
        end

        def get_metabox_branch
            current_metabox_branch
        end

        def current_metabox_branch

            result = ENV.fetch("METABOX_GIT_BRANCH", nil)

            if result.nil?

                # TODO - auto detect metabox branch here would be really fancy
                # but needs to be working under both win/mac platforms

                # defaulting to 'beta' 
                #log.warn("'METABOX_GIT_BRANCH' env variable is nil or empty. Trying to use git to extract current branch")

                # file = nil

                # begin
                #     file = open('|git rev-parse --abbrev-ref HEAD')
                #     result = file.read
                # rescue => exception 
                #     log.error("Coudn't get current branch from git. Using 'master' ENV variable")
                #     result = "master"
                # ensure
                #     if !file.nil?
                #         begin
                #             file.close
                #         rescue => file_close_exeption
                #             log.warn "Error while closing file: #{file_close_exeption}" 
                #         end
                #     end
                # end
                
                result = 'beta'
            end

            result = result.gsub("\n",'').gsub("\r\n",'')

            result
        end
        
        def get_service(service_type)
            Metabox::ServiceContainer.instance.get_service(service_type)
        end

        def get_service_by_name(service_name)
            Metabox::ServiceContainer.instance.get_service_by_name(service_name)
        end

        def get_services(service_type)
            Metabox::ServiceContainer.instance.get_services(service_type)
        end

        def services 
            Metabox::ServiceContainer.instance
        end

        def log
            services.get_service(Metabox::LogService) 
        end

        def env_service 
            services.get_service(Metabox::EnvironmentService) 
        end

        def os_service 
            services.get_service(Metabox::OSService) 
        end

        def packer_service 
            services.get_service(Metabox::PackerService) 
        end

        def yaml_service
            get_service(Metabox::YamlConfigService)
        end

        def virtualbox_service
            get_service_by_name("metabox::core::virtualbox_service")
        end

        def task_service
            get_service_by_name("metabox::core::task_execution_service")
        end

        def tool_validation_service
            get_service_by_name("metabox::core::tool_validation_service")
        end

        def document_service
            _get_document_service
        end

        def _get_document_service
            get_service(Metabox::DocumentService)
        end

        def run_cmd(cmd:, silent: false, pwd: nil, valid_exit_codes:[0], exclude_variables: nil)
            os_service.run_cmd(
                cmd:cmd, 
                silent: silent, 
                pwd: pwd, 
                valid_exit_codes: valid_exit_codes,
                exclude_variables: exclude_variables)
        end

        def create_packer_vars_file(template_name:)
            env_service.create_packer_vars_file(template_name:template_name)
        end

        def create_packer_vars_file(template_name:)
            env_service.create_packer_vars_file(template_name:template_name)
        end

        def get_section_value(hash, path, default_value = nil)
            HashUtils.get_value_by_path(hash, path, default_value)
        end

        private 

        def _env
            env_service.get_env_variables
        end

        def _load_classes(parent_class:)
            ObjectSpaceUtils.load_metabox_classes(parent_class: parent_class)
        end
        
        def _safe_merge_hash(to, from)

            from.each { | name, value |

                if !to.keys.include? name
                    to[name] = ObjectUtils.deep_clone(value)
                else
                    if value.is_a? Hash 
                        _safe_merge_hash(to[name], from[name])
                    else
                        to[name] = ObjectUtils.deep_clone(value)
                    end
                end

            }

        end

        def _get_metabox_env_variables
            # get all metabox env variables
            env_variables = _env.select { |k, v| k.downcase.include?("metabox_") }
            env_variables = env_variables.collect{|k,v| [k.to_s.upcase, v]}.to_h

            if(env_variables.keys.include? "METABOX_GIT_BRANCH" != true)
                env_variables["METABOX_GIT_BRANCH"] = current_metabox_branch
            elsif env_variables["METABOX_GIT_BRANCH"] == nil || env_variables["METABOX_GIT_BRANCH"].empty?
                env_variables["METABOX_GIT_BRANCH"] = current_metabox_branch
            end

            env_variables
        end

        def _process_env_variables(hash:)
            
            key_replacements = {}

            # update all values such as
            # "${ENV:METABOX_GIT_BRANCH}"
            # "${ENV:METABOX_DOWNLOADS_PATH}/7zip/7z1604.msi"
            hash.each { | name, value |

                #log.debug "Processing: #{name}"

                # replace string value
                if value.is_a?(String) 
                    hash[name] = _get_replaced_env_varaible value
                end

                # check is the whole section needs to be replaced
                if name.is_a?(String) && name.upcase.include?("${ENV:")
                    new_section_name = _get_replaced_env_varaible name
                    section_clone = Object.deep_clone(value)

                    key_replacements[name] = {
                        name: new_section_name,
                        value: section_clone
                    }
                end

                if(value.is_a?(Hash))
                    if( key_replacements[name] == nil)
                        _process_env_variables(hash: value) 
                    else
                        _process_env_variables(hash: key_replacements[name][:value]) 
                    end
                end
            }

            key_replacements.each { |name, value| 
                hash.delete(name)
                hash[value[:name]] = value[:value]
            }

        end

    end
end