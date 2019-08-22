require 'open-uri'

module FacebookCreation
  class ImageService
    def self.call(facebook_account, url)
      session =  FacebookAds::Session.new(access_token: facebook_account.api_token)
      ad_account = FacebookAds::AdAccount.get("act_#{facebook_account.api_identificator}", 'name', session)
      tempfile = NetUtils.download(url)
      filename = NetUtils.file_name_with_extention(url)
      ad_account.adimages.create({ filename => tempfile })
    ensure
      tempfile.close if tempfile
    end
  end
end
