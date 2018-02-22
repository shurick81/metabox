
require_relative "task_service_base"
require 'json'

module Metabox

    class ResourceTaskService < TaskServiceBase

        def name 
            "metabox::tasks:resource"
        end

        def rake_alias 
            "resource"
        end

        def list(params)

            #log.info "Running task [#{__method__}] with arguments: #{params}"
            
            document_service.list params
        end

        def generate(params)
            #log.info "Running task [#{__method__}] with arguments: #{params}"
     
            document_service.generate params
        end

    end

end