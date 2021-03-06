module FacebookCreation
  class AdsetSerializer
    class AdsetSerializerError < StandardError; end

    BILLING_EVENT = 'IMPRESSIONS'.freeze
    OPTIMIZATION_GOAL = "OFFSITE_CONVERSIONS".freeze
    BID_STRATEGY = 'LOWEST_COST_WITHOUT_CAP'.freeze
    POSITION_OPTIONS = {
      'facebook' => :facebook_positions,
      'instagram' => :instagram_positions,
      'audience_network' => :audience_network_positions,
      'messenger' => :messenger_positions
    }.freeze

    ALLOWED_POSITIONS = {
      'facebook' => %w[
        feed
        right_hand_column
        instant_article
        marketplace
        story
      ].freeze,
      'instagram' => %w[
        stream
        story
      ].freeze,
      'audience_network' => %w[
        classic
        instream_video
        rewarded_video
      ].freeze,
      'messenger' => %w[
        messenger_home
        sponsored_messages
        story
      ].freeze
    }

    GENDERS = {
      'male' => 1,
      'female' => 2
    }.freeze

    def initialize(facebook_account:, adset_attributes:)
      @facebook_account = facebook_account
      @adset_attributes = adset_attributes
    end

    def as_json
      age_min, age_max = @adset_attributes.fetch('Age').strip.split('-').map(&:strip).map(&:to_i)
      platfrom = @adset_attributes.fetch('Platform')
      {
        name: @adset_attributes.fetch('Ad Set Name'),
        status: 'PAUSED',
        billing_event: BILLING_EVENT,
        optimization_goal: OPTIMIZATION_GOAL,
        bid_strategy: BID_STRATEGY,
        promoted_object: {
          pixel_id: @adset_attributes.fetch('Pixel Id'),
          custom_event_type: @adset_attributes.fetch('Conversion/Website').upcase
        },
        daily_budget: (@adset_attributes.fetch('Budget').gsub(/[^\d\,\.]+/, '').to_f * 100).to_i,
        targeting: {
          geo_locations: {
            countries: country_lookup(@adset_attributes.fetch('Locations')),
            location_types: [
              "home",
              "recent"
            ]
          },
          age_min: age_min,
          age_max: age_max,
          locales: locale_lookup(@adset_attributes.fetch('Languages')),
          publisher_platforms: [platfrom],
          POSITION_OPTIONS.fetch(platfrom) => retrive_position(platfrom, @adset_attributes.fetch('Placement'))
        }.merge(genders_targeting(@adset_attributes.fetch('Gender')))
      }
    rescue => e
      raise AdsetSerializerError.new(e.message)
    end

    private

    def retrive_position(platfrom, placement)
      result = placement.split(',').map(&:strip)
      allowed = ALLOWED_POSITIONS.fetch(platfrom)
      result.each do |position|
        unless allowed.include?(position)
          raise AdsetSerializerError.new("Wrong Placement attribute, allowed values: #{allowed.join(', ')}")
        end
      end
    end

    def genders_targeting(genders)
      return {} if genders == 'all'
      [GENDERS.fetch(genders)]
    end

    def country_lookup(location)
      [FacebookApi::LocationLookupService.call(@facebook_account, location).first.fetch('country_code')]
    end

    def locale_lookup(locale)
      [FacebookApi::LocaleLookupService.call(@facebook_account, locale).first.fetch('key')]
    end
  end
end