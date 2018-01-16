
class HashUtils

    def self.unnest
        new_hash = {}
        each do |key,val|
        if val.is_a?(Hash)
            new_hash.merge!(val.prefix_keys("#{key}."))
        else
            new_hash[key] = val
        end
        end
        new_hash
    end

    def self.prefix_keys(prefix)
        Hash[map{|key,val| [prefix + key, val]}].unnest
    end
    
    def self.get_value_by_path(hash, path, default_value = nil)
            
        result = hash
        
        path_parts = path.split('.')
        current_path = nil

        path_parts.each do | path_part |
            
            if current_path.nil?
                current_path = path_part
            else 
                current_path = current_path + "." + path_part
            end
            
            result = result.fetch(path_part, nil)

            if result.nil?

                # is last value?
                is_last_value = path_part == path_parts.last
                has_default_value = !default_value.nil?

                if has_default_value
                    return default_value
                end

                error_message = "Cannot find section: #{current_path} \n document was: #{hash.to_yaml}"
                raise error_message
            end
        end

        return result

    end
end