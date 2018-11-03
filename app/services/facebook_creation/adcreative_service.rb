module FacebookCreation
  class AdcreativeService
    def self.call(facebook_account, attributes)
      session =  FacebookAds::Session.new(access_token: facebook_account.api_token,
                                          app_secret: facebook_account.api_secret)
      ad_account = FacebookAds::AdAccount.get("act_#{facebook_account.account_id}", 'name', session)
      ad_account.adcreatives.create(attributes)
    end
  end
end