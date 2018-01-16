require 'yaml'

module Metabox
    class SchemaValidationService < ServiceBase

        def name
            "metabox::core::schema_validation"
        end

        def validate_hash(hash, schema) 
            _internal_validate_hash(hash, schema)
        end

        def get_schema_example(meta_schema)
            result = {}
           
            meta_schema.each { | prop_name, prop_value |
                is_meta_hash = prop_value.is_a?(Hash) && prop_value.keys.include?(:comments)
    
                comments = prop_value[:comments]
                required = prop_value[:required]
                value = prop_value[:value]
    
                comments_string = ""

                if !comments.nil? && !comments.empty?
                    comments_string = "# #{required} #{comments}, #{value}"
                else
                    comments_string = "# #{required}, no description provided, #{value}"
                end
    
                if !is_meta_hash
                    comments_string = "# #{prop_value.class.to_s}"
                end

                result[prop_name + "__Comment"] = comments_string    

                if is_meta_hash
                    result[prop_name] = value
                else
                    result[prop_name] = get_schema_example prop_value
                end
            }
    
            result
        end
    
        def get_schema_example_yaml(schema) 
    
            schema_metadata = get_schema_metadata schema
            yaml = get_schema_example(schema_metadata).to_yaml
    
            regexp =  Regexp::new("(\\w+__Comment): \"(\# .+)\"")
    
            result = []
    
            yaml.split("\n").each do | line |
                new_line = line
                regexp_match = regexp.match(new_line)  
    
                if !regexp_match.nil? && !regexp_match.captures.nil? && regexp_match.captures.count == 2
                    
                    name_value = regexp_match.captures[0] 
                    comment_value = regexp_match.captures[1] 
    
                    trim_value = name_value + ": "
                    new_line = new_line.gsub(trim_value, '').tr('\"','')
                end
    
                result << new_line
            end
    
            result.join("\n")
        end
       
        def get_schema_metadata(schema)
            result = {}
    
            schema.each { | prop_name, prop_value |
    
                is_meta_hash = prop_value.is_a?(Hash) && prop_value.keys.include?(:type)
    
                type_value = prop_value[:type]
                value = prop_value[:value]
                comments = prop_value[:comments]
                required = prop_value[:required]
    
                required_string = "[r]"
                
                if required.nil? 
                    required_string = "[r]"
                else 
                    if required == true
                        required_string = "[r]"
                    else
                        required_string = "[o]"
                    end
                end
    
                if type_value.nil?
                    type_value = prop_value.class.to_s
                end
    
                comments_string = comments
                value_string = type_value
                
                if !value.nil? && !value.empty?
                    value_string = value
                end
    
                if is_meta_hash
                    result[prop_name] = {
                        :comments => comments_string,
                        :required => required_string,
                        :value => value_string
                    }
                else
                    result[prop_name] = get_schema_metadata(prop_value)
                end
            }
    
            result
        end

        private 

        def _internal_validate_hash(hash, schema) 

        end
        
    end
end
