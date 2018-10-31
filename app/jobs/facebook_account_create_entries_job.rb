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
  #   daily_budget: '100',
  #   campaign_id: '120330000052891710',
  #   status: 'PAUSED',
  #     'targeting' => {
  #       "geo_locations" => {
  #         "countries" => ["MX"]
  #       },
  #       "age_min" => '18',
  #       'age_max' => '65',
  #       'locales' => ['23']
  #     }
  # })
end
