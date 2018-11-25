require 'rails_helper'

RSpec.describe FacebookAccountStatsRetrieveJob do
  let!(:facebook_account) do
    FacebookAccount.new(name: 'Facebook Account',
      api_identificator: ENV['FACEBOOK_ACCOUNT_ID'],
      api_token: ENV['FACEBOOK_API_TOKEN'],
      api_secret: ENV['FACEBOOK_APP_SECRET']).tap {|n| n.save!(validate: false) }
  end
  let(:date_unix) {
    Time.local(2018, 11, 5).to_i
  }
  let(:result_data) {
    ["Active", "05/11/2018", "New Sandbox Ad Account", "ACTIVE", "MX - (18+) - 1", "-", "5000.0 $", "10.0 $", "-", "-", "-", "-", "-"]
  }
  let(:next_result_data) {
    ["Active", "05/11/2018", "New Sandbox Ad Account", "ACTIVE", "MX - (18+) - 2", "-", "25.0 $", "5.0 $", "-", "-", "-", "-", "-"]
  }

  subject do
    described_class
      .new
      .perform(date_unix, facebook_account.id)
  end

  it 'Sets SendToGoogleSpreadsheetFacebookAccountJob job with received data' do
    expect(SendToGoogleSpreadsheetFacebookAccountJob)
      .to(receive(:perform_later).with(date_unix,
                                      facebook_account.id,
                                      result_data,
                                      FacebookAccountStatsRetrieveJob::COLUMN_HEADERS))
    VCR.use_cassette('facebook_report/all_spreadsheet/success') do
      expect(subject).to eq(true)
    end
  end

  it 'When facebook library returns NoMethodError because of Missing custom_event_type, ignores it' do
    expect(SendToGoogleSpreadsheetFacebookAccountJob)
      .to(receive(:perform_later).with(date_unix,
                                      facebook_account.id,
                                      next_result_data,
                                      FacebookAccountStatsRetrieveJob::COLUMN_HEADERS))
    VCR.use_cassette('facebook_report/all_spreadsheet/failure') do
      expect(subject).to eq(true)
    end
  end
end
