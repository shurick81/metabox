
require_relative 'packer_config_base'

module Metabox

    class PackerConfigProvisionerShellCentOS7 < PackerConfigBase

        def name
            "packer::provisioners::shell_centos7"
        end

        def configure_section(name:, value:, packer_config:)

            properties = {
                "type" => "shell",
                "execute_command" => "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'" 
            }

            _safe_merge_hash(properties, value.fetch('Properties', {}) )
            packer_config["tmp"] = properties
        end

    end

end