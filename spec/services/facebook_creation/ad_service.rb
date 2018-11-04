require 'rails_helper'

RSpec.describe FacebookCreation::AdService do
  CREATED_ADCREATIVE = '120330000053085310'.freeze
  CREATED_ADSET_ID = '120330000053077910'.freeze
  CREATED_AD_ID = '123'.freeze

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
      account_id: ENV['FACEBOOK_ACCOUNT_ID'],
      api_token: ENV['FACEBOOK_API_TOKEN'],
      api_secret: ENV['FACEBOOK_APP_SECRET'])
  end

  it 'Returns new adcreative id' do
    VCR.use_cassette('facebook_creation/ad/success') do
      expect(described_class.call(facebook_account, attributes).id).to eq(CREATED_AD_ID)
    end
  end
end
