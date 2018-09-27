class FacebookAccountStatsRetrieveJob
  include Sidekiq::Worker

  ACCOUNT_STATUS = {
    1 => 'Active',
    2 => 'Disabled',
    3 => 'Unsettled',
    7 => 'Pending_risk_review',
    8 => 'Pending_settlement',
    9 => 'In_grace_period',
    100 => 'Pending_closure',
    101 => 'Closed',
    201 => 'Any_active',
    202 => 'Any_closed'
  }

  COLUMN_HEADERS = [
    'Account Status',
    'Date',
    'Account name',
    'Adset Status',
    'Adset Name',
    'Result',
    'Daily Budget',
    'Amount Spent',
    'CPL',
    'CPM',
    'CPC (Link)',
    'CTR (Link)',
    'Clicks',
    'image/vid'
  ]
  CONVERSION_TARGET_ACTION = 'offsite_conversion'.freeze
  MAX_RETRIES = 20

  def format_money(price, currency)
    return '-' unless price
    "#{price} #{currency_info.fetch(currency.downcase).fetch("symbol")}"
  end

  def currency_info
    @currency_info ||= JSON.load(File.read(Rails.root.join('config', 'currency_iso.json')))
  end

  def format_value(value)
    return '-' unless value
    value.to_f.round(2)
  end

  def ignored_exception?(e)
    e.message =~ /load! is not supported for this object/
  end

  def retriable_exception?(e)
    e.message =~ /User request limit reached/
  end

  def with_exception_control(&block)
    retry_count = 0
    yield
  rescue FacebookAds::ClientError => e
    log_file = File.new(Rails.root.join('log', 'parser.log'), 'a+')
    log_file.sync = true
    logger = Logger.new(log_file)
    logger.warn("Facebook client error: #{e.message}")
    if retry_count <= MAX_RETRIES && retriable_exception?(e)
      sleep 120 * retry_count
      retry
    else
      raise e
    end
  rescue RuntimeError => e
    return '-' if ignored_exception?(e)
    raise e
  end

  def try_get_data(ad_object, field)
    with_exception_control { ad_object.send(field) }
  end

  def get_promoted_object_event_type(adset)
    with_exception_control { adset.promoted_object&.custom_event_type&.to_s&.downcase&.capitalize }
  end

  def get_budget(adset, currency)
    daily_budget = try_get_data(adset, 'daily_budget')
    return daily_budget if daily_budget == '-'
    format_money(daily_budget.to_f/100.0, currency)
  end

  def get_and_format_money(ad_object, field, currency)
    attribute = try_get_data(ad_object, field)
    return attribute if attribute == '-'
    format_money(format_value(attribute), currency)
  end

  def get_and_format_percentage(ad_object, field)
    attribute = try_get_data(ad_object, field)
    return attribute if attribute == '-'
    "#{format_value(attribute)} %"
  end

  def adstats_type_value(adstats, action_type)
    return unless adstats
    adstats.find { |adstat| adstat.action_type == action_type }&.value
  end

  def perform(date_unix, facebook_account_id)
    date = Time.at(date_unix)
    facebook_account  = FacebookAccount.find(facebook_account_id)
    time_range = { 'since' => date.strftime('%Y-%m-%d'),  'until' => date.strftime('%Y-%m-%d') }
    log_file = File.new(Rails.root.join('log', 'parser.log'), 'a+')
    log_file.sync = true
    logger = Logger.new(log_file)
    account_id = facebook_account.api_identificator
    session = FacebookAds::Session.new(access_token: facebook_account.api_token, app_secret: facebook_account.api_secret)
    ad_account = FacebookAds::AdAccount.get("act_#{account_id}", 'name', session)
    account_name = try_get_data(ad_account, 'name')
    logger.info("Scanning #{account_name}")
    currency = ad_account.currency
    account_status = ACCOUNT_STATUS.fetch(try_get_data(ad_account, 'account_status'))
    # Format - Binom` Hash[<camp_id><price>]
    binom_costs_hash = {}
    binom_campaigns = facebook_account.binom_campaigns
    insight_metrics = ['spend', 'cpm', 'cpc', 'ctr', 'unique_actions', 'cost_per_unique_action_type', 'inline_link_clicks']
    report_formated_date = date.strftime('%d/%m/%Y')

    result =  ad_account.adsets(time_range: time_range).map do |adset|
                insight_data = adset.insights(fields: insight_metrics, time_range: time_range).first
                # To not exceed requests quota
                sleep 15
                next if insight_data.nil?
                adset_status = try_get_data(adset, 'status')
                adset_name = try_get_data(adset, 'name')

                # To not exceed requests quota
                sleep 15
                adset_unique_actions = adstats_type_value(try_get_data(insight_data, 'unique_actions'), CONVERSION_TARGET_ACTION) || '-'
                unique_count = adstats_type_value(try_get_data(insight_data, 'cost_per_unique_action_type'), CONVERSION_TARGET_ACTION)
                adset_unique_action_cost = unique_count ? format_money(format_value(unique_count), currency) : '-'
                adset_budget = get_budget(adset, currency)
                adset_spend = get_and_format_money(insight_data, 'spend', currency)
                adset_cpm = get_and_format_money(insight_data, 'cpm', currency)
                adset_cpc = get_and_format_money(insight_data, 'cpc', currency)
                adset_ctr = get_and_format_percentage(insight_data, 'ctr')
                adset_inline_link_clicks = try_get_data(insight_data, 'inline_link_clicks')

                sleep 10
                campaign = binom_campaigns.find { |n| n.facebook_campaign_identificator == adset.campaign.id }
                if campaign
                  binom_costs_hash[campaign.binom_identificator] = { 'costs' => 0, 'currency' => currency } unless binom_costs_hash[campaign.binom_identificator]
                  binom_costs_hash[campaign.binom_identificator]['costs'] += insight_data.spend.to_f
                end
                logger.warn("Cannot find campaign for id - #{adset.campaign.id}")
                [
                  account_status,
                  report_formated_date,
                  account_name,
                  adset_status,
                  adset_name,
                  adset_unique_actions,
                  adset_budget,
                  adset_spend,
                  adset_unique_action_cost,
                  adset_cpm,
                  adset_cpc,
                  adset_ctr,
                  adset_inline_link_clicks
                ]
              end.compact
    logger.info(result)
    SendToGoogleSpreadsheetFacebookAccountJob.perform_async(date_unix, facebook_account_id, result, COLUMN_HEADERS)
    logger.info(binom_costs_hash)
    binom_costs_hash.each_pair do |campaign_id, compaign_hash|
      SendToBinomApiFacebookCampaignJob.perform_async(date_unix, campaign_id, compaign_hash['costs'], compaign_hash['currency'])
    end
    log_file.close
  end
end
