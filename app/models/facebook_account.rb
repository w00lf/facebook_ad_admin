class FacebookAccount < ApplicationRecord
  validates :name, :api_identificator, :api_token, :api_secret, presence: true
  validate :correct_request, on: :create

  has_many :binom_campaigns
  belongs_to :facebook_group_account

  private

  def correct_request
    session = FacebookAds::Session.new(access_token: api_token, app_secret: api_secret)
    FacebookAds::AdAccount.get("act_#{api_identificator}", 'name', session).name
  rescue => e
    Rails.logger.error(e)
    errors.add(:base, 'Incorrect creditinals, cannot receive account data, please check you api_identificator, api_secret and api_token')
  end
end
