require 'yaml'

module Metabox
    class RevisionService < ServiceBase

        def name
            "metabox::core::revision"
        end       

        def apply_revisions(resource_config:, vm_config:, stack_name:, vm_name:)
            _apply_revisions(resource_config: resource_config, vm_config: vm_config, stack_name: stack_name, vm_name: vm_name)
        end

        private

        def _apply_revisions(resource_config:, vm_config:, stack_name:, vm_name:)
            
            log.info "Applying revisions for stack: #{stack_name}, vm: #{vm_name}"
            revisions = _load_revisions
           
            log.debug "Filtering revisions..."
            active_revisions = _filter_revisions(
                revisions: revisions,
                resource_config: resource_config,
                stack_name: stack_name,
                vm_name: vm_name
            )

            log.debug "Mergin filtered revisions with original Vagrant template..."         
            vagrant_config = resource_config.fetch('VagrantTemplate')

            active_revisions.each  { | name,  revision |
            revision_vagrant_templates = revision.fetch('VagrantTemplate')
                log.verbose "Adding revision: #{name} to Vagrant template: "
                
                revision_vagrant_templates.each do | revision_vagrant_template | 
                    vagrant_config << revision_vagrant_template
                end
            }
            
        end

        def _filter_revisions(revisions:, resource_config:, stack_name:, vm_name:) 
            result = {}

            vm_full_name = "#{stack_name}::#{vm_name}"
            vm_tags      = resource_config.fetch('Tags', [])
            
            revisions.each  { | name, revision |

                revision_title = revision.fetch('Name', "")
                revision_target_resources = revision.fetch('TargetResource')

                has_name_match = _has_name_match?(revision, revision_target_resources, vm_full_name)
                has_tag_match  = _has_tag_match?(revision, revision_target_resources, vm_tags)

                log.debug "name-tag match: #{has_name_match}/#{has_tag_match}"
              
                if has_name_match || has_tag_match

                    if has_name_match && has_tag_match
                        log.info "  [+/b] #{name}"
                    elsif has_name_match
                        log.info "  [+/n] #{name}"
                    else
                        log.info "  [+/t] #{name}"
                    end

                    result[name] = revision
                else
                    log.warn "  [-/-] #{name}"
                end
            }
 
            result
        end

        def _check_string_match(value, match_value)
            has_match = false

            if value.nil? || match_value.nil?
                return false
            end

            if match_value == "*"
                return true
            end

            if match_value.include? "*"
                sub_value = match_value.split('*').first.downcase
                has_match = value.start_with?(sub_value.downcase)
            else
                has_match = value.downcase == match_value.downcase
            end

            has_match
        end

        def _has_name_match?(revision, revision_target_resources, vm_full_name) 
            matches = revision_target_resources.select { |v| v.fetch('MatchType') == "name" }

            matches.each do | match |
                match_values = match.fetch('Values')

                match_values.each do | match_value |
                    has_match = _check_string_match(vm_full_name, match_value)

                    if has_match
                        return has_match
                    end
                end
            end

            return false
        end

        def _has_tag_match?(revision, revision_target_resources, tags) 
            matches = revision_target_resources.select { |v| v.fetch('MatchType') == "tag" }

            matches.each do | match |
                match_values = match.fetch('Values')

                match_values.each do | match_value |

                    tags.each do | tag |

                        has_match = _check_string_match(tag, match_value)

                        if has_match
                            return has_match
                        end
                    end
                end
            end

            return false
        end

        def _load_revisions
            result = nil

            log.debug "Loading all revisions..."
            result = document_service.get_revision_resources

            log.debug "Found #{result.count} revisions"
            log.verbose result.to_yaml

            result
        end
        
    end
end