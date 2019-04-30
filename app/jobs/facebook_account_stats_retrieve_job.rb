class FacebookAccountStatsRetrieveJob < ApplicationJob
  queue_as :default

  attr_reader :logger, :log_file

  COLUMN_HEADERS = [
    'Account Status',
    'Date',
    'Account name',
    'Adset Status',
    'Adset Name',
    'Result',
    'Daily Budget',
    'Amount Spent',
    'CPA',
    'CPM',
    'CPC (Link)',
    'CTR (Link)',
    'Clicks',
    'image/vid'
  ]

  def perform(date_unix, facebook_account_id)
    facebook_account = FacebookAccount.find(facebook_account_id)
    parse_result = facebook_account.parse_results.create(status: 'in_progress')
    date = Time.at(date_unix)
    initialize_logger(facebook_account)
    ad_account = ::FacebookAccountApiRepresentation.new(facebook_account: facebook_account, date: date, logger: logger)

    logger.info("Scanning #{ad_account.name}")

    # Format - Binom` Hash[<camp_id><price>]
    binom_costs_hash = {}
    binom_campaigns = facebook_account.binom_campaigns
    insight_metrics = ['spend', 'cpm', 'cost_per_inline_link_click', 'inline_link_click_ctr', 'actions', 'inline_link_clicks']
    report_formated_date = date.strftime('%d/%m/%Y')

    result =  ad_account.adsets.map do |adset|
                result = serialize_adset_stats(adset, ad_account, report_formated_date, binom_costs_hash, binom_campaigns)
                # Only run one time for tests
                if Rails.env.test? && result
                  break result
                else
                  result
                end
              end.compact

    logger.info(result)

    SendToGoogleSpreadsheetFacebookAccountJob.perform_later(date_unix, facebook_account_id, result, COLUMN_HEADERS)
    logger.info(binom_costs_hash)
    binom_costs_hash.each_pair do |campaign_id, compaign_hash|
      SendToBinomApiFacebookCampaignJob.perform_later(date_unix, campaign_id, compaign_hash['costs'], compaign_hash['currency'])
    end
    parse_result.update!(status: 'ok')
  # rescue => e
  #   parse_result.update!(status: 'error', error_type: e.class, error_text: e.message)
  ensure
    log_file.close
  end

  private

  def initialize_logger(subject)
    @log_file = File.new(Rails.root.join('log', 'parser.log'), 'a+')
    @log_file.sync = true
    @logger = SubjectTaggedLogger.new(ActiveSupport::Logger.new(log_file), subject)
  end

  def serialize_adset_stats(adset, ad_account, report_formated_date, binom_costs_hash, binom_campaigns)
    insight_data = adset.insights.first
    # To not exceed requests quota
    sleep 10 unless Rails.env.test?
    return if insight_data.nil?
    adset_spend = insight_data.formated_spend
    return if adset_spend == '-'

    # To not exceed requests quota
    sleep 10 unless Rails.env.test?
    conversion_action = adset.conversion_action
    return if conversion_action.blank?

    adset_unique_actions = adset.unique_actions
    spend = insight_data.spend
    unique_count = adset_unique_actions != '-' && spend != '-' ? spend.to_f / adset_unique_actions.to_f : nil
    adset_unique_action_cost = unique_count ? adset.format_money(adset.format_value(unique_count), adset.currency) : '-'

    campaign = binom_campaigns.find { |n| n.facebook_campaign_identificator == adset.campaign.id }

    if campaign && adset_spend != '-'
      binom_costs_hash[campaign.binom_identificator] = { 'costs' => 0, 'currency' => ad_account.currency } unless binom_costs_hash[campaign.binom_identificator]
      binom_costs_hash[campaign.binom_identificator]['costs'] += adset_spend.to_f
    else
      logger.warn("Cannot find campaign for id - #{adset.campaign.id}")
    end

    [
      ad_account.formated_account_status,
      report_formated_date,
      ad_account.name,
      adset.status,
      adset.name,
      adset_unique_actions,
      adset.formated_daily_budget,
      adset_spend,
      adset_unique_action_cost,
      insight_data.formated_cpm,
      insight_data.formated_cost_per_inline_link_click,
      insight_data.formated_inline_link_click_ctr,
      insight_data.inline_link_clicks
    ]
  end
end
