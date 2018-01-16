namespace "resource" do
    
    desc "Lists all resources from all metabox documents"
    task :list do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Generates Vagrant/Packer files from all resources from all metabox documents"
    task :generate do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

end