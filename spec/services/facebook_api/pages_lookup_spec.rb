require 'rails_helper'

RSpec.describe FacebookApi::PagesLookup do
  let(:facebook_account) do
    double('Facebook Account',
      api_identificator: ENV['FACEBOOK_ACCOUNT_ID'],
      api_token: ENV['FACEBOOK_API_TOKEN'],
      api_secret: ENV['FACEBOOK_APP_SECRET'])
  end

  it 'Returns new image id' do
    VCR.use_cassette('facebook_api/pages_lookup/success') do
      expect(described_class.call(facebook_account)).to be_an_instance_of(Array)
    end
  end
end
