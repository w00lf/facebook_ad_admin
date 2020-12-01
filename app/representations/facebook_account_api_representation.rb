class FacebookAccountApiRepresentation < FacebookAPIBaseRepresenter
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
  DISABLE_REASON = {
    0 => 'NONE',
    1 => 'ADS_INTEGRITY_POLICY',
    2 => 'ADS_IP_REVIEW',
    3 => 'RISK_PAYMENT',
    4 => 'GRAY_ACCOUNT_SHUT_DOWN',
    5 => 'ADS_AFC_REVIEW',
    6 => 'BUSINESS_INTEGRITY_RAR',
    7 => 'PERMANENT_CLOSE',
    8 => 'UNUSED_RESELLER_ACCOUNT',
    9 => 'UNUSED_ACCOUNT'
  }

  attr_accessor :time_range, :session, :ad_account, :object, :logger, :facebook_account

  def initialize(facebook_account:, logger: Logger.new(STDOUT), date: nil)
    date = 1.days.ago if date.nil?
    @time_range = { 'since' => date.strftime('%Y-%m-%d'),  'until' => date.strftime('%Y-%m-%d') }
    account_id = facebook_account.api_identificator
    @session = FacebookAds::Session.new(access_token: facebook_account.api_token)
    @object = FacebookAds::AdAccount.get("act_#{account_id}", %w[name id currency account_status disable_reason], session)
    @logger = logger
    @facebook_account = facebook_account
  end

  def adsets(limit = 50, attributes = %w[id status name promoted_object daily_budget campaign_id])
    object.adsets(time_range: time_range, fields: attributes, limit: limit).map do |n|
      FacebookAdsetApiRepresentation.new(object: n, time_range: time_range, logger: logger, currency: object.currency, parent: self)
    end
  end

  def campaigns
    @campaigns ||= object.campaigns(fields: %w[objective name])
  end

  def adcreatives(limit: 50, fields: %w[id object_id effective_object_story_id])
    @adcreatives ||= object.adcreatives(fields: fields, limit: limit)
  end

  def formated_account_status
    ACCOUNT_STATUS.fetch(account_status) rescue nil
  end

  def formated_disable_reason
    DISABLE_REASON.fetch(disable_reason) rescue nil
  end
end