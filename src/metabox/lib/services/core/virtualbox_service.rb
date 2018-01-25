
module Metabox

    class VirtualBoxService < ServiceBase

        def initialize
            
        end
        
        def name
            "metabox::core::virtualbox_service"
        end

        def set_machinefolder(machinefolder)
            machinefolder = File.expand_path machinefolder
            FileUtils.mkdir_p machinefolder

            if !File.exists? machinefolder
                raise "Cannot VirtualBox default machinefolder - folder does not exist: #{machinefolder}"
            end

            log.info "      - updating VirtualBox default machinefolder to '#{machinefolder}'"
            run_cmd(cmd: "VBoxManage setproperty machinefolder #{machinefolder}")              
        end

        def set_default_machinefolder
            log.info "      - reverting VirtualBox default machinefolder to 'default'"
            
            run_cmd(cmd: "VBoxManage setproperty machinefolder default")
        end

    end

end