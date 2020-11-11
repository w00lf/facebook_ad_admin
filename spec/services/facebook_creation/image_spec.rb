require 'rails_helper'

RSpec.xdescribe FacebookCreation::ImageService do
  let(:url) {
    'http://localhost:3000/905.jpg'
  }
  let(:facebook_account) do
    double('Facebook Account',
      api_identificator: ENV['FACEBOOK_ACCOUNT_ID'],
      api_token: ENV['FACEBOOK_API_TOKEN'],
      api_secret: ENV['FACEBOOK_APP_SECRET'])
  end
  IMAGE_HASH = 'a7313faa165852e5acd4a2905d40fdf6'

  it 'Returns new image id' do
    # allow(NetUtils).to receive(:download).and_return(mock_image)
    VCR.use_cassette('facebook_creation/image_download/success') do
      VCR.use_cassette('facebook_creation/image/success') do
        expect(described_class.call(facebook_account, url).first.hash).to eq(IMAGE_HASH)
      end
    end
  end
end
