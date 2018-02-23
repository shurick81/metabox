MetaboxResource.define_config("regression-win2016") do | metabox |

  metabox.description = " Regression to test win2016 platform - DC, client, SQL, VS and SharePoint"

  git_branch  = metabox.env.get_metabox_branch
  working_dir = metabox.env.get_metabox_working_dir

  custom_machine_folder = "#{working_dir}/vagrant_vms/#{git_branch}/regression-win2016"
  
  box_app     =  "win2016-mb-app-#{git_branch}"
  box_sp      =  "win2016-mb-bin-sp16rtm-#{git_branch}"
  box_sp_fp2  =  "win2016-mb-bin-sp16fp2-#{git_branch}"

  dc_short_name = "reg-win2016"

  dc_domain_name            = "#{dc_short_name}.local"
  dc_domain_admin_name      = "admin"
  dc_domain_admin_password  = "u8wxvKQ2zn"

  sql_instance_name       = "MSSQLSERVER"
  sql_instance_features   = "SQLENGINE,SSMS,ADV_SSMS"
  sql16_instance_features = "SQLENGINE,CONN,REPLICATION,FULLTEXT"

  # SharePoint specific settings
  sp_setup_user_name      = "#{dc_short_name}\\vagrant"
  sp_setup_user_password  = "vagrant"

  metabox.define_vagrant_stack("regression-win2016") do | vagrant_stack |
  
    dc_host = vagrant_stack.define_host("dc") do | vagrant_host |
      vagrant_host.add_roles([
        MinimalHostRole.half_g(box_app),
        Win12SOERole.default
      ])
    end

    vagrant_stack.define_host("client") do | vagrant_host |
      vagrant_host.add_roles([
        MinimalHostRole.half_g(box_app),
        Win12SOERole.default,
        WinDCJoinRole.default do | role | 
          role.dc_domain_name           = dc_domain_name 
          role.dc_domain_admin_name     = dc_domain_admin_name
          role.dc_domain_admin_password = dc_domain_admin_password
        end
      ])
    end

    vagrant_stack.define_host("vs13") do | vagrant_host |
      vagrant_host.add_roles([
        MinimalHostRole.half_g(box_app),
        Win12SOERole.default,

        WinDCJoinRole.default do | role | 
          role.dc_domain_name           = dc_domain_name 
          role.dc_domain_admin_name     = dc_domain_admin_name
          role.dc_domain_admin_password = dc_domain_admin_password
        end,

        VisualStudio13_SP5_Enterprise_Role.default do | role |
          role.dc_short_name = dc_short_name
        end,

      ])
    end

    vagrant_stack.define_host("vs15") do | vagrant_host |
      vagrant_host.add_roles([
        MinimalHostRole.half_g(box_app),
        Win12SOERole.default,

        WinDCJoinRole.default do | role | 
          role.dc_domain_name           = dc_domain_name 
          role.dc_domain_admin_name     = dc_domain_admin_name
          role.dc_domain_admin_password = dc_domain_admin_password
        end,

        VisualStudio15_SP3_Enterprise_Role.default do | role |
          role.dc_short_name = dc_short_name
        end,

      ])
    end

    sql12 = vagrant_stack.define_host("sql12") do | vagrant_host |
      vagrant_host.add_roles([
        MinimalHostRole.four_g(box_app),
        Win12SOERole.default,

        WinDCJoinRole.default do | role | 
          role.dc_domain_name           = dc_domain_name 
          role.dc_domain_admin_name     = dc_domain_admin_name
          role.dc_domain_admin_password = dc_domain_admin_password
        end,

        Sql12Role.default do | role |
          role.sql_sys_admin_accounts = [
            "vagrant",
            "#{dc_short_name}\\vagrant"
          ]
        end,

      ])
    end

    sql14 = vagrant_stack.define_host("sql14") do | vagrant_host |
      vagrant_host.add_roles([
        MinimalHostRole.four_g(box_app),
        Win12SOERole.default,

        WinDCJoinRole.default do | role | 
          role.dc_domain_name           = dc_domain_name 
          role.dc_domain_admin_name     = dc_domain_admin_name
          role.dc_domain_admin_password = dc_domain_admin_password
        end,

        Sql14Role.default do | role |
          role.sql_sys_admin_accounts = [
            "vagrant",
            "#{dc_short_name}\\vagrant"
          ]
        end,

      ])
    end

    sql16 = vagrant_stack.define_host("sql16") do | vagrant_host |
      vagrant_host.add_roles([
        MinimalHostRole.four_g(box_app),
        Win12SOERole.default,

        WinDCJoinRole.default do | role | 
          role.dc_domain_name           = dc_domain_name 
          role.dc_domain_admin_name     = dc_domain_admin_name
          role.dc_domain_admin_password = dc_domain_admin_password
        end,

        Sql16Role.default do | role |
          role.sql_sys_admin_accounts = [
            "vagrant",
            "#{dc_short_name}\\vagrant"
          ]
        end,

      ])
    end

    vagrant_stack.define_host("sp16_rtm") do | vagrant_host |
      vagrant_host.add_roles([
        MinimalHostRole.six_g(box_sp),
        Win12SOERole.default,

        WinDCJoinRole.default do | role | 
          role.dc_domain_name           = dc_domain_name 
          role.dc_domain_admin_name     = dc_domain_admin_name
          role.dc_domain_admin_password = dc_domain_admin_password
        end,

        SharePoint16_Standalone_Role.default do | role |
          role.sp_farm_sql_server_host_name = sql14.get_host_name
          role.sp_farm_sql_db_prefix        = vagrant_host.name

          role.sp_farm_passphrase     = dc_domain_admin_password

          role.sp_setup_user_name     = sp_setup_user_name
          role.sp_setup_user_password = sp_setup_user_password
        end,

      ])
    end

    vagrant_stack.define_host("sp16_rtm") do | vagrant_host |
      vagrant_host.add_roles([
        MinimalHostRole.six_g(box_sp_fp2),
        Win12SOERole.default,

        WinDCJoinRole.default do | role | 
          role.dc_domain_name           = dc_domain_name 
          role.dc_domain_admin_name     = dc_domain_admin_name
          role.dc_domain_admin_password = dc_domain_admin_password
        end,

        SharePoint16_Standalone_Role.default do | role |
          role.sp_farm_sql_server_host_name = sql14.get_host_name
          role.sp_farm_sql_db_prefix        = vagrant_host.name

          role.sp_farm_passphrase     = dc_domain_admin_password

          role.sp_setup_user_name     = sp_setup_user_name
          role.sp_setup_user_password = sp_setup_user_password
        end,

      ])
    end
  
  end

end