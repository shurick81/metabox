require_relative "../spec_helper"

include Metabox::Utilson

RSpec.describe MetaboxEnv do

  it 'can get env value service' do
    value = MetaboxEnv.test_value

    expect(value).to be(nil)
  end

  it 'can get env value service' do
    test_value = RndUtils.get_random_string

    ENV["test_value1"] = test_value
    result_value = MetaboxEnv.test_value1

    expect(result_value).to eq(test_value)
  end

end