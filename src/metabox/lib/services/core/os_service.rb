
module Metabox

    class OSService < ServiceBase

        def name
            "os"
        end

        def process_windows_cmd(cmd:, masked_cmd: nil) 
            # legacy fixes
            cmd = cmd.gsub('pwd', 'cd')

            # buy default, 'cd' on windows does not change drive
            # this is a fix to ensure drive changes if metabox dirs are on seprate drives
            # https://stackoverflow.com/questions/11065421/command-prompt-wont-change-directory-to-another-drive
            cmd = cmd.gsub('cd ', 'cd /d ')
            
            # fixing up pwsh -> powershell on windows platform
            # 'pwsh' usage makes it work consistently for both win and non-win environments 
            cmd = cmd.gsub('pwsh ', 'powershell ')

            cmd
        end

        def run_cmd(cmd:, is_dry_run: false, pwd: nil, silent: false, valid_exit_codes: [0])
            
            if is_windows?
                cmd = process_windows_cmd(cmd: cmd)
            end

            if pwd.nil?
                pwd = env_service.get_metabox_working_dir
            end

            env_vars = env_service.get_metabox_variables

            metabox_cmds = []
            metabox_masked_cmds = []

            env_vars.each { | key, value |

                tmp_value = value

                if key.downcase.include?("key") || name.downcase.include?("password")
                    tmp_value = "****************"
                end

                if(is_windows?)
                    metabox_cmds << "SET \"#{key}=#{value}\""
                    metabox_masked_cmds << "SET \"#{key}=#{tmp_value}\""
                else
                    metabox_cmds << "#{key}=#{value}"
                    metabox_masked_cmds << "#{key}=#{tmp_value}"
                end
            }

            if(is_windows?)
                metabox_cmd = metabox_cmds.join(' && ')
                metabox_masked_cmd = metabox_masked_cmds.join(' && ')
            else
                metabox_cmd = metabox_cmds.join(' ')
                metabox_masked_cmd = metabox_masked_cmds.join(' ')
            end

            result = true
            
            final_cmd = "" 
            final_cmd_masked = "" 

            exitstatus = nil

            if is_windows?
                final_cmd = "cd /d #{pwd} && #{metabox_cmd} && #{cmd}"
                final_cmd_masked =  "cd /d #{pwd} && #{metabox_masked_cmd} && #{cmd}"
            else
                final_cmd = "cd #{pwd} && #{metabox_cmd} #{cmd}"
                final_cmd_masked =  "cd #{pwd} && #{metabox_masked_cmd} #{cmd}"
            end
            
            if !is_dry_run
                if !silent
                    log.info "Running cmd:"
                    log.info "  #{final_cmd_masked}"
                end

                result = system(final_cmd)
                exitstatus = $?.exitstatus
            else
                if !silent
                    log.warn "DRY RUN!"
                    log.warn "#{final_cmd_masked}"
                end
            end 

            if !silent
                log.info "Finished running cmd with result: [#{result}]"
            end

            if(result != true)
                
                if !exitstatus.nil? && valid_exit_codes.include?(exitstatus)
                    log.debug "result failed but valid_exit_codes: #{exitstatus} among #{valid_exit_codes}"
                else
                    error_message = "Failed running cmd, exitstatus: #{exitstatus}: #{final_cmd_masked}"
                    log.error error_message

                    raise error_message
                end
            end

            return result
        end

        def is_windows? 
            ENV['OS'] == 'Windows_NT'
        end
    end
end