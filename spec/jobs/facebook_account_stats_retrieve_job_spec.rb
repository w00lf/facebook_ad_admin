require 'rails_helper'

RSpec.describe FacebookAccountStatsRetrieveJob do
  let!(:facebook_account) do
    FacebookAccount.new(name: 'Facebook Account',
      api_identificator: facebook_app_id,
      api_token: facebook_api_token).tap {|n| n.save!(validate: false) }
  end
  let(:date_unix) {
    Time.local(2018, 11, 5).to_i
  }
  let(:result_data) {
    []
  }
  let(:next_result_data) {
    []
  }

  subject do
    described_class
      .new
      .perform(date_unix, facebook_account.id)
  end

  it 'Does not raise error' do
    VCR.use_cassette('facebook_report/all_spreadsheet/success') do
      expect { subject }.to_not raise_error
    end
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
