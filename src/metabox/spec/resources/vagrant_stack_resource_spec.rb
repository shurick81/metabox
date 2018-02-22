require_relative "../spec_helper"


RSpec.describe PackerBuildResource do

  def _get_service 
    VagrantStackResource.new
  end

  it 'can create service' do
    service = _get_service

    expect(service).not_to be nil
  end

  class RoleResource 
    def get_config
      []
    end

    def name
      "default-role"
    end
  end

  class SharePoint2013WfeRole < RoleResource 

    attr_accessor :ram
    attr_accessor :cpu

    def initialize
      @ram = 4096
      @cpu = 4
    end

    def name 
      "sharepoint-2013-wfe"
    end

    def get_config 
      [
        {
            "Type" => "vagrant::config::vm",
            "Properties" => {
              "box" => "Fn::GetParameter app_box_name"
            }
        },
        {
            "Type" => "vagrant::config::vm::provider::virtualbox",
            "Properties" => {
              "cpus" => @cpu,
              "memory" => @ram,
              "machinefolder" => "Fn::GetParameter custom_machine_folder"
            }
        }
      ]
    end
  end

  it 'can configure' do

    metabox = MetaboxResource.new do | metabox |

      metabox.define_vagrant_stack do | vagrant_stack |
        
        vagrant_stack.define_vagrant_template("dc") do | vagrant |
          
          vagrant.add_config({
            "Type" => "vagrant::config::vm",
            "Properties" => {
              "box" => "Fn::GetParameter app_box_name"
            }
          })

          vagrant.add_config({
            "Type" => "vagrant::config::vm::provider::virtualbox",
            "Properties" => {
              "cpus" => 4,
              "memory" => 2048,
              "machinefolder" => "Fn::GetParameter custom_machine_folder"
            }
          })
        end

        vagrant_stack.define_vagrant_template("client") do | vagrant |
          # other configs
        end

      end
    end

    puts metabox
    
    expect(metabox).not_to be nil
  end

end