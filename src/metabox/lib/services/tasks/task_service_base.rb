

module Metabox

    class TaskServiceBase < ServiceBase

        def name 
            "metabox::tasks:base"
        end

        def rake_alias 
            "base"
        end

        private 

        def _execute_workflow(tasks:) 
            all_tasks_count = tasks.count
            task_flow = " \n - " + (tasks.collect { |t| t[:name] + "#{t[:params]}" }).join("\n - ")

            log.info "  - executing [#{all_tasks_count}] tasks: #{task_flow}"

            tasks.each do | task |
                current_task_index = (tasks.index(task) + 1)
            
                log.info "  - [#{current_task_index}/#{all_tasks_count}] running task #{task[:description]}..."
               
                task_service.execute_task(
                    task_name: task[:name], 
                    params: task[:params]
                )
            end
        end
    end

end