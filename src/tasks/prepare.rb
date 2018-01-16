
namespace "prepare" do

    desc "Downloads files as per metabox resource"
    task :download do | task, task_args |
        $mb_api.execute_task(
            task_name: task.name,
            params: task_args.to_a
        )
    end

end