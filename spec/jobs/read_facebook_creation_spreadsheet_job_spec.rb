require 'rails_helper'

RSpec.describe ReadFacebookCreationSpreadsheetJob do
  let(:facebook_account) do
    double('Facebook Account',
      api_identificator: ENV['FACEBOOK_ACCOUNT_ID'],
      api_token: ENV['FACEBOOK_API_TOKEN'],
      api_secret: ENV['FACEBOOK_APP_SECRET'])
  end

  subject do
    described_class
      .new
      .perform(file_name: 'Facebook import', config_file: Rails.root.join('config', 'config.json').to_s)
  end

  it 'Returns new adcreative id' do
    expect(FacebookAccount).to receive(:find_by).and_return(facebook_account)
    VCR.use_cassette('google_spreadshet/facebook_creation/read/success') do
      VCR.use_cassette('facebook_creation/campaign/success') do
        VCR.use_cassette('facebook_api/location_lookup') do
          VCR.use_cassette('facebook_api/locale_lookup') do
            VCR.use_cassette('facebook_creation/adset/success') do
              VCR.use_cassette('facebook_creation/image/success') do
                VCR.use_cassette('facebook_creation/ad/success') do
                  expect(subject).to eq('CREATED_AD_ID')
                end
              end
            end
          end
        end
      end
    end
  end
end
