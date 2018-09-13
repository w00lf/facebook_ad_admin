class SendToBinomApiFacebookCampaignJob
  include Sidekiq::Worker

  def perform(date_unix, campaign_id, costs)
    date_string = Time.at(date_unix).strftime('%Y-%m-%d')
    # 1 - Cost (full cost), 2 - CPC (cost per click)
    # date - 12 == custom date
    uri = URI("#{Settings.binom_api.url}/?page=save_update_costs&camp_id=#{campaign_id}&type=1&date=12&date_s=#{date_string}&date_e=#{date_string}&timezone=3&cost=#{costs}&value=#{costs}&api_key=#{Settings.binom_api.key}")
    result = JSON.load(Net::HTTP.get(uri))
    raise(result.fetch('error')) if result.fetch('check_status') != "true"
  end
end
