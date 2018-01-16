
require_relative 'packer_config_base'

module Metabox

    class PackerConfigPostProcessorsVagrant < PackerConfigBase

        def name
            "packer::post-processors::vagrant"
        end

        def configure_section(name:, value:, packer_config:)

            properties = {
                "type" => "vagrant",
                "keep_input_artifact" => false
            }

            _safe_merge_hash(properties, value.fetch('Properties', {}) )
            packer_config["tmp"] = properties
        end

    end

end