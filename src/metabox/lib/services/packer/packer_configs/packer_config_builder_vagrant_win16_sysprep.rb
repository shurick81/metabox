
require_relative 'packer_config_base'

module Metabox

    class PackerConfigBuilderVagrantWin16SysPrep < PackerConfigBase

        def name
            "packer::builders::vagrant_win16_sysprep"
        end

        def configure_section(name:, value:, packer_config:)

            properties = {
                "type" => "vagrant",

                "box_provider" => "virtualbox",
                "box_file" => ".ovf",

                'builder' => {
                    "type" =>  "virtualbox-ovf",
                    "headless" =>  'true',
                    "boot_wait" =>  "30s",
                    
                    "ssh_username" =>  "vagrant",
                    "ssh_password" =>  "vagrant",
                    "ssh_wait_timeout" =>  "8h",
                    
                    "shutdown_command" => "IF EXIST c:\\run-sysprep.cmd (CALL c:\\run-sysprep.cmd) ELSE (IF EXIST e:\\run-sysprep.cmd (CALL e:\\run-sysprep.cmd) ELSE (CALL f:\\run-sysprep.cmd)) &IF \"%ERRORLEVEL%\" == \"0\" (ECHO \"Shutdown script succeeded with exit code = %ERRORLEVEL%\" &EXIT 0) ELSE (ECHO \"Shutdown script failed with exit code = %ERRORLEVEL%\" &EXIT %ERRORLEVEL%)",
                    "shutdown_timeout" => "15m"
                }
            }

            _safe_merge_hash(properties, value.fetch('Properties', {}) )
            packer_config["tmp"] = properties
        end

    end

end