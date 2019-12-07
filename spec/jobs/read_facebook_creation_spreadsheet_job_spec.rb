require 'rails_helper'

RSpec.describe ReadFacebookCreationSpreadsheetJob do
  let(:facebook_account) do
    FacebookAccount.new(name: 'Facebook Account',
      api_identificator: ENV['FACEBOOK_ACCOUNT_ID'],
      api_token: ENV['FACEBOOK_API_TOKEN'],
      api_secret: ENV['FACEBOOK_APP_SECRET']).tap {|n| n.save!(validate: false) }
  end

  subject do
    described_class
      .new
      .perform(file_name: 'Facebook import', config_file: Rails.root.join('config', 'config.json').to_s)
  end

  xit 'Returns new adcreative id' do
    expect(FacebookAccount).to receive(:find_by).and_return(facebook_account)
    VCR.use_cassette('facebook_creation/all_spreadsheet/success') do
      expect(subject).to eq(true)
    end
  end
end
