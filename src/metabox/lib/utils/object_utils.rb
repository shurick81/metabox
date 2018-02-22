module Metabox
    module Utils
        class ObjectUtils

            def self.deep_clone(object)
                Marshal.load(Marshal.dump(object))
            end

        end
    end
end