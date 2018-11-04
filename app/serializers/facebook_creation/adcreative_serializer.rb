module FacebookCreation
  class AdcreativeSerializer
    class AdcreativeSerializerError < StandardError; end

    def initialize(adcreative_attributes)
      @adcreative_attributes = adcreative_attributes
    end

    def as_json
      {
        object_story_spec: {
          page_id: @adcreative_attributes.fetch("Page Id"),
          link_data: {
            message: @adcreative_attributes.fetch("Text"),
            link: @adcreative_attributes.fetch("Website URL"),
            attachment_style: "link",
            caption: "",
            name: @adcreative_attributes.fetch("Headline"),
            description: @adcreative_attributes.fetch("News Feed Link Description"),
            image_hash: @adcreative_attributes.fetch("Image hash")
          }
        },
        object_type: "SHARE",
        url_tags: @adcreative_attributes.fetch("URL Parameters")
      }
    rescue => e
      raise AdcreativeSerializerError.new(e.message)
    end
  end
end