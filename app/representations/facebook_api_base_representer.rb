class FacebookAPIBaseRepresenter
  MAX_RETRIES = 20
  BLANK_RESPONSE = '-'

  def method_missing(method, *args)
    with_exception_control { object.send(method) }
  end

  def format_money(price, currency)
    return '-' unless price
    "#{price} #{currency_info.fetch(currency.downcase).fetch("symbol")}"
  end

  def format_value(value)
    return BLANK_RESPONSE unless value
    value.to_f.round(2)
  end

  def with_exception_control(&block)
    retry_count = 0
    yield
  rescue FacebookAds::ClientError => e
    logger.warn("Facebook client error: #{e.message}")
    if retry_count <= MAX_RETRIES && retriable_exception?(e)
      sleep 120 * retry_count
      retry
    else
      raise e
    end
  rescue NoMethodError, RuntimeError => e
    return BLANK_RESPONSE if ignored_exception?(e)
    raise e
  end

  def retriable_exception?(e)
    e.message =~ /User request limit reached/ ||
      e.message =~ /Application request limit reached/
  end

  def ignored_exception?(e)
    # All these exceptions occur when facebook request does not receive or recive blank data for attribute
    e.message =~ /load! is not supported for this object/ ||
      e.message =~ /undefined method `gsub' for nil:NilClass/
  end

  protected

  def currency_info
    @currency_info ||= JSON.load(File.read(Rails.root.join('config', 'currency_iso.json')))
  end

  def get_and_format_money(attribute, currency)
    return attribute if attribute == BLANK_RESPONSE
    format_money(format_value(attribute), currency)
  end

  def get_and_format_percentage(attribute)
    return attribute if attribute == BLANK_RESPONSE
    "#{format_value(attribute)} %"
  end
end