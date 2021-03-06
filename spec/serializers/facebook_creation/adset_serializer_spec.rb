require 'rails_helper'

RSpec.xdescribe FacebookCreation::AdsetSerializer do
  MAIN_ATTRIBUTES = [
    "Ad Set Name",
    'Pixel Id' ,
    "Conversion/Website",
    "Budget" ,
    "Age",
    "Placement",
    "Platform"
  ].freeze

  let(:attributes) {
    {
      "Ad Set Name"=>"MX - (18+) - 1",
      'Pixel Id' => '123456',
      "Conversion/Website"=>"Lead",
      "Budget" => "$50,00",
      "Locations"=>"Mexico",
      "Age"=>"18-65+",
      "Gender"=>"all",
      "Languages"=>"Spanish",
      "Placement"=>"feed",
      "Platform" => 'facebook'
    }
  }
  let(:result) {
    {
      :name=>"MX - (18+) - 1",
      :status=>"PAUSED",
      :billing_event=>"IMPRESSIONS",
      :optimization_goal=>"OFFSITE_CONVERSIONS",
      :bid_strategy=>"LOWEST_COST_WITHOUT_CAP",
      :promoted_object=> {
        :pixel_id=>"123456",
        :custom_event_type=>"LEAD"
      },
      :daily_budget=>5000,
      :targeting=> {
        :geo_locations=> {
          :countries=>["MX"],
          location_types: [
            "home",
            "recent"
          ]
        },
        :age_min=>18,
        :age_max=>65,
        :locales=>[23],
        :publisher_platforms =>["facebook"],
        :facebook_positions =>["feed"]
      }
    }
  }
  let(:facebook_account) { double('Facebook Account', api_token: ENV['FACEBOOK_API_TOKEN'], api_secret: ENV['FACEBOOK_APP_SECRET']) }

  subject { described_class.new(facebook_account: facebook_account, adset_attributes: attributes).as_json }

  it 'Returns formated result' do
    VCR.use_cassette('facebook_api/lookups') do
      is_expected.to eq(result)
    end
  end

  MAIN_ATTRIBUTES.reject { |n| ['Languages', 'Locations'].include?(n) }.each do |attribute|
    it "Raises AdsetSerializerError on missing attribute #{attribute}" do
      VCR.use_cassette('facebook_api/lookups') do
        expect {
          described_class.new(facebook_account: facebook_account, adset_attributes: attributes.reject {|n| n == attribute }).as_json
        }.to raise_error(FacebookCreation::AdsetSerializer::AdsetSerializerError)
      end
    end
  end

  it 'Raise AdsetSerializerError if wrong gender provided' do
    VCR.use_cassette('facebook_api/lookups') do
      expect {
        described_class.new(facebook_account: facebook_account, adset_attributes: attributes.merge('Gender' => 'foo')).as_json
      }.to raise_error(FacebookCreation::AdsetSerializer::AdsetSerializerError)
    end
  end

  it 'Raise AdsetSerializerError if wrong position provided' do
    VCR.use_cassette('facebook_api/lookups') do
      expect {
        described_class.new(facebook_account: facebook_account, adset_attributes: attributes.merge('Placement' => 'feeds')).as_json
      }.to raise_error(FacebookCreation::AdsetSerializer::AdsetSerializerError)
    end
  end
end
