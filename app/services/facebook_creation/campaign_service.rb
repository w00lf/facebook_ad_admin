module FacebookCreation
  class CampaignService
    def self.call(facebook_account, attributes)
      session =  FacebookAds::Session.new(access_token: facebook_account.api_token,
                                          app_secret: facebook_account.api_secret)
      ad_account = FacebookAds::AdAccount.get("act_#{account_id}", 'name', session)
      ad_account.campaigns.create(attributes)
    end
  end
end