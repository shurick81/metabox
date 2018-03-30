
MetaboxResource.define_config("centos7-java8") do | metabox |

  box_name = "geerlingguy/centos7"
  
  git_branch  = metabox.env.get_metabox_branch
  working_dir = metabox.env.get_metabox_working_dir

  metabox.description = "Builds CentOS7 with pre-installed Java8"

  metabox.define_packer_build("centos7-mb-java8") do | packer_build |

    packer_build.os = "linux"

    packer_build.packer_file_name = "centos7-mb-java8.json"
    packer_build.vagrant_box_name = "centos7-mb-java8-#{git_branch}"

    packer_build.define_packer_template do | packer_template |
     
      packer_template.builders << {
        "Type" => "packer::builders::vagrant_centos7",
        "Properties" => {
          "box_name" => box_name,
          "builder"  => {
            "output_directory" => "#{working_dir}/packer_output/centos7-mb-java8-#{git_branch}"
          }
        }
      }

      packer_template.provisioners << {
        "Type" => "packer::provisioners::shell_centos7",
        "Properties" => {
          "scripts" => [
            "./scripts/packer/packer.provisioners.shell_centos7/mb_printenv.sh",
            "./scripts/packer/packer.provisioners.shell_centos7/mb_yum_install.sh",
            "./scripts/packer/packer.provisioners.shell_centos7/mb_java8_install.sh"
          ]
        }
      }

      packer_template.post_processors << {
        "Type" => "packer::post-processors::vagrant",
        "Properties" => {
          "output": "#{working_dir}/packer_boxes/centos7-mb-java8-#{git_branch}-{{.Provider}}.box"
        }
      }
      
    end

  end

end