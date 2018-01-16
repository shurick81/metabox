require_relative "../spec_helper"

RSpec.describe Metabox::OSService do
  
  def _get_service 
    Metabox::OSService.new
  end

  it 'Can create service' do
    service = _get_service

    expect(service).not_to be nil
  end

  it '.process_windows_cmd' do
    service = _get_service

    service.process_windows_cmd(
      cmd:  "tmp"
    )
  end

  it '.run_cmd' do
    service = _get_service

    service.process_windows_cmd(
      cmd: "echo test"
    )
  end

  it '.is_windows?' do    
    service = _get_service
    
    service.is_windows?
  end
  
end
