module Metabox

    module Document

        class DocumentGeneratorBase < ServiceBase

            def process(context:, resources:) 
                
            end

            private 

            def _get_resources_by_type(resources, type)
                resources.select { |key, value| value.is_a?(type)  }
            end

        end

    end

end
