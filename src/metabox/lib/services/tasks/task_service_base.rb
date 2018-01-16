

module Metabox

    class TaskServiceBase < ServiceBase

        def name 
            "metabox::tasks:base"
        end

        def rake_alias 
            "base"
        end

    end

end