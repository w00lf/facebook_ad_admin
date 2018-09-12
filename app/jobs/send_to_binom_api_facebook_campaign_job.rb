class SendToBinomApiFacebookCampaignJob
  include Sidekiq::Worker

  def perform(date_unix, campaign_id, costs)
    Rails.logger.info("Does not implemented yet!")
  end
end
