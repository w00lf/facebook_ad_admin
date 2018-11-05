require 'rails_helper'

RSpec.describe FacebookCreation::AdService do
  CREATED_ADCREATIVE = '23843093148650049'.freeze
  CREATED_ADSET_ID = '23843093138150049'.freeze
  CREATED_AD_ID = '23843093149950049'.freeze

  let(:attributes) {
    {
      name: 'Ad Name',
      status: 'PAUSED',
      adset_id: CREATED_ADSET_ID,
      creative: { creative_id: CREATED_ADCREATIVE }
    }
  }
  let(:facebook_account) do
    double('Facebook Account',
      api_identificator: ENV['FACEBOOK_ACCOUNT_ID'],
      api_token: ENV['FACEBOOK_API_TOKEN'],
      api_secret: ENV['FACEBOOK_APP_SECRET'])
  end

  it 'Returns new adcreative id' do
    VCR.use_cassette('facebook_creation/ad/success') do
      expect(described_class.call(facebook_account, attributes).id).to eq(CREATED_AD_ID)
    end
  end
end
