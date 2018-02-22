
MetaboxResource.define_config("metabox-sharepoint2016") do | metabox |

  download_dir = metabox.env.get_metabox_downloads_path

  metabox.description = "Downloads Visual Studio 2013 and 2015"

  metabox.define_file_set("visualstudio") do | file_set |

    # Visual Studio 2013 SP5 ISO
    # https://superuser.com/questions/840295/microsoft-visual-studio-2013-update-4-rtm-iso-offline-installer
    file_set.define_file("vs2013.5_ent_enu") do | file |
      file.source_url        = "https://go.microsoft.com/fwlink/?LinkId=532504&type=ISO&clcid=0x409"
      file.destination_path  = "#{download_dir}/vs2013.5_ent_enu/vs2013.5.ent_enu.iso"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "918ea4a911858d32c977148026e7edb7b238e6f6"
      end  
    end

    # Visual Studio 2015 SP3 ISO
    # https://www.kunal-chowdhury.com/2015/07/download-visualstudio-2015.html#b7GbWSlJxPurpwlA.97
    file_set.define_file("vs2015.3_ent_enu") do | file |
      file.source_url        = "https://go.microsoft.com/fwlink/?LinkId=615436&clcid=0x409"
      file.destination_path  = "#{download_dir}/vs2015.3_ent_enu/vs2015.3.ent_enu.iso"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "40ea340070e3684935689e60d8b7669d519d49d4"
      end  
    end

  end

end