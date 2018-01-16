
module Metabox

    class PackerConfigCore < PackerConfigBase

        @default_type;

        def name
            "metabox::packer::core"
        end

        def configure_section(name:, value:, packer_config:)

            properties = {
                "type" => "file",

                "source" => "./scripts/vagrant/metabox.vagrant.core/_metabox_core.ps1",
                "destination" => "c:/Windows/Temp/_metabox_core.ps1"
            }

            _safe_merge_hash(properties, value.fetch('Properties', {}) )
            packer_config["tmp"] = properties
        end

        private
     
    end

end