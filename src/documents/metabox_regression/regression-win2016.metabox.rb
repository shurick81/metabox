
MetaboxResource.define_config("regression-win2016") do | metabox |

  metabox.description = " Regression to test win2016 platform - DC, client, SQL, VS and SharePoint"

  git_branch  = metabox.env.get_metabox_branch
  working_dir = metabox.env.get_metabox_working_dir

  custom_machine_folder = "#{working_dir}/vagrant_vms/#{git_branch}/regression-win2016"
  
  box_app     =  "win2016-mb-app-$#{git_branch}"
  box_sp      =  "win2016-mb-bin-sp16rtm-$#{git_branch}"
  box_sp_fp2  =  "win2016-mb-bin-sp16fp2-$#{git_branch}"

  dc_short_name = "reg-win2016"

  dc_domain_name            = "#{dc_short_name}.local"
  dc_domain_admin_name      = "admin"
  dc_domain_admin_password  = "u8wxvKQ2zn"

  sql12_bin_path = "c:\\_metabox_resources\\sql2012sp2"
  sql14_bin_path = "c:\\_metabox_resources\\sql2014sp1"
  sql16_bin_path = "c:\\_metabox_resources\\sql2016"

  sql_instance_name       = "MSSQLSERVER"
  sql_instance_features   = "SQLENGINE,SSMS,ADV_SSMS"
  sql16_instance_features = "SQLENGINE,CONN,REPLICATION,FULLTEXT"

  # SharePoint specific settings
  sp_setup_user_name      = "#{dc_short_name}\\vagrant"
  sp_setup_user_password  = "vagrant"

  def standard_vm_config(vagrant_host:, box_name:, machinefolder:, cpus: 2, memory: 512)
    vagrant_host.handlers << {
      "Type" => "vagrant::config::vm",
      "Properties" => {
        "box" => box_name
      }
    }

    vagrant_host.handlers << {
      "Type" => "vagrant::config::vm::provider::virtualbox",
      "Properties" => {
        "cpus" => cpus,
        "memory" => memory,
        "machinefolder" => machinefolder
      }
    }  

    vagrant_host.handlers << {
      "Type" => "metabox::vagrant::host",
      "Properties" => {
        "hostname" => "Fn::GetHostName"
      }
    }  
  end

  def standard_soe_config(vagrant_host:)

    vagrant_host.handlers << {
      "Type" => "metabox::vagrant::win12soe",
      "Name" => "SOE config",
      "Tags" => [ "soe" ],
      "Properties" => {
        "execute_tests" => true
      }
    }  

  end

  def standard_dc_join(vagrant_host:, dc_domain_name:, dc_domain_admin_name:, dc_domain_admin_password:)

    vagrant_host.handlers << {
      "Type" => "metabox::vagrant::dc12",
      "Name" => "DC configuration",
      "Tags" => [ "dc" ],
      "Properties" => {
        "execute_tests" => true,

        "dc_domain_name" => dc_domain_name,
        "dc_domain_admin_name" => dc_domain_admin_name,
        "dc_domain_admin_password" => dc_domain_admin_password
      }
    }  

  end

  def standard_vs_isntall(vagrant_host:, 
    dc_short_name:,

    vs_resource_name: "vs2013.5_ent_enu",

    vs_product_name: nil,

    vs_test_product_name: "Microsoft Visual Studio Ultimate 2013 with Update 5",
    vs_test_officetools_package_name:  "Microsoft Office Developer Tools for Visual Studio"
  )

    # transfer VS binary files
    vagrant_host.handlers << {
      "Type" => "metabox::vagrant::shell",
      "Name" => "vs installation media",
      "Tags" => [ "vs_bin" ],
      "Properties" => {
        "path" => "./scripts/packer/metabox.packer.core/_metabox_dist_helper.ps1",
        "env" => [
          "METABOX_RESOURCE_NAME=#{vs_resource_name}"
        ]
      }
    }  

    vagrant_host.handlers << {
      "Type" => "metabox::vagrant::visual_studio13",
      "Name" => "vs isntall",
      "Tags" => [ "vs_install" ],
      "Properties" => {
        "vs_domain_user_name" =>  "#{dc_short_name}\\vagrant",
        "vs_domain_user_password" => "vagrant",

        "dsc_check" => "1",
        "execute_tests" => true,

        "vs_executable_path" => "c:\\_metabox_resources\\#{vs_resource_name}",
        "vs_product_name" => vs_product_name,

        "vs_test_product_name" => vs_test_product_name,
        "vs_test_officetools_package_name" => vs_test_officetools_package_name
      }
    }  

  end

  def standard_sql_isntall(
    vagrant_host:,

    sql_resource_name:,
    sql_instance_name:,
    sql_instance_features:,
    sql_sys_admin_accounts: 
  )

    # transfer VS binary files
    vagrant_host.handlers << {
      "Type" => "metabox::vagrant::shell",
      "Name" => "sql installation media",
      "Tags" => [ "sql_bin" ],
      "Properties" => {
        "path" => "./scripts/packer/metabox.packer.core/_metabox_dist_helper.ps1",
        "env" => [
          "METABOX_RESOURCE_NAME=#{sql_resource_name}"
        ]
      }
    }  

    vagrant_host.handlers << {
      "Type" => "metabox::vagrant::sql12",
      "Name" => "sql isntall",
      "Tags" => [ "sql_install" ],
      "Properties" => {
        "execute_tests" => true,

        "sql_bin_path" =>  "c:\\_metabox_resources\\#{sql_resource_name}",
        "sql_instance_name" => sql_instance_name,
        "sql_instance_features" => sql_instance_features,
        "sql_sys_admin_accounts" => sql_sys_admin_accounts,
        "dsc_check" => 1
      }
    }  

  end

  def standard_sp_install(
    vagrant_host:,

    sp_version:,
    sp_role:,

    sp_farm_sql_server_host_name:,
    sp_farm_sql_db_prefix:,

    sp_farm_passphrase:,

    sp_setup_user_name:,
    sp_setup_user_password:
  )

  vagrant_host.handlers << {
    "Type" => "metabox::vagrant::sharepoint",
    "Name" => "sharepoint install",
    "Tags" => [ "sp_install" ],
    "Properties" => {
      "execute_tests" => true,

      "sp_version" => sp_version,
      "sp_role" => sp_role,

      "sp_farm_sql_server_host_name" => sp_farm_sql_server_host_name,
      "sp_farm_sql_db_prefix" => sp_farm_sql_db_prefix,

      "sp_farm_passphrase" => sp_farm_passphrase,

      "sp_setup_user_name" => sp_setup_user_name,
      "sp_setup_user_password" => sp_setup_user_password      
    }
  }  
    
  end

  metabox.define_vagrant_stack("regression-win2016") do | vagrant_stack |
  

    vagrant_stack.define_vagrant_host("dc") do | vagrant_host |
      standard_vm_config(
        vagrant_host: vagrant_host,
        box_name: box_app,
        machinefolder: custom_machine_folder
      )

      standard_soe_config(
        vagrant_host: vagrant_host
      )
    end

    vagrant_stack.define_vagrant_host("client") do | vagrant_host |
      standard_vm_config(
        vagrant_host: vagrant_host,
        box_name: box_app,
        machinefolder: custom_machine_folder
      )

      standard_soe_config(
        vagrant_host: vagrant_host
      )

      standard_dc_join(
        vagrant_host: vagrant_host,
        dc_domain_name: dc_domain_name,
        dc_domain_admin_name: dc_domain_admin_name,
        dc_domain_admin_password: dc_domain_admin_password
      )

    end

    vagrant_stack.define_vagrant_host("vs13") do | vagrant_host |

      standard_vm_config(
        vagrant_host: vagrant_host,
        box_name: box_app,
        machinefolder: custom_machine_folder,
        cpus: 4,
        memory: 4096
      )

      standard_soe_config(
        vagrant_host: vagrant_host
      )

      standard_dc_join(
        vagrant_host: vagrant_host,
        dc_domain_name: dc_domain_name,
        dc_domain_admin_name: dc_domain_admin_name,
        dc_domain_admin_password: dc_domain_admin_password
      )

      standard_vs_isntall(
        vagrant_host: vagrant_host,
        dc_short_name: dc_short_name,

        vs_resource_name: "vs2013.5_ent_enu",

        vs_test_product_name: "Microsoft Visual Studio Ultimate 2013 with Update 5",
        vs_test_officetools_package_name:  "Microsoft Office Developer Tools for Visual Studio"
      )

    end

    vagrant_stack.define_vagrant_host("vs15") do | vagrant_host |

      standard_vm_config(
        vagrant_host: vagrant_host,
        box_name: box_app,
        machinefolder: custom_machine_folder,
        cpus: 4,
        memory: 4096
      )

      standard_soe_config(
        vagrant_host: vagrant_host
      )

      standard_dc_join(
        vagrant_host: vagrant_host,
        dc_domain_name: dc_domain_name,
        dc_domain_admin_name: dc_domain_admin_name,
        dc_domain_admin_password: dc_domain_admin_password
      )

      standard_vs_isntall(
        vagrant_host: vagrant_host,
        dc_short_name: dc_short_name,

        vs_resource_name: "vs2015.3_ent_enu",

        vs_product_name: "Microsoft Visual Studio Enterprise 2015 with Update 3",

        vs_test_product_name: "Microsoft Visual Studio Enterprise 2015 with Updates",
        vs_test_officetools_package_name: "Microsoft Office Developer Tools for Visual Studio 2015"
      )
    end

    vagrant_stack.define_vagrant_host("sql12") do | vagrant_host |

      standard_vm_config(
        vagrant_host: vagrant_host,
        box_name: box_app,
        machinefolder: custom_machine_folder,
        cpus: 4,
        memory: 4096
      )

      standard_soe_config(
        vagrant_host: vagrant_host
      )

      standard_dc_join(
        vagrant_host: vagrant_host,
        dc_domain_name: dc_domain_name,
        dc_domain_admin_name: dc_domain_admin_name,
        dc_domain_admin_password: dc_domain_admin_password
      )

      standard_sql_isntall(
        vagrant_host: vagrant_host,

        sql_resource_name: "sql2012sp2",
        sql_instance_name: sql_instance_name,
        sql_instance_features: sql_instance_features,
        sql_sys_admin_accounts: [
          "vagrant",
          "#{dc_short_name}\\vagrant"
        ]
      )

    end

    vagrant_stack.define_vagrant_host("sql14") do | vagrant_host |

      standard_vm_config(
        vagrant_host: vagrant_host,
        box_name: box_app,
        machinefolder: custom_machine_folder,
        cpus: 4,
        memory: 4096
      )

      standard_soe_config(
        vagrant_host: vagrant_host
      )

      standard_dc_join(
        vagrant_host: vagrant_host,
        dc_domain_name: dc_domain_name,
        dc_domain_admin_name: dc_domain_admin_name,
        dc_domain_admin_password: dc_domain_admin_password
      )

      standard_sql_isntall(
        vagrant_host: vagrant_host,

        sql_resource_name: "sql2014sp1",
        sql_instance_name: sql_instance_name,
        sql_instance_features: sql_instance_features,
        sql_sys_admin_accounts: [
          "vagrant",
          "#{dc_short_name}\\vagrant"
        ]
      )

    end

    vagrant_stack.define_vagrant_host("sql16") do | vagrant_host |

      standard_vm_config(
        vagrant_host: vagrant_host,
        box_name: box_app,
        machinefolder: custom_machine_folder,
        cpus: 4,
        memory: 4096
      )

      standard_soe_config(
        vagrant_host: vagrant_host
      )

      standard_dc_join(
        vagrant_host: vagrant_host,
        dc_domain_name: dc_domain_name,
        dc_domain_admin_name: dc_domain_admin_name,
        dc_domain_admin_password: dc_domain_admin_password
      )

      standard_sql_isntall(
        vagrant_host: vagrant_host,

        sql_resource_name: "sql2016",
        sql_instance_name: sql_instance_name,
        sql_instance_features: sql_instance_features,
        sql_sys_admin_accounts: [
          "vagrant",
          "#{dc_short_name}\\vagrant"
        ]
      )

    end

    vagrant_stack.define_vagrant_host("sp16_rtm") do | vagrant_host |

      standard_vm_config(
        vagrant_host: vagrant_host,
        box_name: box_sp,
        machinefolder: custom_machine_folder,
        cpus: 4,
        memory: 6144
      )

      standard_soe_config(
        vagrant_host: vagrant_host
      )

      standard_dc_join(
        vagrant_host: vagrant_host,
        dc_domain_name: dc_domain_name,
        dc_domain_admin_name: dc_domain_admin_name,
        dc_domain_admin_password: dc_domain_admin_password
      )

      standard_sp_install(
        vagrant_host: vagrant_host,
        sp_version: "sp2016",
        sp_role:  ["wfe"],

        sp_farm_sql_server_host_name: "sql14",
        sp_farm_sql_db_prefix: "sp16_rtm",
        
        sp_farm_passphrase: dc_domain_admin_password,

        sp_setup_user_name:     sp_setup_user_name,
        sp_setup_user_password: sp_setup_user_password
      )

    end

    vagrant_stack.define_vagrant_host("sp16_fp2") do | vagrant_host |

      standard_vm_config(
        vagrant_host: vagrant_host,
        box_name: box_sp_fp2,
        machinefolder: custom_machine_folder,
        cpus: 4,
        memory: 6144
      )

      standard_soe_config(
        vagrant_host: vagrant_host
      )

      standard_dc_join(
        vagrant_host: vagrant_host,
        dc_domain_name: dc_domain_name,
        dc_domain_admin_name: dc_domain_admin_name,
        dc_domain_admin_password: dc_domain_admin_password
      )

      standard_sp_install(
        vagrant_host: vagrant_host,
        sp_version: "sp2016",
        sp_role:  ["wfe"],

        sp_farm_sql_server_host_name: "sql14",
        sp_farm_sql_db_prefix: "sp16_rtm",
        
        sp_farm_passphrase: dc_domain_admin_password,

        sp_setup_user_name:     sp_setup_user_name,
        sp_setup_user_password: sp_setup_user_password
      )


    end


  end

end