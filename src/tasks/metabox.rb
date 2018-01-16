namespace "metabox" do
    
    desc "Installs 3rd part tools required by metabox"
    task :configure_metabox do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Configures Vagrant the way required by metabox"
    task :configure_vagrant do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Checks is all metabox dependencies are in place"
    task :configure_packer do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Checks is all metabox dependencies are in place"
    task :validate_config do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

end