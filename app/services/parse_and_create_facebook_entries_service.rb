class ParseAndCreateFacebookEntriesService

  # class AdsetSerializeError < StandardError; end
  # class AdSerializeError < StandardError; end
  # class AdCreativeSerializeError< StandardError; end

  # CAMPAIGN_ATTRIBUTES = [
  #   'Campaign Name',
  #   'Objective'
  # ].freeze

  # ADSET_ATTRIBUTES = [
  #   'Pixel Id',
  #   'Ad Set Name',
  #   'Conversion/Website',
  #   'Budget',
  #   'Locations',
  #   'Age',
  #   'Gender',
  #   'Languages',
  #   'Placement'
  # ].freeze

  # AD_ATTRIBUTES = [
  #   'Image',
  #   'Website URL',
  #   'Text',
  #   'Headline',
  #   'News Feed Link Description(optional)',
  #   'URL Parameters'
  # ].freeze

  # BILLING_EVENT = 'IMPRESSIONS'.freeze
  # OPTIMIZATION_GOAL = "OFFSITE_CONVERSIONS".freeze
  # BID_STRATEGY = 'LOWEST_COST_WITHOUT_CAP'.freeze


  # {
  #   "Status"=>"ready",
  #   "Account id"=>"975851439267688",
  #   "Campaign Name"=>"MX - How one family paid off from debt - Conversions",
  #   "Objective"=>"conversions",
  #   "Ad Set Name"=>"MX - (18+) - 1",
  #   "Conversion/Website"=>"Lead",
  #   "Budget "=>"$50,00",
  #   "Locations"=>"Mexico",
  #   "Age"=>"18-65+",
  #   "Gender"=>"all",
  #   "Languages"=>"Spanish",
  #   "Placement/Edit Placements"=>"feeds",

  #   "Ad Name"=>"Ads 1",
  #   "Image"=>"https://drive.google.com/file/d/1wKyKIksshJw9uYZAGWixZHDxB3ZUy_Nt/view?usp=sharing",
  #   "Website URL"=>"http://martzharmony.com/how-one-family-paid-off-30000-of-credit-card-debt-in-less-than-2-year",
  #   "Text"=>"Cómo una mujer cambió su vida a pesar de todos los desafíos.",
  #   "Headline"=>"¿Quién hubiera pensado que podría cambiar su vida?",
  #   "News Feed Link Description(optional)"=>"-",
  #   "URL Parameters"=>"Ad=1&d=1_30.10&utm_source=S1VM33BM&utm_medium=191490645002195"
  # }

  # def perform(facebook_account, attributes)
  #   account_id = facebook_account.api_identificator
  #   @session =  FacebookAds::Session.new(access_token: facebook_account.api_token, app_secret: facebook_account.api_secret)
  #   {
  #     facebook_account_id: import_result.facebook_account_id,
  #     campaign_attributes: serialize_campaign_attributes(attributes.slice(*CAMPAIGN_ATTRIBUTES)),
  #     adset_attributes: serialize_adset_attributes(attributes.slice(*ADSET_ATTRIBUTES)),
  #     ad_creative_attributes: serialize_ad_creative_attributes(attributes.slice(*AD_ATTRIBUTES)))
  #     ad_attributes: serialize_ad_attributes(attributes.slice('Ad Name'))
  #   }
  # end

  # private

  # def serialize_campaign_attributes(campaign_attributes)
  #   {
  #     name: campaign_attributes.fetch('Name')
  #     objective: campaign_attributes.fetch('Objective').upcase
  #   }
  # rescue => e
  #   raise CampaignSerializeError.new(e.message)
  # end

  # def serialize_adset_attributes(adset_attributes)
  #   age_min, age_max = adset_attributes.fetch('Age').trim.split('-')
  #   {
  #     name: adset_attributes.fetch('Name')
  #     billing_event: BILLING_EVENT,
  #     optimization_goal: OPTIMIZATION_GOAL,
  #     bid_strategy: BID_STRATEGY,
  #     promoted_object: {
  #       pixel_id: adset_attributes.fetch('Pixel Id'),
  #       custom_event_type: adset_attributes.fetch('Conversion/Website').upcase
  #     },
  #     daily_budget: adset_attributes.fetch('Budget').gsub(/[^\d.]+/, '').to_f * 100,
  #     targeting: {
  #       geo_locations: => {
  #         countries: retrive_countries(adset_attributes.fetch('Locations'))
  #       }
  #       age_min: age_min,
  #       age_max: age_max,
  #       locales: retrive_locales(adset_attributes.fetch('Languages'))
  #     }
  #   }
  # rescue => e
  #   raise AdsetSerializeError.new(e.message)
  # end

  # def serialize_ad_creative_attributes(ad_attributes)
  # end

  # def serialize_ad_attributes(ad_attributes)
  #   {
  #     name: ad_attributes.fetch('Ad Name')
  #   }
  # end

  # def retrive_countries(location)
  #   request = FacebookAds::APIRequest.new(:get,
  #               'search',
  #               session: @session,
  #               params: {
  #                 q: location,
  #                 type: 'adgeolocation',
  #                 location_types: ["country"]
  #               }
  #             ).execute_now
  #   JSON.parse(request.body).fetch('data')
  # end

  # def retrive_locales(location)
  #   request = FacebookAds::APIRequest.new(:get,
  #               'search',
  #               session: @session,
  #               params: {
  #                 q: location,
  #                 type: 'adlocale'
  #               }
  #             ).execute_now
  #   JSON.parse(request.body).fetch('data')
  # end

  # # {
  # #   name: 'adset without bid_amount test',
  # #   billing_event: 'IMPRESSIONS',
  # #   optimization_goal: "OFFSITE_CONVERSIONS",
  # #   bid_strategy: 'LOWEST_COST_WITHOUT_CAP',
  # #   promoted_object: {
  # #     "pixel_id"=>"1573475279464976",
  # #     custom_event_type: 'LEAD',
  # #   },
  # #   daily_budget: '10000',
  # #   campaign_id: '120330000052891710',
  # #   status: 'PAUSED',
  # #   'targeting'=> {
  # #     "geo_locations"=> {
  # #       "countries"=>["MX"]
  # #     }

  # #     ,
  # #     "age_min"=>'18',
  # #     'age_max'=>'65',
  # #     'locales'=>['23']
  # #   }
  # # }

  # # Request Location
  # # FacebookAds::APIRequest.new(:get, 'search', session: session, params: { q: 'Spanish', type: 'adgeolocation', location_types: ["country"] }).execute_now

  # # Request language locale
  # # FacebookAds::APIRequest.new(:get, 'search', session: session, params: { q: 'Spanish', type: 'adlocale' }).execute_now

  # # Create adset example
  # # ad_account.adsets.create({
  # #   promoted_object: {
  # #     custom_event_type: 'LEAD'
  # #   },
  # #   bid_amount: 2,
  # #   name: 'adset without omp test',
  # #   daily_budget: '100000', #  In cents
  # #   campaign_id: '120330000052891710',
  # #   status: 'PAUSED',
  # #     'targeting' => {
  # #       "geo_locations" => {
  # #         "countries" => ["MX"]
  # #       },
  # #       "age_min" => '18',
  # #       'age_max' => '65',
  # #       'locales' => ['23'],
  # #
  # #       # Placemnts:
  # #       # Facebook:
  # #       'publisher_platforms' => ["facebook"], # facebook, instagram, messenger, audience_network
  # #       'facebook_positions' => ["feed", "marketplace"], # feed, right_hand_column, instant_article, marketplace, and story.
  # #
  # #       Instagram:
  # #       'publisher_platforms' => ["instagram"]
  # #       'instagram_positions' => ['stream', 'story']
  # #
  # #       Audience:
  # #       publisher_platforms' => ["audience_network"]
  # #       'audience_network_positions' => ['classic', 'instream_video', 'rewarded_video']
  # #
  # #       Messenger:
  # #       'messenger_positions' => ['messenger_home', 'sponsored_messages', 'story']
  # #       'device_platforms' => ["mobile", "desktop"]
  # #
  # #     }
  # # })
  # # LEAD or AD_TO_CART types:
  # # bid_amount: nil
  # # billing_event: 'IMPRESSIONS'
  # # optimization_goal: "OFFSITE_CONVERSIONS"
  # # bid_strategy: 'LOWEST_COST_WITHOUT_CAP'
end
