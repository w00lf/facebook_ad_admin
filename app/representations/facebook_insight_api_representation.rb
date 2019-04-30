class FacebookInsightAPIRepresentation < FacebookAPIBaseRepresenter
  attr_accessor :object, :time_range, :logger, :currency

  def initialize(object:, time_range:, logger:, currency:)
    @object = object
    @time_range = time_range
    @currency = currency
    @logger = logger
  end

  def formated_spend
    get_and_format_money(spend, currency)
  end

  def formated_cpm
    get_and_format_money(cpm, currency)
  end

  def formated_cpm
    get_and_format_money(cpm, currency)
  end

  def formated_cost_per_inline_link_click
    get_and_format_money(cost_per_inline_link_click, currency)
  end

  def formated_inline_link_click_ctr
    get_and_format_percentage(inline_link_click_ctr)
  end
end
