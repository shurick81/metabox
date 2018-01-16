module Metabox

    module VagrantConfigs

        class VagrantConfigStack < VagrantConfigBase

            def initialize

            end

            def name 
                "vagrant::stack"
            end
           
            def _get_vagrant_template(resource_value) 

                os = resource_value.fetch('OS', 'windows')
                result = resource_value.fetch('VagrantTemplate')

                case os.downcase
                when "windows"
                    _inject_metabox_windows_vagrant_sections(result)
                when "linux"
                    _inject_metabox_linux_vagrant_sections(result)
                else
                    raise "Unsupported OS: #{os}"
                end
                
                result
            end

            def _inject_metabox_linux_vagrant_sections(vagrant_template_section)

            end

            def _inject_metabox_windows_vagrant_sections(vagrant_template_section) 

                # always update metabox core script on target Vagrant VM
                vagrant_template_section.insert(0, {
                    "Type" => "metabox::vagrant::core"
                })

                vagrant_template_section
            end

            def pre_vagrant(config:)
                config.each { | environment_name, environment_value |
                    log.info "pre_vagrant: stack: #{environment_name}"

                    # vm name -> environment + resource
                    resources = environment_value.fetch('Resources')
                    
                    resources.each { | resource_name, resource_value |
                        vm_name = (environment_name + "-" + resource_name).downcase

                        environment_config = {}
                        environment_config[environment_name] = {
                            "Resources" => {}    
                        }

                        environment_config[environment_name]["Resources"][resource_name] = resource_value

                        vagrant_template_section = _get_vagrant_template(resource_value)

                        vagrant_template_section.each do | template |
                            type = template.fetch('Type')
                            service = get_service_by_name(type)

                            log.info "  - pre_vagrant on service: #{service.name}"

                            service.environment_config = environment_config;
                            service.pre_vagrant(config: template)
                        end
                    }
                }
            end

            def post_vagrant(config:)

                log.verbose "incoming config"
                log.verbose config.to_yaml

                config.each { | environment_name, environment_value |
                    log.info "post_vagrant: stack: #{environment_name}"
                    #log.warn environment_value.to_yaml

                    # vm name -> environment + resource
                    resources = environment_value.fetch('Resources')
                    
                    resources.each { | resource_name, resource_value |
                        vm_name = (environment_name + "-" + resource_name).downcase

                        environment_config = {}
                        environment_config[environment_name] = {
                            "Resources" => {}    
                        }

                        environment_config[environment_name]["Resources"][resource_name] = resource_value

                        vagrant_template_section = _get_vagrant_template(resource_value)

                        vagrant_template_section.each do | template |
                            type = template.fetch('Type')
                            service = get_service_by_name(type)

                            log.info "  - post_vagrant on service: #{service.name}"

                            service.environment_config = environment_config;

                            begin
                                service.post_vagrant(config: template)
                            rescue => exception
                                log.error "Error on post-vagrant service: #{service.name}"
                                log.error "#{exception}"
                            end
                        end
                    }
                }
            end

            def configure_host(config:, vm_config:)
                _configire_vagrant_handlers(config: config, vm_config: vm_config)
            end

            def _configire_resource_revisions(environment_name:, resource_name:, resource_config:, vm_config:)
                
                log.info "Configuring revisions: #{environment_name} and vm: #{resource_name}"

                if !env_service.metabox_features_revisions?
                    log.info "  - revisions feature is disabled"
                    return 
                end
                
                log.verbose resource_config.to_yaml

                revision_service = get_service_by_name("metabox::core::revision")
                revision_service.apply_revisions(
                    resource_config: resource_config,
                    vm_config: vm_config,
                    stack_name: environment_name,
                    vm_name: resource_name
                )
            end

            def _configire_vagrant_handlers(config:, vm_config:)
                config.each { | environment_name, environment_value |
                    log.info "  stack: #{environment_name}"

                    # vm name -> environment + resource
                    resources = environment_value.fetch('Resources')
                    
                    # configuring stack resources
                    resources.each { | resource_name, resource_value |
                        vm_name = (environment_name + "-" + resource_name).downcase

                        environment_config = {}
                        environment_config[environment_name] = {
                            "Resources" => {}    
                        }

                        environment_config[environment_name]["Resources"][resource_name] = resource_value

                        log.info "      - vm: #{vm_name}"

                        vm_config.vm.define vm_name do |vm|

                            # configuring revisions
                            _configire_resource_revisions(
                                environment_name: environment_name, 
                                resource_name: resource_name,
                                resource_config: resource_value,
                                vm_config: vm
                            )

                            # process VagrantTemplate for a resorce
                            _process_vagrant_template(
                                environment_config: environment_config,
                                resource_config: resource_value, 
                                vm_config: vm)
                            
                        end

                        
                    }
                }
            end

            def _process_vagrant_template(environment_config:, resource_config:, vm_config:) 
                vagrant_template_section = _get_vagrant_template(resource_config)

                vagrant_template_section.each do | template |
                    type = template.fetch('Type')
                    service = get_service_by_name(type)

                    log.verbose "   - service: #{service.name}"

                    service.environment_config = environment_config;
                    service.configure_host(config: template, vm_config: vm_config)
                end
            end

        end

    end

end