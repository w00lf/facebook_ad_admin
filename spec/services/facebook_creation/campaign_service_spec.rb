require 'rails_helper'

RSpec.xdescribe FacebookCreation::CampaignService do
  let(:attributes) {
    {
      objective: "CONVERSIONS",
      name: "Test campaign"
    }
  }
  let(:facebook_account) do
    double('Facebook Account',
      api_identificator: ENV['FACEBOOK_ACCOUNT_ID'],
      api_token: ENV['FACEBOOK_API_TOKEN'],
      api_secret: ENV['FACEBOOK_APP_SECRET'])
  end
  CREATED_CAMPAIGN_ID = '23843093131260049'

  it 'Returns new campaign id' do
    VCR.use_cassette('facebook_creation/campaign/success') do
      expect(described_class.call(facebook_account, attributes).id).to eq(CREATED_CAMPAIGN_ID)
    end
  end
end
