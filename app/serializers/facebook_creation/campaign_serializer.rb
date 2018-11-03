module FacebookCreation
  class CampaignSerializer
    class CampaignSerializerError < StandardError; end

    def initialize(campaign_attributes)
      @campaign_attributes = campaign_attributes
    end

    def as_json
      {
        name: @campaign_attributes.fetch('Campaign Name'),
        objective: @campaign_attributes.fetch('Objective').upcase
      }
    rescue => e
      raise CampaignSerializerError.new(e.message)
    end
  end
end