module Metabox

    module VagrantConfigs

        class VagrantConfigCustomSHell < VagrantConfigBase

            def initialize

            end

            def name 
                "metabox::custom::shell"
            end

            def pre_vagrant(config:)

                if !should_run?(config: config) 
                    return 
                end

                _execute_scripts(config, 'pre_vagrant')
            end

            def pre_vagrant_destroy(config:)

                if !should_run?(config: config) 
                    return 
                end

                _execute_scripts(config, 'pre_vagrant_destroy')
            end

            def post_vagrant(config:)

                if !should_run?(config: config) 
                    return 
                end

                _execute_scripts(config, 'post_vagrant')
            end

            def post_vagrant_destroy(config:)

                if !should_run?(config: config) 
                    return 
                end

                _execute_scripts(config, 'post_vagrant_destroy')
            end

            def _execute_scripts(config, section)
                scripts = _get_script_sections(config, section)

                _execute_inline_scripts(scripts[:inline])
                _execute_file_scripts(scripts[:scripts])
            end

            def _execute_file_scripts(script_paths)
                
                if script_paths.nil? || script_paths.empty?
                    return
                end

                raise "not implemented yet"
            end

            def _execute_inline_scripts(scripts)

                if scripts.nil? || scripts.empty?
                    return
                end

                home_folder = env_service.get_metabox_vagrant_dir

                # we need to exclude VAGRANT_PROVISION_TAGS variable from custom inline script
                # custom hooks are used to setup/shutdown CI agents
                # if this variable gets into CI agent, then Vagant will always be run in 'revision' mode
                # hence, eliminatibg these vars from custom hooks
                scripts.each do | script |
                    run_cmd(cmd: "#{script}", pwd: home_folder, exclude_variables: [
                        "METABOX_VAGRANT_PROVISION_TAGS",
                        "VAGRANT_PROVISION_TAGS"
                    ])
                end
            end

            def _get_script_sections(config, section)
                props = config.fetch('Properties',{})
                hooks = props.fetch('hooks',{})

                target_section = hooks.fetch(section, {})

                {
                    :inline =>target_section.fetch('inline', []),
                    :scripts =>target_section.fetch('scripts', [])
                }
            end

            def configure_host(config:, vm_config:)

                if !should_run?(config: config) 
                    return 
                end    

                default_properties = {
                  
                }

                _safe_merge_hash(default_properties, config.fetch('Properties', {}))
                _execute_scripts(config, 'vagrant')
            end

        end

    end

end