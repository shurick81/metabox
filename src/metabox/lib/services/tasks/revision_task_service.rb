
require_relative "task_service_base"
require 'json'

module Metabox

    class RevisionTaskService < TaskServiceBase

        def name 
            "metabox::tasks:revision"
        end

        def rake_alias 
            "revision"
        end

        def apply(params)
            service = get_service_by_name("metabox::tasks:metabox")
            service.apply_revision(params)
        end

        
    end

end