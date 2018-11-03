class FacebookAccountCreateEntriesJob < ApplicationJob
  queue_as :default

  # {
  #   name: "My First campaign",
  #   objective: "CONVERSIONS",
  # }
  def perform(facebook_account_id:, campaign_attributes:, adset_attributes:, ads_level:)
    facebook_account = FacebookAccount.find(facebook_account_id)
    campaign = create_campaign(facebook_account, campaign_attributes)
    adset = create_adset(facebook_account, adset_attributes.merge(campaign_id: campaign.id))
  end

  private

  def create_campaign(facebook_account, campaign_attributes)
    ad_account.campaigns.create(campaign_attributes)
  end

  def create_adset(facebook_account, adset_attributes)
    facebook_account.adsets.create(adset_attributes)
  end

  # Request Location
  # FacebookAds::APIRequest.new(:get, 'search', session: session, params: { q: 'Spanish', type: 'adgeolocation', location_types: ["country"] }).execute_now

  # Request language locale
  # FacebookAds::APIRequest.new(:get, 'search', session: session, params: { q: 'Spanish', type: 'adlocale' }).execute_now

  # Create adset example
  # ad_account.adsets.create({
  #   promoted_object: {
  #     custom_event_type: 'LEAD'
  #   },
  #   bid_amount: 2,
  #   name: 'adset without omp test',
  #   daily_budget: '100000', #  In cents
  #   campaign_id: '120330000052891710',
  #   status: 'PAUSED',
  #     'targeting' => {
  #       "geo_locations" => {
  #         "countries" => ["MX"]
  #       },
  #       "age_min" => '18',
  #       'age_max' => '65',
  #       'locales' => ['23'],
  #
  #       # Placemnts:
  #       # Facebook:
  #       'publisher_platforms' => ["facebook"], # facebook, instagram, messenger, audience_network
  #       'facebook_positions' => ["feed", "marketplace"], # feed, right_hand_column, instant_article, marketplace, and story.
  #
  #       Instagram:
  #       'publisher_platforms' => ["instagram"]
  #       'instagram_positions' => ['stream', 'story']
  #
  #       Audience:
  #       publisher_platforms' => ["audience_network"]
  #       'audience_network_positions' => ['classic', 'instream_video', 'rewarded_video']
  #
  #       Messenger:
  #       'messenger_positions' => ['messenger_home', 'sponsored_messages', 'story']
  #       'device_platforms' => ["mobile", "desktop"]
  #
  #     }
  # })
  # LEAD or AD_TO_CART types:
  # bid_amount: nil
  # billing_event: 'IMPRESSIONS'
  # optimization_goal: "OFFSITE_CONVERSIONS"
  # bid_strategy: 'LOWEST_COST_WITHOUT_CAP'
end
