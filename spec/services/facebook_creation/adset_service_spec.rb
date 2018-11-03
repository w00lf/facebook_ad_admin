require 'rails_helper'

RSpec.describe FacebookCreation::AdsetService do
  CREATED_CAMPAIGN_ID = '120330000053077610'
  CREATED_ADSET_ID = '120330000053077910'
  let(:attributes) {
    {
      :name=>"MX - (18+) - 1",
      :billing_event=>"IMPRESSIONS",
      :optimization_goal=>"OFFSITE_CONVERSIONS",
      :bid_strategy=>"LOWEST_COST_WITHOUT_CAP",
      :promoted_object=> {
        :pixel_id=>"1573475279464976",
        :custom_event_type=>"LEAD"
      },
      :daily_budget=>500000,
      :targeting=> {
        :geo_locations=> {
          :countries=>["MX"]
        },
        :age_min=>'18',
        :age_max=>'65',
        :locales=>[23],
        :publisher_platforms =>["facebook"],
        :facebook_positions =>["feed"]
      },
      campaign_id: CREATED_CAMPAIGN_ID
    }
  }
  let(:facebook_account) do
    double('Facebook Account',
      account_id: ENV['FACEBOOK_ACCOUNT_ID'],
      api_token: ENV['FACEBOOK_API_TOKEN'],
      api_secret: ENV['FACEBOOK_APP_SECRET'])
  end

  it 'Returns new campaign id' do
    VCR.use_cassette('facebook_creation/adset/success') do
      expect(described_class.call(facebook_account, attributes).id).to eq(CREATED_ADSET_ID)
    end
  end
end
