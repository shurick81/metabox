namespace "test" do 
    task :nothing do 
        puts "Default task to ensure Rakefile works well"
        puts "  - use 'rake -T' to see all tasks available"
        puts "  - use 'rake task:sub_task as per metabox documentation - https://github.com/SubPointSolutions/metabox"
    end
end