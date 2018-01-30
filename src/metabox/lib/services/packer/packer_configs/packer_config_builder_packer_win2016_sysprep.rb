
require_relative 'packer_config_base'

module Metabox

    class PackerConfigBuilderPackerWin16SysPrep < PackerConfigBase

        def name
            "packer::builders::packer_win16_sysprep"
        end

        def configure_section(name:, value:, packer_config:)

            properties = {
                "type" => "virtualbox-iso",

                # Error removing floppy controller #2401
                # https://github.com/hashicorp/packer/issues/2401
                "headless" => true,

                "guest_additions_mode" => "attach",
                "guest_os_type" => "Windows2012_64",

                "communicator" => "winrm",

                "winrm_username" => "vagrant",
                "winrm_password" => "vagrant",
                "winrm_timeout" => "12h",
                
                "shutdown_command" => "IF EXIST c:\\run-sysprep.cmd (CALL c:\\run-sysprep.cmd) ELSE (IF EXIST e:\\run-sysprep.cmd (CALL e:\\run-sysprep.cmd) ELSE (CALL f:\\run-sysprep.cmd)) &IF \"%ERRORLEVEL%\" == \"0\" (ECHO \"Shutdown script succeeded with exit code = %ERRORLEVEL%\" &EXIT 0) ELSE (ECHO \"Shutdown script failed with exit code = %ERRORLEVEL%\" &EXIT %ERRORLEVEL%)",
                "shutdown_timeout" => "15m",
                "post_shutdown_delay" => "2m",

                "floppy_files" => [
                   "./scripts/packer/metabox.packer.core/answer_files/2016/autounattend.xml",
                   "./scripts/packer/metabox.packer.core/win2016/winrm.ps1",
                   "./scripts/packer/metabox.packer.core/win2016/run-sysprep-nounattend.cmd",
                   "./scripts/packer/metabox.packer.core/win2016/run-sysprep-nounattend.ps1"
                ],

                "vboxmanage" => [
                    [ "modifyvm", "{{.Name}}", "--memory", "2048" ],
                    [ "modifyvm", "{{.Name}}", "--vram", "48" ],
                    [ "modifyvm", "{{.Name}}", "--cpus", "2" ]
                ]
    
            }

            _safe_merge_hash(properties, value.fetch('Properties', {}) )
            packer_config["tmp"] = properties
        end


    end

end