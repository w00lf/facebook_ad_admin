require 'rails_helper'

RSpec.describe FacebookAccountStatsRetrieveJob do
  let!(:facebook_account) do
    FacebookAccount.new(name: 'Facebook Account',
      api_identificator: facebook_app_id,
      api_token: facebook_api_token).tap {|n| n.save!(validate: false) }
  end
  let(:report_time) { Time.local(2020, 11, 30) }
  let(:date_unix) { report_time.to_i }
  let(:result_data) do
    [["Disabled",
      "30/11/2020",
      "Heartstrings",
      "ACTIVE",
      "adset1automatic24",
      "-",
      "50.0 $",
      "25.38 $",
      "-",
      "23.59 $",
      "1.27 $",
      "1.86 %",
      "20",
      "1.03164",
      "BELOW_AVERAGE_20"]]
  end
  let(:parsed_data) do
    {
      "CPA"=>"-",
      "CPM"=>"23.59 $",
      "Date"=>"30/11/2020",
      "Clicks"=>"20",
      "Result"=>"-",
      "ad_name"=>"ad1",
      "Frequency"=>"1.03164",
      "image/vid"=>nil,
      "Adset Name"=>"adset1automatic24",
      "CPC (Link)"=>"1.27 $",
      "CTR (Link)"=>"1.86 %",
      "Account name"=>"Heartstrings",
      "Adset Status"=>"ACTIVE",
      "Amount Spent"=>"25.38 $",
      "Daily Budget"=>"50.0 $",
      "campaign_name"=>"SG - Heartstrings - Conversions",
      "Account Status"=>"Disabled",
      "Quality Ranking"=>"BELOW_AVERAGE_20"
    }
  end

  subject do
    described_class
      .new
      .perform(date_unix,
        facebook_account.id)
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

  it 'writes down parsed data' do
    VCR.use_cassette('facebook_report/all_spreadsheet/success') do
      expect do
        subject
      end.to(change do
        ParseResult
          .where(report_date: report_time.to_date)
          .count
      end.by(1))
      expect(ParseResult.last.parsed_data.first).to(eq(parsed_data))
    end
  end
end
