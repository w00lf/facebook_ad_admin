require 'rails_helper'

RSpec.describe FacebookCreation::ImageService do
  let(:url) {
    'http://localhost:3000/IMG_4111.jpg'
  }
  let(:facebook_account) do
    double('Facebook Account',
      account_id: ENV['FACEBOOK_ACCOUNT_ID'],
      api_token: ENV['FACEBOOK_API_TOKEN'],
      api_secret: ENV['FACEBOOK_APP_SECRET'])
  end
  IMAGE_HASH = '61b44ff5533fdea8c9663ff3efbc7b20'

  it 'Returns new campaign id' do
    VCR.use_cassette('facebook_creation/image/success') do
      expect(described_class.call(facebook_account, url).first.hash).to eq(IMAGE_HASH)
    end
  end
end
