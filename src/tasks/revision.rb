namespace "revision" do
    
    desc "Applies revision to virtual machine"
    task :apply do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

end