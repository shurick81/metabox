namespace "packer" do
    
    desc "Executes 'packer build' for a particular metabox resource"
    task :build do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Cleans Packer leftovers produces by previous builds"
    task :clean do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end
    
end