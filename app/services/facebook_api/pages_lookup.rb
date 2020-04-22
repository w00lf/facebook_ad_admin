module FacebookApi
  class PagesLookup
    def self.call(facebook_account)
      session =  FacebookAds::Session.new(access_token: facebook_account.api_token)
      request = FacebookAds::APIRequest.new(:get,
              'me/accounts',
              session: session
            ).execute_now
      JSON.parse(request.body).fetch('data')
    end
  end
end
