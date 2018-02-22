
MetaboxResource.define_config("centos7-jenkins2") do | metabox |

  metabox.description = "Builds CentOS7 box with pre-installed Jenkins2"

  git_branch  = metabox.env.get_metabox_branch
  working_dir = metabox.env.get_metabox_working_dir
  
  jenkins_package_name  = "jenkins-2.84-1.1"

  jenkins_plugins        = "blueocean,ace-editor,antisamy-markup-formatter,authentication-tokens,bouncycastle-api,branch-api,cloudbees-folder,credentials-binding,credentials,display-url-api,docker-commons,docker-workflow,durable-task,git-client,git,git-server,handlebars,jackson2-api,jquery-detached,jsch,junit,mailer,mapdb-api,matrix-auth,matrix-project,momentjs,pipeline-build-step,pipeline-graph-analysis,pipeline-input-step,pipeline-milestone-step,pipeline-model-api,pipeline-model-declarative-agent,pipeline-model-definition,pipeline-model-extensions,pipeline-rest-api,pipeline-stage-step,pipeline-stage-tags-metadata,pipeline-stage-view,plain-credentials,scm-api,scm-sync-configuration,script-security,ssh-agent,ssh-credentials,ssh-slaves,ssh,structs,subversion,windows-slaves,workflow-aggregator,workflow-api,workflow-basic-steps,workflow-cps-global-lib,workflow-cps,workflow-durable-task-step,workflow-job,workflow-multibranch,workflow-scm-step,workflow-step-api,workflow-support,swarm"
  jenkins_ui_port        = metabox.env.METABOX_JENKINS_UI_PORT
  jenkins_web_agent_port = metabox.env.METABOX_JENKINS_WEB_AGENT_PORT
  jenkins_pipelines_path = "/vagrant/scripts/vagrant/centos7-mb-jenkins2/pipelines"

  custom_machine_folder  = "#{working_dir}/vagrant_vms/#{git_branch}/metabox_ci"
  metabox_ci_box_name    = metabox.env.METABOX_CI_BOX_NAME 

  box_name               = "centos7-mb-java8-#{git_branch}"

  metabox.define_packer_build("centos7-mb-jenkins2") do | packer_build |

    packer_build.os = "linux"

    packer_build.packer_file_name = "centos7-mb-jenkins2.json"
    packer_build.vagrant_box_name = "centos7-mb-jenkins2-#{git_branch}"

    packer_build.define_packer_template do | packer_template |
     
      packer_template.builders << {
        "Type" => "packer::builders::vagrant_centos7",
        "Properties" => {
          "box_name" => box_name,
          "builder"  => {
            "output_directory" => "#{working_dir}/packer_output/centos7-mb-jenkins2-#{git_branch}"
          }
        }
      }

      packer_template.provisioners << {
        "Type" => "packer::provisioners::shell_centos7",
        "Properties" => {
          "scripts" => [
            "./scripts/packer/shared/mb_printenv.sh",
            "./scripts/packer/centos7-jenkins2/j2_install.sh",
            "./scripts/packer/centos7-jenkins2/j2_configure_cli.sh",
            "./scripts/packer/centos7-jenkins2/j2_configure_plugins.sh",
            "./scripts/packer/centos7-jenkins2/j2_safe_restart.sh"
          ],
          "environment_vars" => [
            "METABOX_JENKINS2_PACKAGE=#{jenkins_package_name}",
            "METABOX_JENKINS2_PLUGINS=#{jenkins_plugins}"
          ]
        }
      }

      packer_template.post_processors << {
        "Type" => "packer::post-processors::vagrant",
        "Properties" => {
          "output": "#{working_dir}/packer_boxes/centos7-mb-jenkins2-#{git_branch}-{{.Provider}}.box"
        }
      }
      
    end

  end

end