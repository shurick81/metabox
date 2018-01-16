module Metabox

    module Document

        class DocumentGeneratorBase < ServiceBase

            def process(context:, resources:) 
                
            end

            private 

            def _get_resources_by_type(resources, type_name)
                resources.select { |key, value| value.fetch('Type', nil) == type_name  }
            end

        end

    end

end
