module FacebookApi
  class LocaleLookupService
    def self.call(facebook_account, locale)
      session =  FacebookAds::Session.new(access_token: facebook_account.api_token)
      request = FacebookAds::APIRequest.new(:get,
                  'search',
                  session: session,
                  params: {
                    q: locale,
                    type: 'adlocale'
                  }
                ).execute_now
      JSON.parse(request.body).fetch('data')
    end
  end
end