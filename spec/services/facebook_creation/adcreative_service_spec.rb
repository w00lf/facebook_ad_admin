require 'rails_helper'

RSpec.describe FacebookCreation::AdcreativeService do
  CREATED_ADCREATIVE = '23843093148650049'.freeze

  let(:attributes) {
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
          image_hash: "a7313faa165852e5acd4a2905d40fdf6",
        }
      },
      object_type: "SHARE",
      url_tags: "Ad=1&d=20.10&utm_source=HDSDSW&utm_medium=4325365476"
    }
  }
  let(:facebook_account) do
    double('Facebook Account',
      api_identificator: ENV['FACEBOOK_ACCOUNT_ID'],
      api_token: ENV['FACEBOOK_API_TOKEN'],
      api_secret: ENV['FACEBOOK_APP_SECRET'])
  end

  it 'Returns new adcreative id' do
    VCR.use_cassette('facebook_creation/adcreative/success') do
      expect(described_class.call(facebook_account, attributes).id).to eq(CREATED_ADCREATIVE)
    end
  end
end
