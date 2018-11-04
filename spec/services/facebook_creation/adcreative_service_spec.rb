require 'rails_helper'

RSpec.describe FacebookCreation::AdcreativeService do
  CREATED_ADCREATIVE = '120330000053085310'.freeze

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
          image_hash: "61b44ff5533fdea8c9663ff3efbc7b20",
        }
      },
      object_type: "SHARE",
      url_tags: "Ad=1&d=20.10&utm_source=HDSDSW&utm_medium=4325365476"
    }
  }
  let(:facebook_account) do
    double('Facebook Account',
      account_id: ENV['FACEBOOK_ACCOUNT_ID'],
      api_token: ENV['FACEBOOK_API_TOKEN'],
      api_secret: ENV['FACEBOOK_APP_SECRET'])
  end

  it 'Returns new adcreative id' do
    VCR.use_cassette('facebook_creation/adcreative/success') do
      expect(described_class.call(facebook_account, attributes).id).to eq(CREATED_ADCREATIVE)
    end
  end
end
