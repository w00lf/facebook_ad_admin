module FacebookCreation
  class AdcreativeSerializer
    class AdcreativeSerializerError < StandardError; end

    def initialize(adcreative_attributes)
      @adcreative_attributes = adcreative_attributes
    end

    def as_json
      {
        image_url: @adcreative_attributes.fetch("Image"),
        link_url: @adcreative_attributes.fetch("Website URL"),
        body: @adcreative_attributes.fetch("Text"),
        title: @adcreative_attributes.fetch("Headline"),
        url_tags: @adcreative_attributes.fetch("URL Parameters")
      }
    rescue => e
      raise AdcreativeSerializerError.new(e.message)
    end
  end
end