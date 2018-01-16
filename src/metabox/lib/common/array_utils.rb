class ArrayUtils
    def thread_each(&block)
        inject([]){|threads,e| threads << Thread.new{yield(e)}}.each{|t| t.join}
    end
end