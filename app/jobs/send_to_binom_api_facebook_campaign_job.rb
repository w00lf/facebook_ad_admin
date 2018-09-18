class SendToBinomApiFacebookCampaignJob
  include Sidekiq::Worker

  def perform(date_unix, campaign_id, costs, currency)
    eu_bank = EuCentralBank.new
    Money.default_bank = eu_bank
    eu_bank.update_rates

    date_string = Time.at(date_unix).strftime('%Y-%m-%d')
    usd_costs = currency == "USD" ? costs : eu_bank.exchange(costs * 100, currency, "USD").to_f
    # 1 - Cost (full cost), 2 - CPC (cost per click)
    # date - 12 == custom date
    uri = URI("#{Settings.binom_api.url}/?page=save_update_costs&camp_id=#{campaign_id}&type=1&date=12&date_s=#{date_string}&date_e=#{date_string}&timezone=3&cost=#{usd_costs}&value=#{usd_costs}&api_key=#{Settings.binom_api.key}")
    result = JSON.load(Net::HTTP.get(uri))
    raise(result.fetch('error')) if result.fetch('check_status') != "true"
  end
end