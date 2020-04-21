class BinomCampaign < ApplicationRecord
  validates :binom_identificator,
            :facebook_campaign_identificator,
            :name,
            presence: true
  validates :binom_identificator, format: { with: /\A\d+\z/, message: 'Binom identificator must be number' }
  validates :facebook_campaign_identificator, format: { with: /\A\d+\z/, message: 'Must be number, example - 23843000141680670' }
  belongs_to :facebook_account
  belongs_to :binom_server
end
