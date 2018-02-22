require_relative "../spec_helper"

RSpec.describe PackerBuildResource do

  def _get_service 
    PackerBuildResource.new
  end

  it 'can create service' do
    service = _get_service

    expect(service).not_to be nil
  end

  it 'can configure' do

    metabox = MetaboxResource.new do | metabox |

      metabox.define_packer_build("my-build") do | packer_build |

        packer_build.packer_file_name = "win2012-mb-soe.json"
        packer_build.vagrant_box_name = "win2012-mb-soe-${ENV:METABOX_GIT_BRANCH}"

        packer_build.define_packer_template do | packer_template |
         
          packer_template.builders << {
            "Type" => "packer::builders::vagrant_win12_shutdown",
            "Properties" => {
              "box_name" => "",
              "builder"  => {
                "output_directory" => "{{ user `metabox_working_dir` }}/packer_output/win2012-mb-soe-{{ user `metabox_git_branch` }}"
              }
            }
          }

          packer_template.provisioners << {
            "type"    => "powershell",
            "scripts" => [
              "./scripts/packer/metabox.packer.core/_choco_bootstrap.ps1"
            ]
          }

          packer_template.provisioners << {
            "type" => "windows-restart"
          }

          packer_template.post_processors << {
            "Type" => "packer::post-processors::vagrant",
            "Properties" => {
              "output" => "{{ user `metabox_working_dir` }}/packer_boxes/win2012-mb-soe-{{ user `metabox_git_branch` }}-{{.Provider}}.box"
            }
          }
        
        end
      end

    end

    puts metabox
    
    expect(metabox).not_to be nil
  end

end