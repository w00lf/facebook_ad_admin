module FacebookApi
  class LocationLookupService
    def self.call(facebook_account, location)
      session =  FacebookAds::Session.new(access_token: facebook_account.api_token)
      request = FacebookAds::APIRequest.new(:get,
              'search',
              session: session,
              params: {
                q: location,
                type: 'adgeolocation',
                location_types: ["country"]
              }
            ).execute_now
      JSON.parse(request.body).fetch('data')
    end
  end
end