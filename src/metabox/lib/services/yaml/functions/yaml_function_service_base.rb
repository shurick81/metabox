require 'yaml'

require_relative '../yaml_service_base'

module Metabox
    class YamlFunctionServiceBase < ServiceBase

        def name
            "yaml::function::base"
        end

        def order
            100
        end

        def function_aliases
            []
        end

        def process(hash)
           
            if hash.nil?
                return
            end

            root = hash

            tree = []

            _add_tree_node(tree: tree, name: nil, value: hash)
            _internal_process(root: root, tree: tree, hash: hash)
        end

        private

        def _get_function_value(tree:, value:)

            function_aliases.each do | function_aliase |
                if value.is_a?(String) && value.include?(function_aliase)
                    function_param = value.split(function_aliase)[1].strip
                    function_value = _lookup_parameter(tree: tree, name: function_param)

                    return function_value
                end
            end

            return value
        end

        def _add_tree_node(tree:, name:, value:) 
            tree << {
                name: name, 
                value: value
            }
        end

        def _process_array_property(root:, tree:, name:, value:) 
            {
                :name => name, 
                :value => value
            }
        end

        def _process_hash_property(root:, tree:, name:, value:) 
            {
                name: name, 
                value: value
            }
        end

        def _process_simple_property(root:, tree:, name:, value:) 
            {
                name: name, 
                value: value
            }
        end

        def _process_key_replacements(hash:, new_hash:)
            new_hash.each { |name, value| 
                hash.delete(name)
                hash[name] = value
            }
        end

        def _process_properties(root:, tree:, name:, value:) 
            if value.is_a?(Hash)
                return _process_hash_property(root: root, tree: tree, name: name, value: value) 
            elsif value.is_a?(Array)
                return _process_array_property(root: root, tree: tree, name: name, value: value) 
            end

            return _process_simple_property(root: root, tree: tree, name: name, value: value)          
        end

        def _get_tree_parameter_sections(tree:) 
            _get_tree_sections(
                tree: tree,
                section_name: 'Parameters'
            )
        end

        def _get_first_tree_resource_sections(tree:)
            _get_first_tree_sections(tree: tree, section_name: 'Resources')
        end

        def get_first_tree_environment_section_name(tree:)
            result = []
            
            tree.each do | tree_node | 
                node = tree_node[:value]
                node_name = tree_node[:name]

                if node.is_a?(Hash) && node.fetch('Type', nil) == "vagrant::stack"
                    return node_name
                end

            end

            raise "Cannot find environment section in document tree"
        end

        def get_first_tree_vagrant_section_name(tree:)
            result = []
            
            tree.each do | tree_node | 
                node = tree_node[:value]
                node_name = tree_node[:name]

                if node.is_a?(Hash) && node.fetch('VagrantTemplate', nil) != nil
                    return node_name
                end

            end

            raise "Cannot find resource section in document tree"
        end

        def _get_first_tree_sections(tree:, section_name:) 
            
            result = []
            
            tree.each do | tree_node | 
                node = tree_node[:value]
                node_name = tree_node[:name]

                if node.is_a?(Hash) && node_name == section_name
                    return tree_node[:value]
                end

            end

            []
        end

        def _get_tree_sections(tree:,section_name:) 
            
            result = []
            
            tree.each do | tree_node | 
                node = tree_node[:value]

                if node.is_a?(Hash)
                    section = node.fetch(section_name, nil)
                end

                if !section.nil?
                    result << {
                        name: tree_node[:name],
                        value: section
                    }
                end
            end

            result.reverse
        end

        def _internal_process(root:, tree:, hash:) 

            key_replacements = {}            

            hash.each { | name, value | 

                _add_tree_node(tree: tree, name: name, value: value)

                new_value = _process_properties(root: root, tree: tree, name: name, value: value)

                is_section_replace = new_value[:name] != name
               
                if is_section_replace
                    key_replacements[name] = new_value
                else 
                    if(hash[name] != new_value[:value])
                        hash[name] = new_value[:value]
                    end
                end

                if value.is_a? Array
                    new_array_value = []

                    value.each do | array_value |

                        array_value_clone =  ObjectUtils.deep_clone(array_value)

                        if array_value_clone.is_a? Hash
                            _internal_process(root: root, tree: tree, hash: array_value_clone)
                            new_array_value << array_value_clone
                        else
                            if !array_value_clone.is_a? Array
                                replaced = _process_properties(root: root, tree: tree, name: nil, value: array_value_clone)
                                new_array_value << replaced[:value]
                            else
                                new_array_value << array_value_clone
                            end
                        end
                    end

                    hash[name] = new_array_value
                    
                end

                if value.is_a? Hash
                    if(is_section_replace)
                        _internal_process(root: root, tree: tree, hash: key_replacements[name][:value])
                    else
                        _internal_process(root: root, tree: tree, hash: value)
                    end
                end

                tree.pop
            }

            key_replacements.each { |name, value| 
                hash.delete(name)
                hash[value[:name]] = value[:value]
            }
        end
       
    end
end
