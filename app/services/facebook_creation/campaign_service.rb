module FacebookCreation
  class CampaignService
    def self.call(facebook_account, attributes)
      session =  FacebookAds::Session.new(access_token: facebook_account.api_token)
      ad_account = FacebookAds::AdAccount.get("act_#{facebook_account.api_identificator}", 'name', session)
      ad_account.campaigns.create(attributes)
    end
  end
end