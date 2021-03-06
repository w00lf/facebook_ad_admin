class SendToBinomApiFacebookCampaignJob < ApplicationJob
  queue_as :binom
  class UpdateRequestError < StandardError; end
  MAX_RETRIES = 5

  def perform(date_unix, binom_server_id, campaign_id, costs, currency, adset_name = nil)
    add_missing_rates
    server = BinomServer.find(binom_server_id)
    retries = 0
    begin
      date_string = Time.at(date_unix).strftime('%Y-%m-%d')
      res_cost = currency.downcase == 'vnd' ? costs : costs * 100
      money = Money.new(res_cost, currency)
      usd_costs = currency == "USD" ? costs : money.exchange_to(:USD).to_f
      # 1 - Cost (full cost), 2 - CPC (cost per click)
      # date - 12 == custom date
      uri = if adset_name
              URI("#{server.url}/?page=save_update_costs&camp_id=#{campaign_id}&token_number=3&token_value=#{adset_name}&type=1&date=12&date_s=#{date_string}&date_e=#{date_string}&timezone=3&cost=#{usd_costs}&value=#{usd_costs}&api_key=#{server.api_key}")
            else
              URI("#{server.url}/?page=save_update_costs&camp_id=#{campaign_id}&type=1&date=12&date_s=#{date_string}&date_e=#{date_string}&timezone=3&cost=#{usd_costs}&value=#{usd_costs}&api_key=#{server.api_key}")
            end
      result = JSON.load(Net::HTTP.get(uri))
      log_file = File.new(Rails.root.join('log', 'binom.log'), 'a+')
      log_file.sync = true
      logger = Logger.new(log_file)
      logger.info(uri)
      logger.info(result)
      if result.fetch('check_status', false) != "true"
        raise(UpdateRequestError, "Error in response: #{result}")
      end
    rescue UpdateRequestError => e
      if retries < MAX_RETRIES
        retries += 1
        sleep(20)
        logger.warn('Retrying request!')
        retry
      end
      raise
    end
  end

  private

  def add_missing_rates
    Money.default_bank.add_rate('VND', 'USD', 0.000043)
  end
end
