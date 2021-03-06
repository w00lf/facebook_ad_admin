class FacebookAdsetApiRepresentation < FacebookAPIBaseRepresenter
  attr_accessor :object, :time_range, :logger, :currency, :parent

  # "START_TRIAL",
  # "SEARCH"
  # "CONTACT"
  # "CUSTOMIZE_PRODUCT"
  # "FIND_LOCATION"
  # "SCHEDULE"
  # "SUBMIT_APPLICATION"
  # "DONATE"
  TARGET_CONVERSION_BY_TYPE = {
    'ADD_TO_CART' => 'offsite_conversion.fb_pixel_add_to_cart',
    'COMPLETE_REGISTRATION' => 'offsite_conversion.fb_pixel_complete_registration',
    'LEAD' => 'offsite_conversion.fb_pixel_lead',
    'PURCHASE' => 'offsite_conversion.fb_pixel_purchase',
    "ADD_PAYMENT_INFO" => 'offsite_conversion.fb_pixel_add_payment_info',
    "ADD_TO_WISHLIST" => 'offsite_conversion.fb_pixel_add_to_wishlist',
    "CONTENT_VIEW" => 'offsite_conversion.fb_pixel_view_content',
    "INITIATED_CHECKOUT" => 'offsite_conversion.fb_pixel_initiate_checkout',
    "LINK_CLICKS" => 'link_click',
    "SUBSCRIBE" => 'subscribe'
  }

  def initialize(object:, time_range:, logger:, currency:, parent:)
    @object = object
    @time_range = time_range
    @currency = currency
    @logger = logger
    @parent = parent
  end

  def insights(insight_metrics: %w[spend cpm cost_per_inline_link_click inline_link_click_ctr actions inline_link_clicks frequency])
    object.insights(fields: insight_metrics, time_range: time_range).map do |insight|
      FacebookInsightAPIRepresentation.new(object: insight, time_range: time_range, logger: logger, currency: currency)
    end
  end

  def quality_ranking
    with_exception_control do
      object.ads.first.insights(fields: ['quality_ranking'], time_range: time_range).first.try(:[], :quality_ranking)
    end
  end

  def promoted_object_event_type
    if promoted_object.blank? || promoted_object == BLANK_RESPONSE
      campaign = with_exception_control { parent.campaigns.find{|n| n['id'] == campaign_id } }
      return campaign.objective if campaign
      logger.warn("Adset without promoted object: #{object.name}(##{object.id})")
      return ''
    end
    with_exception_control { promoted_object.custom_event_type.to_s }
  end

  def campaign_name
    campaign = with_exception_control { parent.campaigns.find{|n| n['id'] == campaign_id } }
    campaign.name if campaign
  end

  def conversion_action
    result = TARGET_CONVERSION_BY_TYPE.fetch(promoted_object_event_type, nil)
    if result.nil?
      logger.warn("Unknown conversion type for promoted_object_event_type: #{promoted_object_event_type}, #{object.name}(##{object.id})")
      result
    end
    result
  end

  def formated_daily_budget
    return daily_budget if daily_budget == BLANK_RESPONSE
    format_money(daily_budget.to_f/100.0, currency)
  end

  def unique_actions
    adstats_type_value(insights.first.actions, conversion_action) || '-'
  end

  private

  def adstats_type_value(adstats, action_type)
    return unless adstats.is_a?(Array)
    adstat = adstats.find { |adstat| adstat.action_type == action_type }
    return unless adstat
    adstat.value
  end
end
