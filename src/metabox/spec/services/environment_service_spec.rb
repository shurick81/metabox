require_relative "../spec_helper"

RSpec.describe Metabox::EnvironmentService do
  
  def _get_service 
    Metabox::EnvironmentService.new
  end

  it 'can create service' do
    service = _get_service

    expect(service).not_to be nil
  end

end