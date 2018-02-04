namespace "fileset" do
    
    desc "Downloads one or several fileset resources"
    task :download do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Packs one or several fileset resources"
    task :pack do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

    desc "Imports fileset resource from existing file"
    task :import_from_file do | task, task_args | 
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

end