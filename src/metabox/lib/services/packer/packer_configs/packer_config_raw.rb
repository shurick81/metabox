
require_relative 'packer_config_base'

module Metabox

    class PackerConfigRaw < PackerConfigBase

        def name
            "metabox::packer::config::raw"
        end

        def configure_section(name:, value:, packer_config:)

            if name.nil?
                packer_config["tmp"] = value
            else
                packer_config[name] = value
            end
        end

    end

end