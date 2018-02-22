require_relative "../spec_helper"

RSpec.describe FileResource do

  def _get_service 
    FileResource.new
  end

  it 'can create service' do
    service = _get_service

    expect(service).not_to be nil
  end

  it 'can configure' do

    metabox = MetaboxResource.new do | metabox |

      metabox.define_file_set do | file_set  |
        file_set.define_file do | file |
          file.source_url        = "http://www.7-zip.org/a/7z1701.exe"
          file.destination_path  = "#{MetaboxEnv.default_download_path}/7z1701-x86/7z1701-x86.exe"
    
          file.define_checksum do | sum |
            sum.enabled = false
            sum.type    = "22"
            sum.value   = "2c94bd39e7b3456873494c1520c01ae559bc21d7"
          end
        end
      end

    end

    puts metabox
    
    expect(metabox).not_to be nil
  end

end