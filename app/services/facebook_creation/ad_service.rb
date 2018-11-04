module FacebookCreation
  class AdService
    def self.call(facebook_account, attributes)
      session =  FacebookAds::Session.new(access_token: facebook_account.api_token,
                                          app_secret: facebook_account.api_secret)
      ad_account = FacebookAds::AdAccount.get("act_#{facebook_account.api_identificator}", 'name', session)
      ad_account.ads.create(attributes)
    end
  end
end