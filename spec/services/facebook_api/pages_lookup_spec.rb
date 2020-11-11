require 'rails_helper'

RSpec.describe FacebookApi::PagesLookup do
  let(:facebook_account) do
    double('Facebook Account',
      api_identificator: facebook_app_id,
      api_token: facebook_api_token)
  end

  it 'Returns new image id' do
    VCR.use_cassette('facebook_api/pages_lookup/success') do
      expect(described_class.call(facebook_account)).to be_an_instance_of(Array)
    end
  end
end
