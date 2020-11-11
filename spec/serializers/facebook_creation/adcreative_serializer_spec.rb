require 'rails_helper'

RSpec.xdescribe FacebookCreation::AdcreativeSerializer do
  MAIN_ATTRIBUTES = [
    "Image hash",
    "Website URL",
    "Text",
    "Headline",
    "URL Parameters"
  ].freeze

  let(:facebook_account) do
    double('Facebook Account',
      api_identificator: ENV['FACEBOOK_ACCOUNT_ID'],
      api_token: ENV['FACEBOOK_API_TOKEN'],
      api_secret: ENV['FACEBOOK_APP_SECRET'])
  end

  let(:attributes) {
    {
      "Image hash"=>"42fdgt45gfg4",
      "Website URL"=>"http://ya.ru",
      "Text"=>"Test text",
      "Headline"=>"Text headline",
      "News Feed Link Description(optional)"=>"-",
      'News Feed Link Description' => 'This is news feed',
      "URL Parameters"=>"Ad=1&d=20.10&utm_source=HDSDSW&utm_medium=4325365476"
    }
  }
  let(:result) {
    {
      object_story_spec: {
        page_id: '250515082286181',
        link_data: {
          message: "Test text",
          link: "http://ya.ru",
          attachment_style: "link",
          caption: "",
          name: "Text headline",
          description: 'This is news feed',
          image_hash: "42fdgt45gfg4",
        }
      },
      object_type: "SHARE",
      url_tags: "Ad=1&d=20.10&utm_source=HDSDSW&utm_medium=4325365476"
    }
  }

  subject { described_class.new(facebook_account, attributes).as_json }

  it 'Returns formated result' do
    VCR.use_cassette('facebook_api/pages_lookup/success') do
      is_expected.to eq(result)
    end
  end

  it 'raises AdcreativeSerializerError on blank accounts response' do
    VCR.use_cassette('facebook_api/pages_lookup/blank_success') do
      expect {
        described_class.new(facebook_account, attributes).as_json
      }.to raise_error(FacebookCreation::AdcreativeSerializer::AdcreativeSerializerError)
    end
  end

  MAIN_ATTRIBUTES.each do |attribute|
    it "Raises AdsetSerializerError on missing attribute #{attribute}" do
      expect {
        described_class.new(facebook_account, attributes.reject {|n| n == attribute }).as_json
      }.to raise_error(FacebookCreation::AdcreativeSerializer::AdcreativeSerializerError)
    end
  end
end
