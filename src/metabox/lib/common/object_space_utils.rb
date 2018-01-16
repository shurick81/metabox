
class ObjectSpaceUtils


    def self.load_metabox_classes(parent_class:)
        
        result = []
        classes = load_classes(parent_class: parent_class)
                
        classes.each do |klass|
            class_name = klass.to_s

            if(!class_name.include?("Metabox::"))
                next
            end

            result << klass
        end

        result
    end

    def self.load_classes(parent_class:)
        result = []
                
        ObjectSpace.each_object do |klass|
            next unless Module === klass 

            class_name = klass.to_s

            if class_name.include?("#") 
                next
            end

            result << klass if parent_class >= klass
        end

        result
    end

end