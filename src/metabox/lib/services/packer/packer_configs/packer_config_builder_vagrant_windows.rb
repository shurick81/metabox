
require_relative 'packer_config_base'

module Metabox

    class PackerConfigBuilderVagrantWindows < PackerConfigBase

        def name
            "packer::builders::vagrant_windows"
        end

        def configure_section(name:, value:, packer_config:)

            properties = {
                "type" => "vagrant",

                "box_name" => "opentable/win-2012r2-standard-amd64-nocm",
                "box_provider" => "virtualbox",
                "box_file" => ".ovf",

                'builder' => {
                    "output_directory" => "output-centos7-mb-canary-{{ user `metabox_git_branch` }}",
                    "type" =>  "virtualbox-ovf",
                    "headless" =>  'true',
                    "boot_wait" =>  "30s",
                    "ssh_username" =>  "vagrant",
                    "ssh_password" =>  "vagrant",
                    "ssh_wait_timeout" =>  "8h",
                    "shutdown_command" => "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\"",
                    "shutdown_timeout" => "15m"
                }
            }

            _safe_merge_hash(properties, value.fetch('Properties', {}) )
            packer_config["tmp"] = properties
        end

    end

end