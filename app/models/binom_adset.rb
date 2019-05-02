class BinomAdset < ApplicationRecord
  validates :facebook_adset_identificator,
            :name,
            presence: true
  validates :facebook_adset_identificator, format: { with: /\A\d+\z/, message: 'Must be number, example - 23843000141680670' }
  belongs_to :facebook_account
end
