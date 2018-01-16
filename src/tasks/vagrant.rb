namespace "vagrant" do
    
    desc "Executes 'vagrant add' for a particular metabox resource"
    task :add do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Executes 'vagrant add' passing file name and box name. This allows importing boxes to metabox from raw Vagrant box file built somewhere else."
    task :add_from_file do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Executes 'vagrant up' for a particular metabox resource"
    task :up do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Executes 'vagrant destroy' for a particular metabox resource"
    task :destroy do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Executes 'vagrant reload' for a particular metabox resource"
    task :reload do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Executes 'vagrant box list'"
    task :box_list do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Executes 'vagrant box remove'"
    task :box_remove do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Executes 'vagrant global-status'"
    task :global_status do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Executes 'vagrant halt'"
    task :halt do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Executes 'vagrant status'"
    task :status do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Executes 'vagrant validate'"
    task :validate do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

end