
module Metabox

    class ToolValidationService < ServiceBase

        def initialize
            
        end
        
        def name
            "metabox::core::tool_validation_service"
        end

        def require_tools(tool_names:)
            result = {}

            tool_names.each do | tool_name |
                result[tool_name] = _has_tool(tool_name: tool_name)
            end

            has_all_tools = true
            
            result.each { | name, presence |
                presence_string = _get_presence_string(presence)

                if presence
                    log.info "  - #{presence_string} #{name}"
                else
                    log.error "  - #{presence_string} #{name}"
                    has_all_tools = false
                end
            }

            if !has_all_tools
                error_message = "Canot find all tools required by resource"
                log.error error_message

                raise error_message
            end
        end

        private

        def _get_presence_string(value)
            if value 
                "[+]"
            else
                "[-]"
            end
        end

        def _has_tool(tool_name:)
            cmd = _get_validation_cmd(tool_name)
            result = run_cmd(cmd: cmd, silent: true, valid_exit_codes: [0,1])

            return result
        end

        def _get_validation_cmd(tool_name) 

            if os_service.is_windows? 
                "exit (Get-Command -Name #{tool_name} -ErrorAction SilentlyContinue) -ne $null)"
            else
                "which #{tool_name}"
            end

        end

    end
end